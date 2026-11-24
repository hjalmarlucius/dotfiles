"""Checks of endos.py. Run it without access to anything that matters:

bwrap --ro-bind / / --dev /dev --proc /proc --tmpfs /tmp --unshare-net \\
    --ro-bind "$PWD" "$PWD" --chdir "$PWD" python3 -B test_endos.py
"""

import ast
import os
import subprocess
import sys
import tempfile
from pathlib import Path

SOURCE = Path(__file__).with_name("endos.py")
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
    for function in ast.parse(SOURCE.read_text()).body:
        if getattr(function, "name", None) in GATES:
            continue
        for node in ast.walk(function):
            if not isinstance(node, ast.Call):
                continue
            func = node.func
            bad = isinstance(func, ast.Name) and func.id in BUILTINS | {"make_link"}
            bad |= isinstance(func, ast.Attribute) and func.attr in CHANGES
            assert not bad, f"line {node.lineno}: {ast.unparse(node)} is not in a gate"


def in_child(home: Path, code: str) -> str:
    """Run code after importing endos with HOME=home; packages are never touched."""
    setup = "import endos, sys, subprocess, os\nfrom pathlib import Path\n"
    result = subprocess.run(
        [sys.executable, "-B", "-c", setup + code],
        cwd=SOURCE.parent,
        env={**os.environ, "HOME": str(home)},
        capture_output=True,
        text=True,
        check=False,
    )
    assert result.returncode == 0, result.stdout + result.stderr
    return result.stdout


def snapshot(home: Path) -> dict[str, object]:
    paths = sorted(home.rglob("*"))
    return {str(p): os.readlink(p) if p.is_symlink() else p.stat() for p in paths}


DRY = "endos.args.dry_run = True\nsys.addaudithook(endos.audit)\n"
LINK = "endos.PRIVATE = ()\nendos.link_all(endos.groups_for('mothership'))\n"
YES = "endos.confirm = lambda question: True\n"


def check_links(home: Path) -> None:
    (home / ".config/nvim").mkdir(parents=True)
    (home / ".config/nvim/after").symlink_to(SOURCE.parent / "CONFIG/nvim/after")
    (home / ".config/dead").symlink_to(SOURCE.parent / "CONFIG/gone")
    (home / ".gitconfig").write_text("mine\n")
    before = snapshot(home)
    plan = in_child(home, DRY + LINK)
    assert snapshot(home) == before, "the dry run changed something"
    done = in_child(home, YES + LINK)

    def lines(output: str) -> list[str]:
        return [line for line in output.splitlines() if line.startswith("+ ")]

    assert lines(plan) == lines(done), "the dry run showed something else"
    assert len(lines(done)) > 50
    assert (home / ".gitconfig.endos-bak").read_text() == "mine\n"
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
    setattr(endos, name, lambda *a, name=name: calls.append(name))
endos.install = lambda packages: (calls.append("install"), works)[1]
endos.HOSTNAME = host
sys.argv = ["endos.py", *options]
status = 0
try: endos.main()
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
    broken = "host, options, works = 'sl3', [], True\nendos.run('false')\n"
    in_child(home, broken + MAIN + "assert 'false' in status, status")


UNLOCK = """
import pathlib
at = Path.home()
endos.CRYPT_CONF = Path("conf")  # a relative path: / and the checkout hold it
endos.UNLOCK_KEYS, endos.CMDLINE = at / "keys/authorized_keys", at / "cmdline"
endos.HOST_KEY = str(at / "keys/host")
endos.dracut_confs = lambda: [at / "omit.conf"]
endos.CUSTOM = at / "custom"
planned = []
endos.run = lambda *cmd, text=None: (planned.append((cmd[:2], text)), True)[1]
endos.install = lambda packages: planned.append("install") or True
endos.query = lambda *cmd, text=None, **o: "256 SHA256:abc me (ED25519)" if text else ""
endos.read_as_root = lambda *cmd: (
    "ssh-ed25519 AAAA me" if cmd[0] == "cat" and cmd[1].startswith("/root") else ""
)
endos.choose = lambda question, options: []
endos.confirm = lambda question: True
"""


