#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "defopt",
# ]
# ///
# TODO
# add or deprecate
# - ROOT/etc/[greetd|qtgreet]
# - ROOT/usr/local/bin/start-sway
# - custom-droneship
# - custom-mothership
# - homeassistant + musicassistant
# - environment.d
# - HOME/.profile
# - waybar
# - mypy
# - mako
# - helix
# - nushell
from difflib import unified_diff
from os.path import lexists
from pathlib import Path
from subprocess import run
from urllib.request import urlretrieve

HOME = Path("~").expanduser()
CFG = HOME / ".config"
DOTFILES = HOME / "dotfiles"
CUSTOMDIR = DOTFILES / f"custom-{open('/etc/hostname').read().strip()}"
installmap = dict(
    fonts=("noto-fonts-emoji", "ttf-hack", "font-manager"),
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
    ),
    tmux=("tmux", "urlscan"),
    nvim=("neovim", "ripgrep"),
    utils=("uv", "bat", "ncdu", "unzip", "jq"),
    gittools=("tig", "diff-so-fancy", "git-secret", "git-delta", "git-lfs", "lazygit"),
    pdftools=("sioyek", "zathura", "zathura-pdf-mupdf", "zathura-djvu", "zathura-ps"),
    media=("vlc", "mpv", "protobuf", "yt-dlp", "quodlibet", "qimgv"),
    filebrowsers=("pcmanfm", "yazi", "ranger", "zoxide", "eza"),
    netbrowsers=(
        "qutebrowser",
        "firefox",
        "python-adblock",
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
        "btop",  # hardware
        "nvtop",  # gpu
        "lazyjournal",  # journald
        "isd",  # systemd
        "bandwhich",  # network
    ),
    apps=("bitwarden", "qalculate-gtk", "vesktop"),
    swaytools=(
        "flashfocus",  # quick flash when changing app in focus
        "noisetorch",  # noise cancellation
        "unipicker",  # unicode symbol selector
        "wl-clip-persist",  # keep clipboard after close
        "wlsunset",  # eye saver
        "blueman",  # bluetooth
        "wdisplays",  # ui for display settings
        "wev",  # debugging of ui
        "gtklock",  # lock screen
    ),
    remotedata=("rclone", "dropbox", "minio-client"),
    screensharing=(
        "wireplumber",
        "xdg-desktop-portal",
        "xdg-desktop-portal-wlr",
    ),
    optional_nvidia=("cuda", "nvidia-settings"),
    optional_coolercontrol=("coolercontrol",),
    optional_containers=(
        "docker",
        "docker-compose",
        "docker-buildx",  # advanced build
        "qemu-user-static-binfmt",  # build arm64
        "qemu-user-static",  # build arm64
        "dry-bin",  # docker tui
        "k9s",  # kubernetes tui
    ),
    optional_nvidia_containers=("nvidia-docker",),
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


def helper_maybe_symlink(src: Path, tgt: Path, overwrite: bool) -> bool:
    src = src.expanduser()
    tgt = tgt.expanduser()
    tgt.parent.mkdir(exist_ok=True)
    if lexists(tgt):
        if not overwrite:
            if diff := compare(src, tgt):
                print("DIFF:\n" + diff)
                if input("overwrite? (y/n) ") == "n":
                    return False
        if tgt.is_file() or tgt.is_symlink():
            tgt.unlink()
        else:
            tgt.rmdir()
    tgt.symlink_to(src)
    return True


def helper_symlink_contents(
    src_folder: Path, tgt_folder: Path, overwrite: bool
) -> None:
    src_folder = src_folder.expanduser()
    tgt_folder = tgt_folder.expanduser()
    tgt_folder.mkdir(exist_ok=True)
    assert src_folder.is_dir()
    assert tgt_folder.is_dir() or tgt_folder.is_symlink()
    for src in src_folder.iterdir():
        if src.name.endswith(".secret"):  # git-secret item
            continue
        helper_maybe_symlink(src, tgt_folder / src.name, overwrite)


def helper_check_if_installed(pkg: str) -> bool:
    return run(["yay", "-Qs", pkg], capture_output=True).returncode == 0


def helper_uninstall(*pkgs: str) -> None:
    for pkg in pkgs:
        run(["yay", "-Rns", pkg], capture_output=True)


