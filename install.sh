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
      echo "${ERROR} `hl $1` isn't a symlink, folder or file. Do something!"
      exit 1
    fi
  fi
}

command_exists() {
  hash $1 2> /dev/null
}

if [ $MACOS ]; then
  bash -c "$DIR/macos"
fi

curl -L https://git.io/n-install | bash -s -- -y lts

if ! command_exists node; then
  echo "${ERROR} You need to install nodejs before running this script."
  exit 1
fi

pushd $DIR &> /dev/null
  npm install .
popd &> /dev/null

pushd $HOME &> /dev/null
  $DIR/bin/apply_template.js ".gitconfig" "$DIR/.gitconfig"
  create_ln_for ".vim" "$DIR/vim/.vim"
  create_ln_for ".vimrc" "$DIR/vim/.vimrc"
  create_ln_for ".bash_profile" "$DIR/.bash_profile"
  create_ln_for "./fish/config.fish" "$DIR/.config/fish/config.fish"
  create_ln_for ".ackrc" "$DIR/.ackrc"
  create_ln_for ".tmux.conf" "$DIR/.tmux.conf"
popd &> /dev/null

# setup backup job
pushd $HOME &> /dev/null
  mkdir -p bin
  create_ln_for "bin/mortadela" "$DIR/templates/bin/mortadela"
  $DIR/bin/apply_template.js \
    "Library/LaunchAgents/com.fabs.mortadela.plist" \
    "$DIR/templates/LaunchAgents/com.fabs.mortadela.plist"
  sudo chown root:wheel "$HOME/Library/LaunchAgents/com.fabs.mortadela.plist"
  sudo launchctl load -w "$HOME/Library/LaunchAgents/com.fabs.mortadela.plist"
popd &> /dev/null

# WE ARE EXPERIMENTING WITH TIME MACHINE BACKUP
# LOOK AT `macos` FILE
# pushd $HOME &> /dev/null
#   mkdir -p bin
#   create_ln_for "bin/framboesa" "$DIR/templates/bin/framboesa"
# popd &> /dev/null

# updating vim's plugins
if command_exists vim; then

  # install vim-plug
  if [ ! -d "$HOME/.vim/autoload/plug.vim" ]; then
    echo "Installing `hl 'vim-plug'`..."
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  else
    echo "${OK} `hl 'vim-plug'` is already installed."
  fi

  echo "Installing/Updating `hl "vim's plugins"`..."
  vim --noplugin -f +PlugInstall +qall
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
