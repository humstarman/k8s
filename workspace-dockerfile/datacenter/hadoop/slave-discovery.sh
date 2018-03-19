#!/bin/bash

:(){
WAIT="10"
i=0
while true; do 
  if [ "$i" -gt "$TRIES" ]; then
    echo "=== Cannot resolve the DNS entry for $DSCV. Has the service been created yet, and is SkyDNS functional?"
    echo "=== See http://kubernetes.io/v1.1/docs/admin/dns.html for more details on DNS integration."
    echo "=== Sleeping ${WAIT}s before pod exit."
    sleep $WAIT
    return 
  fi
  if ! getent hosts $DSCV; then
    i=$[i+1]
    sleep 1
  else
    break;
  fi
done

THIS_IP=$(hostname -i)
HADOOP_HOME=/opt/hadoop
LOG=$HADOOP_HOME/logs/slave-discovery.log
FILE=${HADOOP_HOME}/etc/hadoop/slaves

# update slaves
CONFUSE=$(getent hosts $DSCV)
IPS=""
#echo "$(date) - $0 - confuse info: $CONFUSE"
j=0
for ip in $CONFUSE; do
  if [[ $ip =~ ^([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])$ ]] && [ "127.0.0.1" != "$ip" ] && [ "$THIS_IP" != "$ip" ]; then
    WORKER=$ip
    if [ "0" == "$j" ]; then
      echo $WORKER > $FILE
    else
      echo $WORKER >> $FILE
    fi
    /opt/auto-cp-ssh-id.sh root $PASSWD $WORKER > /dev/null 2>&1
    IPS+=" $ip"
  else
    echo "$(date) - $0 - worker: ip -> $WORKER, name -> $ip, in the cluster." > $LOG
    j=$[$j+1]
  fi
done

# update /etc/hosts
N=$(echo $IPS | wc | awk -F ' ' '{print $2}')
for i in $(seq -s ' ' 0 $[$N-1]); do
  NAME="${DSCV}-${i}"
  TRY=0
  IP=$(getent hosts $NAME.$DSCV | awk -F ' ' '{print $1}')
  while [ -z "$IP" ]; do
    sleep 1
    TRY=$[${TRY}+1]
    if [ "$TRY" -gt "$TRIES" ]; then
      echo "=== Cannot resolve the DNS entry for ${NAME}. Has the service been created yet, and is SkyDNS functional?"
      echo "=== See http://kubernetes.io/v1.1/docs/admin/dns.html for more details on DNS integration."
      echo "=== Sleeping ${WAIT}s before pod exit."
      sleep $WAIT
      exit 0
    fi
    IP=$(getent hosts $NAME.$DSCV | awk -F ' ' '{print $1}')
  done
  IF0=$(cat /etc/hosts | grep "$NAME")
  if [ -z "$IF0" ]; then
    echo -e "${IP}\t${NAME}" >> /etc/hosts
  else
    TARGET=$(cat /etc/hosts | grep "$NAME" | awk -F ' ' '{print $1}' | tail -n 1)
    if [ "$TARGET" != "$IP" ]; then 
      FROM="${NAME}"
      TO="${IP} ${NAME}"
      sed -i "/$FROM/ c $TO" /etc/hosts
    fi
  fi
done
}

while true; do
  :
  sleep $INTERVAL
done