def helper_install(*pkgs: str, reinstall: bool) -> None:
    for pkg in pkgs:
        if reinstall or not helper_check_if_installed(pkg):
            assert run(["yay", "-S", pkg]).returncode == 0


def install_fonts(reinstall: bool) -> None:
    urlretrieve(
        "https://raw.githubusercontent.com/SUNET/static_sunet_se/refs/heads/master/fonts/Akkurat-Mono.otf",
        Path("~/.local/share/fonts/Akkurat-Mono.otf").expanduser(),
    )
    helper_install(*installmap["fonts"], reinstall=reinstall)


def install_zsh(overwrite: bool, reinstall: bool) -> None:
    helper_install(*installmap["zsh"], reinstall=reinstall)
    helper_symlink_contents(DOTFILES / "zsh", CFG / "zsh", overwrite)
    run("sudo chsh -s /usr/bin/zsh".split())
    helper_maybe_symlink(DOTFILES / "starship.toml", CFG / "starship.toml", overwrite)
    helper_maybe_symlink(DOTFILES / "HOME/.zshenv", HOME / ".zshenv", overwrite)
    helper_maybe_symlink(
        DOTFILES / "atuin/config.toml", CFG / "atuin/config.toml", overwrite
    )


def install_tmux(overwrite: bool, reinstall: bool) -> None:
    helper_install(*installmap["tmux"], reinstall=reinstall)
    helper_symlink_contents(DOTFILES / "tmux", CFG / "tmux", overwrite)
    tpmpath = CFG / "tmux/plugins/tpm"
    if overwrite or not lexists(tpmpath):
        if lexists(tpmpath):
            if tpmpath.is_symlink():
                tpmpath.unlink()
            else:
                tpmpath.rmdir()
        run(["git", "clone", "https://github.com/tmux-plugins/tpm", tpmpath])


def install_nvim(overwrite: bool, reinstall: bool) -> None:
    helper_install(*installmap["nvim"], reinstall=reinstall)
    helper_symlink_contents(DOTFILES / "nvim", CFG / "nvim", overwrite)


def install_gittools(overwrite: bool, reinstall: bool) -> None:
    helper_install(*installmap["gittools"], reinstall=reinstall)
    helper_symlink_contents(DOTFILES / "tig", CFG / "tig", overwrite)
    helper_maybe_symlink(DOTFILES / "HOME/.gitconfig", Path("~/.gitconfig"), overwrite)


def install_pdftools(overwrite: bool, reinstall: bool) -> None:
    helper_install(*installmap["pdftools"], reinstall=reinstall)
    helper_symlink_contents(DOTFILES / "sioyek", CFG / "sioyek", overwrite)
    helper_symlink_contents(DOTFILES / "zathura", CFG / "zathura", overwrite)


def install_filebrowsers(overwrite: bool, reinstall: bool) -> None:
    helper_install(*installmap["filebrowsers"], reinstall=reinstall)
    helper_symlink_contents(DOTFILES / "ranger", CFG / "ranger", overwrite)
    helper_symlink_contents(DOTFILES / "yazi", CFG / "yazi", overwrite)
    for plugin in [
        "chmod",
        "git",
        "mount",
        "piper",
        "smart-enter",
        "smart-filter",
        "toggle-pane",
    ]:
        run(f"ya pkg add yazi-rs/plugins:{plugin}".split())


def install_chat(overwrite: bool, reinstall: bool) -> None:
    helper_install(*installmap["chat"], reinstall=reinstall)
    helper_symlink_contents(DOTFILES / "discordo", CFG / "discordo", overwrite)
    helper_symlink_contents(DOTFILES / "gurk", CFG / "gurk", overwrite)


def install_emailcalrss(overwrite: bool, reinstall: bool) -> None:
    helper_install(*installmap["emailcalrss"], reinstall=reinstall)
    for tgt in ["vdirsyncer", "khard", "khal", "aerc", "newsboat"]:
        helper_symlink_contents(DOTFILES / tgt, CFG / tgt, overwrite)
    for sub in [".local/share/applications/userapp-khalimport.des", ".w3m/keymap"]:
        helper_maybe_symlink(DOTFILES / "HOME" / sub, HOME / sub, overwrite)
    run(f"chmod 600 {CFG / 'aerc/accounts.conf'}".split())


