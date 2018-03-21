#!/bin/bash

IF0=$(cat /etc/fstab | grep "/dev/sda3")

if [ -z "${IF0}" ]; then
  mkdir -p /opt
  echo "/dev/sda3 /opt xfs defaults 0 0" >> /etc/fstab
  mount -a
else
  echo "written already"
fi
