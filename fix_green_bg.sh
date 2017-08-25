#!/bin/bash
DIR=${1:=.}
echo "====Directory:${DIR}====="
find ${DIR} -type d -print0 | xargs -0 chmod o-w 
echo "====DONE==="
