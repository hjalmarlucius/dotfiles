"""Leftovers of older versions, removed if the owner says so."""

import os
from pathlib import Path

import gate
from links import delete, into_checkout, may_delete
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
    elif into_checkout(path) or may_delete(path):
        if name.startswith("/"):
            gate.run("sudo", "rm", path)
        else:
            delete(path)
