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

FILE=$(echo $0 | awk -F '/' '{print $NF}' | awk -F '.' '{print $1}')
LOG="$LOG_DIR/$FILE"

while true
do
  ETCD=$($WORKDIR/etcd-choice.py -c "$(cat $ETC/etcd)")
  JSON=$(curl -s http://${ETCD}:${ETCD_PORT}/v2/keys/cmd/${THIS_IP}?wait=true)
  CMD=$($WORKDIR/read-json.py -j "$JSON" -f "node/value")
  echo "$(date) - $0 - $CMD." 
  #RAW=$($WORKDIR/read-json.py -j "$JSON" -f "node/value")
  #CMD=$(echo $RAW | sed 's/\\//g')
  [ -z "$CMD" ] || eval "$CMD"
  echo "$(date) - $0 - $CMD." >> $LOG 
  ETCD=$($WORKDIR/etcd-choice.py -c "$(cat $ETC/etcd)")
  curl -s http://${ETCD}:${ETCD_PORT}/v2/keys/cmd/${THIS_IP} -X PUT -d value="done"
  ETCD=$($WORKDIR/etcd-choice.py -c "$(cat $ETC/etcd)")
  JSON=$(curl -s http://${ETCD}:${ETCD_PORT}/v2/keys/cmd/${THIS_IP})
  RET=$($WORKDIR/read-json.py -j "$JSON" -f "node/value")
  while [ "$RET" != "done" ]
  do
    ETCD=$($WORKDIR/etcd-choice.py -c "$(cat $ETC/etcd)")
    curl -s http://${ETCD}:${ETCD_PORT}/v2/keys/cmd/${THIS_IP} -X PUT -d value="done"
    ETCD=$($WORKDIR/etcd-choice.py -c "$(cat $ETC/etcd)")
    JSON=$(curl -s http://${ETCD}:${ETCD_PORT}/v2/keys/cmd/${THIS_IP})
    RET=$($WORKDIR/read-json.py -j "$JSON" -f "node/value")
  done
done
