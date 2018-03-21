#!/bin/bash

USER=root
PASSWD="9ol.8ik,"
VM_PREFIX="192.168.0.4"
for i in $(seq -s " " 1 6); do
  VM="${VM_PREFIX}$i"
  ./auto-cp-ssh-id.sh $USER $PASSWD $VM
done
