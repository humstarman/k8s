#!/bin/bash

MODULES="dm_snapshot dm_mirror dm_thin_pool"
for MODULE in $MODULES; do
  modprobe $MODULE
done
for MODULE in $MODULES; do
  lsmod | grep $MODULE
done

iptables -I INPUT -p tcp --dport 24007 -j ACCEPT
