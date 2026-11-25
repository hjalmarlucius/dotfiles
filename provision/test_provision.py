#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.13"
# dependencies = ["tyro"]
# ///
"""Checks of provision. Run it without access to anything that matters (and
./provision/apply.py --help once before, which puts tyro in the cache of uv):

bwrap --ro-bind / / --dev /dev --proc /proc --tmpfs /tmp --unshare-net \\
    --overlay-src ~/.cache/uv --tmp-overlay ~/.cache/uv \\
    --ro-bind "$PWD" "$PWD" --chdir "$PWD" uv run --offline --script \\
    provision/test_provision.py
"""

import ast
import os
import subprocess
import sys
import tempfile
from pathlib import Path

SOURCE = Path(__file__).resolve().parent
DOTFILES = SOURCE.parent
CHANGES = {"chmod", "mkdir", "open", "rename", "replace", "rmdir", "symlink_to"}
CHANGES |= {"touch", "unlink", "write_bytes", "write_text", "hardlink_to"}
CHANGES |= {"call", "check_call", "check_output", "Popen", "run", "system"}
BUILTINS = {"open", "input", "exec", "eval", "__import__"}
GATES = {
    "query",
    "read_as_root",
    "do",
    "confirm",
    "choose",
    "make_link",
}  # make_link only runs in do()


def check_gates() -> None:
    """Calls that change something are only made inside the gates."""
    files = [p for p in SOURCE.glob("*.py") if p.name != Path(__file__).name]
    assert len(files) == 13, files
    for path in files:
        gates = {"gate": GATES - {"make_link"}, "links": {"make_link"}}
        scan(path, gates.get(path.stem, set()))


def scan(path: Path, gates: set[str]) -> None:
    for function in ast.parse(path.read_text()).body:
        if getattr(function, "name", None) in gates:
            continue
        for node in ast.walk(function):
            if not isinstance(node, ast.Call):
                continue
            func = node.func
            bad = isinstance(func, ast.Name) and func.id in BUILTINS | {"make_link"}
            bad |= (
                isinstance(func, ast.Attribute)
                and func.attr in CHANGES
                and ast.unparse(func) != "gate.run"
            )
            where = f"{path.name}:{node.lineno}"
            assert not bad, f"{where}: {ast.unparse(node)} is not in a gate"


def in_child(home: Path, code: str) -> str:
    """Run code after importing the modules with HOME=home; packages are never touched."""
    setup = (
        "import apply, cleanup, copies, drift, gate, links, options, packages, paths, steps, summary, tables, unlock\n"
        "import sys, subprocess, os\nfrom pathlib import Path\n"
    )
    result = subprocess.run(
        [sys.executable, "-B", "-c", setup + code],
        cwd=SOURCE,
        env={**os.environ, "HOME": str(home)},
        capture_output=True,
        text=True,
        check=False,
    )
    assert result.returncode == 0, result.stdout + result.stderr
    return result.stdout


def snapshot(home: Path) -> dict[str, object]:
    found = {}
    for path in sorted(home.rglob("*")):
        stat = path.lstat()  # without atime, which reading may change
        target = os.readlink(path) if path.is_symlink() else ""
        found[str(path)] = (stat.st_mode, stat.st_ino, stat.st_mtime_ns, target)
    return found


DRY = "options.args.dry_run = True\nsys.addaudithook(gate.audit)\n"
LINK = "links.PRIVATE = ()\nlinks.link_all(tables.groups_for('mothership'))\n"
YES = "gate.confirm = lambda question: True\n"


def check_links(home: Path) -> None:
    (home / ".config/nvim").mkdir(parents=True)
    (home / ".config/nvim/after").symlink_to(DOTFILES / "CONFIG/nvim/after")
    (home / ".config/dead").symlink_to(DOTFILES / "CONFIG/gone")
    (home / ".gitconfig").write_text("mine\n")
    before = snapshot(home)
    plan = in_child(home, DRY + LINK)
    assert snapshot(home) == before, "the dry run changed something"
    done = in_child(home, YES + LINK)

    def lines(output: str) -> list[str]:
        return [line for line in output.splitlines() if line.startswith("+ ")]

    assert lines(plan) == lines(done), "the dry run showed something else"
    assert len(lines(done)) > 50
    assert (home / ".gitconfig").is_symlink()
    assert not list(home.rglob("*.dotfiles-bak"))
    assert not (home / ".config/nvim/after").is_symlink()
    assert not (home / ".config/dead").is_symlink()
    assert not lines(in_child(home, LINK)), "a second run changed something"


