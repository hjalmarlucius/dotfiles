#!/usr/bin/env python3
"""Install the owner's dotfiles and packages on this host (see manual.md too).

--dry-run shows what a run would do and changes nothing. Every change goes
through run() or do(), and in a dry run audit() stops anything that doesn't.
"""

import argparse
import os
import pwd
import shlex
import subprocess
import sys
from collections.abc import Callable
from difflib import unified_diff
from pathlib import Path

HOSTNAME = Path("/etc/hostname").read_text().strip()
DOTFILES = Path(__file__).resolve().parent
HOME = Path.home()
CFG = HOME / ".config"
CUSTOM = DOTFILES / f"custom-{HOSTNAME}"

# The package groups not named here are for every host.
HOSTS = {
    "mothership": ("nvidia", "luks", "k8s", "coolercontrol", "docker", "virtwin"),
    "droneship": ("nvidia", "luks", "k8s", "coolercontrol"),
    "sl3": (),
    "spro5": ("tablet",),
}
PACKAGES = {
    "fonts": (
        "noto-fonts-emoji",
        "ttf-hack",
        "font-manager",
    ),
    "zsh": (
        "zsh",
        "zsh-autosuggestions",
        "zsh-syntax-highlighting",
        "zsh-vi-mode",
        "atuin",
        "fzf",
        "fd",  # FZF_DEFAULT_COMMAND
        "starship",
        "zoxide",
        "bat",
    ),
    "tmux": ("tmux", "urlscan"),
    "editors": (
        "neovim",
        "ripgrep",
        "npm",  # required for nvim plugins
        "go",  # required for vim-hexokinase build
        "tree-sitter-cli",  # required for nvim treesitter
    ),
    "utils": ("uv", "gdu", "unzip", "jq", "bluetui"),
    "gittools": (
        "tig",
        "diff-so-fancy",
        "git-secret",
        "git-delta",
        "git-lfs",
        "lazygit",
        "gnome-keyring",  # for git credentials
        "seahorse",  # keyring ui
    ),
    "readers": (
        "sioyek-git",
        "zathura",
        "zathura-pdf-mupdf",
        "zathura-djvu",
        "zathura-ps",
        "typst",
        "okular",
        "calligra",
        "libreoffice-fresh",
        "xournalpp",
    ),
    "mediaviewers": (
        # video
        "vlc",
        "mpv",
        "protobuf",
        "yt-dlp",
        "v4l-utils",
        # photos
        "qimgv",
        "krita",  # yazi opener
        "kimageformats5",  # heif support
        # music
        "quodlibet",
        "gst-plugins-good",  # required deb
        # audio
        "pamixer",
        "pavucontrol",  # waybar
        "playerctl",  # sway media keys
    ),
    "filebrowsers": (
        "yazi",
        "ranger",
        "pcmanfm",
        "thunar",
        "ouch",
        "gparted",
        "sshfs",
        "file-roller",
        "7zip",  # explore zip files
        "eza",  # pretty alternative to `ls`
        "glow",  # markdown renderer
        "perl-image-exiftool",  # yazi keymap
        "duckdb",  # yazi parquet-preview plugin
    ),
    "netbrowsers": (
        "qutebrowser",
        "firefox",
        "google-chrome",
        "w3m",
        "python-adblock",  # for qutebrowser ad blocker
        "python-tldextract",
        "python-readability-lxml",  # for qutebrowser reader mode
        "pdfjs",  # for qutebrowser pdf viewer
        "bitwarden-cli",  # for qutebrowser autofill
    ),
    "chat": ("discord", "gurk"),
    "emailcalrss": (
        "khard",  # contacts
        "khal",  # calendar
        "aerc",  # email
        "eilmeldung",  # rss reader
        "vdirsyncer",  # sync calendar+contacts
        "pandoc-cli",  # md2html for aerc
        "poppler",  # pdftotext for aerc
        "pass",  # password manager for aerc
        "w3m",  # terminal browser for aerc
        "python-aiohttp-oauthlib",  # for google vdirsyncer
    ),
    "monitors": (
        "htop",  # hardware
        "btop",  # hardware
        "nvtop",  # gpu
        "systemctl-tui",  # systemd
        "bandwhich",  # network
        "sysstat",
        "lm_sensors",  # waybar
    ),
    "apps": ("keepassxc", "bitwarden", "qalculate-gtk"),
    "sway": (
        "xdg-terminal-exec",
        "swaync",  # notifications
        # visuals
        "wlsunset",  # eye saver
        "wdisplays",  # ui for display settings
        # clipboard
        "wl-clip-persist",  # keep clipboard after close
        # div
        "unipicker",  # unicode symbol selector
        "blueman",  # bluetooth
        "wev",  # debugging of ui
    ),
    "remotedata": ("rclone", "dropbox", "minio-client"),
    "screensharing": ("wireplumber",),
    "nvidia": ("cuda", "nvidia-settings"),
    "coolercontrol": ("coolercontrol",),
    "docker": (
        "docker",
        "dry-bin",  # docker tui
    ),
    "k8s": (
        "docker",
        "docker-buildx",  # advanced build
        "qemu-user-static-binfmt",  # build arm64
        "qemu-user-static",  # build arm64
        "k9s",  # kubernetes tui
        "wireguard-tools",  # includes wg-quick
        "sops",  # secret mgmt
        "flux-bin",
        "open-iscsi",  # required by longhorn
        "kubectl-cnpg",
    ),
    "tablet": ("squeekboard",),  # on-screen keyboard, bound in sway
    "luks": (  # unlock LUKS over ssh from the initramfs
        "dracut-crypt-ssh-git",
        "dropbear",
    ),
    "virtwin": (
        "qemu-full",  # the emulator itself
        "libvirt",  # the backend manager - handles running qemu
        "virt-manager",  # the graphical dashboard
        "virt-viewer",  # the display window
        "iptables",  # the nft backend; replaced iptables-nft
        "dnsmasq",  # lightweight DHCP and DNS server
        "bridge-utils",  # tools for creating network bridges
        "vde2",  # networking plumbing
        "openbsd-netcat",  # networking plumbing
        "swtpm",  # win11 requirement
    ),
}
REMOVE = ("autotiling", "cliphist", "mako")  # EndeavourOS defaults we replace
UNITS = {  # system unit: package group
    "bluetooth.service": "sway",
    "docker.service": "k8s",
    "iscsid.service": "k8s",
    "coolercontrold.service": "coolercontrol",
    "libvirtd.service": "virtwin",
}
TREES = (
    (DOTFILES / "HOME", HOME),
    (DOTFILES / "CONFIG", CFG),
    (CUSTOM / "CONFIG", CFG),
)
PRIVATE = ("CONFIG/aerc/accounts.conf", "CONFIG/vdirsyncer/config")  # mode 600
FONT_URL = "https://raw.githubusercontent.com/SUNET/static_sunet_se/refs/heads/master/fonts/Akkurat-Mono.otf"
QUERIES = (  # all that query() may run: these change nothing
    ("git", "ls-files"),
    ("id", "-nG"),
    ("pacman", "-Qq"),
    ("pacman", "-T"),
    ("systemctl", "is-enabled"),
    ("systemctl", "--user", "is-enabled"),
)

