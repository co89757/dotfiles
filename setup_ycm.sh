#!/usr/bin/env bash


echo "Prerequisites for installing YCM"
sudo apt-get install build-essential cmake python-dev python3-dev 
echo "cd to ~/.vim/bundle/YouCompleteMe"
cd ~/.vim/bundle/YouCompleteMe && ./install.py --clang-completer 
EXTRA_CONFIG_FILE=.ycm_extra_conf.py
if [[ -e $EXTRA_CONFIG_FILE ]]; then
  echo "Found $EXTRA_CONFIG_FILE!"
else
  echo "$EXTRA_CONFIG_FILE not found, please provide"
fi

echo "YCM setup ready!"
