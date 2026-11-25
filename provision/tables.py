"""The tables in hosts.toml."""

import tomllib
from pathlib import Path

TABLES = tomllib.loads(Path(__file__).with_name("hosts.toml").read_text())
HOSTS: dict[str, list[str]] = TABLES["hosts"]
PACKAGES: dict[str, list[str]] = TABLES["packages"]
UNITS: dict[str, str] = TABLES["units"]
CLEANUP: dict[str, str] = TABLES["cleanup"]


def groups_for(host: str) -> list[str]:
    special = {group for groups in HOSTS.values() for group in groups}
    return [g for g in PACKAGES if g not in special or g in HOSTS[host]]


def packages_for(host: str) -> set[str]:
    return {package for group in groups_for(host) for package in PACKAGES[group]}
