"""Leftovers of older versions, removed if the owner says so."""

import os
from pathlib import Path

import gate
from links import into_checkout, set_aside
from paths import HOME

# Leftovers of older versions, and EndeavourOS defaults we replace: removed if you
# say so. A name is a package, a user unit (*.service), or a path (~/ or /).
CLEANUP = {
    "flashfocus.service": "dropped 2025-11",
    "flashfocus": "dropped 2025-11",
    "autotiling": "EndeavourOS default, not used in our sway config",
    "cliphist": "EndeavourOS default, replaced by wl-clip-persist",
    "mako": "EndeavourOS default, replaced by swaync",
    "carapace-bin": "replaced by zsh 2025-10",
    "digikam": "dropped 2026-10",
    "discordo-git": "dropped 2026-10",
    "docker-compose": "dropped 2025-11",
    "doxx": "dropped 2025-11, yazi opens docx with LibreOffice",
    "helix": "dropped 2026-10",
    "isd": "dropped 2026-11, systemctl-tui is used",
    "lazyjournal": "dropped 2026-11",
    "microsoft-edge-stable-bin": "dropped 2026-03",
    "ncdu": "replaced by gdu 2026-10",
    "newsboat": "replaced by eilmeldung 2026-03",
    "noisetorch": "dropped 2026-10",
    "nushell": "replaced by zsh 2025-10",
    "nvidia-docker": "dropped 2025-11",
    "oh-my-posh": "replaced by starship 2025-10",
    "vesktop": "replaced by discord 2026-03",
    "~/.config/discordo": "config dropped 2026-10",
    "~/.config/helix": "config dropped 2026-10",
    "~/.config/hypr": "config dropped",
    "~/.config/mako": "config dropped 2026-10",
    "~/.config/newsboat": "config dropped 2026-03",
    "~/.config/nushell": "config dropped 2026-10",
    "~/.cache/newsboat": "made by an older version for newsboat",
    "~/.config/sway/config.d": "EndeavourOS default, not used by our sway config",
    "~/.local/share/applications/userapp-khalimport.des": "misspelt link 2025-10",
    "/lib/systemd/system-sleep/iptsd-hack.sh": "installed by hand, now iptsd.sh",
}


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
    elif name.startswith("/"):
        if path.is_symlink():
            gate.run("sudo", "rm", path)
        elif gate.run("sudo", "chmod", "a-x", path):
            gate.run("sudo", "mv", "--backup=numbered", path, f"{path}.dotfiles-bak")
    elif into_checkout(path):
        gate.do(f"remove the link {path}", path.unlink)
    elif path.is_dir() and not path.is_symlink() and not any(path.iterdir()):
        gate.do(f"remove the empty folder {path}", path.rmdir)
    else:
        set_aside(path)
