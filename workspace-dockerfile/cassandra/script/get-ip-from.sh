#!/bin/bash

# $1: node hostname
# ret: IP string
NODE=$1
IP="$NET_ID"
IPS=$(ansible ${NODE} -m shell -a "ifconfig" | grep "inet addr" | awk -F ':' '{print $2}' | awk -F ' ' '{print $1}')

SUFFIX=$(echo ${IPS#*${NET_ID}} | awk -F ' ' '{print $1}')
IP+=${SUFFIX}

echo "$IP" > $ETC/${NODE}.ip
