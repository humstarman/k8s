#!/bin/bash

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

TARGET=$1

if [ -n "$TARGET" ]; then
  IPS=$($CASSANDRA_HOME/bin/nodetool status | grep "DN" | awk -F ' ' '{print $2}')
  if [ -n "$IPS" ]; then
    for IP in "$IPS"; do
      if [ "$TARGET" == "$IP" ]; then
        $CASSANDRA_HOME/bin/nodetool assassinate $TARGET
      fi
    done
  fi
fi
