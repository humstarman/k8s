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

$WORKDIR/mk-redis-cluster.sh
ping -c $SLOT 127.0.0.1 > /dev/null 2>&1
I=$($REDIS_HOME/src/redis-cli -c -p $REDIS_PORT -h $THIS_IP cluster nodes | wc | awk -F ' ' '{print $1}')

echo "$(date) - $0 - Nodes in cluster: $I"

while [ "$I" -lt "2" ]
do
  $WORKDIR/mk-redis-cluster.sh
  ping -c $SLOT 127.0.0.1 > /dev/null 2>&1
  I=$($REDIS_HOME/src/redis-cli -c -p $REDIS_PORT -h $THIS_IP cluster nodes | wc | awk -F ' ' '{print $1}')
  echo "$(date) - $0 - Nodes in cluster: $I"
done 
