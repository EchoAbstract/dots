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
maybe_append_path ${HOME}/.local/sbin

# Software I build myself
maybe_append_path ${HOME}/sw/bin
maybe_append_path ${HOME}/sw/sbin
maybe_append_path ${HOME}/Unix/bin
maybe_append_path ${HOME}/Unix/sbin
maybe_append_path /u/sw/bin
maybe_append_path /u/sw/sbin

# Homebrew package locations
maybe_append_path /usr/local/share/npm/bin
maybe_append_path /usr/local/opt/ruby/bin

# go Support
maybe_append_path /usr/local/go/bin

if [[ -d ${HOME}/go ]]
then
    export GOPATH=${HOME}/go
    maybe_append_path ${HOME}/go/bin
fi

# Setup a modern clang/llvm toolchain
maybe_append_path ${HOME}/LLVM/latest/bin

# Tarsnap
maybe_append_path /usr/local/tarsnap/bin


# OPAM configuration
if [[ -f $HOME/.opam/opam-init/init.sh ]]
then
    . $HOME/.opam/opam-init/init.sh
fi


# Setup Python versions
if [[ -f /usr/local/bin/virtualenvwrapper.sh ]]
then
    export WORKON_HOME=$HOME/.virtualenvs
    source /usr/local/bin/virtualenvwrapper.sh
    export PIP_VIRTUALENV_BASE=$WORKON_HOME
    export PIP_RESPECT_VIRTUALENV=true
fi

# Setup Python Conda
maybe_prepend_path ${HOME}/miniconda3/bin
maybe_prepend_path ${HOME}/miniconda2/bin
maybe_prepend_path ${HOME}/anaconda/bin
maybe_prepend_path ${HOME}/anaconda3/bin

## TeX
TEXROOT=/usr/local/texlive
if [[ -d ${TEXROOT} ]]
then
    # We may have a texlive installation...
    latest_year=$(cd $TEXROOT && /bin/ls -1d 2* | sort -rn | head -1)

    if [[ ! -z "$latest_year" ]]
    then
        # Remove any older versions that might be in our path
        path_remove_match texlive
        TEXROOT=${TEXROOT}/${latest_year}

        if [[ $PLATFORM == 'Darwin' ]]
        then
            maybe_append_path ${TEXROOT}/bin/x86_64-darwin
        elif [[ $PLATFORM == 'Linux' ]]
        then
            maybe_append_path ${TEXROOT}/bin/x86_64-linux
        fi

        export MANPATH=$MANPATH:${TEXROOT}/texmf-dist/doc/man
        export INFOPATH=$INFOPATH:${TEXROOT}/texmf-dist/doc/info
    fi
fi

## CUDA
if [[ $PLATFORM == 'Linux' && -d /usr/local/cuda ]];
then
    maybe_append_path /usr/local/cuda/bin
fi

# Deprecated, since Apple doesn't ship nvidia at the moment
if [[ $PLATFORM == 'Darwin' && -d /Developer/NVIDIA/CUDA-7.0/bin ]]
then
    maybe_append_path /Developer/NVIDIA/CUDA-7.0/bin
    export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:/Developer/NVIDIA/CUDA-7.0/lib
fi


# Sometimes tput can get confused as to where terminfo is
# so far (need to check fedora) it's here:
if [[ -d /usr/share/terminfo ]]
then
  export TERMINFO=/usr/share/terminfo
fi

INFOPATH+=/usr/share/info:/usr/local/share/info:${INFOPATH}:${HOME}/sw/share/info:${HOME}/.local/share/info:${HOME}/info

###############################
# Non interactive stuff only! #
###############################

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
    maybe_source_file $(brew --prefix)/etc/bash_completion
fi

maybe_source_file /usr/share/bash-completion/bash_completion
maybe_source_file /etc/bash_completion


# RBENV
if which rbenv > /dev/null 2>&1;
then
    eval "$(rbenv init -)"
fi

# OPAM configuration
if [[ -f $HOME/.opam/opam-init/init.sh ]]
then
    . $HOME/.opam/opam-init/init.sh
fi

# Setup Java versions
# if [[ -x /usr/libexec/java_home ]]
# then
#     export JAVA_HOME=$(/usr/libexec/java_home)
# fi

##### Plan 9 Support #######
# This needs to be "enabled"
# if [[ -d /usr/local/plan9  && -f ${HOME}/lib/plumbing ]];
# then
#     export PLAN9=/usr/local/plan9
#     maybe_prepend_path $PLAN9/bin
# fi

### PERL
#PERL_MB_OPT="--install_base \"/Users/brian/perl5\""; export PERL_MB_OPT;
#PERL_MM_OPT="INSTALL_BASE=/Users/brian/perl5"; export PERL_MM_OPT;

maybe_source_file ${HOME}/dots/prompt.sh
