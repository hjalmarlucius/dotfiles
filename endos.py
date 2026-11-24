#!/usr/bin/env python3
"""Install the owner's dotfiles and packages on this host (see manual.md too).

--dry-run shows what a run would do and changes nothing. Every change goes
through run() or do(), and in a dry run audit() stops anything that doesn't.
--check only checks SSH unlock (mothership, droneship), and offers repairs.
"""

import argparse
import os
import pwd
import re
import shlex
import shutil
import subprocess
import sys
import tomllib
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
    "~/.cache/newsboat": "made by endos.py for newsboat",
    "~/.config/sway/config.d": "EndeavourOS default, not used by our sway config",
    "~/.local/share/applications/userapp-khalimport.des": "misspelt link 2025-10",
    "/lib/systemd/system-sleep/iptsd-hack.sh": "installed by hand, now iptsd.sh",
}
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
    ("pacman", "-Qqtt"),
    ("pacman", "-T"),
    ("ssh-keygen", "-l"),
    ("systemctl", "is-enabled"),
    ("systemctl", "--user", "is-enabled"),
)

# SSH unlock: mothership and droneship
CRYPT_CONF = Path("etc/dracut.conf.d/crypt-ssh.conf")
HOST_KEY = "/etc/dracut-crypt-ssh/ssh_host_ed25519_key"
UNLOCK_KEYS = Path("/etc/dracut-crypt-ssh/authorized_keys")  # no root logins
CMDLINE = Path("/etc/kernel/cmdline")
BOOT_ENTRIES = "/efi/loader/entries"

args = argparse.Namespace(dry_run=False, overwrite=False, reinstall=False, check=False)
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


def query(*cmd: str, cwd: Path = DOTFILES, text: str | None = None) -> str:
    """Output of a command that only reads."""
    assert is_query(cmd), cmd
    result = subprocess.run(
        cmd, cwd=cwd, input=text, stdout=subprocess.PIPE, text=True, check=False
    )
    return result.stdout


def read_as_root(*cmd: str) -> str | None:
    """The same with sudo, which a dry run doesn't use."""
    assert cmd[0] in ("cat", "grep", "lsinitrd"), cmd
    if args.dry_run:
        print("! not read, as it needs sudo:", shlex.join(cmd))
        return None
    result = subprocess.run(
        ("sudo", *cmd),
        stdout=subprocess.PIPE,
        text=True,
        errors="replace",
        check=False,
    )
    return result.stdout


def run(*cmd: str | Path, text: str | None = None) -> bool:
    """Run a command that changes something, with text as its input."""
    output = None if text is None else subprocess.DEVNULL
    line = shlex.join(map(str, cmd))
    return do(
        line, subprocess.run, cmd, input=text, stdout=output, text=True, check=True
    )


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


def choose(question: str, options: dict[str, str]) -> list[str]:
    """Some of the options (name: description), by name or number."""
    for number, (name, description) in enumerate(options.items(), 1):
        print(f"  {number}. {name}: {description}")
    if args.dry_run:
        print("? would ask:", question)
        return list(options)
    answer = input(f"{question} (names, numbers or all; default none) ").split()
    if answer == ["all"]:
        return list(options)
    return [n for i, n in enumerate(options, 1) if n in answer or str(i) in answer]


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


def show_diff(src: Path, tgt: Path) -> None:
    try:
        old, new = (p.read_text().splitlines(keepends=True) for p in (tgt, src))
    except (OSError, UnicodeDecodeError) as err:
        print("! cannot compare:", err)
        return
    if src.with_name(src.name + ".secret").exists():
        print("a git-secret file: the differences are not shown")
    else:
        print("".join(unified_diff(old, new, str(tgt), str(src))))


def may_replace(src: Path, tgt: Path) -> bool:
    show_diff(src, tgt)
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
        for name in list_files(source, "--others", "--directory", "--exclude-standard"):
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
    units = False
    for rel in tracked(source):
        src, tgt = source / rel, Path("/") / rel
        if same(src, tgt) or rel == CRYPT_CONF:  # see check_unlock()
            continue
        if not os.path.lexists(tgt) or may_replace(src, tgt):
            mode = f"{src.stat().st_mode & 0o777:o}"
            run("sudo", "install", "-D", "-m", mode, src, tgt)
            units |= rel.is_relative_to("etc/systemd/system")
    if units:
        run("sudo", "systemctl", "daemon-reload")


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


