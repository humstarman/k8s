#!/bin/bash

:(){
WAIT="10"
if ! getent hosts $DSCV; then
  echo "=== Cannot resolve the DNS entry for $DSCV. Has the service been created yet, and is SkyDNS functional?"
  echo "=== See http://kubernetes.io/v1.1/docs/admin/dns.html for more details on DNS integration."
  echo "=== Sleeping ${WAIT}s before pod exit."
  sleep $WAIT
  exit 0
fi

THIS_IP=$(hostname -i)
HADOOP_HOME=/opt/hadoop
LOG=$HADOOP_HOME/logs/slave-discovery.log
FILE=${HADOOP_HOME}/etc/hadoop/slaves

CONFUSE=$(getent hosts $DSCV)
echo "$(date) - $0 - confuse info: $CONFUSE"
j=0
for ip in $CONFUSE; do
  if [[ $ip =~ ^([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])$ ]] && [ "127.0.0.1" != "$ip" ] && [ "$THIS_IP" != "$ip" ]; then
    WORKER=$ip
    if [ "0" == "$j" ]; then
      echo $WORKER > $FILE
    else
      echo $WORKER >> $FILE
    fi
    /opt/auto-cp-ssh-id.sh root $PASSWD $WORKER
  else
    echo "$(date) - $0 - worker: ip -> $WORKER, name -> $ip, in the cluster." > $LOG
    j=$[$j+1]
  fi
done
}

while true; do
  :
  sleep $INTERVAL
done
