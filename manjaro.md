# linux
* basics
  * AUR `sudo pacman -S yay`
* fonts
  * `yay -S nerd-fonts-source-code-pro powerline-fonts-git libxft-bgra`
* applications
  * `yay -S onedrive-abraunegg dropbox slack-desktop chromium zathura-pdf-mupdf trash-cli rofi redshift flameshot fish pavucontrol thunar drawio-desktop`
* gaming and media
  + `yay -S steam-manjaro vlc libmicrodns protobuf ncspot-git mkchromecast`
* hardware
  * `yay -S liquidctl glances pulseaudio-bluetooth asus-fan-control`

# coding
* `yay -S cuda nvidia-container-toolkit`
  `yay -S docker docker-compose dry-bin neovim tmux diff-so-fancy the_silver_searcher ripgrep bat npm nodejs yarn ninja ctags tig git-lfs`
* `git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`

# python
* `pip install ipython pytest neovim numpy scipy sympy flake8 ptvsd addict dill`
* matplotlib stuff `pip install matplotlib seaborn matplotlib-label-lines ipympl qbstyles`
* other plotting `pip install plotly ggplot`
* install torch from [link](https://pytorch.org/)
* `pip install tensorboard torchtext pytorch-lightning torchvision`

# settings
* bmenu for system config incl setting shell
* replace caps with esc `setxkbmap -option 'caps:escape'`
* enable docker non-root daemon [link](https://docs.docker.com/engine/install/linux-postinstall)
* base16 shell `git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell`
* ssh enable `sudo systemctl enable --now sshd.service`
* jupyter `openssl req -x509 -nodes -days 365 -newkey rsa:1024 -keyout ~/.jupyter/mykey.key -out ~/.jupyter/mycert.pem`
* start onedrive `systemctl enable --user onedrive --now`
* ssd maintenance `sudo systemctl enable fstrim.timer --now`
* show log `journalctl --user-unit onedrive -f`
* nvim as default editor `xdg-mime default nvim.desktop application/octet-stream`
* change from alsa to pavu `install_pulse`
* manage `~/.config.mimeapps.list` associations

# OMF
* curl -L https://get.oh-my.fish | fish
* omf install https://github.com/FabioAntunes/fish-nvm
* omf install https://github.com/edc/bass
* omf install https://github.com/jethrokuan/fzf

# ROUTER
* asus merlin - install conmon, skynet, scMerlin, FlexQOS
  + maybe: Diversion + uiDivStats + yazFi
* wifi adapter: kill bluetooth and background scans. tools:
  * **rfkill** (=interact with wireless devices) see blocked `rfkill`
  * **inxi** (=tool to show stuff) see network drivers `inxi -N`
  * **iwconfig** (=wireless ifconfig) see signal strength, bit rate etc `iwconfig`
  * **lsusb & lspci**: show info on usb & pci `sudo lsusb -vv -s [device]` and `sudo lspci -vv -s [device]`

