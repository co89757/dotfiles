#!/usr/bin/env bash

RED="\e[31m"
B_RED="\e[1;31m"
GREEN="\e[32m"
B_GREEN="\e[1;32m"
YELLOW="\e[33m"
B_YELLOW="\e[1;33m"
BLUE="\e[34m"
PURPLE="\e[35m"
B_PURPLE="\e[1;35m"
B_BLUE="\e[1;34m"
NIL="\e[0m"
set -euo pipefail
trap "echo 'error: Script failure: see failed command above '" ERR
export PS4="'+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'"
SCRIPT_DEBUG=0 #Switch for debug mode
DRY=0
loginfo() {
  printf "${B_GREEN}[INFO]${NIL} ${GREEN}$*${NIL}\n"
}

logdebug() {
  (( SCRIPT_DEBUG )) && printf "${B_BLUE}[DEBUG]${NIL} ${BLUE}$*${NIL}\n" || :
}

logerr() {
  printf "${B_RED}[ERROR]${NIL} ${RED}$*${NIL}\n"
}

logfatal() {
  printf "${B_RED}[FATAL]${NIL} ${RED}$*${NIL}\n"
  exit 1
}

logwarning() {
  printf "${B_YELLOW}[WARN]${NIL} ${YELLOW}$*${NIL}\n"
}
#######################################################
## ---------- Parse arguments and flags ---------------
#######################################################

while [[ $# -gt 0 ]];do
 flag=$1
 case "$flag" in
  -n | --dry_run )
    DRY=1
    ;;
  -v | --verbose)
   SCRIPT_DEBUG=1
   ;;
  *)
   echo "unknown flag $1"
   ;;
 esac
 shift # past current flag
done
more_dirs=(borg dev/repo dev/script misc ~/.local/bin )
loginfo "Create more directories under home: ${more_dirs[*]}"
for di in ${more_dirs[@]}; do
  if [[ ! -d "$HOME/$di" ]]; then
   logdebug "~/$di does not exist, creating it..."
   (( DRY )) && loginfo "DRY_RUN: mkdir -p ~/$di" ||  mkdir -p "$HOME/$di"
  fi
done

loginfo "Install essential packages...."
basic_pkgs=(vim git curl jq )
for p in "${basic_pkgs[@]}"; do
 if hash $p &>/dev/null; then
   loginfo "missing essential package: $p. installing"
   (( DRY )) && loginfo "DRY_RUN: sudo apt install $p" ||  sudo apt install $p
 fi
done

more_pkgs=(fd-find net-tools)
loginfo "install more packages: ${more_pkgs[*]}"
if (( DRY )); then
 loginfo "DRY_RUN: sudo apt install ${more_pkgs[*]}"
 else
 sudo apt update && sudo apt install ${more_pkgs[*]}
fi

loginfo "install fzf..."
if (( ! DRY  )); then
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
fi

loginfo "Copy bashrc file..."
if (( DRY  )); then
  loginfo "DRY_RUN: cp .bashrc ~/.bashrc \ntouch ~/.more_bashrc\n"
else
  [[ -f .bashrc ]] && cp .bashrc ~/.bashrc || logwarning ".bashrc NOT FOUND. No copy done."

  loginfo "Create .more_bashrc"
  touch ~/.more_bashrc

  loginfo "Install z.sh"
  curl -o ~/dev/script/z.sh https://raw.githubusercontent.com/rupa/z/master/z.sh
  [[ -f ~/dev/script/z.sh ]] && echo "export _Z_SRC=~/dev/script/z.sh" >> ~/.more_bashrc
  loginfo "source .more_bashrc"
  source ~/.more_bashrc
fi
