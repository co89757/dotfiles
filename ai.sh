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

workfile=$(mktemp /tmp/chatgpt-XXXXXXXX)
logdebug "temp workfile is $workfile. it will store the chatGPT response"
curl -s --location --insecure --request POST 'https://api.openai.com/v1/chat/completions' \
--header "Authorization: Bearer ${OPENAI_KEY}" \
--header 'Content-Type: application/json' \
--data-raw "{
 \"model\": \"gpt-3.5-turbo\",
 \"messages\": [{\"role\": \"user\", \"content\": \"$*\"}]
}" | \
jq '.choices[].message.content' > ${workfile}
response=$(cat ${workfile})
if hash glow &> /dev/null ; then
  echo -e $response | glow -
else
  logwarning "No markdown rendering available, outputting raw text"
  echo -e $response
fi
