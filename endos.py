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
from difflib import unified_diff
from os.path import lexists
from pathlib import Path
from shutil import rmtree
from subprocess import run
from urllib.request import urlretrieve

HOSTNAME = open("/etc/hostname").read().strip()
HOME_TGT = Path("~").expanduser()
ROOT_TGT = Path("/")
DOTFILES = HOME_TGT / "dotfiles"
HOME_SRC = DOTFILES / "HOME"
ROOT_SRC = DOTFILES / "ROOT"
CFG_TGT = HOME_TGT / ".config"
CFG_SRC = DOTFILES / "CONFIG"
CUSTOM_SRC = DOTFILES / f"custom-{HOSTNAME}"
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
        "git-delta",
        "starship",
        "zoxide",
        "bat",
    ),
    tmux=("tmux", "urlscan"),
    editors=(
        "neovim",
        "helix",
        "ripgrep",
        "npm",  # required for nvim plugins
        "go",  # required for vim-hexokinase build
    ),
    utils=("uv", "ncdu", "unzip", "jq", "bluetui"),
    gittools=(
        "tig",
        "diff-so-fancy",
        "git-secret",
        "git-delta",
        "git-lfs",
        "lazygit",
        "bat",
    ),
    readers=(
        "sioyek",
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
        "digikam",
        # music
        "quodlibet",
        "gst-plugins-good",  # required deb
        # audio
        "pamixer",
        "noisetorch",
    ),
    filebrowsers=(
        "yazi",
        "ranger",
        "pcmanfm",
        "thunar",
        "gparted",
        "sshfs",
        "file-roller",
        "7zip",  # explore zip files
        "zoxide",  # quick search
        "eza",  # pretty alternative to `ls`
        "glow",  # markdown renderer
    ),
    netbrowsers=(
        "qutebrowser",
        "firefox",
        "google-chrome",
        "microsoft-edge-stable-bin",
        "w3m",
        "python-adblock",  # for qutebrowser ad blocker
        "python-tldextract",
        "bitwarden-cli",  # for qutebrowser autofill
    ),
    chat=("discordo-git", "gurk"),
    emailcalrss=(
        "khard",  # contacts
        "khal",  # calendar
        "aerc",  # email
        "newsboat",  # rss reader
        "vdirsyncer",  # sync calendar+contacts
        "pandoc",  # md2html for aerc
        "pass",  # password manager for aerc and newsboat
        "w3m",  # terminal browser for aerc and newsboat
        "urlscan",  # url finder for newsboat
        "python-aiohttp-oauthlib",  # for google vdirsyncer
    ),
    monitors=(
        "htop",  # hardware
        "btop",  # hardware
        "nvtop",  # gpu
        "lazyjournal",  # journald
        "isd",  # systemd
        "bandwhich",  # network
        "sysstat",
    ),
    apps=("keepassxc", "bitwarden", "qalculate-gtk", "vesktop"),
    sway=(
        "xdg-terminal-exec",
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
        "docker-buildx",  # advanced build
        "qemu-user-static-binfmt",  # build arm64
        "qemu-user-static",  # build arm64
        "k9s",  # kubernetes tui
        "wireguard-tools",  # includes wg-quick
        "sops",  # secret mgmt
        "flux-bin",
        "open-iscsi",  # required by longhorn
        "kubectl-cnpg",
        # ssh for luks unlocking
        "dracut-crypt-ssh",
        "dropbear",
    ),
    virtwin=(
        "qemu-full",  # the emulator itself
        "libvirt",  # the backend manager - handles running qemu
        "virt-manager",  # the graphical dashboard
        "virt-viewer",  # the display window
        "iptables-nft",  # for using iptables instead of nft
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
            subpath = subsrc.relative_to(src)  # NOTE: dirty code!
            subtgt = tgt / subpath
            if subtgt.exists() and lexists(subtgt):
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
    helper_clone_foldercontents(CFG_SRC, CFG_TGT, "helix", overwrite)


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
    for plugin in [
        "yazi-rs/plugins:chmod",
        "yazi-rs/plugins:git",
        "yazi-rs/plugins:mount",
        "yazi-rs/plugins:piper",
        "yazi-rs/plugins:smart-enter",
        "yazi-rs/plugins:smart-filter",
        "yazi-rs/plugins:toggle-pane",
        "boydaihungst/file-extra-metadata",
    ]:
        run(f"ya pkg add {plugin}".split())
    tgt = ".local/share/applications/userapp-file-roller.desktop"
    helper_maybe_copy(HOME_SRC, HOME_TGT, tgt, overwrite, symlink=True)


def install_netbrowsers(overwrite: bool, reinstall: bool) -> None:
    helper_install(*installmap["netbrowsers"], reinstall=reinstall)
    helper_clone_foldercontents(CFG_SRC, CFG_TGT, "qutebrowser", overwrite)
    helper_maybe_copy(HOME_SRC, HOME_TGT, ".w3m/keymap", overwrite, symlink=True)
    (HOME_TGT / "Downloads").mkdir(exist_ok=True)


def install_chat(overwrite: bool, reinstall: bool) -> None:
    helper_install(*installmap["chat"], reinstall=reinstall)
    helper_clone_foldercontents(CFG_SRC, CFG_TGT, "discordo", overwrite)
    helper_clone_foldercontents(CFG_SRC, CFG_TGT, "gurk", overwrite)


def install_monitors(overwrite: bool, reinstall: bool) -> None:
    helper_install(*installmap["monitors"], reinstall=reinstall)
    helper_clone_foldercontents(CFG_SRC, CFG_TGT, "btop", overwrite)


def install_emailcalrss(overwrite: bool, reinstall: bool) -> None:
    helper_install(*installmap["emailcalrss"], reinstall=reinstall)
    for tgt in ["vdirsyncer", "khard", "khal", "aerc", "newsboat"]:
        helper_clone_foldercontents(CFG_SRC, CFG_TGT, tgt, overwrite)
    tgt = ".local/share/applications/userapp-khalimport.desktop"
    helper_maybe_copy(HOME_SRC, HOME_TGT, tgt, overwrite, symlink=True)
    run("systemctl enable --user --now vdirsyncer.timer".split())
    run(f"chmod 600 {CFG_TGT / 'aerc/accounts.conf'}".split())
    (HOME_TGT / ".cache/newsboat").mkdir(exist_ok=True)
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
        "mako",
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
    run("sudo usermod -aG libvirt $USER".split())
    run("sudo virsh net-start default".split())
    run("sudo virsh net-autostart default".split())
    run("systemctl enable --now libvirtd".split())


def install_k8sreqs(overwrite: bool, reinstall: bool) -> None:
    # sudo
    helper_install(*installmap["k8s"], reinstall=reinstall)
    run("sudo systemctl enable --now docker.service".split())
    sub = "etc/modules-load.d/br_netfilter.conf"
    run(["sudo", "cp", str(ROOT_SRC / sub), str(ROOT_TGT / sub)])
    run("sudo systemctl enable --now iscsid".split())
    # user
    helper_clone_foldercontents(CFG_SRC, CFG_TGT, "k9s", overwrite)
    # luks
    run("sudo mkdir -p /root/.ssh".split())
    run("sudo chmod 700 /root/.ssh".split())
    run("sudo touch /root/.ssh/authorized_keys".split())
    run("sudo chmod 600 /root/.ssh/authorized_keys".split())


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
    if HOSTNAME in ["mothership"]:
        helper_install(*installmap["docker"], reinstall=reinstall)
        install_virtwin(overwrite, reinstall)
        helper_clone_foldercontents(
            CFG_SRC, CFG_TGT, "homeassistant", overwrite, symlink=False
        )
        print("installed docker + home assistant")
    print("""
    MANUAL NEXT STEPS:

    # vdirsyncer
    - set up with google calendar using
      https://vdirsyncer.pimutils.org/en/stable/config.html#google
    - run `vdirsyncer discover` then `vdiscover sync`

    # firefox
    - allow windowed fullscreen by setting full-screen-api.ignore-widgets to
      true in about:config

    # coolercontrol
    - set coolercontrold log level to WARN: `sudo systemctl edit
      coolercontrold.service`

    # k8s
    - configure /etc/hosts
    - /etc/hosts: configure
    - /root/.ssh/authorized_keys: add permitted ssh keys
    - /etc/dracut.conf.d/crypt-ssh.conf: set port + 'unlock' helper
    - /etc/dracut.conf.d/eos-defaults.conf: don't omit network
    - /etc/kernel/cmdline: add `rd.neednet=1 ip=dhcp` arguments
    - `sudo dracut-rebuild`
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
