## This was taken from: http://zeitlens.com/posts/2014-06-29-howto-zsh-vi-style.html

# You may already have those in your .zshrc somewhere
autoload -U promptinit && promptinit
autoload -U colors     && colors

setopt prompt_subst

# Set the colors to your liking
local vi_normal_marker="[%{$fg[green]%}%BN%b%{$reset_color%}]"
local vi_insert_marker="[%{$fg[cyan]%}%BI%b%{$reset_color%}]"
local vi_unknown_marker="[%{$fg[red]%}%BU%b%{$reset_color%}]"
local vi_mode="$vi_insert_marker"
vi_mode_indicator () {
case ${KEYMAP} in
  (vicmd)      echo $vi_normal_marker ;;
  (main|viins) echo $vi_insert_marker ;;
  (*)          echo $vi_unknown_marker ;;
esac
}

# Reset mode-marker and prompt whenever the keymap changes
function zle-line-init zle-keymap-select {
  vi_mode="$(vi_mode_indicator)"
  zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select

# Multiline-prompts don't quite work with reset-prompt; we work around this by
# printing the first line(s) via a precmd which is executed before the prompt
# is printed.  The following can be integrated into PROMPT for single-line
# prompts.
#
# Colorize freely
if [[ -z ${ORIG_PS1} ]]; then
  export ORIG_PS1=${PS1:0: -3}
fi
#local user_host='%B%n%b@%m'
#local current_dir='%~'
precmd () print -rP "${ORIG_PS1}"

local return_code="%(?..%{$fg[red]%}%? %{$reset_color%})"
PROMPT='${return_code}${vi_mode} %# '
