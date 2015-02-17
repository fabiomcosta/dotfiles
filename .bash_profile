#!/usr/bin/env bash

DEV="$HOME/Dev"

append_if_exists() {
  local var_name=$1
  local path_var_value="$(eval echo $`echo $var_name`)"
  local path="$2"
  if [[ -e "$path" ]]; then
    # remove the path from $path_var_value
    # also cleans leading ":" chars
    local path_var_value=`echo "$path_var_value" | perl -ple "s,(^|:)$path(:|$),:,g" | perl -ple 's,^:|:$,,g'`
    export $var_name="$path_var_value:$path"
  fi
}

prepend_if_exists() {
  local var_name=$1
  local path_var_value="$(eval echo $`echo $var_name`)"
  local path="$2"
  if [[ -e "$path" ]]; then
    # remove the path from $path_var_value
    # also cleans leading ":" chars
    local path_var_value=`echo "$path_var_value" | perl -ple "s,(^|:)$path(:|$),:,g" | perl -ple 's,^:|:$,,g'`
    export $var_name="$path:$path_var_value"
  fi
}

execute_if_exists() {
  local cmd=$1
  local path="$2"
  if [[ -s "$path" ]]; then
    $cmd "$path"
  fi
}

command_exists() {
  local cmd=$1
  hash $cmd 2> /dev/null
}

start_slow() {
  local port=$1
  sudo ipfw pipe 1 config bw 100KByte/s
  sudo ipfw add 1 pipe 1 src-port $port
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
  local ip="`ifconfig | grep 192 | awk '{print \$2}'`"
  echo "$ip"
  echo "$ip" | pbcopy
}

tssh() {
  ssh $1 -t "source ~/.bash_profile && tmux attach"
}

tmosh() {
  mosh $1 -- tmux attach
}

# PS1 structure
_PWD() {
  pwd | awk -F\/ '{if (NF>4) print "...", $(NF-2), $(NF-1), $(NF); else if (NF>3) print $(NF-2),$(NF-1),$(NF); else if (NF>2) print $(NF-1),$(NF); else if (NF>1) print $(NF);}' | sed -e 's# #\/#g'
}
RED="\[\033[0;31m\]"
YELLOW="\[\033[0;33m\]"
GREEN="\[\033[0;32m\]"
LIGHTBLUE="\[\033[1;34m\]"
LIGHTYELLOW="\[\033[1;33m\]"
LIGHTCYAN="\[\033[1;36m\]"
NOCOLOR="\[\e[0m\]"
export PS1="$RED[\$(date +%H:%M)]$NOCOLOR $LIGHTBLUE\u$NOCOLOR@$LIGHTYELLOW\h $NOCOLOR[/\$(_PWD)]$LIGHTCYAN\$(__git_ps1)$NOCOLOR\n\$ "

export EDITOR=`which vim`
if command_exists mvim; then
  alias mvim='mvim -v'
  alias vim='mvim -v'
  alias vi='mvim -v'
fi

# sets bash vi mode
set -o vi

## aliases
alias la='ls -a'
alias ll='ls -l'
alias g='git'
alias gs='git status'
alias gd='git diff'
alias eb="$EDITOR ~/.bash_profile; source ~/.bash_profile"
alias simpleserver='python -m SimpleHTTPServer'
if [[ -e "$HOME/Applications/node-webkit.app/Contents/MacOS/node-webkit" ]]; then
  alias nw="$HOME/Applications/node-webkit.app/Contents/MacOS/node-webkit"
fi

## colors
export TERM=xterm-256color
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad

# android
export ANDROID_HOME=$HOME/Dev/android/sdk
prepend_if_exists PATH $ANDROID_HOME/tools

# nvm
execute_if_exists source $HOME/.nvm/nvm.sh

# do not create .pyc files
export PYTHONDONTWRITEBYTECODE=x
# virtualenv
export WORKON_HOME=$HOME/.virtualenvs
export PIP_VIRTUALENV_BASE=$WORKON_HOME
export PIP_RESPECT_VIRTUALENV=true

# RVM
execute_if_exists source $HOME/.rvm/scripts/rvm # Load RVM into a shell session *as a function*

## adding brew paths to PATH and other brew specific stuff
if command_exists brew; then
  ## brew
  BREW_PREFIX=`brew --prefix`

  ## ruby
  prepend_if_exists PATH `brew --prefix ruby`/bin

  ## node
  prepend_if_exists NODE_PATH $BREW_PREFIX/lib/node_modules
  prepend_if_exists PATH      $BREW_PREFIX/share/npm/bin

  ## python3 with more priority than python2
  prepend_if_exists PATH $BREW_PREFIX/share/python3

  prepend_if_exists PATH $BREW_PREFIX/bin
  prepend_if_exists PATH $BREW_PREFIX/sbin

  if command_exists complete; then
    # bash completion
    execute_if_exists source $BREW_PREFIX/etc/bash_completion
  fi

  ## virtualenv
  execute_if_exists source $BREW_PREFIX/bin/virtualenvwrapper.sh
fi

# prepends depot_tools from the chromium project
prepend_if_exists PATH $DEV/other/depot_tools

# prepends my bin folder to the path
prepend_if_exists PATH $HOME/bin

if command_exists complete; then
  # run `complete -p` to see already available autocomplete functions
  complete -F _ssh tssh

  # pip bash completion start
  _pip_completion() {
    COMPREPLY=( $( COMP_WORDS="${COMP_WORDS[*]}" \
                COMP_CWORD=$COMP_CWORD \
                PIP_AUTO_COMPLETE=1 $1 ) )
  }
  complete -o default -F _pip_completion pip
  # pip bash completion end
fi
