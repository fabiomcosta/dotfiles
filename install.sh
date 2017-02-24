#!/usr/bin/env bash

OK=`printf "\033[1;32m✓\033[0m"`
WARNING=`printf "\033[1;33m⚠\033[0m"`
ERROR=`printf "\033[1;31m✖\033[0m"`
MACOS=$(test "`uname`" == "Darwin" && echo "x")
# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

if [ $MACOS ]; then
  source $DIR/macos
fi

if ! command_exists node; then
  echo "${ERROR} You need to install the nodejs project to run this script."
  exit 1
fi

npm install .

./bin/apply_template.js "$HOME/.gitconfig" "$DIR/.gitconfig"

# TODO do this using nodejs and a template engine
pushd $HOME &> /dev/null
  create_ln_for ".vim" "$DIR/vim/.vim"
  create_ln_for ".vimrc" "$DIR/vim/.vimrc"
  create_ln_for ".bash_profile" "$DIR/.bash_profile"
  create_ln_for ".ackrc" "$DIR/.ackrc"
  create_ln_for ".js" "$DIR/.js"
  create_ln_for ".tmux.conf" "$DIR/.tmux.conf"
popd &> /dev/null


# clone the neobundle plugin, to manage vim plugins
if [ ! -d "$HOME/.vim/bundle/neobundle.vim/.git" ]; then
  echo "Installing `hl 'neobundle'`..."
  git clone https://github.com/Shougo/neobundle.vim.git $HOME/.vim/bundle/neobundle.vim
else
  echo "${OK} `hl 'neobundle'` is already installed."
fi

# updating vim's plugins
if command_exists vim; then
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