def check_unlocking(home: Path) -> None:
    (home / "cmdline").write_text("quiet root=/dev/x ip=10.0.0.2 rw\n")
    (home / "omit.conf").write_text('omit_dracutmodules+=" nfs network brltty "\n')
    (home / "custom/ROOT").mkdir(parents=True)
    (home / "custom/ROOT/conf").write_text("ours")
    for overwrite in ("False", "True"):  # no key chosen: the conf stays out
        setup = f"{UNLOCK}endos.args.overwrite = {overwrite}\nendos.check_unlock()\n"
        in_child(home, setup + "assert 'install' not in str(planned), planned")
    (home / "keys").mkdir()
    for name in ("host", "host.pub", "authorized_keys"):
        (home / "keys" / name).write_text("ssh-ed25519 AAAA me\n")
    done = in_child(
        home,
        UNLOCK
        + """
endos.has_unlock_keys = lambda: True
endos.check_unlock()
print([(cmd, text) for cmd, text in planned])
assert (("sudo", "tee"), "quiet root=/dev/x ip=10.0.0.2 rw rd.neednet=1\\n") in planned
assert (("sudo", "tee"), 'omit_dracutmodules+=" nfs  brltty "\\n') in planned
assert (("sudo", "install"), None) in planned
assert not any("reinstall-kernels" in cmd for cmd, text in planned)
endos.args.check = True
planned.clear()
endos.entries_ok, endos.image_ok = lambda: True, lambda version: None
endos.check_unlock()
assert (("sudo", "reinstall-kernels"), None) not in planned, "unknown is no reason"
endos.image_ok = lambda version: False
endos.confirm = lambda question: "rebuild the" not in question
endos.check_unlock()
assert (("sudo", "reinstall-kernels"), None) not in planned, "no means no"
assert endos.failed
endos.confirm = lambda question: True
endos.check_unlock()
assert (("sudo", "reinstall-kernels"), None) in planned
""",
    )
    assert "AAAA" not in done
    same = in_child(
        home,
        "for line in ('a b', 'a rd.neednet=1 ip=dhcp\\n', 'a\\nb\\n'):\n"
        "    new = endos.with_network(line).split()\n"
        "    assert new[:len(line.split())] == line.split()\n"
        "    assert {'rd.neednet=1', 'ip=dhcp'} <= set(new)",
    )
    assert not same


def check_cleanup(home: Path) -> None:
    (home / ".config/helix").mkdir(parents=True)
    (home / ".config/mako").mkdir()
    (home / ".config/mako/config").write_text("mine\n")
    stub = """
endos.query = lambda *cmd: "mako\\nzsh\\n" if cmd[0] == "pacman" else "disabled\\n"
endos.run = lambda *cmd: print("RUN", *cmd)
asked = []
endos.choose = lambda question, options: (asked.extend(options), picked)[1]
"""
    for overwrite in ("False", "True"):
        option = f"endos.args.overwrite = {overwrite}\npicked = []\n"
        before = snapshot(home)
        in_child(home, stub + option + "endos.clean_up()")
        assert snapshot(home) == before
    out = in_child(home, stub + "picked = asked\nendos.clean_up()\nprint(asked)")
    assert "RUN yay -Rns mako" in out
    assert "zsh" not in out
    assert not (home / ".config/helix").exists()
    assert (home / ".config/mako.endos-bak/config").read_text() == "mine\n"


YAZI = """
endos.DOTFILES = Path.home() / "checkout"
plugins = endos.CFG / "yazi/plugins"
def ya(*cmd):
    if works: (plugins / "git.yazi").mkdir(parents=True)
    return works
endos.run = ya
endos.confirm = lambda question: True
endos.setup_yazi()
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
    in_child(home, "works = False\nendos.args.dry_run = True\n" + YAZI)
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
