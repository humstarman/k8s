#!/bin/bash

set -e

service ssh start

if ! getent hosts $DSCV; then
  echo "=== Cannot resolve the DNS entry for $DSCV. Has the service been created yet, and is SkyDNS functional?"
  echo "=== See http://kubernetes.io/v1.1/docs/admin/dns.html for more details on DNS integration."
  echo "=== Sleeping 10s before pod exit."
  sleep 10
  exit 0
fi

THIS_IP=$(hostname -i)
SEED=$(getent hosts $DSCV | awk -F ' ' '{print $1}')
echo "$(date) - $0 - seed: $SEED"

# mk config
# 5 data file directories 
#/opt/ch-line.py -f /opt/cassandra/conf/cassandra.yaml -1 "- /var/lib/cassandra/data" -2 "    - /mnt/lib/cass-${CLUSTER_NAME}-${ID}/data"
# 6 commitlog directory 
#/opt/cassandra/conf/ch-line.py -f /opt/cassandra/conf/cassandra.yaml -1 "commitlog_directory: /var/lib/cassandra/commitlog" -2 "commitlog_directory: /mnt/lib/cass-${CLUSTER_NAME}-${ID}/commitlog"
# write to $CASSANDRA_HOME/confUcp /opt/cassandra/conf/${CLUSTER_TYPE}.yaml $HOME/conf

# 1 cluster name
sed -i "s/cluster_name: 'Test Cluster'/cluster_name: '${CLUSTER_NAME}'/g" /opt/cassandra/conf/cassandra.yaml

# 2 seed
sed -i "s/- seeds: \"a.b.c.d,a.b.c.d\"/        - seeds: \"$SEED\"/g" /opt/cassandra/conf/cassandra.yaml

# 3 listen address
sed -i "s/listen_address: a.b.c.d/listen_address: ${THIS_IP}/g" /opt/cassandra/conf/cassandra.yaml

# 4 listen address
sed -i "s/rpc_address: a.b.c.d/rpc_address: ${THIS_IP}/g" /opt/cassandra/conf/cassandra.yaml

# 5 data file directories 
sed -i "s/var\/lib/mnt\/$(hostname -s)/g" /opt/cassandra/conf/cassandra.yaml

/opt/cassandra/bin/cassandra -f -R
