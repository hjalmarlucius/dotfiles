# linux
* AUR package manager `sudo pacman -S yay`
* fonts `yay -S ttf-hack`
* cloud storage `yay -S onedrive-abraunegg dropbox`
* multimedia `yay -S ncspot-git pavucontrol manjaro-pulse pa-applet pavucontrol pulseaudio-bluetooth`
* web `yay -S slack-desktop vivaldi-stable`
* pdf reader `yay -S zathura zathura-pdf-mupdf zathura zathura-djvu zathura-ps`
* shell `yay -S fish`
  * `curl -L https://get.oh-my.fish | fish`
  * `omf install https://github.com/edc/bass`
  * `omf install https://github.com/jethrokuan/fzf`
* div applications `yay -S thunar ranger drawio-desktop steam-manjaro bpytop nvtop`
* div utils `yay -S trash-cli rofi redshift flameshot asus-fan-control`
* sysrq lock shutdown https://forum.manjaro.org/t/howto-reboot-turn-off-your-frozen-computer-reisub-reisuo/3855
  + `echo kernel.sysrq=1 | sudo tee --append /etc/sysctl.d/99-sysctl.conf`
  + `sudo update-grub`
* WakeOnLan `yay ethtool`

# coding
* essentials `yay -S neovim tmux`
* tmux plugins `git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm`
* base16 shell `git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell`
* docker `yay -S docker docker-compose dry-bin`
* git `yay -S diff-so-fancy tig git-lfs`
* indexing `yay -S fsearch-git the_silver_searcher ripgrep ctags`
* java `yay -S npm nodejs`
* build `yay -S ninja`
* language servers and linting
  * `yay prettier efm-langserver`
  * `npm install -g yaml-language-server`
  * `npm install -g pyright`

# python
* pytorch `yay python-pytorch-opt-cuda`
* `pip install ipython pytest neovim numpy scipy sympy flake8 ptvsd addict dill ipdb pudb web-pdb isort`
* matplotlib stuff `pip install matplotlib seaborn matplotlib-label-lines ipympl qbstyles`
* other plotting `pip install plotly ggplot`
* `pip install tensorboard torchtext pytorch-lightning torchvision`

# settings
* set shell to fish via `chsh`
* enable docker non-root daemon [link](https://docs.docker.com/engine/install/linux-postinstall)
  * `sudo groupadd docker`
  * `sudo usermod -aG docker $USER`
  * `newgrp docker`
  * `sudo systemctl enable docker.service`
  * `sudo systemctl enable containerd.service`
* ssh enable `sudo systemctl enable --now sshd.service`
* jupyter `openssl req -x509 -nodes -days 365 -newkey rsa:1024 -keyout ~/.jupyter/mykey.key -out ~/.jupyter/mycert.pem`
* start onedrive `systemctl enable --user onedrive --now`
* ssd maintenance `sudo systemctl enable fstrim.timer --now`
* set nodeadkeys and caps to escape `setxkbmap -layout no -model pc105 -variant nodeadkeys -option caps:escape`

# wsl
* sudo apt install fish neovim ranger tmux docker docker/compose tig git-lfs ctags ripgrep silversearcher-ag python3-pip
