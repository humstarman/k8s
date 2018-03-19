#!/bin/bash

set -e

service ssh start

SEED=${POD_IP}
echo "$(date) - $0 - seed: $SEED"

# mk config
# 5 data file directories 
#/opt/ch-line.py -f /opt/cassandra/conf/cassandra.yaml -1 "- /var/lib/cassandra/data" -2 "    - /mnt/lib/cass-${CLUSTER_NAME}-${ID}/data"
# 6 commitlog directory 
#/opt/cassandra/conf/ch-line.py -f /opt/cassandra/conf/cassandra.yaml -1 "commitlog_directory: /var/lib/cassandra/commitlog" -2 "commitlog_directory: /mnt/lib/cass-${CLUSTER_NAME}-${ID}/commitlog"
# write to $CASSANDRA_HOME/confUcp /opt/cassandra/conf/${CLUSTER_TYPE}.yaml $HOME/conf

# 1 cluster name
sed -i "s/{{cluster.name}}/${CLUSTER_NAME}/g" /opt/cassandra/conf/cassandra.yaml

# 2 seed
sed -i "s/{{seed.ip}}/$SEED/g" /opt/cassandra/conf/cassandra.yaml

# 3 listen address
sed -i "s/{{pod.ip}}/${POD_IP}/g" /opt/cassandra/conf/cassandra.yaml

# 4 listen address
sed -i "s/{{pod.ip}}/${POD_IP}/g" /opt/cassandra/conf/cassandra.yaml

# 5 data file directories 
sed -i "s/var\/lib/mnt\/$(hostname -s)/g" /opt/cassandra/conf/cassandra.yaml

/opt/cassandra/bin/cassandra -f -R
