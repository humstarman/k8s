#!/bin/bash

set -e

# function
## config env
function config_env() {
  FILES=$(find /var/env -name "*.env")

  if [ -n "$FILES" ]
  then
    for FILE in $FILES
    do
      [ -f $FILE ] && source $FILE
    done
  fi
}

config_env

for ID in $(seq -s " " 0 $[$N_NODES-1]); do
  NODE_NAME="${ALIAS}-$ID"
  if [ "$NODE_NAME" == "${HOSTNAME}" ]; then
    echo "server.$ID=0.0.0.0:2888:3888" >> $WORKDIR/zoo.cfg
  else
    echo "server.$ID=${NODE_NAME}:2888:3888" >> $WORKDIR/zoo.cfg
  fi
done
    
