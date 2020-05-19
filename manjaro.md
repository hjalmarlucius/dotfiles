# linux
* storage
  * `yay megasync`
  * `yay onedrive-abraunegg`
  * `yay dropbox`
* applications `sudo pacman -S npm nodejs ninja zathura-pdf-mupdf redshift yay trash-cli conky-manager feh pv fancontrol-gui thefuck ncdu`
* spotify `yay ncspot-git`
* code `sudo pacman -S neovim tig powerline the_silver_searcher tmux diff-so-fancy ttf-inconsolata`
* gaming `sudo pacman -S steam-manjaro steam-native`
* ssh setup
  * enable SSH `sudo systemctl enable --now sshd.service`
  * enable X11 forwarding in `/etc/ssh/sshd_config`
* set shell to 'fish' via `bmenu`
* replace caps with esc `setxkbmap -option 'caps:escape`
* nvidia
  * `sudo pacman -S cuda`
  * `yay nvidia-vulkan`

# python
* `pip install --pre torch torchvision -f https://download.pytorch.org/whl/nightly/cu101/torch_nightly.html`
* `pip install nodejs plotly flake8 numpy scipy sympy matplotlib seaborn pytorch-lightning ggplot ptvsd tensorboard torchtext ipython matplotlib-label-lines ipympl pytest qbstyles`
* `jupyter nbextension enable --py widgetsnbextension`

# enable services
* `systemctl enable --user onedrive --now`
* `sudo systemctl enable fstrim.timer --now`

# log services
* log onedrive `journalctl --user-unit onedrive -f`
