# -*- mode: sh -*-

###########################
## Brian Wilson's BASHRC ##
###########################

# First get the system name
PLATFORM=`uname`

# Load aliases / Functions
if [[ -r ${HOME}/.bash_aliases ]]
then
   . ${HOME}/.bash_aliases
fi

# Build the default path for OS-X (nop on linux)
if [[ -x /usr/libexec/path_helper ]]
then
    eval `/usr/libexec/path_helper -s`
fi

# Setup initial path
maybe_prepend_path /usr/local/bin
maybe_append_path /usr/local/sbin
maybe_prepend_path ${HOME}/bin

# freedesktop software installation location
maybe_append_path ${HOME}/.local/bin

# Software I build myself
maybe_append_path ${HOME}/sw/bin
maybe_append_path ${HOME}/sw/sbin
maybe_append_path ${HOME}/Unix/bin
maybe_append_path ${HOME}/Unix/sbin
maybe_append_path /u/sw/bin
maybe_append_path /u/sw/sbin


# System-wide .bashrc file for interactive bash(1) shells.
if [[ -z "$PS1" ]]
then
   return
fi

# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]]
then
	# Shell is non-interactive.  Be done now!
	return
fi

## Set shell options
# Make bash check its window size after a process completes
shopt -s checkwinsize

# Enable history appending instead of overwriting.  #139609
shopt -s histappend

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=20000


# Bash Completion

# Mac
if [[ -x /usr/local/bin/brew ]]
then
    maybe_source_file `brew --prefix`/etc/bash_completion
fi

maybe_source_file /usr/share/bash-completion/bash_completion
maybe_source_file /etc/bash_completion


# ENV Vars
export CLICOLOR=1
export EDITOR=vim


# Homebrew package locations
maybe_append_path /usr/local/share/npm/bin
maybe_append_path /usr/local/opt/ruby/bin

# go Support
maybe_append_path /usr/local/go/bin

if [[ -d ${HOME}/go ]]
then
    export GOPATH=${HOME}/go
    maybe_append_path ${HOME}/go
fi

# Anaconda python support
maybe_append_path ${HOME}/anaconda/bin

# Tarsnap
maybe_append_path /usr/local/tarsnap/bin

# RBENV
if which rbenv > /dev/null;
then
    eval "$(rbenv init -)"
fi

# OPAM configuration
if [[ -f $HOME/.opam/opam-init/init.sh ]]
then
    . $HOME/.opam/opam-init/init.sh
fi

# Setup Java versions
if [[ -x /usr/libexec/java_home ]]
then
    export JAVA_HOME=$(/usr/libexec/java_home)
fi

# Setup Python versions
if [[ -f /usr/local/bin/virtualenvwrapper.sh ]]
then
    export WORKON_HOME=$HOME/.virtualenvs
    source /usr/local/bin/virtualenvwrapper.sh
    export PIP_VIRTUALENV_BASE=$WORKON_HOME
    export PIP_RESPECT_VIRTUALENV=true
fi

## TeX
## TODO(brian): Linuxify this at some point
if [[ $PLATFORM == 'Darwin' && -d /usr/local/texlive/2015 ]]
then
    export PATH=$PATH:/usr/local/texlive/2015/bin/x86_64-darwin
    export MANPATH=$MANPATH:/usr/local/texlive/2015/texmf-dist/doc/man
    export INFOPATH=$INFOPATH:/usr/local/texlive/2015/texmf-dist/doc/info
fi

## CUDA
## TODO(brian): Linuxify this at some point
if [[ $PLATFORM == 'Darwin' && -d /Developer/NVIDIA/CUDA-7.0/bin ]]
then
    maybe_append_path /Developer/NVIDIA/CUDA-7.0/bin
    export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:/Developer/NVIDIA/CUDA-7.0/lib
fi

##### Plan 9 Support #######
# This needs to be "enabled"
# if [ -d /usr/local/plan9 ];
# then
#     export PLAN9=/usr/local/plan9
#     export PATH=$PATH:$PLAN9/bin
# fi

### PERL
#PERL_MB_OPT="--install_base \"/Users/brian/perl5\""; export PERL_MB_OPT;
#PERL_MM_OPT="INSTALL_BASE=/Users/brian/perl5"; export PERL_MM_OPT;

PS1="\[$(tput setaf 6)\]\u\[$(tput sgr0)\] @ \[$(tput setaf 3)\]\h\[$(tput sgr0)\] : \[$(tput setaf 2)\]\W\[$(tput sgr0)\] \\$ \[$(tput sgr0)\]"
