autoload -U colors && colors
PROMPT="%B%{$fg[green]%}%n%{$fg[white]%}@%{$fg[green]%}%M %{$fg[blue]%}%~%{$reset_color%}$%b "
RPROMPT="%{$fg_bold[red]%}%(?..%? )%{$reset_color%} %{$date%}"
source "$HOME/.config/aliasrc"

# keep processes running when exiting zsh
setopt NO_HUP
setopt NO_CHECK_JOBS

# History in cache directory:
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zsh/history

#plugins=(zsh-completions)
# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.

# auto quote pasted urls
autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic

autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

[ -f "$HOME/.config/aliasrc" ] && source "$HOME/.config/aliasrc"
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null

# fix slow git autocompletion
__git_files () {
    _wanted files expl 'local files' _files
}


# Need a tweak in arch for home and end keys to work properly
# (as well as insert, delete, pageup, pagedown, perhaps others...)
# https://wiki.archlinux.org/index.php/Home_and_End_keys_not_working#Zsh
bindkey "^[[2~" overwrite-mode # Ins
bindkey "^[[3~" delete-char # Del
bindkey "^[[5~" beginning-of-history #PageUp
bindkey "^[[6~" end-of-history #PageDown

# but.... home and end key escape sequences
# are DIFFERENT depending on whether I'm in a tmux session or not!
# To determine if tmux is running, examine values of $TERM and $TMUX.
if [ "$TERM" = "screen" ] && [ -n "$TMUX" ]; then
  bindkey "^[[1~" beginning-of-line
  bindkey "^[[4~" end-of-line
else
  # Assign these keys if tmux is NOT being used:
  bindkey "^[[H" beginning-of-line
  bindkey "^[[F" end-of-line
fi

