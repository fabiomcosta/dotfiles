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
    mkdir -p "$(dirname "$1")"
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

if [ ! -d "$(dirname $DIR)/secrets" ]; then
  echo "Cloning secrets repo..."
  git clone https://github.com/fabiomcosta/secrets.git "$(dirname $DIR)/secrets"
else
  echo "${OK} `hl 'secrets'` already available."
fi

if [ $MACOS ]; then
  bash -c "$DIR/macos"
fi

pushd $HOME &> /dev/null
  create_ln_for ".vim" "$DIR/vim/.vim"
  create_ln_for ".vimrc" "$DIR/vim/.vimrc"
  create_ln_for ".bash_profile" "$DIR/.bash_profile"
  create_ln_for ".ackrc" "$DIR/.ackrc"
  create_ln_for ".ripgreprc" "$DIR/.ripgreprc"
  create_ln_for ".tmux.conf" "$DIR/.tmux.conf"
  create_ln_for ".config/alacritty/alacritty.yml" "$DIR/alacritty.yml"
  create_ln_for ".config/fish/config.fish" "$DIR/fish/config.fish"
  create_ln_for ".config/karabiner" "$DIR/karabiner"
  create_ln_for ".config/nvim/init.vim" "$DIR/vim/.vimrc"
  create_ln_for ".config/nvim/coc-settings.json" "$DIR/vim/.vim/coc-settings.json"
popd &> /dev/null

if ! command_exists node; then
  echo "${ERROR} You need to install nodejs before running this script."
  exit 1
fi

pushd $DIR &> /dev/null
  npm install .
popd &> /dev/null

pushd $HOME &> /dev/null
  $DIR/bin/apply_template.js ".gitconfig" "$DIR/.gitconfig"
popd &> /dev/null

if command_exists nvim; then
  if [ ! -d "$HOME/.local/share/nvim/site/autoload/plug.vim" ]; then
    echo "Installing `hl 'vim-plug'` for neovim..."
    curl -fLo $HOME/.local/share/nvim/site/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  else
    echo "${OK} `hl 'vim-plug'` for neovim is already installed."
  fi

  echo "Installing/Updating `hl "neovim's plugins"`..."
  nvim -f +PlugInstall +qall
  if [ $? -eq 0 ]; then
    echo "${OK} `hl "neovim's plugins"` updated successfuly.";
  else
    echo "${ERROR} We had a problem while updating `hl "neovim's plugins"`.";
    exit 1
  fi
fi

if [ ! -d "$HOME/.keyboard" ]; then
  echo "Cloning keyboard repo..."
  git clone https://github.com/fabiomcosta/keyboard.git "$HOME/.keyboard"
  pushd $HOME/.keyboard &> /dev/null
    ./script/setup
  popd &> /dev/null
else
  echo "${OK} `hl 'keyboard'` already available."
fi

echo "Setting rebase to be the default for the master branch on this repo..."
git config branch.master.rebase true