def check_install(home: Path) -> None:
    out = in_child(
        home,
        """
packages.PINS = {}
gate.query = lambda *cmd: "zsh\\nmpv" if cmd[1] == "-Qqd" else missing
gate.run = lambda *cmd: print("RUN", *cmd) or cmd[0] != "yay"
missing = ""
assert packages.install({"mpv", "fd"})
missing = "fd"
assert not packages.install({"fd"})
""",
    )
    assert out == "RUN sudo pacman -D --asexplicit mpv\nRUN yay -S fd\n", out


def check_pins(home: Path) -> None:
    out = in_child(
        home,
        """
packages.HOSTNAME, packages.PINS = "h", {"h": ["nvidia-open*", "cuda"]}
answers = {"IgnorePkg": "cuda", "-Qq": "cuda nvidia-open-dkms nvidia-container-toolkit"}
answers["-T"] = "fd"
gate.query = lambda *cmd: answers.get(cmd[1], "")
gate.run = lambda *cmd: print("RUN", *cmd) or True
assert not packages.install({"fd"})
assert "IgnorePkg = nvidia-open-dkms" in gate.warned
answers["IgnorePkg"] = "cuda nvidia-*"
assert packages.install({"fd"})
options.args.reinstall = True
assert packages.install({"fd", "cuda"})
""",
    )
    runs = [line for line in out.splitlines() if line.startswith("RUN")]
    assert runs == ["RUN yay -S fd", "RUN yay -S fd"], runs


COPY = """
at = Path.home()
copies.tracked = lambda source: [Path(str(at / "new")[1:])]
gate.run = lambda *cmd: print("RUN", *cmd)
gate.confirm = lambda question: "install" in question and yes
copies.copy_system_files(at / "src")
"""


def check_copies(home: Path) -> None:
    source = home / "src" / str(home / "new")[1:]
    source.parent.mkdir(parents=True)
    source.write_text("x")
    assert "RUN" not in in_child(home, "yes = False\n" + COPY)
    assert "RUN sudo install" in in_child(home, "yes = True\n" + COPY)


def check_skips(home: Path) -> None:
    code = "print(links.tracked(paths.DOTFILES / 'CONFIG', {'homeassistant'}))"
    assert "homeassistant" not in in_child(home, code)


def check_keeps(home: Path) -> None:
    """No means no, and --overwrite doesn't delete folders or dead links unasked."""
    (home / ".gtkrc-2.0/mine").mkdir(parents=True)
    (home / ".config").mkdir()
    (home / ".config/dead").symlink_to(DOTFILES / "CONFIG/gone")
    option = "options.args.overwrite = True\ngate.confirm = lambda question: False\n"
    in_child(home, option + LINK)
    assert (home / ".gtkrc-2.0/mine").is_dir()
    assert (home / ".config/dead").is_symlink()
    assert (home / ".gtkrc-2.0").is_dir()
    (home / ".gitconfig").unlink()
    (home / ".gitconfig").mkdir()  # git fails on this
    stop = "try: links.link_all([])\nexcept SystemExit: pass\nelse: sys.exit(1)"
    in_child(home, option + stop)


def check_audit(home: Path) -> None:
    for change in (
        "Path('/tmp/x').write_text('')",
        "Path('/tmp/x').unlink()",
        "os.mkdir('/tmp/x')",
        "os.system('true')",
        "input()",
        "subprocess.run(['true'])",
        "subprocess.run(['systemctl', '--user', 'enable', 'x'])",
        "__import__('urllib.request').request.urlopen('http://127.0.0.1')",
    ):
        expect = f"try: {change}\nexcept RuntimeError: pass\nelse: sys.exit(1)"
        in_child(home, DRY + expect)


def check_tables(home: Path) -> None:
    """Groups exist, and hosts.toml has the right shape."""
    in_child(
        home,
        """
from tables import CLEANUP, HOSTS, PACKAGES, PINS, TABLES, UNITS, packages_for
assert set(PINS) <= set(HOSTS)
assert list(TABLES) == ["hosts", "packages", "pins", "units", "cleanup"]
used = [group for groups in HOSTS.values() for group in groups]
for group in used + list(UNITS.values()):
    assert group in PACKAGES, group
for group, names in PACKAGES.items():
    assert isinstance(names, list) and names, group
    assert all(isinstance(name, str) for name in names), group
    assert len(set(names)) == len(names), group
for host in HOSTS:
    assert (Path(paths.DOTFILES) / f"custom-{host}").is_dir(), host
    assert not packages_for(host) & set(CLEANUP), "installed and cleaned up"
assert all(isinstance(reason, str) for reason in CLEANUP.values())
""",
    )


