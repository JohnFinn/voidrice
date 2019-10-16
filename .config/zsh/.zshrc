autoload -U colors && colors
PROMPT="%B%{$fg[green]%}%n%{$fg[white]%}@%{$fg[green]%}%M %{$fg[blue]%}%~%{$reset_color%}$%b "
RPROMPT="%{$fg_bold[red]%}%(?..%? )%{$reset_color%}"
source "$HOME/.config/aliasrc"

# keep processes running when exiting zsh
setopt NO_HUP
setopt NO_CHECK_JOBS

# History in cache directory:
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zsh/history

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

[ -f "$HOME/.config/aliasrc" ] && source "$HOME/.config/aliasrc"
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