def install_swaytools(overwrite: bool, reinstall: bool) -> None:
    helper_install(*installmap["swaytools"], reinstall=reinstall)
    for base in [DOTFILES, CUSTOMDIR]:
        sub = "sway/config.d"
        helper_symlink_contents(base / sub, CFG / sub, overwrite)
        run("sudo systemctl enable --now bluetooth".split())
    for sub in [
        "etc/systemd/logind.conf.d/suspend.conf",
        "etc/systemd/sleep.conf.d/hibernate.conf",
    ]:
        run(["sudo", "cp", str(DOTFILES / "ROOT" / sub), str(Path("/") / sub)])
    run("sudo systemctl enable --now bluetooth".split())


def configure_pytools(overwrite: bool) -> None:
    for sub in [".ipython/profile_default", ".jupyter"]:
        helper_symlink_contents(DOTFILES / "HOME" / sub, HOME / sub, overwrite)


def configure_foot(overwrite: bool) -> None:
    helper_symlink_contents(DOTFILES / "foot", CFG / "foot", overwrite)


def installer(
    overwrite: bool = False,
    reinstall: bool = False,
    with_gpu: bool = False,
    with_containers: bool = False,
    with_coolercontrol: bool = False,
) -> None:
    if helper_check_if_installed("cliphist"):
        helper_uninstall("cliphist")
        print("removed cliphist")
    install_fonts(reinstall)
    print("installed fonts")
    install_zsh(overwrite, reinstall)
    print("installed zsh")
    install_tmux(overwrite, reinstall)
    print("installed tmux")
    install_nvim(overwrite, reinstall)
    print("installed nvim")
    helper_install(*installmap["utils"], reinstall=reinstall)
    print("installed utils")
    install_gittools(overwrite, reinstall)
    print("installed gittools")
    install_pdftools(overwrite, reinstall)
    print("installed pdftools")
    helper_install(*installmap["media"], reinstall=reinstall)
    print("installed media")
    install_filebrowsers(overwrite, reinstall)
    print("installed filebrowsers")
    helper_install(*installmap["netbrowsers"], reinstall=reinstall)
    print("installed netbrowsers")
    install_emailcalrss(overwrite, reinstall)
    print("installed emailcalrss")
    install_chat(overwrite, reinstall)
    print("installed chat")
    helper_install(*installmap["monitors"], reinstall=reinstall)
    print("installed monitors")
    helper_install(*installmap["apps"], reinstall=reinstall)
    print("installed apps")
    install_swaytools(overwrite, reinstall)
    print("installed sway")
    helper_install(*installmap["remotedata"], reinstall=reinstall)
    print("installed remotedata")
    helper_install(*installmap["screensharing"], reinstall=reinstall)
    print("installed screensharing")
    configure_pytools(overwrite=overwrite)
    print("configured python tools")
    configure_foot(overwrite=overwrite)
    print("configured foot")
    if with_gpu:
        helper_install(*installmap["optional_nvidia"], reinstall=reinstall)
        print("installed nvidia")
    if with_containers:
        helper_install(*installmap["optional_containers"], reinstall=reinstall)
        run("sudo systemctl enable --now docker.service".split())
        helper_symlink_contents(DOTFILES / "k9s", CFG / "k9s", overwrite)
        print("installed containers")
    if with_gpu and with_containers:
        helper_install(*installmap["optional_nvidia_containers"], reinstall=reinstall)
        print("installed nvidia containers")
    if with_coolercontrol:
        helper_install(*installmap["optional_coolercontrol"], reinstall=reinstall)
        run("sudo systemctl enable --now coolercontrold.service".split())
        print("installed coolercontrol")
    print("""
    MANUAL NEXT STEPS:

    set up vdirsyncer with google calendar using
    https://vdirsyncer.pimutils.org/en/stable/config.html#google

    allow firefox windowed fullscreen by setting full-screen-api.ignore-widgets
    to true in about:config

    set coolercontrold log level to WARN:
    `sudo systemctl edit coolercontrold.service`

    docker with non-root daemon
    `sudo groupadd docker && sudo usermod -aG docker $USER`
    """)


if __name__ == "__main__":
    import defopt

    defopt.run(installer)
