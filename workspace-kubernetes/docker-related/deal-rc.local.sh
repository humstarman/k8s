#!/bin/bash

DistributorID=$(lsb_release -i | awk -F ' ' '{print $3}' | tail -n 1)

echo $DistributorID

IF0=$(cat /etc/rc.local | grep "sleep 60 && \/sbin\/iptables -P FORWARD ACCEPT")

if [ "CentOS" == "$DistributorID" ]; then
  # rc.local
  if [ -z "$IF0" ]; then
    echo "sleep 60 && /sbin/iptables -P FORWARD ACCEPT" >> /etc/rc.d/rc.local
    chmod +x /etc/rc.d/rc.local
  fi
elif [ "Ubuntu" == "$DistributorID" ]; then
  # rc.local
  if [ -z "$IF0" ]; then
    sed -i "/exit 0/i\sleep 60 && /sbin/iptables -P FORWARD ACCEPT" /etc/rc.local
  fi
else
  echo "$(date) - $0 - [ERROR] - unknown Distributor ID."
  exit 1
fi
