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

CONFUSE=$(getent hosts $DSCV)
echo "$(date) - $0 - confuse info: $CONFUSE"
if [ -z "$CONFUSE" ]; then
  echo "=== Cannot resolve the DNS entry for $DSCV. Has the service been created yet, and is SkyDNS functional?"
  echo "=== See http://kubernetes.io/v1.1/docs/admin/dns.html for more details on DNS integration."
  echo "=== Sleeping 10s before pod exit."
  sleep 10
  exit 0
fi

# get zk info
ZK_HOSTS=''

for ip in $CONFUSE; do
  if [[ $ip =~ ^([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])$ ]]; then
    ZK_HOSTS+=",$ip:${ZK_PORT}"
  fi
done
ZK_HOSTS=${ZK_HOSTS#*,}
echo "$(date) - $0 - zk info: $ZK_HOSTS"

${WORKDIR}/ch-line.py -f ${WORKDIR}/server.properties -1 "broker.id=0" -2 "broker.id=${ID}"
${WORKDIR}/ch-line.py -f ${WORKDIR}/server.properties -1 "log.dirs=/tmp/kafka-logs" -2 "log.dirs=/mnt/lib/${SVC}-${ID}\/kafka-logs"
${WORKDIR}/ch-line.py -f ${WORKDIR}/server.properties -1 "#delete.topic.enable=true" -2 "delete.topic.enable=true"
${WORKDIR}/ch-line.py -f ${WORKDIR}/server.properties -1 "zookeeper.connect=localhost:2181" -2 "zookeeper.connect=${ZK_HOSTS}"
echo -e "\n\nlog.cleaner.enable=true\n" >> ${WORKDIR}/server.properties

cp ${WORKDIR}/server.properties $KAFKA_HOME/config

/usr/sbin/cron

$KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties
