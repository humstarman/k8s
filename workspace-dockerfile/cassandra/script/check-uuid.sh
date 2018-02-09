#!/bin/bash

# function
## config env
function config_env() {
  FILES=$(find ~ -name "*.env")

  if [ -n "$FILES" ]
  then
    for FILE in $FILES
    do
      [ -f $FILE ] && source $FILE
    done
  fi
}

config_env

[ -e /mnt/$HOSTNAME ] || mkdir -p /mnt/$HOSTNAME
FILE=$(echo $0 | awk -F '/' '{print $NF}' | awk -F '.' '{print $1}')

case $ID in
  "1")
    # refresh the ttl of uuid
    for i in $(seq -s " " $TRY)
    do
      ETCD=$($WORKDIR/etcd-choice.py -c "$(cat $ETC/etcd)")
      curl -s http://${ETCD}:${ETCD_PORT}/v2/keys/uuid/$ALIAS -X PUT -d ttl=$TTL -d refresh=true -d prevExist=true && break;
      ping -c $SLOT 127.0.0.1 > /dev/null 2>&1
      j="$i"
    done
    if [ "$j" == "$TRY" ]; then
      echo "$(date) - $0 - commit suicide, not reachable to etcd servers." >> /mnt/$HOSTNAME/$FILE
      $WORKDIR/suicide.sh
    fi
    # check config
    $WORKDIR/mk-cluster-config.sh /tmp/config
    CONFIG1=$(cat $ETC/config)
    CONFIG2=$(cat /tmp/config)
    if [ "$CONFIG1" == "$CONFIG2" ]; then 
      echo "$(date) - $0 - commit suicide, different cluster info." >> /mnt/$HOSTNAME/$FILE
      $WORKDIR/suicide.sh
    fi
    ;;
  *) 
    # check the uuid
    UUID2=""
    i="0"
    while [ -z "$UUID2" ]
    do
      ETCD=$($WORKDIR/etcd-choice.py -c "$(cat $ETC/etcd)")
      UUID2=$($WORKDIR/read-json.py -j "$(curl -s http://${ETCD}:${ETCD_PORT}/v2/keys/uuid/$ALIAS -X GET)" -f "node/value")
      if [ "$i" == "$TRY" ] && [ -z "$UUID2" ]
      then
        echo "$(date) - $0 - commit suicide, not reachable to etcd servers." >> /mnt/$HOSTNAME/$FILE
        $WORKDIR/suicide.sh
      else
        i=$[$i+1]
      fi
    done
    if [ ! -f $ETC/uuid ]
    then
      touch $ETC/uuid
      echo "$UUID2" > $ETC/uuid
    fi
    UUID1=$(cat $ETC/uuid)
    echo "$(date) - $0 - uuid-1: $UUID1." >> /mnt/$HOSTNAME/$FILE
    echo "$(date) - $0 - uuid-2: $UUID2." >> /mnt/$HOSTNAME/$FILE
    if [ "$UUID1" != "$UUID2" ]; then
      echo "$(date) - $0 - commit suicide, different cluster uuids." >> /mnt/$HOSTNAME/$FILE
      $WORKDIR/suicide.sh 
    fi
    ;;
esac
echo "$(date) - $0 - Done."
