#!/bin/bash

if [ $# -lt 1 ]; then
echo $0 need a parameter
exit 1
fi
function get_ip() {
  ADDR=$1
  #TMPSTR=`ping ${ADDR} packetsize 1 | grep ${ADDR} | head -n 1`
  TMPSTR=$(ping -c 1 ${ADDR} | grep ${ADDR} | head -n 1)
  [ -f /tmp/ip ] || touch /tmp/ip
  echo ${TMPSTR} | cut -d'(' -f 2 | cut -d')' -f1 > /tmp/ip
}

IP=""
RETRY=0
while [ "$IP" == "" ]
do
  get_ip $1
  IP=$(cat /tmp/ip)
  if [ "$IP" == "" ]
  then
    RETRY=$[$RETRY+1]
    if [ "$RETRY" -gt "10" ]
    then
      exit 1
    fi
    ping -c 2 127.0.0.1 >/dev/null 2>&1
  fi
done

echo $IP
