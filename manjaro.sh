# firewall
sudo ufw enable
sudo ufw allow 22/tcp comment "ssh"
sudo ufw allow 80/tcp comment "web"
sudo ufw allow 443/tcp comment "websecure"
sudo ufw allow 10000:10100/tcp comment "generic"

# keyboard fix
echo 'XKBMODEL="pc105"
XKBLAYOUT="no"
XKBVARIANT="nodeadkeys"
XKBOPTIONS="caps:escape"

BACKSPACE="guess"' | sudo tee /etc/default/keyboard

# general
sudo systemctl enable --now sshd.service
sudo systemctl enable --now fstrim.timer
yay plymouth tldextract go nodejs unzip exa

# nvidia
yay cuda nvidia-settings nvidia-docker

# python
yay python-pip pyenv ipython

# sound
yay pavucontrol pa-applet manjaro-pulse

# terminal and shell
yay kitty fish
chsh -s /usr/bin/fish

# code
yay neovim tig stylua tmux diff-so-fancy ripgrep prettier jq git-lfs shfmt glow
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm

# file sync
yay syncthings rclone
sudo systemctl enable --now syncthing@hjalmarlucius.service
systemctl --user daemon-reload
systemctl --user enable --now rclone-gdrive.service
sudo ufw allow syncthing comment "Syncthing"

# docker incl non-root daemon
yay docker docker-compose dry-bin nvidia-docker docker-buildx
sudo ufw allow 2376/tcp comment "Docker"
sudo ufw allow 2377/tcp comment "Docker"
sudo ufw allow 4789/udp comment "Docker"
sudo ufw allow 7946/udp comment "Docker"
sudo ufw allow 7946/tcp comment "Docker"
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
yay qutebrowser pdfjs bitwarden-cli

# utils
yay i3status rofi mutt redshift coolercontrol
sudo systemctl enable --now coolercontrold.service

# applications
yay plex-media-server qbittorrent discord teamviewer steam qalculate cmus ncspot
sudo ufw allow 8010 comment "chromecast"
sudo ufw allow 27031,27036/udp comment "Steam Link"
sudo ufw allow 27036,27037/tcp comment "Steam Link"
sudo ufw allow to 224.0.0.1 comment "Multicast"
sudo ufw allow from 192.168.1.1 port 1900 to any proto udp comment "Multicast"
