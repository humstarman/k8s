#!/bin/bash

# need a parameter
APP=$1
if [ "$APP" == "" ]
then
echo "Need a parameter to start this script... "
echo "Exit!"
exit
fi

# env info
NUM_ETCD_NODES=3
WORKDIR=/usr/local
TIME_2_SLEEP=10

ETCD_HOST_1=172.31.78.215
ETCD_HOST_2=172.31.78.216
ETCD_HOST_3=172.31.78.217

# get number in the cluster
#echo $(echo $x | awk -F '-' '{print $2}' | awk -F '.' '{print $1}')
ID=$(echo $HOSTNAME | awk -F '-' '{print $2}' | awk -F '.' '{print $1}')
#N=$[${N}%${NUM_ETCD_NODES}+1]
#N=$[${RANDOM}%${NUM_ETCD_NODES}+1]
# make the name in the cluster
THIS_NAME=${APP}-${ID}

# info about ETCD cluster
ETCDS[1]=$ETCD_HOST_1
ETCDS[2]=$ETCD_HOST_2
ETCDS[3]=$ETCD_HOST_3

echo $THIS_NAME

# get the prefix of the overlay net
N=$[${RANDOM}%${NUM_ETCD_NODES}+1]
OVERLAY_NETWORK_PREFIX=$(${WORKDIR}/get-value.py $(curl -s http://${ETCDS[$N]}:2379/v2/keys/info/overlay-network-prefix))

# get the ip address in the overlay network
export THIS_IP=$(${WORKDIR}/get-ip-in-overlay-network.py ${OVERLAY_NETWORK_PREFIX} $(hostname --all-ip-address))
echo $THIS_IP

#N=$[${RANDOM}%${NUM_ETCD_NODES}+1]
#curl http://${ETCDS[$N]}:2379/v2/keys/foo
#VALUE=$(/usr/local/get-value.py $(curl http://${ETCDS[$N]}:2379/v2/keys/foo))
#echo $VALUE

# register the service
while true
do
  N=$[${RANDOM}%${NUM_ETCD_NODES}+1]
  curl -s http://${ETCDS[$N]}:2379/v2/keys/${APP}-cluster/${THIS_NAME} -X PUT -d value=${THIS_IP} && break;
done

# start run.sh
${WORKDIR}/run.sh $1 &

# loop the ip address
while true
do
  export THIS_IP=$(${WORKDIR}/get-ip-in-overlay-network.py ${OVERLAY_NETWORK_PREFIX} $(hostname --all-ip-address))
  N=$[${RANDOM}%${NUM_ETCD_NODES}+1]
  IP_FROM_ETCD=$(${WORKDIR}/get-value.py $(curl -s http://${ETCDS[$N]}:2379/v2/keys/${APP}-cluster/${THIS_NAME}))
  if [ "$THIS_IP" != "$IP_FROM_ETCD" ]
  then
    N=$[${RANDOM}%${NUM_ETCD_NODES}+1]
    curl -s http://${ETCDS[$N]}:2379/v2/keys/${APP}-cluster/${THIS_NAME} -X PUT -d value=${THIS_IP}
  fi
  sleep $TIME_2_SLEEP
done