args = argparse.Namespace(dry_run=False, overwrite=False, reinstall=False)
failed: list[str] = []


# ---- the gate: every command, change and question goes through these ----


def is_query(cmd) -> bool:
    return any(tuple(cmd[: len(allowed)]) == allowed for allowed in QUERIES)


def audit(event: str, info: tuple) -> None:
    """Audit hook for dry runs: refuse whatever could change something."""
    if event == "open":
        refuse = info[2] & (os.O_WRONLY | os.O_RDWR | os.O_CREAT | os.O_TRUNC)
    elif event == "subprocess.Popen":
        refuse = not is_query(info[1])
    elif event in ("os.listdir", "os.scandir", "os.walk"):
        refuse = False
    else:
        refuse = event.startswith(("os.", "shutil.", "socket.", "builtins.input"))
    if refuse:
        raise RuntimeError(f"a dry run must not do this: {event} {info}")


def query(*cmd: str, cwd: Path = DOTFILES) -> str:
    """Output of a command that only reads."""
    assert is_query(cmd), cmd
    result = subprocess.run(
        cmd, cwd=cwd, stdout=subprocess.PIPE, text=True, check=False
    )
    return result.stdout


def run(*cmd: str | Path) -> bool:
    """Run a command that changes something."""
    line = shlex.join(map(str, cmd))
    return do(line, subprocess.run, cmd, check=True)


def do(what: str, change: Callable, *params, **options) -> bool:
    """Show a change, and make it unless this is a dry run."""
    print("+", what, flush=True)
    if args.dry_run:
        return True
    try:
        change(*params, **options)
    except (OSError, subprocess.SubprocessError) as err:
        print("!", err)
        failed.append(what)
        return False
    return True


def confirm(question: str) -> bool:
    if args.dry_run:
        print("? would ask:", question)
        return True
    return input(f"{question} (y/N) ").strip().lower() in ("y", "yes")


# ---- links and copies ----


def list_files(root: Path, *options: str) -> list[str]:
    output = query("git", "ls-files", "-z", *options, cwd=root)
    return [name for name in output.split("\0") if name]


