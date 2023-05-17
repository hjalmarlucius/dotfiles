pyenv init - | source
set -x QT_QPA_PLATFORMTHEME "qt5ct"
set -x GTK2_RC_FILES "$HOME/.gtkrc-2.0"
set -x PAGER "less -isgj.5"

# cuda stuff
set -x CUDA_HOME /opt/cuda
set -x LD_LIBRARY_PATH $LD_LIBRARY_PATH $CUDA_HOME/lib64
set -Ua fish_user_paths /home/hjalmarlucius/.local/bin/
