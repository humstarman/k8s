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

ARGS="-a $ALIAS -i $THIS_IP --port $SVC_PORT --hostname $HOSTNAME --ld $LOG_DIR --ll debug"

# prepare
# echo the values
echo "$(date) - $0 - Nodes in this cluster: $N"
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

SEED=$(getent hosts $DSCV | awk -F ' ' '{print $1}')
echo "$(date) - $0 - seed: $SEED"

# mk config
# 1 cluster-name 
${WORKDIR}/ch-line.py -f ${WORKDIR}/cassandra.yaml -1 "cluster_name: 'Test Cluster'" -2 "cluster_name: '${CLUSTER_NAME}'"
# 2 seed
TO_WRITE="- seeds: \"$SEED\""
${WORKDIR}/ch-line.py -f ${WORKDIR}/cassandra.yaml  -1 '- seeds: "a.b.c.d,a.b.c.d"' -2 "      $TO_WRITE" 
# 3 listen address
${WORKDIR}/ch-line.py -f ${WORKDIR}/cassandra.yaml -1 "listen_address: a.b.c.d" -2 "listen_address: ${THIS_IP}"
# 4 rpc address
${WORKDIR}/ch-line.py -f ${WORKDIR}/cassandra.yaml -1 "rpc_address: a.b.c.d" -2 "rpc_address: ${THIS_IP}"
# 5 data file directories 
${WORKDIR}/ch-line.py -f ${WORKDIR}/cassandra.yaml -1 "- /var/lib/cassandra/data" -2 "    - /mnt/lib/cass-${CLUSTER_NAME}-${ID}/data"
# 6 commitlog directory 
${WORKDIR}/ch-line.py -f ${WORKDIR}/cassandra.yaml -1 "commitlog_directory: /var/lib/cassandra/commitlog" -2 "commitlog_directory: /mnt/lib/cass-${CLUSTER_NAME}-${ID}/commitlog"
# write to $CASSANDRA_HOME/confUcp ${WORKDIR}/${CLUSTER_TYPE}.yaml $HOME/conf
cp ${WORKDIR}/cassandra.yaml $CASSANDRA_HOME/conf
cp ${WORKDIR}/cassandra-env.sh $CASSANDRA_HOME/conf

# for lifecycle
#/usr/sbin/cron -f > /dev/null 2>&1
/usr/sbin/cron

$CASSANDRA_HOME/bin/cassandra -f -R
