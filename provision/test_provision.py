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
    assert len(files) == 9, files
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
        "import apply, cleanup, gate, links, packages, paths, steps, unlock\n"
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


DRY = "gate.args.dry_run = True\nsys.addaudithook(gate.audit)\n"
LINK = "links.PRIVATE = ()\nlinks.link_all(packages.groups_for('mothership'))\n"
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
    assert (home / ".gitconfig.dotfiles-bak").read_text() == "mine\n"
    assert not (home / ".config/nvim/after").is_symlink()
    assert not (home / ".config/dead").is_symlink()
    assert not lines(in_child(home, LINK)), "a second run changed something"


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


MAIN = """
calls = []
for name in ("link_all", "set_up", "check_unlock"):
    setattr(apply, name, lambda *a, name=name: calls.append(name))
apply.install = lambda packages: (calls.append("install"), works)[1]
apply.HOSTNAME = host
sys.argv = ["apply.py", *options]
status = 0
try: apply.main()
except SystemExit as stop: status = stop.code
"""


def check_main(home: Path) -> None:
    normal = ["link_all", "install", "set_up"]
    for host, options, works, calls, status in (
        ("mothership", [], True, normal, "0"),
        ("sl3", ["-o", "-r"], True, normal, "0"),
        ("spro5", ["--dry-run"], True, normal, "0"),
        ("sl3", [], False, normal[:2], "0"),
        ("droneship", ["--check"], True, ["check_unlock"], "0"),
        ("sl3", ["--check"], True, [], "0"),
        ("elsewhere", [], True, [], "'unknown host elsewhere: add it to HOSTS'"),
        ("sl3", ["--nonsense"], True, [], "2"),
    ):
        setup = f"host, options, works = {(host, options, works)!r}\n"
        expect = f"assert (calls, status) == ({calls!r}, {status}), (calls, status)"
        in_child(home, setup + MAIN + expect)
    broken = "host, options, works = 'sl3', [], True\ngate.run('false')\n"
    in_child(home, broken + MAIN + "assert 'false' in status, status")


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
        setup = f"{UNLOCK}gate.args.overwrite = {overwrite}\nunlock.check_unlock()\n"
        in_child(home, setup + "assert 'install' not in str(planned), planned")
    # choosing keys is safe in a dry run, with the real gate
    setup = UNLOCK.replace("gate.choose =", "unused =").replace(
        "gate.run =", "unused ="
    )
    dry = "gate.args.dry_run = True\nsys.addaudithook(gate.audit)\n"
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
gate.args.check = True
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
        option = f"gate.args.overwrite = {overwrite}\npicked = []\n"
        before = snapshot(home)
        in_child(home, stub + option + "cleanup.clean_up()")
        assert snapshot(home) == before
    out = in_child(home, stub + "picked = asked\ncleanup.clean_up()\nprint(asked)")
    assert "RUN yay -Rns mako" in out
    assert "zsh" not in out
    assert not (home / ".config/helix").exists()
    assert (home / ".config/mako.dotfiles-bak/config").read_text() == "mine\n"


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
    in_child(home, "works = False\ngate.args.dry_run = True\n" + YAZI)
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
