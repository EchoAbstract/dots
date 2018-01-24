# -*- mode: sh -*-

## bash aliases and functions

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

fi

# Linux specific aliases
if [[ $PLATFORM == 'Linux' ]];
then
    alias ls='ls --color'
    alias open='xdg-open'
fi

# FreeBSD specific aliases
# N/A

# Common aliases
alias setuptex='. ${HOME}/context/tex/setuptex'
alias ducks='du -cms *|sort -rn|head -11' # ducks: List top ten largest files/directories in current directory
alias showOptions='shopt' # showOptions: display bash options settings
alias fixStty='stty sane' # fixStty: Restore terminal settings when screwed up

alias qemacs="emacs -nw -q $*" 
alias ctop="docker run --name ctop -it --rm -v /var/run/docker.sock:/var/run/docker.sock ctop"

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