MAIN = """
calls = []
for name in ("link_all", "set_up", "check_unlock", "clean_up", "list_drift"):
    setattr(apply, name, lambda *a, name=name: calls.append(name))
apply.install = lambda packages: (calls.append("install"), works)[1]
apply.HOSTNAME = host
sys.argv = ["apply.py", *options]
status = 0
try: apply.main()
except SystemExit as stop: status = stop.code
"""


def check_main(home: Path) -> None:
    last = ["set_up", "clean_up", "list_drift"]
    normal = ["link_all", "install", *last]
    luks = ["link_all", "install", "check_unlock", *last]
    for host, options, works, calls, status in (
        ("mothership", [], True, luks, "0"),
        ("sl3", ["-o", "-r"], True, normal, "0"),
        ("spro5", ["--dry-run"], True, normal, "0"),
        ("sl3", [], False, normal[:2], "0"),
        ("sl3", ["--only", "system", "links"], True, ["link_all", "set_up"], "0"),
        ("sl3", ["--only", "drift"], True, ["list_drift"], "0"),
        ("sl3", ["--only", "nonsense"], True, [], "2"),
        ("droneship", ["--only", "unlock"], True, ["check_unlock"], "0"),
        ("sl3", ["--only", "unlock"], True, [], "0"),
        ("elsewhere", [], True, [], "'unknown host elsewhere: add it to hosts.toml'"),
        ("sl3", ["--nonsense"], True, [], "2"),
    ):
        setup = f"host, options, works = {(host, options, works)!r}\n"
        expect = f"assert (calls, status) == ({calls!r}, {status}), (calls, status)"
        in_child(home, setup + MAIN + expect)
    broken = "host, options, works = 'sl3', [], True\ngate.run('false')\n"
    out = in_child(home, broken + MAIN + "assert status == 1, status")
    assert "FAILED: 1\n  false" in out, out
    stop = "host, options, works = 'sl3', [], True\n"
    ctrl_c = "def stop(*a): raise KeyboardInterrupt\nmain_code"
    code = MAIN.replace("status = 0", "apply.link_all = stop\nstatus = 0")
    stop += ctrl_c.replace("main_code", code) + "assert status == 1, status"
    assert "stopped with Ctrl-C" in in_child(home, stop)


def check_summary(home: Path) -> None:
    out = in_child(
        home,
        """
gate.run("true")
gate.run("false")
gate.do("link a -> b", lambda: None)
gate.do("delete c", lambda: None)
gate.input = lambda question: ""
assert not gate.confirm("replace e?")
assert gate.choose("remove which?", {"f": "old"}) == []
gate.warn("missing g")
summary.print_summary()
""",
    ).split("Summary")[1]
    assert (
        out
        == """
ran: 1
  true
linked: 1
deleted: 1
  delete c
you said no to: 2
  replace e?
  remove which? f
warnings: 1
  missing g
FAILED: 1
  false
"""
    ), out
    assert "nothing to do" in in_child(home, "summary.print_summary()")


UNLOCK = """
import pathlib
at = Path.home()
unlock.CRYPT_CONF = Path("conf")  # a relative path: / and the checkout hold it
unlock.UNLOCK_KEYS, unlock.CMDLINE = at / "keys/authorized_keys", at / "cmdline"
unlock.HOST_KEY = str(at / "keys/host")
unlock.dracut_confs = lambda: [at / "omit.conf"]
unlock.CUSTOM = at / "custom"
planned = []
gate.run = lambda *cmd, text=None: (planned.append((cmd[:2], text)), True)[1]
unlock.install = lambda packages: planned.append("install") or True
gate.query = lambda *cmd, **options: ""
gate.read_as_root = lambda *cmd: (
    "ssh-ed25519 AAAAC3Nz me" if cmd[0] == "cat" and cmd[1].startswith("/root") else ""
)
gate.choose = lambda question, options: []
gate.confirm = lambda question: True
"""


