#!/usr/bin/env bash

DEV="$HOME/Dev"

export_if_exists() {
  local var_name=$1
  local path="$2"
  if [[ -e "$path" ]]; then
    export $var_name="$path"
  fi
}

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
  ssh $1 -t "source ~/.bash_profile && tmux attach -d"
}

tmosh() {
  mosh -6 $1 -- bash -c "source ~/.bash_profile && tmux attach -d"
}

# d8
d8_update() {
  pushd $DEV/tp/v8/
    git checkout master
    git pull
    gclient sync
    GYP_GENERATORS=ninja build/gyp_v8
    ninja -C out/Debug d8
  popd
}

# sets bash vi mode
set -o vi

## aliases
export EDITOR=`which vim`
if command_exists mvim; then
  alias vim='mvim -v'
  alias vi='mvim -v'
fi

# because sometimes I type 'ack' accidentaly (muscle memory)
if command_exists rg && ! command_exists ack; then
  alias ack='rg'
fi

export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'

alias la='ls -a'
alias ll='ls -l'
alias simpleserver='python -m SimpleHTTPServer'
alias d8="$DEV/tp/v8/out/Debug/d8"
alias cat='bat'
alias ping='prettyping --nolegend'
alias help='tldr'

## colors
export TERM=xterm-256color
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad


## adding brew paths to PATH and other brew specific stuff
if command_exists brew; then
  ## brew
  BREW_PREFIX=`brew --prefix`

  ## ruby
  prepend_if_exists PATH "$(brew --prefix ruby)/bin"

  ## node
  prepend_if_exists NODE_PATH $BREW_PREFIX/lib/node_modules
  prepend_if_exists PATH      $BREW_PREFIX/share/npm/bin

  prepend_if_exists PATH $BREW_PREFIX/bin
  prepend_if_exists PATH $BREW_PREFIX/sbin

  append_if_exists PKG_CONFIG_PATH "$(brew --prefix libffi)/lib/pkgconfig"

  if command_exists complete; then
    # bash completion
    execute_if_exists source $BREW_PREFIX/etc/bash_completion
  fi

  if [ -f "$(brew --prefix bash-git-prompt)/share/gitprompt.sh" ]; then
    GIT_PROMPT_THEME=Default
    source "$(brew --prefix bash-git-prompt)/share/gitprompt.sh"
  fi
fi


# autocomplete for ctrl-r
if command_exists fzf; then
  source "$HOME/.fzf.bash"
fi


# do not create .pyc files
export PYTHONDONTWRITEBYTECODE=x

if command_exists pyenv; then
  export PYTHON_CONFIGURE_OPTS="--enable-framework"
  eval "$(pyenv init -)"

  if command_exists pyenv-virtualenv-init; then
    eval "$(pyenv virtualenv-init -)"
  fi
fi

# prepends depot_tools from the chromium project
prepend_if_exists PATH $DEV/other/depot_tools

# prepends my bin folder to the path
prepend_if_exists PATH $HOME/bin

# prepends my gdrive/code/gd/bin folder to the path
prepend_if_exists PATH $HOME/gdrive/code/gd/bin

# export ANDROID_SDK_ROOT="/usr/local/share/android-sdk"
# export ANDROID_HOME="$ANDROID_SDK_ROOT"

# node n
export N_PREFIX="$HOME/.node_n"; [[ :$PATH: == *":$N_PREFIX/bin:"* ]] || PATH+=":$N_PREFIX/bin"  # Added by n-install (see http://git.io/n-install-repo).

execute_if_exists source "$HOME/.$(hostname)"
###-begin-gd-completions-###
#
# yargs command completion script
#
# Installation: gd completion >> ~/.bashrc
#    or gd completion >> ~/.bash_profile on OSX.
#
_yargs_completions()
{
    local cur_word args type_list

    cur_word="${COMP_WORDS[COMP_CWORD]}"
    args=("${COMP_WORDS[@]}")

    # ask yargs to generate completions.
    type_list=$(gd --get-yargs-completions "${args[@]}")

    COMPREPLY=( $(compgen -W "${type_list}" -- ${cur_word}) )

    # if no match was found, fall back to filename completion
    if [ ${#COMPREPLY[@]} -eq 0 ]; then
      COMPREPLY=( $(compgen -f -- "${cur_word}" ) )
    fi

    return 0
}
complete -F _yargs_completions gd
###-end-gd-completions-###

