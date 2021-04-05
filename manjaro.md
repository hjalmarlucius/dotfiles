# linux
* AUR package manager `sudo pacman -S yay`
* fonts `yay -S nerd-fonts-source-code-pro powerline-fonts-git libxft-bgra`
* cloud storage `yay -S onedrive-abraunegg dropbox`
* multimedia `yay -S ncspot-git pavucontrol manjaro-pulse pa-applet pavucontrol pulseaudio-bluetooth xwininfo`
* web `yay -S slack-desktop chromium`
* pdf reader `yay -S zathura zathura-pdf-mupdf zathura zathura-djvu zathura-ps`
* shell `yay -S fish`
  * curl -L https://get.oh-my.fish | fish
  * omf install https://github.com/edc/bass
  * omf install https://github.com/jethrokuan/fzf
* div applications `yay -S thunar ranger drawio-desktop steam-manjaro`
* div utils `yay -S trash-cli rofi redshift flameshot asus-fan-control`
* caps2esc `yay -S caps2esc` [install routine](https://askubuntu.com/questions/979359/how-do-i-install-caps2esc) - mode 1

# coding
* essentials `yay -S neovim tmux`
  * tmux plugins `git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm`
  * base16 shell `git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell`
* cuda `yay -S cuda nvidia-container-toolkit`
* docker `yay -S docker docker-compose dry-bin`
* git `yay -S diff-so-fancy tig git-lfs`
* indexing `yay -S fsearch the_silver_searcher ripgrep ctags`
* java `yay -S npm nodejs`
* build `yay -S ninja`

# python
* `pip install ipython pytest neovim numpy scipy sympy flake8 ptvsd addict dill ipdb pudb web-pdb`
* matplotlib stuff `pip install matplotlib seaborn matplotlib-label-lines ipympl qbstyles`
* other plotting `pip install plotly ggplot`
* install torch from [link](https://pytorch.org/)
* `pip install tensorboard torchtext pytorch-lightning torchvision`

# settings
* set shell to fish via `chsh`
* enable docker non-root daemon [link](https://docs.docker.com/engine/install/linux-postinstall)
* ssh enable `sudo systemctl enable --now sshd.service`
* jupyter `openssl req -x509 -nodes -days 365 -newkey rsa:1024 -keyout ~/.jupyter/mykey.key -out ~/.jupyter/mycert.pem`
* start onedrive `systemctl enable --user onedrive --now`
* ssd maintenance `sudo systemctl enable fstrim.timer --now`
* urxvt ext install `https://github.com/simmel/urxvt-resize-font`
* set nodeadkeys `setxkbmap -layout no -model pc105 -variant nodeadkeys`

# wsl
* sudo apt install fish neovim ranger tmux docker docker/compose tig git-lfs ctags ripgrep silversearcher-ag python3-pip
