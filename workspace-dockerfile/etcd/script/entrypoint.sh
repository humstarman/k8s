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

# persistent volume setting
[ -e /mnt/$HOSTNAME ] || mkdir -p /mnt/$HOSTNAME
[ -e /var/lib/etcd ] || mkdir -p /var/lib/etcd

echo "$(date) - $0 - Nodes in this cluster: $N_NODES"
echo "$(date) - $0 - This ip: ${THIS_IP}"
echo "$(date) - $0 - ID: ${ID}"
echo "$(date) - $0 - Alias: ${ALIAS}"
echo "$(date) - $0 - svc discovery: $DSCV"

service ssh start

if ! getent hosts $DSCV; then
  echo "=== Cannot resolve the DNS entry for $DSCV. Has the service been created yet, and is SkyDNS functional?"
  echo "=== See http://kubernetes.io/v1.1/docs/admin/dns.html for more details on DNS integration."
  echo "=== Sleeping 10s before pod exit."
  sleep 10
  exit 0
fi

ETCD_NODES=""
for i in $(seq -s ' ' 1 $N_NODES); do
  ETCD_NODES+=','
  j=$[$i-1]
  NAME="$ALIAS-$j"
  if [ "$j" == "$ID" ]; then
    THIS_NAME=$NAME
    IP=$THIS_IP
  else
    #IP=""
    #k=0
    #while [ "$k" -lt "$TRY" ];do
      #IP=$(getent hosts $NAME.$DSCV | awk -F ' ' '{print $1}')
      #if [[ $IP =~ ^([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])$ ]]; then
        #break
      #fi
      #k=$[$k+1]
    #done
    IP=$(getent hosts $NAME.$DSCV | awk -F ' ' '{print $1}')
  fi
  ETCD_NODES+="$NAME=http://$IP:2380"
done

ETCD_NODES=${ETCD_NODES#*,}

echo "$(date) - $0 - Etcd nodes: $ETCD_NODES"
echo "$(date) - $0 - this name: ${THIS_NAME}"

$ETCD_HOME/etcd --data-dir=/mnt/$HOSTNAME \
  --name ${THIS_NAME} \
  --initial-advertise-peer-urls http://${THIS_IP}:2380 \
  --listen-peer-urls http://0.0.0.0:2380 \
  --advertise-client-urls http://${THIS_IP}:2379 \
  --listen-client-urls http://0.0.0.0:2379 \
  --initial-cluster ${ETCD_NODES} \
  --initial-cluster-state new \
  --initial-cluster-token ${TOKEN}