def tracked(root: Path) -> list[Path]:
    """Files in git below root. A git-secret file x.secret stands for x."""
    found = []
    for name in list_files(root) if root.is_dir() else ():
        rel = Path(name.removesuffix(".secret"))
        if (root / rel).is_file():
            found.append(rel)
        else:
            print(f"! missing (secret not revealed?): {root / rel}")
    return found


def into_checkout(path: Path) -> bool:
    """Whether path is a link into the checkout."""
    if not path.is_symlink():
        return False
    target = os.path.normpath(path.parent / os.readlink(path))
    return Path(target).is_relative_to(DOTFILES)


def same(src: Path, tgt: Path) -> bool:
    try:
        return src.read_bytes() == tgt.read_bytes()
    except OSError:
        return False


def may_replace(src: Path, tgt: Path) -> bool:
    try:
        old, new = (p.read_text().splitlines(keepends=True) for p in (tgt, src))
    except (OSError, UnicodeDecodeError) as err:
        print("! cannot compare:", err)
    else:
        if src.with_name(src.name + ".secret").exists():
            print("a git-secret file: the differences are not shown")
        else:
            print("".join(unified_diff(old, new, str(tgt), str(src))))
    return args.overwrite or confirm(f"replace {tgt}?")


def set_aside(path: Path) -> bool:
    backup = path.with_name(path.name + ".endos-bak")
    while os.path.lexists(backup):
        backup = backup.with_name(backup.name + "~")
    return do(f"rename {path} to {backup.name}", path.rename, backup)


def make_link(src: Path, tgt: Path) -> None:
    tgt.parent.mkdir(parents=True, exist_ok=True)
    tgt.symlink_to(src)


def link(src: Path, tgt: Path) -> None:
    if tgt.parent.resolve().is_relative_to(DOTFILES):
        # through some link we didn't make; a link here would replace src itself
        failed.append(f"link {tgt}: its folder is in the checkout")
        return
    if tgt.is_symlink() and os.readlink(tgt) == str(src):
        return
    if into_checkout(tgt) or (not tgt.is_symlink() and same(src, tgt)):
        clear = do(f"remove {tgt}, to link it", tgt.unlink)
    elif os.path.lexists(tgt):
        clear = may_replace(src, tgt) and set_aside(tgt)
    else:
        clear = True
    if clear:
        do(f"link {tgt} -> {src}", make_link, src, tgt)


def link_tree(source: Path, root: Path, skip: set[str]) -> None:
    files = [rel for rel in tracked(source) if rel.parts[0] not in skip]
    # older versions linked whole folders; those become real folders
    unfolded = set()
    for folder in sorted({root / p for rel in files for p in rel.parents[:-1]}):
        if into_checkout(folder) and unfolded.isdisjoint(folder.parents):
            do(f"remove the folder link {folder}", folder.unlink)
            unfolded.add(folder)
    for rel in files:
        if args.dry_run and not unfolded.isdisjoint((root / rel).parents):
            print(f"+ link {root / rel} -> {source / rel}")
        else:
            link(source / rel, root / rel)
    if source.is_dir():
        for name in list_files(source, "--others", "--exclude-standard"):
            print(f"! not in git, so not linked: {source / name}")


def prune_links() -> None:
    """Remove dead links to files that are no longer in the checkout."""
    folders = {HOME} | {(HOME / rel).parent for rel in tracked(DOTFILES / "HOME")}
    folders |= {Path(folder) for folder, _, _ in os.walk(CFG)}
    for folder in sorted(filter(Path.is_dir, folders)):
        for path in sorted(folder.iterdir()):
            if into_checkout(path) and not path.exists():
                do(f"remove the dead link {path}", path.unlink)


def copy_system_files(source: Path) -> None:
    """Copy to / with sudo, with the file modes of the checkout."""
    for rel in tracked(source):
        src, tgt = source / rel, Path("/") / rel
        if same(src, tgt):
            continue
        if not os.path.lexists(tgt) or may_replace(src, tgt):
            mode = f"{src.stat().st_mode & 0o777:o}"
            run("sudo", "install", "-D", "-m", mode, src, tgt)


def copy_homeassistant() -> None:
    """The container writes to these files, so never replace them."""
    source, root = DOTFILES / "CONFIG/homeassistant", CFG / "homeassistant"
    for rel in tracked(source):
        if not os.path.lexists(root / rel):
            run("install", "-D", "-m", "644", source / rel, root / rel)


# ---- packages, units and other steps ----


def install(packages: set[str]) -> bool:
    missing = sorted(packages)
    if not args.reinstall:  # -T prints those that nothing installed provides
        missing = query("pacman", "-T", *missing).split()
    return not missing or run("yay", "-S", *missing)


