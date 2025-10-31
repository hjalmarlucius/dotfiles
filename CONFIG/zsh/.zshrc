# --- env ---
export SYSTEMD_EDITOR=nvim
export EDITOR=nvim
export VISUAL=nvim
export PAGER="bat --style=header,rule,snip"
export PATH=~/.local/bin:$PATH
export BROWSER=/usr/bin/qutebrowser
export HISTFILE=~/.config/zsh/history
export HISTSIZE=200000
export SAVEHIST=200000

# --- aliases ---
alias ls='ls --color=auto -Ah'
alias ..='cd ..'
alias ...='cd ../..'

# --- basic keybinds ---
bindkey '^[[Z' reverse-menu-complete  # shift-tab
bindkey '^[^M' self-insert-unmeta  # alt+enter newline
bindkey "^[^?" backward-kill-word  # alt+backspace

# --- options ---
setopt HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE SHARE_HISTORY EXTENDED_HISTORY
setopt AUTO_CD AUTO_MENU
setopt AUTO_PUSHD PUSHD_SILENT PUSHD_TO_HOME
setopt NO_NOMATCH
WORDCHARS='_-*?.[]~=&;!#$%^(){}<>'

# --- command line to EDITOR ---
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# --- autocompletion ---
autoload -Uz compinit
compinit -d "~/.config/zsh/zcompdump"
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' 'r:|[._-]=** r:|=**'
zstyle ':completion:*' list-colors ''
if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion zsh)
fi

# --- div plugins ---
# autosuggestions must come before atuin
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

# --- vi mode ---
bindkey -v
source /usr/share/zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh

# --- search ---
# fzf: Ctrl-T, Alt-C
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh
# atuin: Ctrl+R, /
eval "$(atuin init zsh)"
# handle collisions
function zvm_after_init() {
  bindkey -M vicmd '^R' redo
  bindkey -M viins '^R' atuin-search
}

# ---  syntax hl ---
# must be the last plugins sourced
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
