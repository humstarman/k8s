#!/bin/bash

MASTER=""

ansible all -m copy -a "src=./write-to-etc_profile dest=/tmp"
ansible all -m shell -a "cat /tmp/write-to-etc_profile >> /etc/profile && rm -f /tmp/write-to-etc_profile"
#ansible all -m shell -a "rm -f /tmp/write-to-etc_profile"

BOOTSTRAP_TOKEN=$(head -c 16 /dev/urandom | od -An -t x | tr -d ' ')
mkdir -p ./tmp
cp ./k8s.env ../tmp
sed -i "s/^BOOTSTRAP_TOKEN=\"/BOOTSTRAP_TOKEN=\"${BOOTSTRAP_TOKEN}\"/g" ../tmp/k8s.env

ansible all -m shell -a "mkdir -p /var/env"

ansible all -m copy -a "src=../tmp/k8s.env dest=/var/env"

ansible all -m script -a ./put-this-ip.sh

NAME=etcd

IPS=$MASTER

N=$(echo $MASTER | wc | awk -F ' ' '{print $2}')

NODE_IPS=""
ETCD_NODES=""
ETCD_ENDPOINTS=""

for i in $(seq -s ' ' 1 $N); do
  NODE_NAME="${NAME}-${i}"
  IP=$(echo $IPS | awk -v j=$i -F ' ' '{print $j}')
  NODE_IPS+=" $IP"
  ETCD_NODES+=",${NODE_NAME}=https://$IP:2380"
  ETCD_ENDPOINTS+=",https://$IP:2379"
done

#echo $NODE_IPS
#echo $ETCD_NODES
NODE_IPS=${NODE_IPS#* }
ETCD_NODES=${ETCD_NODES#*,}
ETCD_ENDPOINTS=${ETCD_ENDPOINTS#*,}
#echo $NODE_IPS
#echo $ETCD_NODES

for i in $(seq -s ' ' 1 $N); do
  FILE="../tmp/etcd.env.${i}"
  [ -e $FILE ] && rm -f $FILE
  [ -e $FILE ] || touch $FILE
  NODE_NAME="${NAME}-${i}"
  IP=$(echo $IPS | awk -v j=$i -F ' ' '{print $j}')
  echo "export NODE_NAME=$NODE_NAME" > $FILE
  echo -e "export NODE_IPS=\"$NODE_IPS\"" >> $FILE
  echo "export ETCD_NODES=$ETCD_NODES" >> $FILE
  echo "export ETCD_ENDPOINTS=$ETCD_ENDPOINTS" >> $FILE
  ansible $IP -m copy -a "src=$FILE dest=/var/env/etcd.env"
done

rm -rf ./tmp

ansible all -m script -a ./mk-env-conf.sh
