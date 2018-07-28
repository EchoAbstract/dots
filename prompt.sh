#!/bin/bash

# # OLD
# . ~/dots/scripts/git-prompt.sh
# export GIT_PS1_SHOWDIRTYSTATE=1
# export GIT_PS1_SHOWCOLORHINTS=1
#
#
# case "$TERM" in
#     xterm*)
#         export PS1='\[\033]0;\w\007\][\[$(tput setaf 3)\]\h\[$(tput sgr0)\]$(__git_ps1)] '
#         ;;
#    *256color*)
#         export PS1='\[\033]0;\w\007\][\[$(tput setaf 3)\]\h\[$(tput sgr0)\]$(__git_ps1)] '
#         ;;
#     *)
#         export PS1='[\h$(__git_ps1)] '
#         ;;
# esac

maybe_source_file ~/dots/scripts/git-prompt.sh
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWCOLORHINTS=1



endchar="\$"
if [ "$UID" = "0" ]; then
    endchar="#"
fi

# Blue
BG="\[\e[38;5;39m\]"
# RGBA index:
#BG="\[\e[38;2;255;142;58m\]"

# Orange
FG="\[\e[38;5;208m\]"
# RGBA index:
#FG="\[\e[38;2;0;174;255m\]"

export PS1="$BG\u\[\e[0m\]@$FG\H ${BG}\w${FG}\$(__git_ps1) ${BG}$endchar \[\e[0;0m\]"

if [ "${TERM:0:5}" = "xterm" ]; then
  export PS1="\[\e]2;\u@\H :: \w\a\]$PS1"
fi

shopt -s checkwinsize
