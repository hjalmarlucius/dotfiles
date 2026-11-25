#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.13"
# dependencies = ["tyro"]
# ///
"""Install the owner's dotfiles and packages on this host (see manual.md too)."""

import sys

import gate
import tyro
from links import link_all
from options import Args, args
from packages import install
from paths import DOTFILES, HOSTNAME
from steps import set_up
from tables import HOSTS, groups_for, packages_for
from unlock import check_unlock


def main() -> None:
    flags = (tyro.conf.FlagCreatePairsOff,)
    given = tyro.cli(Args, description=__doc__, config=flags)
    vars(args).update(vars(given))  # the other modules hold this object
    if HOSTNAME not in HOSTS:
        sys.exit(f"unknown host {HOSTNAME}: add it to hosts.toml")
    if args.dry_run:
        sys.addaudithook(gate.audit)
    groups = groups_for(HOSTNAME)
    if args.check:
        if "luks" in groups:
            check_unlock()
    else:
        link_all(groups)
        if install(packages_for(HOSTNAME)):  # the rest needs the packages
            set_up(groups)
    if gate.failed:
        sys.exit("\n".join(["FAILED:", *gate.failed]))
    print(f"Steps left to you: {DOTFILES / 'manual.md'}")


if __name__ == "__main__":
    main()
