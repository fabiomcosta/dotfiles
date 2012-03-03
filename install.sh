#/usr/bin/env bash

create_ln_if_not_yet_created(){
	if [ ! -e "$1" ]; then
		ln -s "$2" "$1"
	else
		echo "symbolic link for $1 already created."
	fi
}

pwd=$PWD

git submodule update --init --recursive

pushd $HOME
	create_ln_if_not_yet_created ".vim" "$pwd/vim/.vim"
	create_ln_if_not_yet_created ".vimrc" "$pwd/vim/.vimrc"
	create_ln_if_not_yet_created ".bash_profile" "$pwd/.bash_profile"
	source ".bash_profile"
popd

# clone the vundle plugin, to manage vim plugins
git clone https://github.com/gmarik/vundle.git $HOME/.vim/bundle/vundle
