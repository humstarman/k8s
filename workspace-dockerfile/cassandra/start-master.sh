#!/bin/bash

set -e

service ssh start

THIS_IP=$(hostname -i)
SEED=${THIS_IP}
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

# 5 listen address
sed -i "s/rpc_address: a.b.c.d/rpc_address: ${THIS_IP}/g" /opt/cassandra/conf/cassandra.yaml

/opt/cassandra/bin/cassandra -f -R
