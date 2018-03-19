#!/bin/bash

set -e

WAIT="10"
i=0
while true; do 
  if [ "$i" -gt "$TRIES" ]; then
    echo "=== Cannot resolve the DNS entry for $DSCV. Has the service been created yet, and is SkyDNS functional?"
    echo "=== See http://kubernetes.io/v1.1/docs/admin/dns.html for more details on DNS integration."
    echo "=== Sleeping ${WAIT}s before pod exit."
    sleep $WAIT
    exit 0
  fi
  if ! getent hosts $DSCV; then
    i=$[i+1]
    sleep 1
  else
    break;
  fi
done

THIS_IP=$POD_IP
THIS_NAME=$(hostname -s)
ALIAS=$(echo $THIS_NAME | awk -F '-' '{print $1}')
ID=$(echo $THIS_NAME | awk -F '-' '{print $2}')
#ID=$(echo $THIS_NAME | awk -F '-' '{print $2}' | awk -F '.' '{print $1}')
echo "$(date) - $0 - Nodes in this cluster: $N_NODES"
echo "$(date) - $0 - IP: ${THIS_IP}"
echo "$(date) - $0 - ID: ${ID}"
echo "$(date) - $0 - Alias: ${ALIAS}"
echo "$(date) - $0 - svc discovery: $DSCV"

service ssh start

ETCD_NODES=""
for i in $(seq -s ' ' 1 $N_NODES); do
  ETCD_NODES+=','
  j=$[$i-1]
  NAME="$ALIAS-$j"
  if [ "$j" == "$ID" ]; then
    IP=$THIS_IP
  else
    IP=""
    TRY=0
    IP=$(getent hosts $NAME.$DSCV | awk -F ' ' '{print $1}')
    while [ -z "$IP" ]; do
      sleep 1
      TRY=$[${TRY}+1]
      if [ "$TRY" -gt "$TRIES" ]; then
        echo "=== Cannot resolve the DNS entry for ${NAME}. Has the service been created yet, and is SkyDNS functional?"
        echo "=== See http://kubernetes.io/v1.1/docs/admin/dns.html for more details on DNS integration."
        echo "=== Sleeping ${WAIT}s before pod exit."
        sleep $WAIT
        exit 0
      fi
      IP=$(getent hosts $NAME.$DSCV | awk -F ' ' '{print $1}')
    done
  fi
  ETCD_NODES+="$NAME=http://$IP:2380"
done

ETCD_NODES=${ETCD_NODES#*,}

echo "$(date) - $0 - Etcd nodes: $ETCD_NODES"
echo "$(date) - $0 - this name: ${THIS_NAME}"

[ -e /mnt/$(hostname -s)/etcd ] || mkdir -p /mnt/$(hostname -s)/etcd

/opt/etcd/etcd --data-dir=/mnt/$(hostname -s)/etcd \
  --name ${THIS_NAME} \
  --initial-advertise-peer-urls http://${THIS_IP}:2380 \
  --listen-peer-urls http://0.0.0.0:2380 \
  --advertise-client-urls http://${THIS_IP}:2379 \
  --listen-client-urls http://0.0.0.0:2379 \
  --initial-cluster ${ETCD_NODES} \
  --initial-cluster-state new \
  --initial-cluster-token ${TOKEN} \
  --force-new-cluster
