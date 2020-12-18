# linux
* yay stuff
  * AUR `sudo pacman -S yay`
  * `yay -S onedrive-abraunegg dropbox slack-desktop ncspot-git rxvt-unicode-truecolor-wide-glyphs chromium`
* applications
  * helpers `sudo pacman -S zathura-pdf-mupdf trash-cli rofi`
  * base16 shell `git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell`
  * night colors `sudo pacman -S redshift`
  * gaming `sudo pacman -S steam-manjaro steam-native`
  * vlc player `sudo pacman -S libmicrodns protobuf vlc`
* hardware
  * glances
  * liquidctl
  * `sudo pacman -S pulseaudio-bluetooth`

# coding
* dry `yay dry-bin`
* cuda `sudo pacman -S cuda`
* cuda-docker `yay nvidia-container-toolkit`
* core `sudo pacman -S neovim tmux`
* `git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`
* fonts `yay nerd-fonts-source-code-pro powerline-fonts-git libxft-bgra`
* git addons `sudo pacman -S diff-so-fancy`
* search `sudo pacman -S the_silver_searcher ripgrep`
* cat replacement `sudo pacman -S bat`
* javascript `sudo pacman -S npm nodejs yarn`
* c++ `sudo pacman -S ninja`

# settings
* set shell to 'fish' via `bmenu`
* replace caps with esc `setxkbmap -option 'caps:escape' `
* ssh setup
  * enable SSH `sudo systemctl enable --now sshd.service`
  * enable X11 forwarding in `/etc/ssh/sshd_config`

# python
* `pip install torch torchvision`
* `pip install plotly flake8 numpy scipy sympy matplotlib seaborn pytorch-lightning ggplot ptvsd tensorboard torchtext ipython matplotlib-label-lines ipympl pytest qbstyles`

# enable services
* `systemctl enable --user onedrive --now`
* `sudo systemctl enable fstrim.timer --now`

# log services
* log onedrive `journalctl --user-unit onedrive -f`

# IP
* hjalmar-droneship 88.89.64.249 10.0.0.2

#OMF
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
