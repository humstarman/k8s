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

TRIES=10

THIS_IP=$(hostname -i)
THIS_NAME=$(hostname -s)
ALIAS=$(echo $THIS_NAME | awk -F '-' '{print $1}')
ID=$(echo $THIS_NAME | awk -F '-' '{print $2}')
MYID=$[${ID}+1]
#ID=$(echo $THIS_NAME | awk -F '-' '{print $2}' | awk -F '.' '{print $1}')
echo "$(date) - $0 - Nodes in this cluster: $N_NODES"
echo "$(date) - $0 - IP: ${THIS_IP}"
echo "$(date) - $0 - ID: ${ID}"
echo "$(date) - $0 - MYID: ${MYID}"
echo "$(date) - $0 - Alias: ${ALIAS}"
echo "$(date) - $0 - svc discovery: $DSCV"

service ssh start

# set myid
mkdir -p /var/lib/zookeeper && \
cd /var/lib/zookeeper && \
touch myid && \
echo "$MYID" > myid

for i in $(seq -s ' ' 1 $N_NODES); do
  j=$[$i-1]
  if [ "$j" == "$ID" ]; then
    echo "server.$MYID=0.0.0.0:2888:3888" >> /opt/zookeeper/conf/zoo.cfg
    IP=$THIS_IP
    NAME=$THIS_NAME
  else
    NAME="${ALIAS}-$j"
    IP=""
    TRY=0
    echo "server.$i=${NAME}:2888:3888" >> /opt/zookeeper/conf/zoo.cfg
    while [ -z "$IP" ]; do
      TRY=$[${TRY}+1]
      if [ "$TRY" -gt "$TRIES" ]; then
        echo "=== Cannot resolve the DNS entry for ${NAME}. Has the service been created yet, and is SkyDNS functional?"
        echo "=== See http://kubernetes.io/v1.1/docs/admin/dns.html for more details on DNS integration."
        echo "=== Sleeping ${WAIT}s before pod exit."
        sleep $WAIT
        exit 0
      fi
      IP=$(getent hosts $NAME.$DSCV | awk -F ' ' '{print $1}')
      if [ -z "$IP" ]; then
        sleep 1
      fi
    done
  fi
  echo -e "${IP}\t${NAME}" >> /etc/hosts
done

/opt/zookeeper/bin/zkServer.sh start-foreground
