"""Installing packages."""

import gate
from options import args


def install(packages: set[str]) -> bool:
    missing = sorted(packages)
    if not args.reinstall:  # -T prints those that nothing installed provides
        missing = gate.query("pacman", "-T", *missing).split()
    installed = not missing or gate.run("yay", "-S", *missing)
    # marked as dependencies, they would go when orphans are removed
    implicit = sorted(packages & set(gate.query("pacman", "-Qqd").split()))
    if implicit:
        gate.run("sudo", "pacman", "-D", "--asexplicit", *implicit)
    return installed
