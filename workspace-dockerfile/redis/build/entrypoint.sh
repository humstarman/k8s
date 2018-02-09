#!/bin/bash

set -e

# function
## config env
function config_env() {
  FILES=$(find /var/env -name "*.env")

  if [ -n "$FILES" ]
  then
    for FILE in $FILES
    do
      [ -f $FILE ] && source $FILE
    done
  fi
}

config_env

ARGS="-a $ALIAS -i $THIS_IP --ld $LOG_DIR --ll debug"

# prepare
# echo the values
echo "$(date) - $0 - Nodes in this cluster: $N"
# prepare
echo "$(date) - $0 - Net ID: $NET_ID"
echo "$(date) - $0 - IP: ${THIS_IP}"
echo "$(date) - $0 - ID: ${ID}"
echo "$(date) - $0 - Alias: ${ALIAS}"
echo "$(date) - $0 - Passwd: $PASSWD"
echo "$(date) - $0 - all ip addr: $(hostname --all-ip-address)"
echo "$(date) - $0 - svc discovery: $DSCV"
echo "$(date) - $0 - role: $ROLE"

service ssh start

# persistent volume setting
#[ -e /mnt/$HOSTNAME ] || mkdir -p /mnt/$HOSTNAME
# del previous cluster info
#echo "Redis port: $REDIS_PORT"
#[ -f /mnt/$HOSTNAME/nodes-${REDIS_PORT}.conf ] && rm /mnt/$HOSTNAME/nodes-${REDIS_PORT}.conf

# start ssh service
#service ssh start

#[ "$ID" == "1" ] && $WORKDIR/mkdir.sh
#echo "$(date) - $0 - between MKDIR and REGISTER-UUID"
#[ "$ID" == "1" ] && $WORKDIR/register-uuid.sh

# mk config
$WORKDIR/ch-line.py -f $WORKDIR/redis.conf -1 "bind 127.0.0.1" -2 "bind $THIS_IP"
$WORKDIR/ch-line.py -f $WORKDIR/redis.conf -1 "# maxmemory <bytes>" -2 "maxmemory $[25*1024*1024*1024]" 
#$WORKDIR/ch-line.py -f $REDIS_HOME/redis.conf -1 "dir ./" -2 "dir /mnt/$HOSTNAME"
#[ "$ID" == 1 ] || $WORKDIR/ch-line.py -f $REDIS_HOME/redis.conf -1 "daemonize yes" -2 "daemonize no"

#echo "*/1 * * * * root $WORKDIR/cmd-listener-svc.sh" >> /etc/crontab
#[ "$ID" == "1" ] || /usr/sbin/cron


#[ "$ID" == "1" ] && echo "$(date) - $0 - Waiting for node to register." 
#[ "$ID" == "1" ] && ping -c $WAIT_FOR_REGISTER 127.0.0.1 > /dev/null 2>&1 
#[ "$ID" == "1" ] && $WORKDIR/mk-cluster-config.sh

#$WORKDIR/mk-flag.sh
#$REDIS_HOME/src/redis-server $REDIS_HOME/redis.conf

#[ "$ID" == "1" ] && CONFIG=$(cat $ETC/config)

# config mk-redis-cluster.sh
#[ "$ID" == "1" ] && $WORKDIR/ch-line.py -f $WORKDIR/mk-redis-cluster.sh -1 "spawn redis" -2 "spawn $REDIS_HOME/src/redis-trib.rb create --replicas 1 $CONFIG"
#[ "$ID" == "1" ] && $WORKDIR/mk-redis-cluster.sh

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
  $WORKDIR/ch-line.py -f $WORKDIR/redis.conf -1 "# slaveof <masterip> <masterport>" -2 "slaveof $MASTER $REDIS_PORT"
else
  echo "=== No such role as $ROLE."
  echo "=== Sleeping 10s before pod exit."
  sleep 10
  exit 0
fi

cp ${WORKDIR}/redis.conf $REDIS_HOME

/usr/sbin/cron

$REDIS_HOME/src/redis-server $REDIS_HOME/redis.conf --protected-mode no
