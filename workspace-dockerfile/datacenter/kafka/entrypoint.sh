#!/bin/bash

set -e

CONFUSE=$(getent hosts $DSCV)
echo "$(date) - $0 - confuse info: $CONFUSE"
WAIT="10"
if ! getent hosts $DSCV; then
  echo "=== Cannot resolve the DNS entry for $DSCV. Has the service been created yet, and is SkyDNS functional?"
  echo "=== See http://kubernetes.io/v1.1/docs/admin/dns.html for more details on DNS integration."
  echo "=== Sleeping ${WAIT}s before pod exit."
  sleep $WAIT
  exit 0
fi

ZK_PORT=2181

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

# get zk info
ZK_HOSTS=''

for ip in $CONFUSE; do
  if [[ $ip =~ ^([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])$ ]]; then
    ZK_HOSTS+=",$ip:${ZK_PORT}"
  fi
done
ZK_HOSTS=${ZK_HOSTS#*,}
echo "$(date) - $0 - zk info: $ZK_HOSTS"

[ -e /mnt/$(hostname -s) ] || mkdir -p /mnt/$(hostname -s)
sed -i "s/{{broker.id}}/${ID}/g" /opt/kafka/config/server.properties
sed -i "s/\/tmp\/kafka-logs/\/mnt\/$(hostname -s)/g" /opt/kafka/config/server.properties
#sed -i "s/\#delete.topic.enable=true/delete.topic.enable=true/g" /opt/kafka/config/server.properties
sed -i "s/{{zookeeper.nodes}}/${ZK_HOSTS}/g" /opt/kafka/config/server.properties
echo -e "\n\nlog.cleaner.enable=true\n" >> /opt/kafka/config/server.properties

/opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties
