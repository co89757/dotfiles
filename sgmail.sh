#!/usr/bin/env bash

########################################################
# A generic email sending script including attachment. #
########################################################

RED="\e[31m"
B_RED="\e[1;31m"
GREEN="\e[32m"
B_GREEN="\e[1;32m"
YELLOW="\e[33m"
B_YELLOW="\e[1;33m"
BLUE="\e[34m"
B_BLUE="\e[1;34m"
NIL="\e[0m"
set -euo pipefail
trap "echo 'error: Script failure: see failed command above '" ERR
export PS4="'+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'"
script_debug=0 #Switch for debug mode
debugme() {
  (($script_debug == 1)) && "$@" || :
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

if ! hash curl >/dev/null 2>&1; then
  logerr "Curl command not found"
  exit 1
fi

show_help() {
  echo -e "
Script to send a email with optional attachments.
${GREEN}Pre-requisite${NIL}: you need to put the sendgrid api key in the environment variable SENDGRID_APIKEY

${GREEN}USAGE${NIL}: ${0##*/} -t|--to TO_EMAILS [-cc|--cc CC_EMAILS]  -f|--from FROM_EMAIL [--sendas NAME]  [-A|--attachments ATTACHMENTS] [-s|--title TITLE ]  -B|--content CONTENT_FILE [--dryrun]
      Optional Flags:
         --sendas:    the name to display as sender
         -A|--attachments:  comma-separated file-paths to attach
         --dryrun:  dryrun mode, only writes the message payload without actually sending
         -s|--title:  email subject
${YELLOW}EXAMPLES:${NIL}
  # send a normal email w/o attachment
  ${0##*/} -t destination@email.com -f me@email.com -s \"I am email title\" -B email_content_file.html
  # send an email with two attachments
  ${0##*/} -t dest@email.com -f me@email.com -s \"two attachments\" -B email-content.html -A path/to/attachment1,path/to/attachment2 --sendas \"James Bond\"
  "
}

##### CONSTANTS #######
APIKEY=${SENDGRID_APIKEY:-}
USER="apikey"
FILE_UPLOAD='.payload'

MIXED_MARKER="MULTIPART-MIXED-BOUNDARY"
ALT_MARKER="MULTIPART-ALTERNATIVE-BOUNDARY"
MIXED_BOUNDARY_BEGIN="--${MIXED_MARKER}"
MIXED_BOUNDARY_END="--${MIXED_MARKER}--"
ALT_BOUNDARY_BEGIN="--${ALT_MARKER}"
ALT_BOUNDARY_END="--${ALT_MARKER}--"
USE_TOR=0
###### Parse Parameters #######
if [[ $# -eq 0 ]]; then
  show_help
  exit 1
fi

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
  -t | --to)
    to=$2
    shift
    ;;
  -cc | --cc)
    cc=$2
    shift
    ;;
  -f | --from)
    from=$2
    shift
    ;;
  --sendas)
    sender_name=$2
    shift
    ;;
  -A | --attachments)
    attachments="$2"
    shift
    ;;
  -s | --title)
    subject=$2
    shift
    ;;
  -B | --content)
    bodyfile="$2"
    shift
    ;;
  --tor|-X)
    USE_TOR=1
    ;;
  --dryrun)
    dry_run=1
    ;;
  --help)
    show_help
    exit 0
    ;;
  *)
    show_help
    exit 1
    ;;
  esac
  shift # past arg or value
done

rtmp_url="smtp://smtp.sendgrid.net:587"
from=${from:-noreply@dnt.me}
default_sendas=${from%@*}
sender_name=${sender_name:-$default_sendas}
to=${to:-}
if [[ -z $to ]]; then
  logwarning "destination email address is required."
  read -p "send to:" to
fi
cc=${cc:-}
subject=${subject:-no_subject}
[ "$subject" == 'no_subject' ] && logwarning "you did not specify a subject, will be sent as title <no_subject>"
attachments=${attachments:-} # attached file paths, comma-separated
bodyfile=${bodyfile:-}
if [[ -z $bodyfile ]]; then
  logwarning "Mail body file is required. Please provide a valid file path for html/text content"
  read -p "path to mail content file: " bodyfile
fi
BODY=$(cat "$bodyfile")

dry_run=${dry_run:-0}

#header
echo "From: "${sender_name}" <$from>
To: $to
Subject: "$subject"
Cc: $cc
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary=\"${MIXED_MARKER}\"

${MIXED_BOUNDARY_BEGIN}
Content-Type: multipart/alternative; boundary=\"${ALT_MARKER}\"

${ALT_BOUNDARY_BEGIN}
Content-Type: text/html; charset=\"utf-8\"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
"${BODY}"
${ALT_BOUNDARY_END}
" >$FILE_UPLOAD

# add attachments\
IFS=, read -r -a attachments_array <<<"$attachments"
num_a=${#attachments_array[@]}
loginfo "you attached %s files in the email" $num_a
if [[ $num_a -gt 0 ]]; then
  loginfo "attaching files to your email"
  for f in "${attachments_array[@]}"; do
    filename=$(basename "$f")
    loginfo "attaching: $filename"
    echo "${MIXED_BOUNDARY_BEGIN}
Content-Type: application/octet-stream
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename=\"${filename}\"" >>$FILE_UPLOAD
    cat $f | base64 >>$FILE_UPLOAD
  done
fi
echo "${MIXED_BOUNDARY_END}" >>$FILE_UPLOAD

# Join $to to multiple --mail-rcpt arguments to curl
IFS=, read -r -a tomails <<<"${to}"
printf -v toarg " --mail-rcpt %s" "${tomails[@]}"

debugme logdebug "Receipents args: %s" "${toarg}"

# determine if this is a dry run
if [[ $dry_run -eq 1 ]]; then
  loginfo "this is a dry run. The payload to send is in file %s" $FILE_UPLOAD
  exit 0
fi

## Send the email using curl
args=(--url "$rtmp_url" --mail-from $from $toarg \
  --upload "${FILE_UPLOAD}" --ssl --user "$USER:$APIKEY")
if [[ $USE_TOR -ne 0 ]]; then
  loginfo "Use TOR proxy at socks5://localhost:9150"
  args+=(--socks5-hostname 127.0.0.1:9150)
fi
curl "${args[@]}"
if [[ $? -ne 0 ]]; then
  logerr "sending error code: $?"
else
  loginfo "Sent OK!"
fi
