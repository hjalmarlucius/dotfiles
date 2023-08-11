#!/bin/sh
set -e

# general
sudo systemctl enable --now sshd.service
sudo systemctl enable --now fstrim.timer
yay plymouth tldextract go nodejs unzip exa

# nvidia
yay cuda nvidia-settings nvidia-docker

# python
yay python-pip pyenv ipython

# sound
yay manjaro-pipewire pavucontrol

# terminal and shell
yay kitty fish
chsh -s /usr/bin/fish

# code
yay neovim tig stylua tmux diff-so-fancy ripgrep prettier jq git-lfs git-secret shfmt yq glow nvimpager git-delta
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm

# file sync
yay syncthings rclone
sudo systemctl enable --now syncthing@hjalmarlucius.service
systemctl --user daemon-reload
systemctl --user enable --now rclone-gdrive.service

# docker incl non-root daemon
yay docker docker-compose dry-bin nvidia-docker docker-buildx
sudo groupadd docker && sudo usermod -aG docker $USER
sudo systemctl enable --now containerd.service
sudo systemctl enable --now docker.service

# printer
yay manajaro-printer samsung-unified-driver-printer

# monitors
yay iftop bpytop nvtop

# pdf
yay zathura zathura-pdf-mupdf zathura-djvu zathura-ps

# fonts
yay noto-fonts-emoji ttf-hack

# browser

# zerotier
yay zerotier-one
sudo systemctl enable --now zerotier-one.service
sudo zerotier-cli join d5e5fb653797795b

# coolercontrol
yay coolercontrol
sudo systemctl enable --now coolercontrold.service
sudo systemctl edit coolercontrold.service  # set log level to WARN

# video streaming
yay vlc protobuf
yay castnow

# div applications
yay i3status \
    rofi \
    mutt \
    redshift \
    discord \
    teamviewer \
    zerotier-one \
    qalculate \
    cmus \
    ncspot \
    steam \
    qbittorrent
