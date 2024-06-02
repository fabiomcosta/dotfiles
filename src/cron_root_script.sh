#!/usr/bin/env bash

DIR=$(dirname "$0")

add_brewpath_to_path(){
    # This is only valid because of how I'm installing homebrew on my machine today
    local brew_path=${HOME}/homebrew/bin
    if [[ -d "$brew_path" ]]; then
        export PATH=$PATH:$brew_path
    else
        echo "$brew_path is not a directory. Did you install homebrew on another folder?"
    fi
}

main() {
    add_brewpath_to_path
    eval "$(fnm env)"
    node $DIR/cron_root_script.js
}

main
