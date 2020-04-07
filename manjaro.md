# linux
* storage
  * `yay megasync`
  * `yay onedrive-abraunegg`
  * `yay dropbox`
* nvidia
  * `sudo pacman -S cuda`
  * `yay nvidia-vulkan`
* applications
  * `sudo pacman -S npm nodejs`
  * `sudo pacman -S ninja the_silver_searcher`
  * `sudo pacman -S zathura-pdf-mupdf redshift yay`
  * `yay ncspot-git`
* code
  * `sudo pacman -S neovim powerline tmux diff-so-fancy ttf-inconsolata`
* gaming
  * `sudo pacman -S steam-manjaro steam-native`
* ssh setup
  * enable SSH `sudo systemctl enable --now sshd.service`
  * enable X11 forwarding in `/etc/ssh/sshd_config`
* set shell to 'fish' via `bmenu`
* onedrive as service `systemctl --user enable onedrive`

# python
* `pip install --pre torch torchvision -f https://download.pytorch.org/whl/nightly/cu101/torch_nightly.html`
* `pip install nodejs plotly flake8 numpy scipy sympy matplotlib seaborn pytorch-lightning ggplot ptvsd tensorboard torchtext ipython matplotlib-label-lines ipympl pytest qbstyles`

# useful commands
* enable onedrive at boot `systemctl --user enable onedrive`
* start onedrive now `systemctl --user start onedrive`
* log onedrive `journalctl --user-unit onedrive -f`
* replace caps with esc `setxkbmap -option 'caps:escape`
