#!/usr/bin/env bash
#
# script to fix Sogou Pinyin bug on Linux that prevents the show-up of words candidates panel   
CONFIGDIR=$HOME/.config
SOGOUDIRS="SogouPY SogouPY.users sogou-qimpanel"


for sgdir in $SOGOUDIRS ; do
  if [[ -d $CONFIGDIR/$sgdir ]]; then
    echo "Found $CONFIGDIR/$sgdir deleting it..."
    rm -r $CONFIGDIR/$sgdir
  fi
done

echo "Sogou pinyin should be fixed! "
