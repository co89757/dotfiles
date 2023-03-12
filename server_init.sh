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
debugme() {
  (( SCRIPT_DEBUG )) && echo "${PURPLE}DEBUG:$*${NIL}" || :
  # be sure to append || : or || true here or use return 0, since the return code
  # of this function should always be 0 to not influence anything else with an unwanted
  # "false" return code (for example the script's exit code if this function is used
  # as the very last command in the script)
}

loginfo() {
  local msg=${1:-}
  shift
  printf "${B_GREEN}[INFO]${NIL} ${GREEN}${msg}${NIL}\n" "$@"
}

logdebug() {
  local msg=${1:-}
  shift
  printf "${B_BLUE}[DEBUG]${NIL} ${BLUE}${msg}${NIL}\n" "$@"
}

logerr() {
  local msg=${1:-}
  shift
  printf "${B_RED}[ERROR]${NIL} ${RED}${msg}${NIL}\n" "$@"
}

logfatal() {
  local msg=${1:-}
  shift
  printf "${B_RED}[FATAL]${NIL} ${RED}${msg}${NIL}\n" "$@"
  exit 1
}

logwarning() {
  local msg=${1:-}
  shift
  printf "${B_YELLOW}[WARN]${NIL} ${YELLOW}${msg}${NIL}\n" "$@"
}


############### Initial VM sever setup ##################
#########################################################
DOTFILE_REPO=https://github.com/co89757/dotfiles.git
loginfo "STEP0: Update package registry"
sudo apt update
loginfo "STEP1: Basic config and dotfiles setup"
mkdir -p ~/{borg,script,misc}
loginfo "STEP1.1 Copy bashrc"
[[ -f ./.bashrc ]] && cp ./.bashrc ~/ || :
loginfo "STEP1.2 Copy vimrc"
bash setup_vimrc.sh
bash setup_vimtheme.sh
loginfo "STEP2: Install docker"
bash install_docker.sh


