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

# prepare
# echo the values
echo "$(date) - $0 - Nodes in this cluster: $N_NODES"
# prepare
echo "$(date) - $0 - Net ID: $NET_ID"
echo "$(date) - $0 - Cluster name: $CLUSTER_NAME"
echo "$(date) - $0 - IP: ${THIS_IP}"
echo "$(date) - $0 - ID: ${ID}"
echo "$(date) - $0 - Alias: ${ALIAS}"
echo "$(date) - $0 - Passwd: $PASSWD"
echo "$(date) - $0 - all ip addr: $(hostname --all-ip-address)"
echo "$(date) - $0 - svc discovery: $DSCV"

service ssh start

if ! getent hosts $DSCV; then
  echo "=== Cannot resolve the DNS entry for $DSCV. Has the service been created yet, and is SkyDNS functional?"
  echo "=== See http://kubernetes.io/v1.1/docs/admin/dns.html for more details on DNS integration."
  echo "=== Sleeping 10s before pod exit."
  sleep 10
  exit 0
fi

# ip and hostname
DNS=''

for i in $(seq -s ' ' 1 $N_NODES); do
  j=$[$i-1]
  if [ "$j" == "$ID" ]; then
    echo "server.$ID=0.0.0.0:2888:3888" >> $WORKDIR/zoo.cfg
    IP=$THIS_IP
    NAME=$HOSTNAME
  else
    NAME="${ALIAS}-$j"
    echo "server.$j=${NAME}:2888:3888" >> $WORKDIR/zoo.cfg
    IP=$(getent hosts $NAME.$DSCV | awk -F ' ' '{print $1}')
  fi
  DNS+="$IP $NAME "
done

echo "$(date) - $0 - DNS: $DNS"
$WORKDIR/mk-etc-hosts.sh $DNS

# persistent volume setting
#[ -e /mnt/$HOSTNAME ] || mkdir -p /mnt/$HOSTNAME
# del previous cluster info

# mk config
# data perisistence
## /var/lib/zookepper -> /mnt/lib/zookeeper-${ID}/zookeeper
DATADIR="/mnt/lib/zookeeper-${ID}/zookeeper"
#[ -e /var/lib/zookeeper ] || mkdir -p /var/lib/zookeeper
[ -e $DATADIR ] || mkdir -p $DATADIR
## set myid
#[ -f /var/lib/zookeeper/myid ] || touch /var/lib/zookeeper/myid
[ -f $DATADIR/myid ] || touch $DATADIR/myid
echo "$ID" >  $DATADIR/myid
## mk hosts and zoo.cfg
#${WORKDIR}/config-zoo.py --info $CONFIG --id $ID --ll debug
${WORKDIR}/ch-line.py -f $WORKDIR/zoo.cfg -1 "dataDir=/var/lib/zookeeper" -2 "dataDir=/mnt/lib/zookeeper-${ID}/zookeeper"
cp ${WORKDIR}/zoo.cfg $ZOOKEEPER_HOME/conf

# mk dir
[ -e /mnt/lib/zookeeper-${ID} ] || mkdir -p /mnt/lib/zookeeper-${ID}
[ -e /mnt/log/zookeeper-${ID} ] || mkdir -p /mnt/log/zookeeper-${ID}

/usr/sbin/cron

${ZOOKEEPER_HOME}/bin/zkServer.sh start-foreground
