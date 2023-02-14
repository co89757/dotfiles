# tested for ubuntu 22
set -euo pipefail
trap "echo 'error: Script failure: see failed command above '" ERR
export PS4="'+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'"
script_debug=0 #Switch for debug mode
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


sudo apt update
loginfo "---- Install prerequisite packages -----"
# install a few prerequisite packages which let apt use packages over HTTPS:
sudo apt install apt-transport-https ca-certificates curl software-properties-common
# Then add the GPG key for the official Docker repository to your system:
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
# Make sure you are about to install from the Docker repo instead of the default Ubuntu repo:
loginfo "---- Running apt-cache policy docker-ce -----------"
apt-cache policy docker-ce
## expected output
# docker-ce:
#   Installed: (none)
#   Candidate: 5:20.10.14~3-0~ubuntu-jammy
#   Version table:
#      5:20.10.14~3-0~ubuntu-jammy 500
#         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages
#      5:20.10.13~3-0~ubuntu-jammy 500
#         500 https://download.docker.com/linux/ubuntu jammy/stable amd64 Packages

loginfo "------ install docker --------"
sudo apt install docker-ce

loginfo "------- Run docker without sudo ------"
sudo usermod -aG docker $USER
loginfo "------- Active new group memership ----"


read -r -n 1 -p "Do you want to continue?(yY|nN) :" ans
case "$ans" in
  y|Y ) echo "You chose: YES"
    su - ${USER}
    loginfo "------- Confirm group change ---- "
    groups
    ;;
  n|N )
    echo "You chose NO"
    exit 1
    ;;
  *)
    echo "invalid answer: $ans"
    exit 1
    ;;
esac

loginfo " ------- Install Docker compose ---- "

mkdir -p ~/.docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/download/v2.15.0/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose && chmod u+x ~/.docker/cli-plugins/docker-compose
