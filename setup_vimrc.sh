#!/usr/bin/env bash 

echo "installing ctags if not found"
hash ctags 2>/dev/null || sudo apt-get install exuberant-ctags 

if [[ ! -e vim8.vimrc ]]; then
	echo "Did not find vim8.vimrc file in current directory, please check again."
	exit 1 
fi

echo "----- setting up your .vimrc and install Vundle ..."

echo "--- copy vimrc to your home dir ---"
cp vim8.vimrc ~/
echo "---- installing vundle package manager ---- "
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

vim +PluginInstall +qall
