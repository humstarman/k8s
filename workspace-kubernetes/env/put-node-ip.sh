#!/bin/bash

NET_ID=$1
if [ -z "$NET_ID" ]
then
  NET_ID="192.168."
fi

THIS_IP=$NET_ID

#IPS=$(hostname --all-ip-address)
#IPS=$(ifconfig | grep "inet addr" | awk -F ':' '{print $2}' | awk -F ' ' '{print $1}')
IPS=$(ip addr | grep inet | awk -F 'inet ' '{print $2}' | awk -F '/' '{print $1}')
#echo "IP lst: $IPS"

SUFFIX=$(echo ${IPS#*${NET_ID}} | awk -F ' ' '{print $1}')

THIS_IP+=${SUFFIX}
MASTER_IP=127.0.0.1
PORT=6443

[ -e /var/env ] || mkdir -p /var/env
[ -f /var/env/this-ip.env ] || touch /var/env/this-ip.env
THIS_IP=$(echo "$THIS_IP" | grep -E "^[0-9]*.[0-9]*.[0-9]*.[0-9]*$")
if [ -n "$THIS_IP" ]; then
  echo "export NET_ID=$NET_ID" > /var/env/this-ip.env
  echo "export THIS_IP=$THIS_IP" >> /var/env/this-ip.env
  echo "export NODE_IP=$THIS_IP" >> /var/env/this-ip.env
  echo "export MASTER_IP=$MASTER_IP" >> /var/env/this-ip.env
  echo "export KUBE_APISERVER=https://${MASTER_IP}:${PORT}" >> /var/env/this-ip.env
else
  echo -e "# check the value of net id" | tee /var/env/this-ip.env
fi
