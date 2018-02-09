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

NODES=$($REDIS_HOME/src/redis-cli -c -p $REDIS_PORT -h $THIS_IP cluster nodes | grep -E 'fail|disconnected' | awk -F ' ' '{print $1}')

if [ -n "$NODES" ]; then
  for NODE in $NODES; do
    $REDIS_HOME/src/redis-cli -c -p $REDIS_PORT -h $THIS_IP cluster forget $NODE
  done
fi
