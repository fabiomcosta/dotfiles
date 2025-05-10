#!/usr/bin/env bash

DIR=$(dirname "$0")

add_brewpath_to_path(){
    local brew_path=${HOME}/homebrew/bin
    if [[ -d "$brew_path" ]]; then
        export PATH=$PATH:$brew_path
    else
        local brew_path=/usr/local/bin
        if [[ -d "$brew_path" ]]; then
            export PATH=$PATH:$brew_path
        else
            echo "$brew_path is not a directory. Did you install homebrew on another folder?"
        fi
    fi
}

main() {
    add_brewpath_to_path
    eval "$(fnm env)"
    node $DIR/cron_root_script.js
}

main
