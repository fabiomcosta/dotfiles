#!/usr/bin/env bash

OK=`printf "\033[1;32m✓\033[0m"`
WARNING=`printf "\033[1;33m⚠\033[0m"`
ERROR=`printf "\033[1;31m✖\033[0m"`

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

install() {
    command=$1
    shift
    if [ ! `which $command` ]; then
        echo "Installing `hl $command`..."
        $@
        if [ $? -eq 0 ]; then
            echo "${OK} `hl $command` successfully installed."
        else
            echo "${ERROR} a problem happened while installing `hl $command`."
            exit 1
        fi
    else
        echo "${OK} `hl $command` is already installed."
    fi
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

install brew ruby -e "$(curl -fsSkL raw.github.com/mxcl/homebrew/go)"
install mvim brew install macvim --with-lua --override-system-vim
install git brew install git

# clone the vundle plugin, to manage vim plugins
if [ ! -d "$HOME/.vim/bundle/vundle/.git" ]; then
    echo "Installing `hl 'vundle'`..."
    git clone https://github.com/gmarik/vundle.git $HOME/.vim/bundle/vundle
else
    echo "${OK} `hl 'vundle'` is already installed."
fi

# updating vim's plugins
if [ `which mvim` ]; then
    echo "Installing/Updating `hl "macvim's plugins"`..."
    mvim -f +BundleInstall! +qall
    if [ $? -eq 0 ]; then
        echo "${OK} `hl "macvim's plugins"` updated successfuly.";
    else
        echo "${ERROR} We had a problem while updating `hl "macvim's plugins"`.";
        exit 1
    fi
fi

pushd $HOME &> /dev/null
    echo "Sourcing `hl ".bash_profile"`...";
    source ".bash_profile"
popd &> /dev/null
