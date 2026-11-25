"""Installing packages."""

import gate
from options import args


def install(packages: set[str]) -> bool:
    missing = sorted(packages)
    if not args.reinstall:  # -T prints those that nothing installed provides
        missing = gate.query("pacman", "-T", *missing).split()
    return not missing or gate.run("yay", "-S", *missing)
