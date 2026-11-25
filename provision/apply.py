#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.13"
# dependencies = ["tyro"]
# ///
"""Install the owner's dotfiles and packages on this host (see manual.md too)."""

import sys
from collections.abc import Callable
from functools import partial

import gate
import tyro
from cleanup import clean_up
from drift import list_drift
from links import link_all
from options import Args, args
from packages import install
from paths import DOTFILES, HOSTNAME
from steps import set_up
from tables import HOSTS, groups_for, packages_for
from unlock import check_unlock


def steps_for(host: str) -> dict[str, Callable]:
    """The steps in order; one that returns False stops the run."""
    groups = groups_for(host)
    steps: dict[str, Callable] = {
        "links": partial(link_all, groups),
        "packages": partial(install, packages_for(host)),
        "unlock": check_unlock,
        "system": partial(set_up, groups),
        "cleanup": clean_up,
        "drift": partial(list_drift, host),
    }
    if "luks" not in groups:
        steps["unlock"] = partial(print, "no SSH unlock on this host")
    return steps


def main() -> None:
    flags = (tyro.conf.FlagCreatePairsOff,)
    given = tyro.cli(Args, description=__doc__, config=flags)
    vars(args).update(vars(given))  # the other modules hold this object
    if HOSTNAME not in HOSTS:
        sys.exit(f"unknown host {HOSTNAME}: add it to hosts.toml")
    if args.dry_run:
        sys.addaudithook(gate.audit)
    for step, act in steps_for(HOSTNAME).items():
        if (not args.only or step in args.only) and act() is False:
            print(f"stopped after {step}: the rest needs it")
            break
    if gate.failed:
        sys.exit("\n".join(["FAILED:", *gate.failed]))
    print(f"Steps left to you: {DOTFILES / 'manual.md'}")


if __name__ == "__main__":
    main()