def clean_up() -> None:
    unneeded = query("pacman", "-Qqtt").split()  # not used by another package
    present = {}
    for name, reason in CLEANUP.items():
        if name.startswith(("~/", "/")):
            found = os.path.lexists(clean_path(name))
        elif name.endswith(".service"):
            found = query("systemctl", "--user", "is-enabled", name).strip()
            found = found == "enabled"
        else:
            found = name in unneeded
        if found:
            present[name] = reason
    if present:
        print("Leftovers:")
        for name in choose("remove which?", present):
            remove_leftover(name)


def clean_path(name: str) -> Path:
    return HOME / name[2:] if name.startswith("~/") else Path(name)


def remove_leftover(name: str) -> None:
    path = clean_path(name)
    if name.endswith(".service"):
        run("systemctl", "--user", "disable", "--now", name)
    elif not name.startswith(("~/", "/")):
        run("yay", "-Rns", name)
    elif name.startswith("/"):
        if path.is_symlink():
            run("sudo", "rm", path)
        elif run("sudo", "chmod", "a-x", path):
            run("sudo", "mv", "--backup=numbered", path, f"{path}.endos-bak")
    elif into_checkout(path):
        do(f"remove the link {path}", path.unlink)
    elif path.is_dir() and not path.is_symlink() and not any(path.iterdir()):
        do(f"remove the empty folder {path}", path.rmdir)
    else:
        set_aside(path)


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
    setup_yazi()
    for folder in (HOME / "Downloads", HOME / "Calendars", HOME / "Contacts"):
        if not folder.is_dir():
            do(f"make folder {folder}", folder.mkdir)
    waybar = CFG / "waybar/config"  # EndeavourOS's; hides our config.jsonc
    if os.path.lexists(waybar):
        set_aside(waybar)
    enable("vdirsyncer.timer", (), "--user")


def setup_yazi() -> None:
    """Install the plugins in CONFIG/yazi/package.toml, in a folder of their own:
    older versions linked it to the checkout."""
    plugins, old = CFG / "yazi/plugins", DOTFILES / "CONFIG/yazi/plugins"
    linked = into_checkout(plugins)
    if linked:
        do(f"remove the folder link {plugins}", plugins.unlink)
    if not run("ya", "pkg", "install") and linked and not plugins.exists():
        do(f"link {plugins} -> {old} again", plugins.symlink_to, old)
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
        print(f"! {old} is kept; not in package.toml: {sorted(unknown)}")
        print(f"  not installed: {sorted(missing)}")
    elif confirm(f"remove {old}, now that {plugins} replaces it?"):
        do(f"remove {old}", shutil.rmtree, old)


def join_group(group: str) -> None:
    user = pwd.getpwuid(os.getuid()).pw_name
    if group not in query("id", "-nG", user).split():
        run("sudo", "usermod", "-aG", group, user)


def setup_virtwin() -> None:
    join_group("libvirt")
    if not os.path.exists("/sys/class/net/virbr0"):
        run("sudo", "virsh", "net-start", "default")
    run("sudo", "virsh", "net-autostart", "default")


# ---- SSH unlock ----


def write_as_root(path: Path, text: str) -> bool:
    """Write a file in /, keeping the old one as .endos-bak."""
    backup = ("sudo", "cp", "-a", "--backup=numbered", path, f"{path}.endos-bak")
    kept = run(*backup) if path.exists() else True
    return kept and run("sudo", "tee", path, text=text)


def make_host_key() -> bool:
    keygen = f"ssh-keygen -q -t ed25519 -N '' -f {HOST_KEY}"
    public = f"ssh-keygen -y -f {HOST_KEY} > {HOST_KEY}.pub"
    steps = f"mkdir -p {UNLOCK_KEYS.parent}; test -f {HOST_KEY} || {keygen}; "
    return run("sudo", "sh", "-ec", f"{steps}test -f {HOST_KEY}.pub || {public}")


