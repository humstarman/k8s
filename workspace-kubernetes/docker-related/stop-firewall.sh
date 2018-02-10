#!/bin/bash

DistributorID=$(lsb_release -i | awk -F ' ' '{print $3}' | tail -n 1)

echo $DistributorID

if [ "CentOS" == "$DistributorID" ]; then
  FIREWALL="firewalld"
elif [ "Ubuntu" == "$DistributorID" ]; then
  FIREWALL="ufw"
else
  echo "$(date) - $0 - [ERROR] - unknown Distributor ID."
  exit 1
fi

systemctl stop $FIREWALL
systemctl disable $FIREWALL
