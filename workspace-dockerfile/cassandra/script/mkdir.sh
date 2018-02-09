#!/bin/bash

echo "$(date) - $0 - Try: $TRY"

# svc
ETCD=$($WORKDIR/etcd-choice.py -c "$(cat $ETC/etcd)")
RET=$($WORKDIR/read-json.py -j "$(curl -s http://${ETCD}:${ETCD_PORT}/v2/keys/$ALIAS -X GET)" -e node)
echo "$(date) - $0 - first RET: $RET"
if [ "$RET" == "no" ]
then
  for i in $(seq -s " " $TRY)
  do
    ETCD=$($WORKDIR/etcd-choice.py -c "$(cat $ETC/etcd)")
    echo "$(date) - $0 - Etcd Server: $ETCD"
    curl -s http://${ETCD}:${ETCD_PORT}/v2/keys/$ALIAS -X PUT -d dir=true && break;
    ping -c $SLOT 127.0.0.1 > /dev/null 2>&1
    j="$i"
  done
fi
[ "$j" == "$TRY" ] && $WORKDIR/suicide.sh

# uuid
ETCD=$($WORKDIR/etcd-choice.py -c "$(cat $ETC/etcd)")
RET=$($WORKDIR/read-json.py -j "$(curl -s http://${ETCD}:${ETCD_PORT}/v2/keys/uuid -X GET)" -e node)
echo "$(date) - $0 - 2nd RET: $RET"
if [ "$RET" == "no" ]
then
  for i in $(seq -s " " $TRY)
  do
    ETCD=$($WORKDIR/etcd-choice.py -c "$(cat $ETC/etcd)")
    echo "$(date) - $0 - Etcd Server: $ETCD"
    curl -s http://${ETCD}:${ETCD_PORT}/v2/keys/uuid -X PUT -d dir=true && break;
    ping -c $SLOT 127.0.0.1 > /dev/null 2>&1
    j="$i"
  done
fi
[ "$j" == "$TRY" ] && $WORKDIR/suicide.sh

# flag
ETCD=$($WORKDIR/etcd-choice.py -c "$(cat $ETC/etcd)")
RET=$($WORKDIR/read-json.py -j "$(curl -s http://${ETCD}:${ETCD_PORT}/v2/keys/flag -X GET)" -e node)
echo "$(date) - $0 - 3rd RET: $RET"
if [ "$RET" == "no" ]
then
  for i in $(seq -s " " $TRY)
  do
    ETCD=$($WORKDIR/etcd-choice.py -c "$(cat $ETC/etcd)")
    echo "$(date) - $0 - Etcd Server: $ETCD"
    curl -s http://${ETCD}:${ETCD_PORT}/v2/keys/flag -X PUT -d dir=true && break;
    ping -c $SLOT 127.0.0.1 > /dev/null 2>&1
    j="$i"
  done
fi
[ "$j" == "$TRY" ] && $WORKDIR/suicide.sh

echo "$(date) - $0 - End."