def uninstall(package: str) -> None:
    installed = query("pacman", "-Qq", package).strip() == package
    if installed and confirm(f"uninstall {package}?"):
        run("yay", "-Rns", package)


def enable(unit: str, sudo: tuple[str, ...] = ("sudo",), *options: str) -> None:
    if query("systemctl", *options, "is-enabled", unit).strip() != "enabled":
        run(*sudo, "systemctl", *options, "enable", "--now", unit)


def setup_common() -> None:
    font = HOME / ".local/share/fonts/Akkurat-Mono.otf"
    if not font.exists():
        options = ("--fail", "--location", "--create-dirs", "--remove-on-error")
        run("curl", *options, "--output", font, FONT_URL)
    if pwd.getpwuid(os.getuid()).pw_shell != "/usr/bin/zsh":
        run("chsh", "-s", "/usr/bin/zsh")
    tpm = CFG / "tmux/plugins/tpm"
    if not tpm.exists():
        run("git", "clone", "https://github.com/tmux-plugins/tpm", tpm)
    run("ya", "pkg", "install")  # plugins listed in CONFIG/yazi/package.toml
    for folder in (HOME / "Downloads", HOME / "Calendars", HOME / "Contacts"):
        if not folder.is_dir():
            do(f"make folder {folder}", folder.mkdir)
    waybar = CFG / "waybar/config"  # EndeavourOS's; hides our config.jsonc
    if os.path.lexists(waybar):
        set_aside(waybar)
    enable("vdirsyncer.timer", (), "--user")


def setup_luks() -> None:
    """Host key and key list that custom-<host>/.../crypt-ssh.conf names."""
    folder = "/etc/dracut-crypt-ssh"
    key = f"{folder}/ssh_host_ed25519_key"
    keys = f"{folder}/authorized_keys"  # may unlock; not root logins
    if not os.path.exists(key):
        keygen = f"test -f {key} || ssh-keygen -q -t ed25519 -N '' -f {key}"
        run("sudo", "sh", "-c", f"mkdir -p {folder} && {{ {keygen}; }}")
    if not os.path.exists(keys):
        run("sudo", "sh", "-c", f"touch {keys} && chmod 600 {keys}")


def setup_virtwin() -> None:
    user = pwd.getpwuid(os.getuid()).pw_name
    if "libvirt" not in query("id", "-nG", user).split():
        run("sudo", "usermod", "-aG", "libvirt", user)
    if not os.path.exists("/sys/class/net/virbr0"):
        run("sudo", "virsh", "net-start", "default")
    run("sudo", "virsh", "net-autostart", "default")


# ---- the run ----


def groups_for(host: str) -> list[str]:
    special = {group for groups in HOSTS.values() for group in groups}
    return [g for g in PACKAGES if g not in special or g in HOSTS[host]]


def packages_for(host: str) -> set[str]:
    return {package for group in groups_for(host) for package in PACKAGES[group]}


def link_all(groups: list[str]) -> None:
    prune_links()
    skip = {"homeassistant"} if "k8s" in groups else {"homeassistant", "k9s"}
    for source, root in TREES:
        link_tree(source, root, skip)
    for path in (DOTFILES / name for name in PRIVATE):
        if path.exists() and path.stat().st_mode & 0o077:
            do(f"chmod 600 {path}", path.chmod, 0o600)


def set_up(groups: list[str]) -> None:
    for package in REMOVE:
        uninstall(package)
    if "luks" in groups:  # before its conf is copied: dracut needs the key
        setup_luks()
    copy_system_files(CUSTOM / "ROOT")
    if "k8s" in groups:
        copy_system_files(DOTFILES / "ROOT")
    for unit, group in UNITS.items():
        if group in groups:
            enable(unit)
    setup_common()
    if "docker" in groups:
        copy_homeassistant()
    if "virtwin" in groups:
        setup_virtwin()


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dry-run", "-n", action="store_true")
    parser.add_argument("--overwrite", "-o", action="store_true", help="don't ask")
    parser.add_argument("--reinstall", "-r", action="store_true", help="all packages")
    parser.parse_args(namespace=args)
    if HOSTNAME not in HOSTS:
        sys.exit(f"unknown host {HOSTNAME}: add it to HOSTS")
    if args.dry_run:
        sys.addaudithook(audit)
    link_all(groups_for(HOSTNAME))
    if install(packages_for(HOSTNAME)):  # the rest needs the packages
        set_up(groups_for(HOSTNAME))
    if failed:
        sys.exit("\n".join(["FAILED:", *failed]))
    print(f"Steps left to you: {DOTFILES / 'manual.md'}")


if __name__ == "__main__":
    main()
