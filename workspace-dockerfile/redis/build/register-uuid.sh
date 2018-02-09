#!/bin/bash

echo "$(date) - $0 - in"  
UUID=$($WORKDIR/mk-uuid.py)
echo "$(date) - $0 - UUID: $UUID"

for i in $(seq -s " " $TRY)
do
  ETCD=$($WORKDIR/etcd-choice.py -c "$(cat $ETC/etcd)")
  curl -s http://${ETCD}:${ETCD_PORT}/v2/keys/uuid/$ALIAS -X PUT -d value=$UUID -d ttl=$LARGER_TTL && break;
  ping -c $SLOT 127.0.0.1 > /dev/null 2>&1
  j="$i"
done
[ "$j" == "$TRY" ] && $WORKDIR/suicide.sh 

echo "$(date) - $0 - Done."
