#!/bin/bash

NET_ID=$1
if [ "$NET_ID" == "" ]
then
  echo "$(date) - [ERROR] - need the prefix of the local network."
  exit 1
fi

THIS_IP=$NET_ID

#IPS=$(hostname --all-ip-address)
IPS=$(ifconfig | grep "inet addr" | awk -F ':' '{print $2}' | awk -F ' ' '{print $1}')
#echo "IP lst: $IPS"

SUFFIX=$(echo ${IPS#*${NET_ID}} | awk -F ' ' '{print $1}')

THIS_IP+=${SUFFIX}
#echo "This IP: $THIS_IP"
echo "$THIS_IP"

