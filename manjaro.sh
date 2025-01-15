#!/bin/sh
set -e

# general
sudo systemctl enable --now sshd.service
sudo systemctl enable --now fstrim.timer
yay -S plymouth tldextract go nodejs unzip exa

# nvidia
yay -S cuda nvidia-settings nvidia-docker

# python
yay -S python-pip pyenv ipython

# sound
yay -S manjaro-pipewire pavucontrol

# terminal and shell
yay -S wezterm zsh urxvt-resize-font
chsh -s /usr/bin/zsh

# zsh setup
yay -S zsh-theme-powerlevel10k \
    zsh-git-prompt \
    zsh-autosuggestions \
    zsh-history-substring-search \
    zsh-syntax-highlighting

# code
yay -S neovim tmux tig diff-so-fancy ripgrep nvimpager
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
# git
yay -S git-secret git-delta git-lfs
# formatters
yay -S python-black python-blackdoc python-pyment python-isort \
    eslint_d eslint jq yamlfmt shfmt prettierd

# file sync
yay -S syncthings rclone
sudo systemctl edit syncthing@hjalmarlucius.service  # uncomment AmbientCapabilities
sudo setcap CAP_CHOWN,CAP_FOWNER=pe /usr/bin/syncthing
sudo systemctl enable --now syncthing@hjalmarlucius.service
systemctl --user daemon-reload
rclone config  # follow instructions and paste creds from https://console.cloud.google.com/apis/credentials
systemctl --user enable --now rclone-gdrive.service

# docker incl non-root daemon
yay -S docker docker-compose dry-bin nvidia-docker docker-buildx
docker plugin install grafana/loki-docker-driver --alias loki --grant-all-permissions
sudo groupadd docker && sudo usermod -aG docker $USER
sudo systemctl enable --now containerd.service
sudo systemctl enable --now docker.service

# printer
yay -S manajaro-printer samsung-unified-driver-printer

# monitors
yay -S iftop bpytop nvtop

# pdf
yay -S sioyek zathura zathura-pdf-mupdf zathura-djvu zathura-ps

# fonts
yay -S noto-fonts-emoji ttf-hack

# browser

# zerotier
yay -S zerotier-one
sudo systemctl enable --now zerotier-one.service
sudo zerotier-cli join d5e5fb653797795b

# coolercontrol
yay -S coolercontrol
sudo systemctl enable --now coolercontrold.service
sudo systemctl edit coolercontrold.service # set log level to WARN

# video streaming
yay -S vlc protobuf yt-dlp
yay -S castnow

# div applications
yay -S i3status \
    qutebrowser \
    firefox \
    rofi \
    mutt \
    redshift \
    discord \
    teamviewer \
    zerotier-one \
    qalculate \
    quodlibet \
    ncspot \
    steam \
    qbittorrent

# firefox windowed fullscreen
# can be achieved by setting full-screen-api.ignore-widgets to true in about:config
