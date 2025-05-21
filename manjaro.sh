#!/bin/sh
set -e

# general
sudo systemctl enable --now sshd.service
sudo systemctl enable --now fstrim.timer
yay -S plymouth tldextract go nodejs unzip exa topgrade

# display manager
yay -S greetd qtgreet

# sway
yay -S manjaro-sway-settings swaytools swaylock pamac-tray-plasma unipicker mako ly wlsunset pcmanfm-qt wev gtklock idlehack sworkstyle foot
systemctl --now --user enable foot-server.socket
# systemctl --now --user enable foot-server
# systemctl --now --user enable idlehack
# systemctl --now --user enable sworkstyle
# systemctl --now --user enable pcmanfm

# nvidia
yay -S cuda nvidia-settings nvidia-docker

# python
yay -S python-pip pyenv ipython

# sound
yay -S manjaro-pipewire pavucontrol-qt

# theme
yay -S mint-themes mint-y-icons kvantum-theme-catppuccin-git catppuccin-gtk-theme-latte catppuccin-gtk-theme-mocha breeze-grub breeze-gtk breeze-icons
yay -S lxinput-gtk3 qt6ct pamac-gtk3

# terminal and shell
yay -S nushell oh-my-posh carapace-bin zoxide
chsh -s /usr/bin/nu
oh-my-posh init nu --config https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/refs/heads/main/themes/peru.omp.json

# code
yay -S neovim tmux tig diff-so-fancy ripgrep nvimpager urlscan
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
# git
yay -S git-secret git-delta git-lfs lazygit
# formatters
yay -S python-black python-blackdoc python-pyment python-isort \
    eslint_d eslint jq yamlfmt shfmt prettierd

# file sync
yay -S syncthings rclone dropbox
sudo systemctl edit syncthing@hjalmarlucius.service # uncomment AmbientCapabilities
sudo setcap CAP_CHOWN,CAP_FOWNER=pe /usr/bin/syncthing
sudo systemctl enable --now syncthing@hjalmarlucius.service
systemctl --user daemon-reload
rclone config # follow instructions and paste creds from https://console.cloud.google.com/apis/credentials
systemctl --now --user enable rclone-gdrive
systemctl --now --user enable dropbox

# docker incl non-root daemon
yay -S docker docker-compose dry-bin nvidia-docker docker-buildx
docker plugin install grafana/loki-docker-driver --alias loki --grant-all-permissions
sudo groupadd docker && sudo usermod -aG docker $USER
sudo systemctl enable --now containerd.service
sudo systemctl enable --now docker.service

# printer
yay -S manajaro-printer samsung-unified-driver-printer

# monitors
yay -S iftop btop nvtop lazyjournal isd

# pdf
yay -S sioyek zathura zathura-pdf-mupdf zathura-djvu zathura-ps

# fonts
yay -S noto-fonts-emoji ttf-hack

# coolercontrol
yay -S coolercontrol
sudo systemctl enable --now coolercontrold.service
sudo systemctl edit coolercontrold.service # set log level to WARN

# video streaming
yay -S vlc protobuf yt-dlp
yay -S castnow

# cal+email+contacts
yay -S khard aerc khal vdirsyncer python-aiohttp-oauthlib pandoc

# div applications
yay -S \
    vesktop \
    qimgview-git \
    firefox \
    font-manager \
    i3status \
    ncspot \
    qalculate-qt \
    qbittorrent \
    quodlibet \
    qutebrowser \
    rofi \
    steam \
    teamviewer \
    yazi

# firefox windowed fullscreen
# can be achieved by setting full-screen-api.ignore-widgets to true in about:config

wget -P ~/.local/share/fonts/ https://raw.githubusercontent.com/SUNET/static_sunet_se/refs/heads/master/fonts/Akkurat-Mono.otf
sudo mkdir -p /usr/share/backgrounds/ultrawide/
sudo wget -O rainbowsmoke.jpg -P /usr/share/backgrounds/ultrawide https://superultrawidewallpaper.com/wp-content/uploads/2022/02/rainbow-smoke-3840x1080-1860x523.jpg

# set up vdirsyncer with google calendar using
# https://vdirsyncer.pimutils.org/en/stable/config.html#google
