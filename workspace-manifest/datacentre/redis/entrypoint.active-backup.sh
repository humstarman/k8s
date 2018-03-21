#!/bin/bash

set -e

service ssh start

THIS_IP=${POD_IP}

# for pv
[ -e /mnt/$(hostname -s) ] || mkdir -p /mnt/$(hostname -s) 

sed -i "s/{{pod.ip}}/${THIS_IP}/g" /opt/redis/redis.conf
sed -i "s/{{pv.dir}}/\/mnt\/$(hostname -s)/g" /opt/redis/redis.conf
sed -i "s/# maxmemory <bytes>/maxmemory $[25*1024*1024*1024]/g" /opt/redis/redis.conf

if [ "$ROLE" == "MASTER" ]; then
  ping -c 1 127.0.0.1 > /dev/null 2>&1
elif [ "$ROLE" == "SLAVE" ]; then
  if ! getent hosts $DSCV; then
    echo "=== Cannot resolve the DNS entry for $DSCV. Has the service been created yet, and is SkyDNS functional?"
    echo "=== See http://kubernetes.io/v1.1/docs/admin/dns.html for more details on DNS integration."
    echo "=== Sleeping 10s before pod exit."
    sleep 10
    exit 0
  fi
  MASTER=$(getent hosts $DSCV | awk -F ' ' '{print $1}')
  echo "$(date) - $0 - master ip: $MASTER"
  if [ -z "$REDIS_PORT" ]; then
    REDIS_PORT="6379"
  fi
  sed -i "s/# slaveof <masterip> <masterport>/slaveof $MASTER $REDIS_PORT/g" /opt/redis/redis.conf
else
  echo "=== No such role as $ROLE."
  echo "=== Sleeping 10s before pod exit."
  sleep 10
  exit 0
fi

/opt/redis/src/redis-server /opt/redis/redis.conf --protected-mode no
