#/usr/bin/env bash

OK=`printf "\033[1;32m✓\033[0m"`
WARNING=`printf "\033[1;33m⚠\033[0m"`
ERROR=`printf "\033[1;31m✖\033[0m"`

create_ln_for() {
    if [ ! -e "$1" ]; then
        ln -s "$2" "$1"
    elif [ -L "$1" ]; then
        echo "${OK} Symlink for \"$1\" was already created."
    else
        if [ -f "$1" ]; then
            echo "${WARNING} There is already a \"$1\" file inside your home folder."
        elif [ -d "$1" ]; then
            echo "${WARNING} There is already a \"$1\" folder inside your home folder."
        else
            echo "${ERROR} \"$1\" isn't a symlink nor a folder nor a file. Do something!"
        fi
    fi
}

pwd=$PWD

pushd $HOME
    create_ln_for ".vim" "$pwd/vim/.vim"
    create_ln_for ".vimrc" "$pwd/vim/.vimrc"
    create_ln_for ".bash_profile" "$pwd/.bash_profile"
    create_ln_for ".gitconfig" "$pwd/.gitconfig"
    create_ln_for ".ackrc" "$pwd/.ackrc"
    create_ln_for ".js" "$pwd/.js"
    source ".bash_profile"
popd

if [ ! `which brew` ]; then
    echo "Installing brew..."
    ruby -e "$(curl -fsSkL raw.github.com/mxcl/homebrew/go)"
    if [[ "$?" ]]; then
        echo "${ERROR} a problem happened while installing brew.";
    else
        echo "${OK} brew successfully installed.";
    fi
else
    echo "${OK} brew is already installed."
fi

if [ ! `which mvim` ]; then
    echo "Installing macvim..."
    brew install macvim --with-lua --override-system-vim
    if [[ "$?" ]]; then
        echo "${ERROR} a problem happened while installing macvim";
    else
        echo "${OK} macvim successfully installed.";
    fi
else
    echo "${OK} macvim is already installed."
fi

# clone the vundle plugin, to manage vim plugins
if [ ! -e $HOME/.vim/bundle/vundle ]; then
    echo "Installing vundle..."
    git clone https://github.com/gmarik/vundle.git $HOME/.vim/bundle/vundle
else
    echo "${OK} vim's vundle is already installed."
fi

if [ ! `which mvim` ]; then
    echo "Installing/Updating macvim's plugins..."
    mvim +BundleInstall! +qall
    if [[ "$?" ]]; then
        echo "${ERROR} We had a problem while updating macvim's plugins.";
    else
        echo "${OK} macvim's plugins updated successfuly.";
    fi
fi
