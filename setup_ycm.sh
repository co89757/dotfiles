#!/usr/bin/env bash


echo "Prerequisites for installing YCM"
hash clang 2>/dev/null || sudo apt-get install clang 
sudo apt-get install build-essential cmake python-dev python3-dev
echo "cd to ~/.vim/bundle/YouCompleteMe"
cd ~/.vim/bundle/YouCompleteMe && ./install.py --clang-completer --system-libclang
EXTRA_CONFIG_FILE=.ycm_extra_conf.py
if [[ -e ./${EXTRA_CONFIG_FILE} ]]; then
  echo "Found $EXTRA_CONFIG_FILE!"
else
  echo "$EXTRA_CONFIG_FILE not found, please provide"
  exit 1
fi

echo "Copying the .ycm_extra_conf.py file to .vim/bundle/YouCompleteMe/"
cp $EXTRA_CONFIG_FILE ~/.vim/bundle/YouCompleteMe/ && echo "copy complete~"

echo " == YCM is done setup =="
