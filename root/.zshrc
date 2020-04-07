# Lines configured by zsh-newuser-install
HISTFILE=~/.zhistory
HISTSIZE=10000
SAVEHIST=10000
setopt nomatch
unsetopt autocd
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/hjalmarlucius/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# more history stuff
REPORTTIME=3                     # Report command running time if it is more than 3 seconds
setopt INC_APPEND_HISTORY        # Add commands to history as they are entered, don't wait for shell to exit
setopt EXTENDED_HISTORY          # Also remember command start time and duration
setopt HIST_IGNORE_ALL_DUPS      # Do not keep duplicate commands in history
setopt HIST_IGNORE_SPACE         # Do not remember commands that start with a whitespace

# default ls settings
alias ls='ls -hat --group-directories-first'
ls --color=auto &> /dev/null && alias ls='ls --color=auto'
export CLICOLOR=1

# fuzzy find
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
bindkey '^y' fzf-cd-widget

# configure custom command prompt
_setup_ps1() {
  GLYPH="▲"
  [ "x$KEYMAP" = "xvicmd" ] && GLYPH="▼"
  PS1="%F{red}[%F{cyan}%*%F{red}] %(?.%F{cyan}.%F{red})$GLYPH%f %(1j.%F{cyan}[%j]%f .)%F{cyan}%~%f %(!.%F{red}#%f .)"
}
_setup_ps1

# Base16 Shell
BASE16_SHELL="$HOME/.config/base16-shell/"
[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
        eval "$("$BASE16_SHELL/profile_helper.sh")"
