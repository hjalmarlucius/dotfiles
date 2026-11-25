"""Units and the other steps after the packages."""

import os
import pwd
import re
import shutil
import tomllib

import gate
from copies import copy_homeassistant, copy_system_files
from links import delete, into_checkout, may_delete
from options import args
from paths import CFG, CUSTOM, DOTFILES, HOME
from tables import UNITS

GITEA = "git.hjarl.com"
FONT_URL = "https://raw.githubusercontent.com/SUNET/static_sunet_se/refs/heads/master/fonts/Akkurat-Mono.otf"


def enable(unit: str, sudo: tuple[str, ...] = ("sudo",), *options: str) -> None:
    if gate.query("systemctl", *options, "is-enabled", unit).strip() != "enabled":
        gate.run(*sudo, "systemctl", *options, "enable", "--now", unit)


def setup_common() -> None:
    font = HOME / ".local/share/fonts/Akkurat-Mono.otf"
    if not font.exists():
        options = ("--fail", "--location", "--create-dirs", "--remove-on-error")
        gate.run("curl", *options, "--output", font, FONT_URL)
    if pwd.getpwuid(os.getuid()).pw_shell != "/usr/bin/zsh":
        gate.run("chsh", "-s", "/usr/bin/zsh")
    tpm = CFG / "tmux/plugins/tpm"
    if not tpm.exists():
        gate.run("git", "clone", "https://github.com/tmux-plugins/tpm", tpm)
    setup_yazi()
    for folder in (HOME / "Downloads", HOME / "Calendars", HOME / "Contacts"):
        if not folder.is_dir():
            gate.do(f"make folder {folder}", folder.mkdir)
    waybar = CFG / "waybar/config"  # EndeavourOS's; hides our config.jsonc
    if os.path.lexists(waybar) and may_delete(waybar):
        delete(waybar)
    enable("vdirsyncer.timer", (), "--user")
    if shutil.which("gt") and GITEA not in gate.query("gt", "auth", "status"):
        gate.warn(f"no Gitea login: gt auth login --host {GITEA}")


def setup_yazi() -> None:
    """Install the plugins in CONFIG/yazi/package.toml, in a folder of their own:
    older versions linked it to the checkout."""
    plugins, old = CFG / "yazi/plugins", DOTFILES / "CONFIG/yazi/plugins"
    linked = into_checkout(plugins)
    if linked:
        gate.do(f"remove the folder link {plugins}", plugins.unlink)
    if not gate.run("ya", "pkg", "install") and linked and not plugins.exists():
        gate.do(f"link {plugins} -> {old} again", plugins.symlink_to, old)
        return
    if not old.is_dir():
        return
    package = tomllib.loads((DOTFILES / "CONFIG/yazi/package.toml").read_text())
    listed = {
        re.split("[/:]", dep["use"])[-1] + ".yazi" for dep in package["plugin"]["deps"]
    }
    unknown = {path.name for path in old.iterdir()} - listed
    missing = {name for name in listed if not (plugins / name).is_dir()}
    in_place = plugins.is_dir() and not into_checkout(plugins) and not missing
    if unknown or not (in_place or args.dry_run):
        gate.warn(
            f"{old} is kept; not in package.toml: {sorted(unknown)}; "
            f"not installed: {sorted(missing)}"
        )
    elif gate.confirm(f"remove {old}, now that {plugins} replaces it?"):
        gate.do(f"remove {old}", shutil.rmtree, old)


def join_group(group: str) -> None:
    user = pwd.getpwuid(os.getuid()).pw_name
    if group not in gate.query("id", "-nG", user).split():
        gate.run("sudo", "usermod", "-aG", group, user)


def setup_virtwin() -> None:
    join_group("libvirt")
    if not os.path.exists("/sys/class/net/virbr0"):
        gate.run("sudo", "virsh", "net-start", "default")
    if not os.path.lexists("/etc/libvirt/qemu/networks/autostart/default.xml"):
        gate.run("sudo", "virsh", "net-autostart", "default")


def set_up(groups: list[str]) -> None:
    copy_system_files(CUSTOM / "ROOT")
    if "k8s" in groups:
        copy_system_files(DOTFILES / "ROOT")
    for unit, group in UNITS.items():
        if group in groups:
            enable(unit)
    setup_common()
    if "docker" in groups:
        join_group("docker")
        copy_homeassistant()
    if "virtwin" in groups:
        setup_virtwin()
