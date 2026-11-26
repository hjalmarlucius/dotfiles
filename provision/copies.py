"""Files that are copied instead of linked."""

import os
from pathlib import Path

import gate
from links import may_replace, same, tracked
from options import args
from unlock import CRYPT_CONF


def copy_system_files(source: Path) -> None:
    """Copy to / with sudo, with the file modes of the checkout."""
    units = False
    for rel in tracked(source):
        src, tgt = source / rel, Path("/") / rel
        if same(src, tgt) or rel == CRYPT_CONF:  # see check_unlock()
            continue
        if os.path.lexists(tgt):
            may = may_replace(src, tgt)
        else:
            may = args.overwrite or gate.confirm(f"install {tgt}?")
        if may:
            mode = f"{src.stat().st_mode & 0o777:o}"
            gate.run("sudo", "install", "-D", "-m", mode, src, tgt)
            units |= rel.is_relative_to("etc/systemd/system")
    if units:
        gate.run("sudo", "systemctl", "daemon-reload")

