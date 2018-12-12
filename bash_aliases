# -*- mode: sh -*-

## bash aliases and functions

reset_path()
{
    export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
}

maybe_append_path()
{
    if [[ -d $1 ]];
    then
        case ":$PATH:" in
            *":$1:"*) :;;
            *) export PATH=${PATH}:$1;;
        esac
    fi
}

maybe_prepend_path()
{
    if [[ -d $1 ]];
    then
        case ":$PATH:" in
            *":$1:"*) :;;
            *) export PATH=$1:${PATH};;
        esac
    fi
}

maybe_source_file()
{
    if [[ -r $1 ]];
    then
        . $1;
    fi
}

pidof()
{
    ps -ef | grep -i $1 | grep -v grep | head -1 | awk '{print $2}';
}

man () {
  LESS_TERMCAP_mb=$'\e'"[1;31m"    \
  LESS_TERMCAP_md=$'\e'"[1;31m"    \
  LESS_TERMCAP_me=$'\e'"[0m"       \
  LESS_TERMCAP_se=$'\e'"[0m"       \
  LESS_TERMCAP_so=$'\e'"[1;44;33m" \
  LESS_TERMCAP_ue=$'\e'"[0m"       \
  LESS_TERMCAP_us=$'\e'"[1;32m"    \
  command man "$@"
}


# OS-X specific aliases
if [[ $PLATFORM == 'Darwin' ]];
then
    alias svn='xcrun svn'
    alias f='open -a Finder ./' # f: Opens current directory in MacOS Finder
    alias c='clear' # c: Clear terminal display
    alias path='echo -e ${PATH//:/\\n}' # path: Echo all executable Paths
    alias DT='tee ~/Desktop/terminalOut.txt' # DT: Pipe content to file on MacOS Desktop
    alias ducks='du -cms *|sort -rn|head -11' # ducks: List top ten largest files/directories in current directory
fi

# Linux specific aliases
if [[ $PLATFORM == 'Linux' ]];
then
    # Hack for now
    if [[ $- = *i* ]]
    then
	alias ls='ls --color'
    fi

    alias open='xdg-open'
    alias ducks='du -xcms *|sort -rn|head -11' # ducks: List top ten largest files/directories in current directory
fi

# FreeBSD specific aliases
# N/A

# Common aliases
alias setuptex='. ${HOME}/context/tex/setuptex'
alias showOptions='shopt' # showOptions: display bash options settings
alias fixStty='stty sane' # fixStty: Restore terminal settings when screwed up
alias fixKeyboardSpeed='xset r rate 200 30'

# Docker aliases
alias ctop="docker run --rm -ti --name=ctop -v /var/run/docker.sock:/var/run/docker.sock quay.io/vektorlab/ctop:latest"

# Kinvey aliases / functions

# Jump to the Kinvey source project given
function kksrc()
{
  local project=$1 tpath=~/Documents/Kinvey/src/
	if [ -d $tpath/$project ];
	then
		tpath=${tpath}${project}
	fi
	cd $tpath
}

_kksrc()
{
        local path dirs cur=${COMP_WORDS[COMP_CWORD]}
        path=~/Documents/Kinvey/src/
        dirs=$(cd $path && ls -1d *)
        COMPREPLY=( $(compgen -W "$dirs" -- $cur) )
}

complete -F _kksrc kksrc


# Node / NPM
alias npm-packages='npm -g ls --depth 0'
alias gnpm='npm -g '

# Oblong stuff
gspeak()
{
    if [[ -d /opt/oblong/g-speak$1 ]];
    then
        cd /opt/oblong/g-speak$1
    else
        cd /opt/oblong/
    fi
}

yobuild()
{
    if [[ -d /opt/oblong/deps-64-$1 ]];
    then
        cd /opt/oblong/deps-64-$1
    else
        cd /opt/oblong/
    fi
}
