"""Packages installed by hand: in no table of this host."""

import gate
from options import args
from tables import packages_for


def list_drift(host: str) -> None:
    """Only a list; many are from the installation of the system."""
    installed = set(gate.query("pacman", "-Qqet").split())  # explicit, not required
    extra = sorted(installed - packages_for(host))
    print(f"{len(extra)} packages installed by hand are not in hosts.toml", end="")
    if "drift" in args.only:
        print(":", *extra, sep="\n  ")
    else:
        print(" (--only drift lists them)")
