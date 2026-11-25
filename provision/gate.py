"""Every command, change and question goes through these functions.

In a dry run, audit() stops whatever does not."""

import os
import shlex
import subprocess
from collections.abc import Callable
from pathlib import Path

from options import args
from paths import DOTFILES

QUERIES = (  # all that query() may run: these change nothing
    ("git", "ls-files"),
    ("id", "-nG"),
    ("pacman", "-Qqet"),
    ("pacman", "-Qqtt"),
    ("pacman", "-T"),
    ("ssh-keygen", "-l"),
    ("systemctl", "is-enabled"),
    ("systemctl", "--user", "is-enabled"),
)

done: list[str] = []
skipped: list[str] = []
warned: list[str] = []
failed: list[str] = []


def is_query(cmd) -> bool:
    return any(tuple(cmd[: len(allowed)]) == allowed for allowed in QUERIES)


def audit(event: str, info: tuple) -> None:
    """Audit hook for dry runs: refuse whatever could change something."""
    if event == "open":
        refuse = info[2] & (os.O_WRONLY | os.O_RDWR | os.O_CREAT | os.O_TRUNC)
    elif event == "subprocess.Popen":
        refuse = not is_query(info[1])
    elif event in ("os.listdir", "os.scandir", "os.walk"):
        refuse = False
    else:
        refuse = event.startswith(("os.", "shutil.", "socket.", "builtins.input"))
    if refuse:
        raise RuntimeError(f"a dry run must not do this: {event} {info}")


def query(*cmd: str, cwd: Path = DOTFILES) -> str:
    """Output of a command that only reads."""
    assert is_query(cmd), cmd
    result = subprocess.run(
        cmd, cwd=cwd, stdout=subprocess.PIPE, text=True, check=False
    )
    return result.stdout


def read_as_root(*cmd: str) -> str | None:
    """The same with sudo, which a dry run doesn't use."""
    assert cmd[0] in ("cat", "grep", "lsinitrd"), cmd
    if args.dry_run:
        print("! not read, as it needs sudo:", shlex.join(cmd))
        return None
    result = subprocess.run(
        ("sudo", *cmd),
        stdout=subprocess.PIPE,
        text=True,
        errors="replace",
        check=False,
    )
    return result.stdout


def run(*cmd: str | Path, text: str | None = None) -> bool:
    """Run a command that changes something, with text as its input."""
    output = None if text is None else subprocess.DEVNULL
    line = shlex.join(map(str, cmd))
    return do(
        line, subprocess.run, cmd, input=text, stdout=output, text=True, check=True
    )


def do(what: str, change: Callable, *params, **options) -> bool:
    """Show a change, and make it unless this is a dry run."""
    print("+", what, flush=True)
    if args.dry_run:
        done.append(what)
        return True
    try:
        change(*params, **options)
    except (OSError, subprocess.SubprocessError) as err:
        print("!", err)
        failed.append(what)
        return False
    done.append(what)
    return True


def warn(text: str) -> None:
    print("!", text)
    warned.append(text)


def confirm(question: str) -> bool:
    if args.dry_run:
        print("? would ask:", question)
        return True
    yes = input(f"{question} (y/N) ").strip().lower() in ("y", "yes")
    if not yes:
        skipped.append(question)
    return yes


def choose(question: str, options: dict[str, str]) -> list[str]:
    """Some of the options (name: description), by name or number."""
    for number, (name, description) in enumerate(options.items(), 1):
        print(f"  {number}. {name}: {description}")
    if args.dry_run:
        print("? would ask:", question)
        return list(options)
    answer = input(f"{question} (names, numbers or all; default none) ").split()
    if answer == ["all"]:
        return list(options)
    chosen = [n for i, n in enumerate(options, 1) if n in answer or str(i) in answer]
    skipped.extend(f"{question} {name}" for name in options if name not in chosen)
    return chosen
