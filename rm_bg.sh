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

HELP="Usage: $0 -f|--url IMAGE_URL [-o|--output OUTPUT_IMAGE_FILENAME] [-b|--bg BG_COLOR]
  Given the input image URL, this tool removes the background using Azure's image segmentation service
  and swaps the background to a given color (either predefined or color code like #000000).

Options:
  -f|--url: The URL to the input image
  -o|--output: The filename of the output image
  -b|--bg: The color of the substitute background for the output image.

Prerequisites:
  (1) curl
  (2) magick
"

#######################################################
## ---------- Parse arguments and flags ---------------
#######################################################
ofile="out.png"
while [[ $# -gt 0 ]];do
 flag=$1
 case "$flag" in
  -f | --url )
    iurl="$2"
    loginfo "input image URL: $iurl"
    shift
    ;;
  -o | --output)
    ofile="$2"
    shift
    ;;
  -b | --bg )
    bgcolor="$2"
    shift
    ;;
  -v | --verbose)
   SCRIPT_DEBUG=1
   ;;
  -help | -h | --help)
    echo "$HELP"
    ;;
  *)
   echo "unknown flag: $flag"
   ;;
 esac
 shift # past current flag
done
hash curl &>/dev/null || logfatal "Missing prequisite command: curl"
[[ -z $iurl ]] && logfatal "Must provide input image URL"
# You need following environmental variables set:
# AZ_CV_ENDPOINT: your Azure cognitive service computer vision endpoint
# AZ_CV_KEY: Your Azure computer vision API key
target="${AZ_CV_ENDPOINT}/computervision/imageanalysis:segment?api-version=2023-02-01-preview&mode=backgroundRemoval"
loginfo "target API endpoint: $target"

# send POST request
curl -X POST "$target" -H "Content-Type: application/json" -H "Ocp-Apim-Subscription-Key: ${AZ_CV_KEY}" \
 -d "{\"url\": \""$iurl"\" }" -o "$ofile"
# add new background color
if [[ -n $bgcolor ]]; then
 hash magick &>/dev/null || logfatal "Prerequisite: magick not found. please install magick"
 echo "[INFO]you specified 3rd arg (bg color): $bgcolor"
 of_base=$(basename "$ofile")
 of_dir=$(dirname "$ofile")
 of_path="$of_dir/o_$of_base"
 magick "$ofile" -background "$bgcolor" -alpha remove -alpha off -compose over -flatten "$of_path"
 loginfo "Final output image file is: $of_path"
else
 echo "[INFO] no new background color give. Output file: $ofile"
fi


