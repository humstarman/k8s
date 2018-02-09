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

FILE="$ETC/cluster-nodes.dat"
ARGS="$@"
ARGS+=" --etc $ETC --cluster ${THIS_IP}"

$REDIS_HOME/src/redis-cli -c -p $REDIS_PORT -h $THIS_IP cluster nodes > $FILE
PREVIOUS=$($REDIS_HOME/src/redis-cli -c -p $REDIS_PORT -h $THIS_IP cluster nodes | wc | awk -F ' ' '{print $1}')  

$WORKDIR/add-new-node.py $ARGS

CMD="$(cat $ETC/add-node)"

eval "$CMD"
AFTER=$($REDIS_HOME/src/redis-cli -c -p $REDIS_PORT -h $THIS_IP cluster nodes | wc | awk -F ' ' '{print $1}')  
echo "$(date) - $0 - Previous node num: $PREVIOUS"
echo "$(date) - $0 - After node num: $AFTER"
ping -c 2 127.0.0.1 > /dev/null 2>&1

while [ "$PREVIOUS" == "$AFTER" ]; do
  eval "$CMD"
  AFTER=$($REDIS_HOME/src/redis-cli -c -p $REDIS_PORT -h $THIS_IP cluster nodes | wc | awk -F ' ' '{print $1}')  
  ping -c 2 127.0.0.1 > /dev/null 2>&1
  echo "$(date) - $0 - After node num: $AFTER"
done
