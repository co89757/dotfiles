#!/usr/bin/env bash 

# set up shadowsocks server 

if [[ $# -lt 2 ]]; then
	echo "Usage: <prog> -c|--config <sserver_config>"
	echo "please specify JSON config file path for sserver"
  exit 1 
fi

#1. check pre-requisites 
echo "========= Start shadowsocks setup ====="
echo " --- checking dependencies ---"
hash pip 2> /dev/null || (echo "pip is missing. install it" && sudo apt-get install python-pip )
# hash ssserver || (echo "shadowsocks is not installed. installing it" && sudo pip install shadowsocks)
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

#copy over config 
sudo cp $SSCONFIGFILE /etc/shadowsocks.json 
echo "--- starting sserver ----"

sudo ssserver -c /etc/shadowsocks.json -d start 

sspid=$(pgrep ssserver)
if [[ -z $sspid ]]; then
  echo "found no ssserver process, the server startup may be unsuccessful"
else
  echo "shadowsocks server successfully starts, PID: $sspid"
fi

