export VISUAL=/usr/bin/nvim
export EDITOR=/usr/bin/nvim
export BROWSER=/usr/bin/chromium
export QT_QPA_PLATFORMTHEME="qt5ct"
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
export PYTHONBREAKPOINT=ipdb.set_trace


# cuda stuff
export CUDA_HOME=/opt/cuda
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${CUDA_HOME}/lib64
PATH=${CUDA_HOME}/bin:/home/hjalmarlucius/.local/bin/:${PATH}
export PATH

# MKL AMD fix
export MKL_DEBUG_CPU_TYPE=5

export NVM_DIR="/home/hjalmarlucius/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
