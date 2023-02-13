set -uo pipefail
trap "echo 'error: Script failure: see failed command above '" ERR
export PS4="'+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'"
## BEGIN: GLOBAL VARIABLES
DRYRUN=0
script_debug=0 #Switch for debug mode
PI=192.168.1.34
## END: GLOBAL VARIABLES

debugme() {
 [[ $script_debug = 1 ]] && "$@" || :
# be sure to append || : or || true here or use return 0, since the return code
# of this function should always be 0 to not influence anything else with an unwanted
# "false" return code (for example the script's exit code if this function is used
# as the very last command in the script)
}

RED="\e[31m"
B_RED="\e[j1;31m"
GREEN="\e[32m"
B_GREEN="\e[1;32m"
YELLOW="\e[33m"
B_YELLOW="\e[1;33m"
BLUE="\e[34m"
B_BLUE="\e[1;34m"
NIL="\e[0m"

logdebug(){
 local msg=${1:-}
 shift
 printf "${B_BLUE}[INFO]${NIL} ${BLUE}${msg}${NIL}\n" "$@"
}

loginfo(){
 local msg=${1:-}
 shift
 printf "${B_GREEN}[INFO]${NIL} ${GREEN}${msg}${NIL}\n" "$@"
}

logerr(){
 local msg=${1:-}
 shift
 printf "${B_RED}[ERROR]${NIL} ${RED}${msg}${NIL}\n" "$@"
}

logfatal(){
 local msg=${1:-}
 shift
 printf "${B_RED}[FATAL]${NIL} ${RED}${msg}${NIL}\n" "$@"
 exit 1
}

logwarning(){
 local msg=${1:-}
 shift
 printf "${B_YELLOW}[WARN]${NIL} ${YELLOW}${msg}${NIL}\n" "$@"
}
# usage: confirm "prompt" && yes-action || no-action
confirm () {
  read -r -n 1 -p "${1:-"please confirm "} [y/n]:" ans
  echo
  case "$ans" in
   y|Y ) return 0 ;;
   n|N )
    return 1  ;;
   *)
    logfatal "invalid answer: $ans"
    ;;
  esac
}

########### ARG PARSING ############
while [[ $# -gt 1 ]];do
 flag=$1
 case "$flag" in
  -n )
    DRYRUN=1
    loginfo "DRYRUN mode is turned on"
    shift
    ;;
  *)
   echo "unknown flag"
   ;;
 esac
 shift # past current flag
done


########### MAIN #################

loginfo "----- INSTALL THE ESSENTIAL PACKAGES ------"
PKGS=(tmux curl ranger xclip xsel fcitx5 fcitx-rime ripgrep fzf fd-find \
python3-dev build-essential \
mpv pqiv ffmpeg zathura)

loginfo "Essential packages:%s" "${PKGS[*]}"
sudo apt update
(( DRYRUN )) && loginfo "sudo apt install ${PKGS[@]}" || sudo apt install ${PKGS[@]}


loginfo "------ ESSENTIAL CONFIGURATION -------"
loginfo "----- COPY .bashrc -----"
[[ -f .bashrc ]] && {cp .bashrc ~/ ; touch ~/.more_bashrc; . ~/.bashrc; }
loginfo "----- copy .tmux.conf ---"
[[ -f .tmux.conf ]] && cp .tmux.conf ~/
loginfo "----- Set up vim -----"
[[ -f setup_vimtheme.sh ]] && bash setup_vimtheme.sh || sed -i -e 's/^colorscheme.*$/"&/' vim8.vimrc
[[ -f setup_vimrc.sh ]] && bash setup_vimrc.sh || logfatal "Setup_vimrc.sh not found"
loginfo "------Set up SSH config ----"
[[ -f .ssh_config ]] && { mkdir -p ~/.ssh ; cp .ssh_config ~/.ssh/config; cat ~/.ssh/config; } || logerror "No .ssh_config found. skip."
loginfo "------Set up RIME config ----"
if [[ -d ~/.config/fcitx/rime ]]; then
  echo "---- copy RIME config backup from pi"
  scp -r pi@$PI:~/backup/config/rime/* ~/.config/fcitx/rime/
fi
[[ -f .gitconfig  ]] && {echo "---Copy gitconfig ---"; cp .gitconfig ~/; }

if confirm "do you want to install brave-browser?" ;then
  sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
  sudo apt update
  sudo apt install brave-browser
fi







