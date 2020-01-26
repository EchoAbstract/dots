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
#            *) export PATH=${PATH}:$1;;
            *) export PATH="${PATH:+${PATH}:}$1";;
        esac
    fi
}

maybe_prepend_path()
{
    if [[ -d $1 ]];
    then
        case ":$PATH:" in
            *":$1:"*) :;;
            # *) export PATH=$1:${PATH};;
            *) export PATH="$1${PATH:+:${PATH}}"
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

path_remove_match () {
    PATH=$(echo $PATH | tr ':' '\n' | grep -v $1 | tr '\n' ':' | sed 's/:$//');
    export PATH;
}

listenvs () {
    local envdir=${ENV_DIR:-${HOME}/envs}
    for env in $(/bin/ls -1 $envdir/${1}* 2>/dev/null)
    do
        echo $(basename $env .env)
    done
}

useenv () {
    local envdir=${ENV_DIR:-${HOME}/envs}
    local envfile=${envdir}/${1}.env
    if [[ -e $envfile ]]
    then
        echo "Found $envfile, sourcing..."
        source $envfile
    else
        echo "There is no $envfile, only Zuul"
    fi
}

_useenv_comp () {
    if [ "${#COMP_WORDS[@]}" != "2" ]; then
        return
    fi

    local first_word=${COMP_WORDS[1]}
    local candidates=$(compgen -W "$(listenvs)" -- $first_word)
    COMPREPLY=( $candidates )
}

complete -F _useenv_comp useenv

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

alias ls="ls -F"
alias ll="ls -Fl"

# Docker aliases
alias ctop="docker run --rm -ti --name=ctop -v /var/run/docker.sock:/var/run/docker.sock quay.io/vektorlab/ctop:latest"

# SSHing Things
alias unsafe-ssh='ssh -o GlobalKnownHostsFile=/dev/null -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'

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

list_gspeak_versions() {
    local sed_bin=$(which sed)
    local sort_bin=$(which sort)

    /bin/ls -1d /opt/oblong/g-speak*            \
        | $sed_bin 's_/opt/oblong/g-speak__'    \
        | $sort_bin -rn
}

use_gspeak() {
    local version=$1

    # FIXME: Doesn't handle the case with 0 g-speaks installed
    if [[ -z "$version" ]]
    then
        version=$(list_gspeak_versions | /usr/bin/head -1)
    fi

    local gs_dir=/opt/oblong/g-speak${version}/bin

    if [[ ! -d $gs_dir ]]
    then
        echo "Can't find g-speak version ${version}"
        return -1
    fi

    path_remove_match oblong
    maybe_prepend_path $gs_dir

    local obs_bin=$(which obs)

    if [[ -z "$obs_bin" ]]
    then
        echo "Please install obs to determine the deps path"
    fi

    local deps_version=$(obs yovo2yoversion $version)
    local deps_dir=/opt/oblong/deps-64-${deps_version}/bin
    local deps_sdir=/opt/oblong/deps-64-${deps_version}/sbin

    if [[ ! -d $deps_dir ]]
    then
        echo "Can't find g-speak version ${version} dependencies..."
    fi

    maybe_prepend_path $deps_sdir
    maybe_prepend_path $deps_dir
}

_use_gspeak_comp () {
    if [ "${#COMP_WORDS[@]}" != "2" ]; then
        return
    fi

    local first_word=${COMP_WORDS[1]}
    local candidates=$(compgen -W "$(list_gspeak_versions)" -- $first_word)
    COMPREPLY=( $candidates )
}

complete -F _use_gspeak_comp use_gspeak

no_use_gspeak() {
    path_remove_match oblong
}
