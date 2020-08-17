# linux
* yay stuff
  * AUR `sudo pacman -S yay`
  * `yay onedrive-abraunegg dropbox slack-desktop ncspot-git nvidia-vulkan`
* applications
  * helpers `sudo pacman -S zathura-pdf-mupdf trash-cli rofi`
  * base16 shell `git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell`
  * night colors `sudo pacman -S redshift`
  * gaming `sudo pacman -S steam-manjaro steam-native`

# coding
* cuda `sudo pacman -S cuda`
* core `sudo pacman -S neovim tmux`
* fonts `sudo pacman -S ttf-inconsolata powerline`
* git addons `sudo pacman -S diff-so-fancy`
* search `sudo pacman -S the_silver_searcher ripgrep`
* syntax highlighting `sudo pacman -S bat`
* javascript `sudo pacman -S npm nodejs yarn`
* c++ `sudo pacman -S ninja`

# settings
* set shell to 'fish' via `bmenu`
* replace caps with esc `setxkbmap -option 'caps:escape' `
* ssh setup
  * enable SSH `sudo systemctl enable --now sshd.service`
  * enable X11 forwarding in `/etc/ssh/sshd_config`

# python
* `pip install --pre torch torchvision -f https://download.pytorch.org/whl/nightly/cu101/torch_nightly.html`
* `pip install nodejs plotly flake8 numpy scipy sympy matplotlib seaborn pytorch-lightning ggplot ptvsd tensorboard torchtext ipython matplotlib-label-lines ipympl pytest qbstyles`

# enable services
* `systemctl enable --user onedrive --now`
* `sudo systemctl enable fstrim.timer --now`

# log services
* log onedrive `journalctl --user-unit onedrive -f`

# IP
* hjalmar-droneship 88.89.64.249 10.0.0.2

OMF
* curl -L https://get.oh-my.fish | fish
* omf install https://github.com/FabioAntunes/fish-nvm
* omf install https://github.com/edc/bass
