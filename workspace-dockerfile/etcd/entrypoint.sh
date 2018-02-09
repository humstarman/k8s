#!/bin/bash

set -e

WAIT="10"
if ! getent hosts $DSCV; then
  echo "=== Cannot resolve the DNS entry for $DSCV. Has the service been created yet, and is SkyDNS functional?"
  echo "=== See http://kubernetes.io/v1.1/docs/admin/dns.html for more details on DNS integration."
  echo "=== Sleeping ${WAIT}s before pod exit."
  sleep $WAIT
  exit 0
fi

echo "$(date) - $0 - ---------->"
echo "$(date) - $0 - sleeping ${WAIT}s waiting for cluster initialization."
sleep $WAIT
echo "$(date) - $0 - <=========="

THIS_IP=$(hostname -i)
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

[ -e /var/lib/etcd ] || mkdir -p /var/lib/etcd

/opt/etcd/etcd --data-dir=/var/lib/etcd \
  --name ${THIS_NAME} \
  --initial-advertise-peer-urls http://${THIS_IP}:2380 \
  --listen-peer-urls http://0.0.0.0:2380 \
  --advertise-client-urls http://${THIS_IP}:2379 \
  --listen-client-urls http://0.0.0.0:2379 \
  --initial-cluster ${ETCD_NODES} \
  --initial-cluster-state new \
  --initial-cluster-token ${TOKEN}
