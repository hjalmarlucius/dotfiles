set -x VISUAL /usr/bin/nvim
set -x EDITOR /usr/bin/nvim
set -x BROWSER /usr/bin/google-chrome-stable
set -x QT_QPA_PLATFORMTHEME "qt5ct"
set -x GTK2_RC_FILES "$HOME/.gtkrc-2.0"
set -x JAVA_HOME "/usr/lib/jvm/default/"
set -x PYTHONBREAKPOINT ipdb.set_trace

# cuda stuff
set -x CUDA_HOME /opt/cuda
set -x LD_LIBRARY_PATH $LD_LIBRARY_PATH:$CUDA_HOME/lib64
set -Ua fish_user_paths /home/hjalmarlucius/.local/bin/

# Base16 Shell
if status --is-interactive
    set BASE16_SHELL "$HOME/.config/base16-shell/"
    source "$BASE16_SHELL/profile_helper.fish"
end

# fzf bindings
set -U FZF_LEGACY_KEYBINDINGS 0
