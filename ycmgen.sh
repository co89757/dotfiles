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
#######################################################
## ---------- Parse arguments and flags ---------------
#######################################################
template="t_ycm_extra_conf.py"
OUTFILE=".ycm_extra_conf.py"
GLOBAL_PKG_DIR=$(pip list --user -v | grep -E -o '/.+/site-packages' | head -n1)
VENV=ai
DESTDIR="./"
while [[ $# -gt 0 ]];do
 flag=$1
 case "$flag" in
  --env | -env | -e )
    VENV=$2
    shift
    ;;
  -P | --pkgroot )
   GLOBAL_PKG_DIR="$2"
   shift
   ;;
  -T|--template)
   template="$2"
   shift
   ;;
  -d|-D|-destdir)
   DESTDIR="$2"
   shift
    ;;
  -v | --verbose)
   SCRIPT_DEBUG=1
   ;;
  *)
   echo "unknown flag: $flag"
   ;;
 esac
 shift # past current flag
done

[[ -d "$GLOBAL_PKG_DIR" ]] || logfatal "global python site-package directory not found:" "$GLOBAL_PKG_DIR"
[[ -f "$template" ]] || logfatal "template file not found: " "$template"
loginfo "Parmas Given: \nGLOBAL_PYTHON_PKG_DIR:$GLOBAL_PKG_DIR\nVENV:$VENV\nTemplate file:$template\nDestDir:$DESTDIR"
sed -e "s@{{\.PyGlobalPkgDir}}@$GLOBAL_PKG_DIR@g" -e "s@{{\.Venv}}@$VENV@g" $template > "$OUTFILE"
loginfo "Copy result .ycm_extra_conf.py to target directory $DESTDIR"
cp "$OUTFILE" "$DESTDIR/"
