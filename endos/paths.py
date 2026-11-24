"""Where things are."""

from pathlib import Path

HOSTNAME = Path("/etc/hostname").read_text().strip()
DOTFILES = Path(__file__).resolve().parent.parent
HOME = Path.home()
CFG = HOME / ".config"
CUSTOM = DOTFILES / f"custom-{HOSTNAME}"
