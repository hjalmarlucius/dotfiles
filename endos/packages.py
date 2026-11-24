"""The packages of each host."""

import gate

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


def groups_for(host: str) -> list[str]:
    special = {group for groups in HOSTS.values() for group in groups}
    return [g for g in PACKAGES if g not in special or g in HOSTS[host]]


def packages_for(host: str) -> set[str]:
    return {package for group in groups_for(host) for package in PACKAGES[group]}


def install(packages: set[str]) -> bool:
    missing = sorted(packages)
    if not gate.args.reinstall:  # -T prints those that nothing installed provides
        missing = gate.query("pacman", "-T", *missing).split()
    return not missing or gate.run("yay", "-S", *missing)
