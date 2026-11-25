"""Leftovers of older versions, removed if the owner says so."""

import os
from pathlib import Path

import gate
from links import into_checkout, set_aside
from paths import HOME
from tables import CLEANUP


def clean_up() -> None:
    unneeded = gate.query("pacman", "-Qqtt").split()  # not used by another package
    present = {}
    for name, reason in CLEANUP.items():
        if name.startswith(("~/", "/")):
            found = os.path.lexists(clean_path(name))
        elif name.endswith(".service"):
            found = gate.query("systemctl", "--user", "is-enabled", name).strip()
            found = found == "enabled"
        else:
            found = name in unneeded
        if found:
            present[name] = reason
    if present:
        print("Leftovers:")
        for name in gate.choose("remove which?", present):
            remove_leftover(name)


def clean_path(name: str) -> Path:
    return HOME / name[2:] if name.startswith("~/") else Path(name)


def remove_leftover(name: str) -> None:
    path = clean_path(name)
    if name.endswith(".service"):
        gate.run("systemctl", "--user", "disable", "--now", name)
    elif not name.startswith(("~/", "/")):
        gate.run("yay", "-Rns", name)
    elif name.startswith("/"):
        if path.is_symlink():
            gate.run("sudo", "rm", path)
        elif gate.run("sudo", "chmod", "a-x", path):
            gate.run("sudo", "mv", "--backup=numbered", path, f"{path}.dotfiles-bak")
    elif into_checkout(path):
        gate.do(f"remove the link {path}", path.unlink)
    elif path.is_dir() and not path.is_symlink() and not any(path.iterdir()):
        gate.do(f"remove the empty folder {path}", path.rmdir)
    else:
        set_aside(path)
