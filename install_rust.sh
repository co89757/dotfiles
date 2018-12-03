#!/bin/bash 

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

setup_racer(){
  echo "Add nightly rust toolchain"
  rustup toolchain add nightly 
  [[ -d $HOME/dev/rs ]] && echo "~/dev/rs exist" || mkdir -p "$HOME/dev/rs" 
  cd $HOME/dev/rs 
  echo "install racer from source now..."
  git clone https://github.com/racer-rust/racer.git
  cd racer 
  cargo +nightly build --release 
  sudo cp $HOME/dev/rs/racer/target/release/racer /usr/local/bin/
  echo "fetch rust src..."
  rustup component add rust-src 
}


if hash rustc ; then
  loginfo "rustc is already installed. skip" 
  exit 0
fi

info "[STEP1] install rust"
curl https://sh.rustup.rs -sSf | sh 

if [[ ! $PATH == *"$HOME/.cargo/bin"* ]]; then
  loginfo  "$HOME/.cargo/bin is not yet in PATH, addding it now" 
  export PATH="$HOME/.cargo/bin:$PATH" 
else
  loginfo "PATH already contains ~/.cargo/bin" 
fi
echo "RUSTC version: "
rustc --version 

read -p "do you want to install racer? [y/n]" install_racer 
case $install_racer in
  [yY] )
    loginfo "Racer will be built from source and RUST_SRC_PATH variable will be set"
    setup_racer 
    export RUST_SRC_PATH="$(rustc --print sysroot)/lib/rustlib/src/rust/src" 
    loginfo "...DONE RACER SETUP... try sample completion now"
    racer complete std::io::B
    ;;
  [nN] )
    echo "You chose not to install racer. quit now"
    exit 0
    ;;
esac

