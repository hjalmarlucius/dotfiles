if status is-interactive
    pyenv init - | source
    set -x PAGER "nvimpager"
    set -Ua fish_user_paths /home/hjalmarlucius/.local/bin/
    set -x CUDA_HOME /opt/cuda
    set -x LD_LIBRARY_PATH $LD_LIBRARY_PATH $CUDA_HOME/lib64
end
