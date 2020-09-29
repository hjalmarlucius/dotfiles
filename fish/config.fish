thefuck --alias | source

set -x VISUAL /usr/bin/nvim
set -x EDITOR /usr/bin/nvim
set -x BROWSER /usr/bin/chromium
set -x QT_QPA_PLATFORMTHEME "qt5ct"
set -x GTK2_RC_FILES "$HOME/.gtkrc-2.0"
set -x PYTHONBREAKPOINT ipdb.set_trace
set -x JAVA_HOME "/usr/lib/jvm/java-14-openjdk/"

# cuda stuff
set -x CUDA_HOME /opt/cuda
set -x LD_LIBRARY_PATH $LD_LIBRARY_PATH:$CUDA_HOME/lib64
set -x PATH $CUDA_HOME/bin:/home/hjalmarlucius/.local/bin/:$PATH

# Base16 Shell
if status --is-interactive
    set BASE16_SHELL "$HOME/.config/base16-shell/"
    source "$BASE16_SHELL/profile_helper.fish"
end

# MKL AMD fix
set -x MKL_DEBUG_CPU_TYPE 5

# fzf bindings
set -U FZF_LEGACY_KEYBINDINGS 0
