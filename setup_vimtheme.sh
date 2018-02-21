#!/usr/bin/env bash

echo "setting up vim themes from vim-themes directory"
THEME_DIR=vim-themes
if [[ ! -d $THEME_DIR ]];then
  echo "theme folder $THEME_DIR not found. exit"
  exit 1
fi

VIM_COLOR_DIR=$HOME/.vim/color 

if [[ ! -d ${VIM_COLOR_DIR} ]]; then
    echo "${VIM_COLOR_DIR} not found, creating it ... "
    mkdir -p $VIM_COLOR_DIR
fi
echo "Copying color themes to vim color folder $VIM_COLOR_DIR"
cp $THEME_DIR/*.vim ~/.vim/color/

echo "DONE"