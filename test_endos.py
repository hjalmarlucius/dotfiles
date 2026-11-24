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
GATES = {"query", "do", "confirm", "make_link"}  # make_link only runs in do()


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


if __name__ == "__main__":
    check_gates()
    for check in (check_audit, check_links):
        with tempfile.TemporaryDirectory() as folder:
            check(Path(folder))
    print("ok")
