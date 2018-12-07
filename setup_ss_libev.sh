#!/usr/bin/env bash 

# set up shadowsocks server 

if [[ $# -lt 2 ]]; then
	echo "Usage: <prog> -c|--config <sserver_config>"
	echo "please specify JSON config file path for sserver"
  exit 1 
fi

#1. check pre-requisites 
echo "========= Start shadowsocks-libev setup ====="
echo "[step0] update repository with sudo apt update "
sudo apt-get update 
hash pip 2> /dev/null || (echo "pip is missing. install it" && sudo apt-get install python-pip )
hash ss-server && echo "ss-server is already installed" || (echo "shadowsocks-libev is not installed. installing it" && sudo apt install shadowsocks-libev simple-obfs)
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
			echo "unrecognised option $key ignoring it" 
			;;
	esac
	shift
done
 
echo "ssserver config file is given by $SSCONFIGFILE"
if [[ ! -e $SSCONFIGFILE ]]; then
	echo "$SSCONFIGFILE is not found. please check if it exists"
fi

echo "Copy ss config files to /etc ..."
sudo cp $SSCONFIGFILE /etc/shadowsocks-libev/config.json 
echo "--- starting sserver using systemd ----"
sspid=$(pgrep ss-server)
if [[ -z $sspid ]]; then
  echo "ssserver is not running, so starting it with systemd"
  sudo systemd start shadowsocks-libev.service 
  sudo systemd enable shadowsocks-libev.service
  sudo systemd restart shadowsocks-libev.service  
else
  echo "detected ssserver instance, restarting it"
  sudo systemd restart shadowsocks-libev.service
fi

echo "Installation complete, sanity check now"

sspid=$(pgrep ssserver)
if [[ -z $sspid ]]; then
  echo "found no ssserver process, the server startup may be unsuccessful"
else
  echo "shadowsocks server successfully starts, PID: $sspid"
fi

# ensure it's listening on given port
echo "check the port ss-server is listening on "
sudo netstat -lnp | grep ss-server 

