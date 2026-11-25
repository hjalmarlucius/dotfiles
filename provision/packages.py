"""Installing packages."""

from fnmatch import fnmatch

import gate
from options import args
from paths import HOSTNAME
from tables import PINS


def matches(package: str, patterns: list[str]) -> bool:
    return any(fnmatch(package, pattern) for pattern in patterns)


def loose_pins() -> list[str]:
    """Installed packages that this host pins but pacman would update."""
    pins = PINS.get(HOSTNAME, [])
    ignored = gate.query("pacman-conf", "IgnorePkg").split()
    installed = gate.query("pacman", "-Qq").split() if pins else []
    return [p for p in installed if matches(p, pins) and not matches(p, ignored)]


def install(packages: set[str]) -> bool:
    if loose := loose_pins():
        gate.warn("not held back, so no packages are touched. In /etc/pacman.conf:")
        gate.warn(f"IgnorePkg = {' '.join(loose)}")
        return False
    missing = sorted(packages)
    if args.reinstall:
        pins = PINS.get(HOSTNAME, [])
        missing = [p for p in missing if not matches(p, pins)]
    else:  # -T prints those that nothing installed provides
        missing = gate.query("pacman", "-T", *missing).split()
    installed = not missing or gate.run("yay", "-S", *missing)
    # marked as dependencies, they would go when orphans are removed
    implicit = sorted(packages & set(gate.query("pacman", "-Qqd").split()))
    if implicit:
        gate.run("sudo", "pacman", "-D", "--asexplicit", *implicit)
    return installed
