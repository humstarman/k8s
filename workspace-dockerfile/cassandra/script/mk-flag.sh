#!/bin/bash

case $ID in
  "1")
    # set the register flag
    for p in $(seq -s " " 10)
    do
      FLAG=${RANDOM}
      echo "$(date) - $0 - Flag: $FLAG"
      for i in $(seq -s " " $TRY)
      do
        ETCD=$($WORKDIR/etcd-choice.py -c "$(cat $ETC/etcd)")
        curl -s http://${ETCD}:${ETCD_PORT}/v2/keys/flag/${ALIAS} -X PUT -d value=$FLAG -d ttl=$LARGER_TTL && break;
        ping -c $SLOT 127.0.0.1 > /dev/null 2>&1
        j="$i"
      done

      [ "$j" == "$TRY" ] && $WORKDIR/suicide.sh
      echo "$(date) - $0 - wait for register -> $p."
      ping -c $SLOT 127.0.0.1 > /dev/null 2>&1
    done
    ;;
  *)
    # watch the flag to change
    for i in $(seq -s " " $TRY)
    do
      ETCD=$($WORKDIR/etcd-choice.py -c "$(cat $ETC/etcd)")
      curl -s http://${ETCD}:${ETCD_PORT}/v2/keys/flag/${ALIAS}?wait=true && break;
      ping -c $SLOT 127.0.0.1 > /dev/null 2>&1
      j="$i"
    done

    #[ "$j" == "$TRY" ] && $WORKDIR/suicide.sh
    ;;
esac

echo "$(date) - $0 - Done."
