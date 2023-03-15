#!/usr/bin/env bash

echo "installing ctags if not found"
hash ctags 2>/dev/null || sudo apt-get install exuberant-ctags

VIMRC=vim8.vimrc
BASIC=0
PS3="Choose the vimrc you want to set up (basic=plugin-free vanilla,full=battery-included) -->"
select choice in "basic" "full" ; do
 echo
 case $choice in
   basic )
     BASIC=1
     VIMRC=basic.vim
     break
     ;;
   full )
     VIMRC=vim8.vimrc
     BASIC=0
     break
     ;;
    *)
      echo "invalid choice, default to full vimrc"
      break
      ;;
 esac
done

echo "VIMRC to use: $VIMRC"

if [[ ! -f "$VIMRC" ]]; then
	echo "Did not find $VIMRC file in current directory, please check again."
	exit 1
fi

echo "----- setting up your .vimrc and install Vundle ..."

echo "--- copy vimrc to your home dir ---"
cp "$VIMRC" ~/.vimrc
mkdir -p ~/.vim/templates
echo "--- Copy vim template files ----"
rsync -aP ./vim-templates/ ~/.vim/templates
echo "---- installing vim-plug package manager ---- "
hash curl 2>/dev/null || sudo apt install curl
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
echo "----- running vim +PlugInstall +qall"
(( BASIC )) && echo "skip plugin-install (basic mode)" || vim +PlugInstall +qall
