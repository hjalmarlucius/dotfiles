# linux
* AUR package manager `sudo pacman -S yay`
* fonts `yay -S nerd-fonts-source-code-pro powerline-fonts-git libxft-bgra`
* cloud storage `yay -S onedrive-abraunegg dropbox`
* multimedia `yay -S ncspot-git pavucontrol manjaro-pulse pa-applet pavucontrol pulseaudio-bluetooth`
* web `yay -S slack-desktop chromium`
* div applications `yay -S zathura-pdf-mupdf fish thunar drawio-desktop steam-manjaro`
* div utils `yay -S trash-cli rofi redshift flameshot asus-fan-control`

# coding
* essentials `yay -S neovim tmux`
  * tmux plugins `git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`
  * base16 shell `git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell`
* cuda `yay -S cuda nvidia-container-toolkit`
* docker `yay -S docker docker-compose dry-bin`
* git `yay -S diff-so-fancy tig git-lfs`
* indexing `yay -S fsearch the_silver_searcher ripgrep ctags`
* java `yay -S npm nodejs`
* build `yay -S ninja`

# python
* `pip install ipython pytest neovim numpy scipy sympy flake8 ptvsd addict dill`
* matplotlib stuff `pip install matplotlib seaborn matplotlib-label-lines ipympl qbstyles`
* other plotting `pip install plotly ggplot`
* install torch from [link](https://pytorch.org/)
* `pip install tensorboard torchtext pytorch-lightning torchvision`

# settings
* bmenu for system config incl setting shell
* enable docker non-root daemon [link](https://docs.docker.com/engine/install/linux-postinstall)
* ssh enable `sudo systemctl enable --now sshd.service`
* jupyter `openssl req -x509 -nodes -days 365 -newkey rsa:1024 -keyout ~/.jupyter/mykey.key -out ~/.jupyter/mycert.pem`
* start onedrive `systemctl enable --user onedrive --now`
* ssd maintenance `sudo systemctl enable fstrim.timer --now`
* urxvt ext install `https://github.com/simmel/urxvt-resize-font`

# OMF
* curl -L https://get.oh-my.fish | fish
* omf install https://github.com/edc/bass
* omf install https://github.com/jethrokuan/fzf

