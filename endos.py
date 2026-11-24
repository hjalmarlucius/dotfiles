#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "defopt",
# ]
# ///
# TODO
# pre-luks remote ssh
# add ufw setup
# - sudo ufw allow 22/tcp comment "ssh"
# - sudo ufw default allow FORWARD
# - sudo ufw allow 2222
# - ... etc
# - sudo enable ufw
# TODO
# sudo sh -c 'echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf'; sudo rmmod pcspkr
from difflib import unified_diff
from getpass import getuser
from os.path import lexists
from pathlib import Path
from shutil import rmtree
from subprocess import run
from urllib.request import urlretrieve

HOSTNAME = open("/etc/hostname").read().strip()
HOME_TGT = Path.home()
ROOT_TGT = Path("/")
DOTFILES = Path(__file__).resolve().parent
HOME_SRC = DOTFILES / "HOME"
ROOT_SRC = DOTFILES / "ROOT"
CFG_TGT = HOME_TGT / ".config"
CFG_SRC = DOTFILES / "CONFIG"
CUSTOM_SRC = DOTFILES / f"custom-{HOSTNAME}"
USERNAME = getuser()
installmap = dict(
    fonts=(
        "noto-fonts-emoji",
        "ttf-hack",
        "font-manager",
    ),
    zsh=(
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
    tmux=("tmux", "urlscan"),
    editors=(
        "neovim",
        "ripgrep",
        "npm",  # required for nvim plugins
        "go",  # required for vim-hexokinase build
        "tree-sitter-cli",  # required for nvim treesitter
    ),
    utils=("uv", "gdu", "unzip", "jq", "bluetui"),
    gittools=(
        "tig",
        "diff-so-fancy",
        "git-secret",
        "git-delta",
        "git-lfs",
        "lazygit",
        "gnome-keyring",  # for git credentials
        "seahorse",  # keyring ui
    ),
    readers=(
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
    mediaviewers=(
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
    filebrowsers=(
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
    netbrowsers=(
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
    chat=("discord", "gurk"),
    emailcalrss=(
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
    monitors=(
        "htop",  # hardware
        "btop",  # hardware
        "nvtop",  # gpu
        "systemctl-tui",  # systemd
        "bandwhich",  # network
        "sysstat",
        "lm_sensors",  # waybar
    ),
    apps=("keepassxc", "bitwarden", "qalculate-gtk"),
    sway=(
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
    remotedata=("rclone", "dropbox", "minio-client"),
    screensharing=("wireplumber",),
    nvidia=("cuda", "nvidia-settings"),
    coolercontrol=("coolercontrol",),
    docker=(
        "docker",
        "dry-bin",  # docker tui
    ),
    k8s=(
        "docker",  # docker.service is enabled by install_k8sreqs
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
    surface=("squeekboard",),  # on-screen keyboard, sway on spro5
    luks=(  # unlock LUKS over ssh from the initramfs
        "dracut-crypt-ssh-git",
        "dropbear",
    ),
    virtwin=(
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
)


def compare(src: Path, tgt: Path) -> str:
    if src.is_dir():
        diff = ""
        for subsrc in src.glob("**/*"):
            if not subsrc.is_file():
                continue
            subtgt = tgt / subsrc.relative_to(src)
            if subtgt.exists():
                diff += compare(subsrc, subtgt)
        return diff
    else:
        srcdata = open(src).readlines() if src.exists() else []
        tgtdata = open(tgt).readlines() if tgt.exists() else []
        return "".join(unified_diff(srcdata, tgtdata, str(src), str(tgt)))


def helper_maybe_copy(
    src_folder: Path, tgt_folder: Path, sub: str, overwrite: bool, symlink: bool
) -> bool:
    src = src_folder.expanduser() / sub
    tgt = tgt_folder.expanduser() / sub
    assert src.exists()
    tgt.parent.mkdir(exist_ok=True, parents=True)
    if lexists(tgt):
        if not overwrite:
            if diff := compare(src, tgt):
                print("DIFF:\n" + diff)
                if input("overwrite? (y/n) ") == "n":
                    return False
        if tgt.is_file() or tgt.is_symlink():
            tgt.unlink()
        else:
            rmtree(str(tgt))
    if symlink:
        tgt.symlink_to(src)
    else:
        run(["cp", str(src), str(tgt)])
    return True


def helper_clone_foldercontents(
    src_parent: Path,
    tgt_parent: Path,
    folder: str,
    overwrite: bool,
    symlink: bool = True,
) -> None:
    src_folder = src_parent.expanduser() / folder
    tgt_folder = tgt_parent.expanduser() / folder
    tgt_folder.mkdir(exist_ok=True, parents=True)
    assert src_folder.is_dir()
    assert tgt_folder.is_dir() or tgt_folder.is_symlink()
    for src in src_folder.iterdir():
        name = src.name
        if name.endswith(".secret"):  # git-secret item
            continue
        helper_maybe_copy(src_folder, tgt_folder, name, overwrite, symlink=symlink)


def helper_check_if_installed(pkg: str) -> bool:
    return run(["pacman", "-Q", pkg], capture_output=True).returncode == 0


def helper_uninstall(*pkgs: str) -> None:
    for pkg in pkgs:
        run(["yay", "-Rns", pkg], capture_output=True)


def helper_install(*pkgs: str, reinstall: bool) -> None:
    for pkg in pkgs:
        if reinstall or not helper_check_if_installed(pkg):
            assert run(["yay", "-S", pkg]).returncode == 0


def install_fonts(reinstall: bool) -> None:
    tgt = Path("~/.local/share/fonts/Akkurat-Mono.otf").expanduser()
    tgt.parent.mkdir(exist_ok=True, parents=True)
    urlretrieve(
        "https://raw.githubusercontent.com/SUNET/static_sunet_se/refs/heads/master/fonts/Akkurat-Mono.otf",
        tgt,
    )
    helper_install(*installmap["fonts"], reinstall=reinstall)


def install_zsh(overwrite: bool, reinstall: bool) -> None:
    helper_install(*installmap["zsh"], reinstall=reinstall)
    helper_clone_foldercontents(CFG_SRC, CFG_TGT, "zsh", overwrite)
    helper_clone_foldercontents(CFG_SRC, CFG_TGT, "atuin", overwrite)
    run("chsh -s /usr/bin/zsh".split())
    helper_maybe_copy(CFG_SRC, CFG_TGT, "starship.toml", overwrite, symlink=True)
    helper_maybe_copy(HOME_SRC, HOME_TGT, ".zshenv", overwrite, symlink=True)
    helper_maybe_copy(HOME_SRC, HOME_TGT, ".local/bin/catai", overwrite, symlink=True)


def install_tmux(overwrite: bool, reinstall: bool) -> None:
    helper_install(*installmap["tmux"], reinstall=reinstall)
    helper_clone_foldercontents(CFG_SRC, CFG_TGT, "tmux", overwrite)
    tpmpath = CFG_TGT / "tmux/plugins/tpm"
    if overwrite or not lexists(tpmpath):
        if lexists(tpmpath):
            if tpmpath.is_symlink():
                tpmpath.unlink()
            else:
                rmtree(str(tpmpath))
        run(["git", "clone", "https://github.com/tmux-plugins/tpm", tpmpath])


def install_editors(overwrite: bool, reinstall: bool) -> None:
    helper_install(*installmap["editors"], reinstall=reinstall)
    helper_clone_foldercontents(CFG_SRC, CFG_TGT, "nvim", overwrite)


def install_gittools(overwrite: bool, reinstall: bool) -> None:
    helper_install(*installmap["gittools"], reinstall=reinstall)
    helper_clone_foldercontents(CFG_SRC, CFG_TGT, "tig", overwrite)
    helper_maybe_copy(HOME_SRC, HOME_TGT, ".gitconfig", overwrite, symlink=True)


def install_readers(overwrite: bool, reinstall: bool) -> None:
    helper_install(*installmap["readers"], reinstall=reinstall)
    helper_clone_foldercontents(CFG_SRC, CFG_TGT, "xournalpp", overwrite)
    helper_clone_foldercontents(CFG_SRC, CFG_TGT, "sioyek", overwrite)
    helper_clone_foldercontents(CFG_SRC, CFG_TGT, "zathura", overwrite)


def install_mediaviewers(reinstall: bool) -> None:
    helper_install(*installmap["mediaviewers"], reinstall=reinstall)


def install_filebrowsers(overwrite: bool, reinstall: bool) -> None:
    helper_install(*installmap["filebrowsers"], reinstall=reinstall)
    helper_clone_foldercontents(CFG_SRC, CFG_TGT, "ranger", overwrite)
    helper_clone_foldercontents(CFG_SRC, CFG_TGT, "yazi", overwrite)
    run(["ya", "pkg", "install"])  # plugins listed in CONFIG/yazi/package.toml


def install_netbrowsers(overwrite: bool, reinstall: bool) -> None:
    helper_install(*installmap["netbrowsers"], reinstall=reinstall)
    helper_clone_foldercontents(CFG_SRC, CFG_TGT, "qutebrowser", overwrite)
    helper_maybe_copy(HOME_SRC, HOME_TGT, ".w3m/keymap", overwrite, symlink=True)
    (HOME_TGT / "Downloads").mkdir(exist_ok=True)


def install_chat(overwrite: bool, reinstall: bool) -> None:
    helper_install(*installmap["chat"], reinstall=reinstall)
    helper_clone_foldercontents(CFG_SRC, CFG_TGT, "gurk", overwrite)


def install_monitors(overwrite: bool, reinstall: bool) -> None:
    helper_install(*installmap["monitors"], reinstall=reinstall)
    helper_clone_foldercontents(CFG_SRC, CFG_TGT, "btop", overwrite)


def install_emailcalrss(overwrite: bool, reinstall: bool) -> None:
    helper_install(*installmap["emailcalrss"], reinstall=reinstall)
    for tgt in ["vdirsyncer", "khard", "khal", "aerc"]:
        helper_clone_foldercontents(CFG_SRC, CFG_TGT, tgt, overwrite)
    run("systemctl enable --user --now vdirsyncer.timer".split())
    run(f"chmod 600 {CFG_TGT / 'aerc/accounts.conf'}".split())
    (HOME_TGT / "Calendars").mkdir(exist_ok=True)
    (HOME_TGT / "Contacts").mkdir(exist_ok=True)


def install_sway(overwrite: bool, reinstall: bool) -> None:
    helper_uninstall("autotiling", "cliphist")
    helper_install(*installmap["sway"], reinstall=reinstall)
    # sudo stuff
    for sub in [
        "etc/systemd/logind.conf.d/suspend.conf",
        "etc/systemd/sleep.conf.d/hibernate.conf",
        "etc/greetd/sway.cfg",
        "lib/systemd/system-sleep/iptsd.sh",
        "etc/dracut.conf.d/crypt-ssh.conf",
    ]:
        src = CUSTOM_SRC / "ROOT" / sub
        if not src.exists():
            continue
        tgt = ROOT_TGT / sub
        run(["sudo", "mkdir", "-p", str(tgt.parent)])
        if tgt.exists():
            if diff := compare(src, tgt):
                print("DIFF:\n" + diff)
                if input("overwrite? (y/n) ") == "n":
                    continue
            run(["sudo", "rm", str(tgt)])
        run(["sudo", "cp", str(src), str(tgt)])
    run("sudo systemctl enable --now bluetooth".split())
    # div app configs
    if (tgt := CFG_TGT / "waybar/config").exists():  # precedence over config.jsonc
        tgt.unlink()
    for sub in [
        "sway",
        "waybar",
        "gtklock",
        "gtk-3.0",
        "swaync",
        "fuzzel",
        "nwg-drawer",
        "xdg-desktop-portal-wlr",
        "foot",
        "xkb/symbols",
    ]:
        helper_clone_foldercontents(CFG_SRC, CFG_TGT, sub, overwrite)
    helper_maybe_copy(CFG_SRC, CFG_TGT, "xdg-terminals.list", overwrite, symlink=True)
    helper_maybe_copy(CFG_SRC, CFG_TGT, "mimeapps.list", overwrite, symlink=True)
    # custom sway configs
    helper_clone_foldercontents(CUSTOM_SRC / "CONFIG", CFG_TGT, "sway", overwrite)
    # custom waybar configs
    helper_clone_foldercontents(CUSTOM_SRC / "CONFIG", CFG_TGT, "waybar", overwrite)
    # desktop entries
    helper_clone_foldercontents(
        HOME_SRC,
        HOME_TGT,
        ".local/share/applications",
        overwrite,
    )


def configure_pytools(overwrite: bool) -> None:
    for sub in [".ipython/profile_default", ".jupyter"]:
        tgt = HOME_TGT / sub
        run(["mkdir", "-p", str(tgt)])
        helper_clone_foldercontents(HOME_SRC, HOME_TGT, sub, overwrite)


def install_virtwin(overwrite: bool, reinstall: bool) -> None:
    helper_install(*installmap["virtwin"], reinstall=reinstall)
    run(["sudo", "usermod", "-aG", "libvirt", USERNAME])
    run("sudo virsh net-start default".split())
    run("sudo virsh net-autostart default".split())
    run("sudo systemctl enable --now libvirtd".split())


def install_k8sreqs(overwrite: bool, reinstall: bool) -> None:
    # sudo
    helper_install(*installmap["k8s"], reinstall=reinstall)
    run("sudo systemctl enable --now docker.service".split())
    sub = "etc/modules-load.d/br_netfilter.conf"
    run(["sudo", "cp", str(ROOT_SRC / sub), str(ROOT_TGT / sub)])
    run("sudo systemctl enable --now iscsid".split())
    # user
    helper_clone_foldercontents(CFG_SRC, CFG_TGT, "k9s", overwrite)


def install_luks_unlock(reinstall: bool) -> None:
    """Packages, host key and key list for custom-<host>/.../crypt-ssh.conf.

    Runs before install_sway copies that file: the package owns the path,
    so pacman would refuse to install it over a copied file, and without
    the key every dracut rebuild would ship an initramfs without dropbear."""
    helper_install(*installmap["luks"], reinstall=reinstall)
    folder = "/etc/dracut-crypt-ssh"
    key = f"{folder}/ssh_host_ed25519_key"
    keys = f"{folder}/authorized_keys"  # may unlock; not root logins
    run(["sudo", "mkdir", "-p", folder], check=False)
    keygen = f"test -f {key} || ssh-keygen -q -t ed25519 -N '' -f {key}"
    run(["sudo", "sh", "-c", keygen], check=False)
    run(["sudo", "sh", "-c", f"touch {keys} && chmod 600 {keys}"], check=False)


def installer(
    *,
    overwrite: bool = False,
    reinstall: bool = False,
) -> None:
    install_fonts(reinstall)
    print("installed fonts")
    install_zsh(overwrite, reinstall)
    print("installed zsh")
    install_tmux(overwrite, reinstall)
    print("installed tmux")
    install_editors(overwrite, reinstall)
    print("installed editors")
    helper_install(*installmap["utils"], reinstall=reinstall)
    print("installed utils")
    install_gittools(overwrite, reinstall)
    print("installed gittools")
    install_readers(overwrite, reinstall)
    print("installed readers")
    install_mediaviewers(reinstall)
    print("installed mediaviewers")
    install_filebrowsers(overwrite, reinstall)
    print("installed filebrowsers")
    install_netbrowsers(overwrite, reinstall)
    print("installed netbrowsers")
    install_emailcalrss(overwrite, reinstall)
    print("installed emailcalrss")
    install_chat(overwrite, reinstall)
    print("installed chat")
    install_monitors(overwrite, reinstall)
    print("installed monitors")
    helper_install(*installmap["apps"], reinstall=reinstall)
    print("installed apps")
    if HOSTNAME in ["mothership", "droneship"]:
        install_luks_unlock(reinstall)
        print("installed luks unlock")
    install_sway(overwrite, reinstall)
    print("installed sway")
    helper_install(*installmap["remotedata"], reinstall=reinstall)
    print("installed remotedata")
    helper_install(*installmap["screensharing"], reinstall=reinstall)
    print("installed screensharing")
    configure_pytools(overwrite=overwrite)
    print("configured python tools")
    if HOSTNAME in ["mothership", "droneship"]:
        helper_install(*installmap["nvidia"], reinstall=reinstall)
        print("installed nvidia")
    if HOSTNAME in ["mothership", "droneship"]:
        install_k8sreqs(overwrite, reinstall)
        print("installed k8s requirements")
    if HOSTNAME in ["mothership", "droneship"]:
        helper_install(*installmap["coolercontrol"], reinstall=reinstall)
        run("sudo systemctl enable --now coolercontrold.service".split())
        print("installed coolercontrol")
    if HOSTNAME in ["sl3", "spro5"]:
        helper_install(*installmap["surface"], reinstall=reinstall)
    if HOSTNAME in ["mothership"]:
        helper_install(*installmap["docker"], reinstall=reinstall)
        install_virtwin(overwrite, reinstall)
        helper_clone_foldercontents(
            CFG_SRC, CFG_TGT, "homeassistant", overwrite, symlink=False
        )
        print("installed docker + home assistant")
    print("""
    MANUAL NEXT STEPS:

    # oom handling

    Add to `sudo systemctl edit user.slice`:
    ```
    [Slice]
    OOMScoreAdjust=500
    ```

    # vdirsyncer
    - set up with google calendar using
      https://vdirsyncer.pimutils.org/en/stable/config.html#google
    - run `vdirsyncer discover` then `vdirsyncer sync`

    # firefox
    - allow windowed fullscreen by setting full-screen-api.ignore-widgets to
      true in about:config

    # coolercontrol
    - set coolercontrold log level to WARN: `sudo systemctl edit
      coolercontrold.service`

    # k8s
    - /etc/hosts: configure
    - LUKS unlock over ssh: this script installs dracut-crypt-ssh, makes the
      host key and copies crypt-ssh.conf; add the public keys that may unlock
      to /etc/dracut-crypt-ssh/authorized_keys
    - /etc/dracut.conf.d/eos-defaults.conf: don't omit network
    - /etc/kernel/cmdline: add `rd.neednet=1 ip=dhcp` arguments
    - `sudo dracut-rebuild`, then test: reboot, `ssh -p 222 root@<host>`, `unlock`
    - run `hjarl-system/k8s.py` scripts

    # docker / home assistant
    - docker with non-root daemon 
      `sudo groupadd docker && sudo usermod -aG docker $USER`
    - run home assistant and music assistant scripts to start docker services

    # virtual machine
    - /etc/libvirt/network.conf: set `firewall_backend = "iptables"` and restart libvirtd
    - download windows + virtio driver ISOs
    - vm setup:
      - CPUs: Uncheck "Copy host CPU configuration" and select host-passthrough
      - Disk (IDE/SATA): Change the "Disk bus" to VirtIO
      - NIC (Network): Change "Device model" to virtio
      - Add Hardware: Click "Add Hardware" -> "Storage" -> Select "CDROM" -> select virtio driver iso
    """)


if __name__ == "__main__":
    import defopt

    defopt.run(installer)