def key_lines(text: str) -> list[str]:
    lines = (line.strip() for line in text.splitlines())
    return [line for line in lines if line and not line.startswith("#")]


def has_unlock_keys() -> bool:
    """Whether a key may unlock. The size says enough once the conf is in place."""
    if not UNLOCK_KEYS.exists() or UNLOCK_KEYS.stat().st_size == 0:
        return False
    if args.dry_run or (
        not args.check and same(CUSTOM / "ROOT" / CRYPT_CONF, "/" / CRYPT_CONF)
    ):
        return True
    return bool(key_lines(read_as_root("cat", str(UNLOCK_KEYS)) or ""))


def add_unlock_keys() -> bool:
    """Let the owner pick from the keys that may log in as root or as the user."""
    texts = [read_as_root("cat", "/root/.ssh/authorized_keys") or ""]
    own = HOME / ".ssh/authorized_keys"
    if own.exists():
        texts.append(own.read_text())
    keys = {}
    for line in key_lines("\n".join(texts)):
        # 256 SHA256:... comment (ED25519)
        info = query("ssh-keygen", "-l", "-f", "-", text=line + "\n").split()
        if len(info) > 1 and info[1].startswith("SHA256:"):
            keys[info[1]] = (" ".join(info[2:]), line)
    if not keys:
        print("! no public keys found to choose from; see manual.md")
        return False
    names = choose("which may unlock?", {name: keys[name][0] for name in keys})
    if not names:
        return False
    text = "".join(f"{keys[name][1]}\n" for name in names)
    return write_as_root(UNLOCK_KEYS, text) and run("sudo", "chmod", "600", UNLOCK_KEYS)


OMITS = re.compile(r"^\s*omit_dracutmodules\+?=.*$", re.MULTILINE)
NETWORK = re.compile(r"(?<![\w-])(network|crypt-ssh)(?![\w-])")


def without_network(conf: str) -> str:
    """The text of a dracut conf, not omitting the modules that unlocking needs."""
    return OMITS.sub(lambda line: NETWORK.sub("", line[0]), conf)


def keep_network() -> bool:
    written = [
        write_as_root(path, without_network(path.read_text()))
        for path in dracut_confs()
        if without_network(path.read_text()) != path.read_text()
    ]
    return all(written)


def dracut_confs() -> list[Path]:
    confs = [Path("/etc/dracut.conf"), *Path("/etc/dracut.conf.d").glob("*.conf")]
    return [path for path in confs if path.exists()]


def with_network(cmdline: str) -> str:
    """The kernel arguments, with those that bring up the network added."""
    has = cmdline.split()
    missing = [] if "rd.neednet=1" in has else ["rd.neednet=1"]
    if not any(argument.startswith("ip=") for argument in has):
        missing.append("ip=dhcp")
    return " ".join([cmdline.rstrip("\n"), *missing]) + "\n" if missing else cmdline


def entries_ok() -> bool | None:
    """Whether the boot entries of this system have the network arguments."""
    machine = Path("/etc/machine-id").read_text().strip()
    found = read_as_root(
        "grep", "-rh", f"--include={machine}-*.conf", "^options", BOOT_ENTRIES
    )
    return (
        all(with_network(line) == line for line in found.splitlines())
        if found
        else None
    )


def image_ok(version: str) -> bool | None:
    """Whether the initramfs of a kernel can be unlocked over SSH."""
    image = ("lsinitrd", "--kver", version)
    listing = read_as_root(*image)
    if not listing:
        return None
    conf = read_as_root(*image, "--file", "etc/crypt-ssh.conf") or ""
    keys = read_as_root(*image, "--file", "root/.ssh/authorized_keys") or ""
    wanted = read_as_root("cat", str(UNLOCK_KEYS)) or ""
    fingerprint = query("ssh-keygen", "-l", "-f", f"{HOST_KEY}.pub").split()[1:2]
    return (
        "/dropbear" in listing
        and "etc/dropbear/dropbear_ed25519_host_key" in listing
        and "dropbear_port='222'" in conf
        and bool(fingerprint)
        and fingerprint[0] in conf
        and bool(key_lines(wanted))
        and key_lines(keys) == key_lines(wanted)
    )


