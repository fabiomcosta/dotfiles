#!/usr/bin/env bash

DEV="$HOME/Dev"

append_if_exists() {
    path_var_value=$(eval echo $`echo $1`)
    if [[ -e "$2" ]]; then
        # remove the path from $path_var_value
        # also cleans leading ":" chars
        path_var_value=`echo "$path_var_value" | perl -ple "s,(^|:)$2(:|$),:,g" | perl -ple 's,^:|:$,,g'`
        export $1="$path_var_value:$2"
    fi
}

prepend_if_exists() {
    path_var_value=$(eval echo $`echo $1`)
    if [[ -e "$2" ]]; then
        # remove the path from $path_var_value
        # also cleans leading ":" chars
        path_var_value=`echo "$path_var_value" | perl -ple "s,(^|:)$2(:|$),:,g" | perl -ple 's,^:|:$,,g'`
        export $1="$2:$path_var_value"
    fi
}

execute_if_exists() {
    if [[ -s "$2" ]]; then
        $1 "$2"
    fi
}

command_exists() {
    hash $1 2> /dev/null
}

start_slow() {
    sudo ipfw pipe 1 config bw 100KByte/s
    sudo ipfw add 1 pipe 1 src-port $1
}

stop_slow() {
    sudo ipfw delete 1
}

findd() {
    # find files containing all the passed arg
    # example: findd landing html -> landing.html some_landing_some.html
    find . $(echo `( for arg in $@; do echo "-iname *$arg*"; done )`)
}

myip() {
    ip="`ifconfig | grep 192 | awk '{print \$2}'`"
    print "$ip"
    echo "$ip" | pbcopy
}


# PS1 structure
PWD() {
    pwd | awk -F\/ '{if (NF>4) print "...", $(NF-2), $(NF-1), $(NF); else if (NF>3) print $(NF-2),$(NF-1),$(NF); else if (NF>2) print $(NF-1),$(NF); else if (NF>1) print $(NF);}' | sed -e 's# #\/#g'
}
RED="\[\033[0;31m\]"
YELLOW="\[\033[0;33m\]"
GREEN="\[\033[0;32m\]"
LIGHTBLUE="\[\033[1;34m\]"
LIGHTYELLOW="\[\033[1;33m\]"
LIGHTCYAN="\[\033[1;36m\]"
NOCOLOR="\[\e[0m\]"
export PS1="$RED[\$(date +%H:%M)]$NOCOLOR $LIGHTBLUE\u$NOCOLOR@$LIGHTYELLOW\h $NOCOLOR[/\$(PWD)]$LIGHTCYAN\$(__git_ps1)$NOCOLOR\n\$ "

# increases number of open files per process
# needed to make thumbor tests work.
# http://superuser.com/questions/433746/is-there-a-fix-for-the-too-many-open-files-in-system-error-on-os-x-10-7-1
ulimit -S -n 2048

export EDITOR=`which vim`
if command_exists mvim; then
    alias mvim='mvim -v'
    alias vim='mvim -v'
    alias vi='mvim -v'
fi

## aliases
alias la='ls -a'
alias ll='ls -l'
alias g='git'
alias gs='git status'
alias gd='git diff'
alias eb="$EDITOR ~/.bash_profile; source ~/.bash_profile"
alias dev='ssh dev -t "export PATH="\$HOME/bin:\$PATH"; if which tmux 2>&1 >/dev/null; then test -z "$TMUX" && (tmux attach || tmux new-session) fi"'

## colors
export TERM=xterm-256color
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad

# nvm
execute_if_exists source $HOME/.nvm/nvm.sh
# do not create .pyc files
export PYTHONDONTWRITEBYTECODE=x
# virtualenv
export WORKON_HOME=$HOME/.virtualenvs
# RVM
execute_if_exists source $HOME/.rvm/scripts/rvm # Load RVM into a shell session *as a function*
# adds arc path to the current path
append_if_exists PATH $DEV/fb/devtools/arcanist/bin

## adding brew paths to PATH and other brew specific stuff
if command_exists brew; then
    ## brew
    BREW_PREFIX=`brew --prefix`

    ## ruby
    prepend_if_exists PATH `brew --prefix ruby`/bin

    ## node
    prepend_if_exists NODE_PATH $BREW_PREFIX/lib/node_modules
    prepend_if_exists PATH      $BREW_PREFIX/share/npm/bin

    ## python opencv module
    prepend_if_exists PYTHONPATH $BREW_PREFIX/lib/python2.7/site-packages
    ## virtualenv
    execute_if_exists source $BREW_PREFIX/bin/virtualenvwrapper.sh
    # execute_if_exists source $BREW_PREFIX/share/python/virtualenvwrapper.sh
    export VIRTUALENV_DISTRIBUTE="x" # makes --distribute the default

    ## python3 with more priority than python2
    prepend_if_exists PATH $BREW_PREFIX/share/python3

    if command_exists complete; then
        # bash completion
        execute_if_exists source $BREW_PREFIX/etc/bash_completion
    fi

    prepend_if_exists PATH $BREW_PREFIX/bin
    prepend_if_exists PATH $BREW_PREFIX/sbin
fi

# prepends my bin folder to the path
prepend_if_exists PATH $HOME/bin

if command_exists complete; then
    # pip bash completion start
    _pip_completion()
    {
        COMPREPLY=( $( COMP_WORDS="${COMP_WORDS[*]}" \
                    COMP_CWORD=$COMP_CWORD \
                    PIP_AUTO_COMPLETE=1 $1 ) )
    }
    complete -o default -F _pip_completion pip
    # pip bash completion end
fi