def check_unlocking(home: Path) -> None:
    (home / "cmdline").write_text("quiet root=/dev/x ip=10.0.0.2 rw\n")
    (home / "omit.conf").write_text('omit_dracutmodules+=" nfs network brltty "\n')
    (home / "custom/ROOT").mkdir(parents=True)
    (home / "custom/ROOT/conf").write_text("ours")
    for overwrite in ("False", "True"):  # no key chosen: the conf stays out
        setup = f"{UNLOCK}options.args.overwrite = {overwrite}\nunlock.check_unlock()\n"
        in_child(home, setup + "assert 'install' not in str(planned), planned")
    # choosing keys is safe in a dry run, with the real gate
    setup = UNLOCK.replace("gate.choose =", "unused =").replace(
        "gate.run =", "unused ="
    )
    dry = "options.args.dry_run = True\nsys.addaudithook(gate.audit)\n"
    shown = in_child(
        home, "import sys\n" + setup + dry + "assert unlock.add_unlock_keys()"
    )
    assert "SHA256:" in shown, shown
    assert "AAAA" not in shown
    (home / "keys").mkdir()
    for name in ("host", "host.pub", "authorized_keys"):
        (home / "keys" / name).write_text("ssh-ed25519 AAAA me\n")
    done = in_child(
        home,
        UNLOCK
        + """
unlock.has_unlock_keys = lambda: True
unlock.check_unlock()
print([(cmd, text) for cmd, text in planned])
assert (("sudo", "tee"), "quiet root=/dev/x ip=10.0.0.2 rw rd.neednet=1\\n") in planned
assert (("sudo", "tee"), 'omit_dracutmodules+=" nfs  brltty "\\n') in planned
assert (("sudo", "install"), None) in planned
assert not any("reinstall-kernels" in cmd for cmd, text in planned)
options.args.only = ("unlock",)
planned.clear()
unlock.entries_ok, unlock.image_ok = lambda: True, lambda version: None
unlock.check_unlock()
assert (("sudo", "reinstall-kernels"), None) not in planned, "unknown is no reason"
unlock.image_ok = lambda version: False
gate.confirm = lambda question: "rebuild the" not in question
unlock.check_unlock()
assert (("sudo", "reinstall-kernels"), None) not in planned, "no means no"
assert gate.failed
gate.confirm = lambda question: True
unlock.check_unlock()
assert (("sudo", "reinstall-kernels"), None) in planned
""",
    )
    assert "AAAA" not in done
    same = in_child(
        home,
        "for line in ('a b', 'a rd.neednet=1 ip=dhcp\\n', 'a\\nb\\n'):\n"
        "    new = unlock.with_network(line).split()\n"
        "    assert new[:len(line.split())] == line.split()\n"
        "    assert {'rd.neednet=1', 'ip=dhcp'} <= set(new)",
    )
    assert not same


def check_cleanup(home: Path) -> None:
    (home / ".config/helix").mkdir(parents=True)
    (home / ".config/mako").mkdir()
    (home / ".config/mako/config").write_text("mine\n")
    stub = """
gate.query = lambda *cmd: "mako\\nzsh\\n" if cmd[0] == "pacman" else "disabled\\n"
gate.run = lambda *cmd: print("RUN", *cmd)
asked = []
gate.choose = lambda question, options: (asked.extend(options), picked)[1]
"""
    for overwrite in ("False", "True"):
        option = f"options.args.overwrite = {overwrite}\npicked = []\n"
        before = snapshot(home)
        in_child(home, stub + option + "cleanup.clean_up()")
        assert snapshot(home) == before
    out = in_child(
        home,
        stub + "picked = asked\ngate.confirm = lambda q: False\ncleanup.clean_up()",
    )
    assert (home / ".config/mako/config").exists(), "no means no"
    stub += YES
    out = in_child(home, stub + "picked = asked\ncleanup.clean_up()\nprint(asked)")
    assert "RUN yay -Rns mako" in out
    assert "zsh" not in out
    assert not (home / ".config/helix").exists()
    assert not (home / ".config/mako").exists()


YAZI = """
steps.DOTFILES = links.DOTFILES = Path.home() / "checkout"
plugins = steps.CFG / "yazi/plugins"
def ya(*cmd):
    if works: (plugins / "git.yazi").mkdir(parents=True)
    return works
gate.run = ya
gate.confirm = lambda question: True
steps.setup_yazi()
"""


def check_yazi(home: Path) -> None:
    old = home / "checkout/CONFIG/yazi/plugins"
    (old / "git.yazi").mkdir(parents=True)
    (old.parent / "package.toml").write_text(
        '[[plugin.deps]]\nuse = "yazi-rs/plugins:git"\n'
    )
    link = home / ".config/yazi/plugins"
    link.parent.mkdir(parents=True)
    link.symlink_to(old)
    in_child(home, "works = False\n" + YAZI)
    assert link.is_symlink(), "the link is put back when ya fails"
    (old / "own.yazi").mkdir()
    out = in_child(home, "works = True\n" + YAZI)
    assert "own.yazi" in out
    assert old.is_dir(), "a plugin that is not in package.toml is kept"
    assert (link / "git.yazi").is_dir()
    (old / "own.yazi").rmdir()
    in_child(home, "works = False\noptions.args.dry_run = True\n" + YAZI)
    assert old.is_dir()
    in_child(home, "works = True\n" + YAZI.replace("if works:", "if False:"))
    assert not old.exists()


if __name__ == "__main__":
    check_gates()
    for name, check in list(globals().items()):
        if name.startswith("check_") and name != "check_gates":
            with tempfile.TemporaryDirectory() as folder:
                check(Path(folder))
    print("ok")
