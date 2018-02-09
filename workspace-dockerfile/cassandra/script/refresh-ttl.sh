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

for i in $(seq -s " " $TRY)
do
  ETCD=$($WORKDIR/etcd-choice.py -c "$(cat $ETC/etcd)")
  curl -s http://${ETCD}:${ETCD_PORT}/v2/keys/$ALIAS/${HOSTNAME} -X PUT -d ttl=$TTL -d refresh=true -d prevExist=true && break;
  ping -c $SLOT 127.0.0.1 > /dev/null 2>&1
  #j="$i"
done
#echo "$(date) - $0 - i: $i." >> /mnt/$HOSTNAME/$FILE
#echo "$(date) - $0 - j: $j." >> /mnt/$HOSTNAME/$FILE
#if [ "$j" == "$TRY" ]; then
#  echo "$(date) - $0 - commit suicide." >> /mnt/$HOSTNAME/$FILE
#  $WORKDIR/suicide.sh
#fi
echo "$(date) - $0 - Done." >> /mnt/$HOSTNAME/$FILE
