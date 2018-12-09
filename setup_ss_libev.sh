#!/usr/bin/env bash 
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
# set up shadowsocks server 
RED="\e[31m"
B_RED="\e[1;31m"
GREEN="\e[32m"
B_GREEN="\e[1;32m"
YELLOW="\e[33m"
B_YELLOW="\e[1;33m"
NIL="\e[0m"

loginfo(){
 local msg=${1:-}
 shift 
 printf "${B_GREEN}[INFO]${NIL} ${GREEN}${msg}${NIL}\n" $@ 
}

logerr(){
 local msg=${1:-}
 shift 
 printf "${B_RED}[ERROR]${NIL} ${RED}${msg}${NIL}\n" $@ 
}

logwarning(){
 local msg=${1:-}
 shift 
 printf "${B_YELLOW}[WARN]${NIL} ${YELLOW}${msg}${NIL}\n" $@ 
}

install_ss(){
  UBVER=$(echo $(lsb_release -r) | grep '[0-9.]\+' -o )
  hash ss-server 
  if [[ $? -eq 0 ]]; then
    logwarning "ss-server is already installed. exit ..."
    return
  fi
  echo "ubuntu version: $UBVER" 
  loginfo "==== install shadowsocks-libev now ====="
  case $UBVER in
    18.* )
      loginfo "version is above 18.04, directly pull from apt-get"
      sudo apt update 
      sudo apt install shadowsocks-libev simple-obfs 
      ;;
    16.04 | 14.04)
      loginfo "pull from PPA"
      sudo apt-get install software-properties-common -y
      sudo add-apt-repository ppa:max-c-lv/shadowsocks-libev -y
      sudo apt-get update
      sudo apt install shadowsocks-libev simple-obfs  
      ;;
    *) 
      logwarning "you may need to install ss yourself"
      ;;
  esac
}

if [[ $# -lt 2 ]]; then
	echo "Usage: <prog> -c|--config <sserver_config>"
	echo "please specify JSON config file path for sserver"
  exit 1 
fi

loginfo "This script is tested on ubuntu 18.04. your system info is:" 
lsb_release -a 
#1. check pre-requisites 
echo "========= Start shadowsocks-libev setup ====="
loginfo "[step0] update repository with sudo apt update "
hash pip 2> /dev/null || (echo "pip is missing. install it" && sudo apt-get install python-pip )
#install ss libev 
install_ss 

SSCONFIGFILE="N/A" 
echo "----- get config ----"
while [[ $# -gt 1 ]]; do
	key="$1"
	case $key in
		-c | --config )
			SSCONFIGFILE="$2"
			echo "config file set to $2"
			shift
			;;
		*)
			logwarning "unrecognised option $key ignoring it" 
			;;
	esac
	shift
done
   
loginfo "ssserver config file is given by $SSCONFIGFILE"
if [[ ! -e $SSCONFIGFILE ]]; then
	echo "$SSCONFIGFILE is not found. please check if it exists"
fi

loginfo "Copy ss config files to /etc ..."
sudo cp $SSCONFIGFILE /etc/shadowsocks-libev/config.json 
echo "--- starting sserver using systemd ----"
sspid=$(pgrep ss-server)
if [[ -z $sspid ]]; then
  loginfo "ssserver is not running, so starting it with systemd"
  sudo systemctl start shadowsocks-libev.service 
  sudo systemctl enable shadowsocks-libev.service
  sudo systemctl restart shadowsocks-libev.service  
else
  loginfo "detected ssserver instance, restarting it"
  sudo systemctl restart shadowsocks-libev.service
fi

echo "Installation complete, sanity check now"

sspid=$(pgrep ss-server)
if [[ -z $sspid ]]; then
  echo "found no ss-server process, the server startup may be unsuccessful"
else
  echo "shadowsocks server successfully starts, PID: $sspid"
fi

# ensure it's listening on given port
loginfo  "check the port ss-server is listening on "
sudo netstat -lnp | grep ss-server 

