"""The options of the command, as args for every module."""

from dataclasses import dataclass
from typing import Annotated

from tyro.conf import arg


@dataclass
class Args:
    dry_run: Annotated[bool, arg(aliases=["-n"])] = False
    """Show what a run would do, and change nothing."""
    overwrite: Annotated[bool, arg(aliases=["-o"])] = False
    """Replace files that differ without asking."""
    reinstall: Annotated[bool, arg(aliases=["-r"])] = False
    """Reinstall all packages."""
    check: Annotated[bool, arg(aliases=["-c"])] = False
    """Only check SSH unlock (mothership, droneship), and offer repairs."""


args = Args()  # apply.main() fills it in
