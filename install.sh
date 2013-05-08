#!/usr/bin/env bash

OK=`printf "\033[1;32m✓\033[0m"`
WARNING=`printf "\033[1;33m⚠\033[0m"`
ERROR=`printf "\033[1;31m✖\033[0m"`
OSX=$(test "`uname`" == "Darwin" && echo "x")

# highlights values
hl() {
    printf "\033[1;37m$1\033[0m"
}

create_ln_for() {
    if [ ! -e "$1" ]; then
        ln -s "$2" "$1"
        echo "${OK} Symlink for `hl $1` created."
    elif [ -L "$1" ]; then
        echo "${OK} Symlink for `hl $1` was already created."
    else
        if [ -f "$1" ]; then
            echo "${WARNING} There is already a `hl $1` file inside your home folder."
        elif [ -d "$1" ]; then
            echo "${WARNING} There is already a `hl $1` folder inside your home folder."
        else
            echo "${ERROR} `hl $1` isn't a symlink nor a folder nor a file. Do something!"
            exit 1
        fi
    fi
}

command_exists() {
  hash $1 2> /dev/null
}

pwd=$PWD

pushd $HOME &> /dev/null
    create_ln_for ".vim" "$pwd/vim/.vim"
    create_ln_for ".vimrc" "$pwd/vim/.vimrc"
    create_ln_for ".bash_profile" "$pwd/.bash_profile"
    create_ln_for ".gitconfig" "$pwd/.gitconfig"
    create_ln_for ".ackrc" "$pwd/.ackrc"
    create_ln_for ".js" "$pwd/.js"
    create_ln_for ".irbrc" "$pwd/.irbrc"
    create_ln_for ".zshrc" "$pwd/.zshrc"
popd &> /dev/null

if [ $OSX ]; then
    echo "Executing some OSX specific changes..."
    if ! command_exists brew; then
      echo "Installing brew..."
      ruby -e "`curl -fsSkL raw.github.com/mxcl/homebrew/go`"
    fi
    brew install macvim --with-lua --override-system-vim
    brew install git bash-completion ack python ruby node tmux
    # decreases the delay repetition on keyboard
    defaults write NSGlobalDomain KeyRepeat -int 0
fi

# clone the neobundle plugin, to manage vim plugins
if [ ! -d "$HOME/.vim/bundle/neobundle.vim/.git" ]; then
    echo "Installing `hl 'neobundle'`..."
    git clone https://github.com/Shougo/neobundle.vim.git $HOME/.vim/bundle/neobundle.vim
else
    echo "${OK} `hl 'neobundle'` is already installed."
fi

# updating vim's plugins
if [[ $OSX && `which vim 2> /dev/null` ]]; then
    echo "Installing/Updating `hl "vim's plugins"`..."
    vim -f +NeoBundleInstall +qall
    if [ $? -eq 0 ]; then
        echo "${OK} `hl "vim's plugins"` updated successfuly.";
    else
        echo "${ERROR} We had a problem while updating `hl "vim's plugins"`.";
        exit 1
    fi
fi

echo "Setting rebase to be the default for the master branch on this repo..."
git config branch.master.rebase true

pushd $HOME &> /dev/null
    echo "Sourcing `hl ".bash_profile"`...";
    source ".bash_profile"
popd &> /dev/null
