#!/bin/bash

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

INTERVAL="10"
[ -f /tmp/maintain.log ] && echo '==============================' > /tmp/maintain.log
[ -f /tmp/maintain.log ] || touch /tmp/maintain.log

#IP_BLANK=$($CASSANDRA_HOME/bin/nodetool status | grep "DN\|UJ" | awk -F ' ' '{print $2}')
IP_BLANK=$($CASSANDRA_HOME/bin/nodetool status | grep "DN" | awk -F ' ' '{print $2}')
IP_STRING_PREVOUS=$($WORKDIR/mk-string.py $IP_BLANK)
TIME=$(date "+%Y-%m-%d %H:%M:%S")
echo "$TIME - previous dn node:" >> /tmp/maintain.log
echo "$IP_STRING_PREVOUS" >> /tmp/maintain.log
echo "" >> /tmp/maintain.log

# wait
ping -c $INTERVAL 127.0.0.1 >/dev/null 2>&1

#IP_BLANK=$($CASSANDRA_HOME/bin/nodetool status | grep "DN\|UJ" | awk -F ' ' '{print $2}')  
IP_BLANK=$($CASSANDRA_HOME/bin/nodetool status | grep "DN" | awk -F ' ' '{print $2}')  
IP_STRING_NOW=$($WORKDIR/mk-string.py $IP_BLANK)
TIME=$(date "+%Y-%m-%d %H:%M:%S")
echo "$TIME - dn node right now:" >> /tmp/maintain.log
echo "$IP_STRING_NOW" >> /tmp/maintain.log
echo "" >> /tmp/maintain.log
IP_2_DEL=$($WORKDIR/find-dn.py $IP_STRING_PREVOUS $IP_STRING_NOW)
echo "dn node to delete:" >> /tmp/maintain.log
echo "$IP_2_DEL" >> /tmp/maintain.log
echo "" >> /tmp/maintain.log
if [ "$IP_2_DEL" != "" ]  
then
  for IP in $(echo $IP_2_DEL)
  do
    TIME=$(date "+%Y-%m-%d %H:%M:%S")
    echo "$TIME - Delete dn: $IP" >> /tmp/maintain.log
    $CASSANDRA_HOME/bin/nodetool assassinate $IP
  done
fi

echo "" >> /tmp/maintain.log
TIME=$(date "+%Y-%m-%d %H:%M:%S")
echo "$TIME - Done." >> /tmp/maintain.log