def item(
    what: str, ok: bool | None, fix: Callable | None = None, how: str = ""
) -> bool:
    """Show the result of a check, and offer to fix what is wrong."""
    print({True: "ok:", False: "PROBLEM:", None: "unknown:"}[ok], what)
    if ok is False and fix and confirm(f"{how}?"):
        ok = fix()
    if not ok and args.check and not args.dry_run:
        failed.append(what)
    return ok is True


def check_unlock() -> None:
    """Set up what is missing. The conf only goes in with a key that may unlock:
    without one, the next kernel update would lock the owner out."""
    source, conf = CUSTOM / "ROOT" / CRYPT_CONF, "/" / CRYPT_CONF
    packages = set(PACKAGES["luks"])
    ready = [
        item(
            "dracut-crypt-ssh and dropbear are installed",
            not query("pacman", "-T", *sorted(packages)).split(),
            lambda: install(packages),
            "install them",
        ),
        item(
            "the host key exists",
            os.path.exists(HOST_KEY) and os.path.exists(f"{HOST_KEY}.pub"),
            make_host_key,
            "make it",
        ),
        item(
            f"{UNLOCK_KEYS} has a key",
            has_unlock_keys(),
            add_unlock_keys,
            "choose keys",
        ),
        item(
            "dracut doesn't omit the network or crypt-ssh",
            all(
                without_network(p.read_text()) == p.read_text() for p in dracut_confs()
            ),
            keep_network,
            "don't omit them",
        ),
        item(
            f"{CMDLINE} has rd.neednet=1 and ip=",
            with_network(CMDLINE.read_text()) == CMDLINE.read_text(),
            lambda: write_as_root(CMDLINE, with_network(CMDLINE.read_text())),
            "add rd.neednet=1 ip=dhcp",
        ),
    ]
    if not all(ready):
        print(f"{conf} and the initramfs are left alone until these are in place")
        return
    if not same(source, conf) and conf.exists():
        show_diff(source, conf)
    copy = ("sudo", "install", "-D", "-m", "644", source, conf)
    how = "install it (it takes effect at the next kernel update or rebuild)"
    ready = item(f"{conf} is ours", same(source, conf), lambda: run(*copy), how)
    if not ready or not args.check:
        return
    if check_boot() and confirm("rebuild the boot entries and every initramfs?"):
        failed.clear()
        if run("sudo", "reinstall-kernels") and not args.dry_run:
            check_boot()


def check_boot() -> bool:
    """Whether there is a problem that a rebuild may fix."""
    results = {"the boot entries have rd.neednet=1 and ip=": entries_ok()}
    for path in sorted(Path("/usr/lib/modules").glob("*/pkgbase")):
        version = path.parent.name
        what = f"the initramfs of {version} has dropbear and our keys"
        results[what] = image_ok(version)
    for what, ok in results.items():
        item(what, ok)
    return False in results.values()


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
    if "luks" in groups:
        check_unlock()
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
    clean_up()


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dry-run", "-n", action="store_true")
    parser.add_argument("--overwrite", "-o", action="store_true", help="don't ask")
    parser.add_argument("--reinstall", "-r", action="store_true", help="all packages")
    parser.add_argument("--check", "-c", action="store_true", help="SSH unlock only")
    parser.parse_args(namespace=args)
    if HOSTNAME not in HOSTS:
        sys.exit(f"unknown host {HOSTNAME}: add it to HOSTS")
    if args.dry_run:
        sys.addaudithook(audit)
    groups = groups_for(HOSTNAME)
    if args.check:
        if "luks" in groups:
            check_unlock()
    else:
        link_all(groups)
        if install(packages_for(HOSTNAME)):  # the rest needs the packages
            set_up(groups)
    if failed:
        sys.exit("\n".join(["FAILED:", *failed]))
    print(f"Steps left to you: {DOTFILES / 'manual.md'}")


if __name__ == "__main__":
    main()
