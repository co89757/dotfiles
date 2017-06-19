#!/usr/bin/env bash 

if [[ ! -e .vimrc ]]; then
	echo "Did not find .vimrc file in current directory, please check again."
	exit 1 
fi

echo "----- setting up your .vimrc and install Vundle ..."

echo "--- copy vimrc to your home dir ---"
cp .vimrc ~/

git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

vim +PluginInstall +qall