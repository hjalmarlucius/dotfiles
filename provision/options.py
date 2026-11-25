"""The options of the command, as args for every module."""

from dataclasses import dataclass
from typing import Annotated, Literal

from tyro.conf import arg

Step = Literal["links", "packages", "unlock", "system", "cleanup", "drift"]


@dataclass
class Args:
    dry_run: Annotated[bool, arg(aliases=["-n"])] = False
    """Show what a run would do, and change nothing."""
    overwrite: Annotated[bool, arg(aliases=["-o"])] = False
    """Replace files that differ without asking."""
    reinstall: Annotated[bool, arg(aliases=["-r"])] = False
    """Reinstall all packages."""
    only: tuple[Step, ...] = ()
    """Run only these steps, in the usual order; unlock and drift then say more."""


args = Args()  # apply.main() fills it in
