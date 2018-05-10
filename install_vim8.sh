#!/usr/bin/env bash
sudo add-apt-repository ppa:jonathonf/vim
sudo apt update
sudo apt install vim 

echo "checking your vim version after update"
vim --version 
