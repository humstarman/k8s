#!/bin/bash

CONFIG=""
for i in $(seq -s " " $N)
do
  IP=""
  while [ -z "$IP" ]
  do
    ETCD=$($WORKDIR/etcd-choice.py -c "$(cat $ETC/etcd)")
    IP=$($WORKDIR/read-json.py -j "$(curl -s http://${ETCD}:${ETCD_PORT}/v2/keys/$ALIAS/${ALIAS}-$i -X GET)" -f "node/value")
  done
  echo "$ALIAS-$i: $IP"
  CONFIG+="$IP:$REDIS_PORT "
done

if [ -z "$1" ]; then
  [ -f "$ETC/config" ] || touch $ETC/config
  echo "$CONFIG" > $ETC/config
else
  [ -f $1 ] || touch $1
  echo "$CONFIG" > $1
fi
