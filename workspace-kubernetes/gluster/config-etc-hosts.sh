#!/bin/bash

IF0=$(cat /etc/hosts | grep "node-")
if [ -z "$IF0" ]; then
  echo "172.31.78.215 node-215" >> /etc/hosts
  echo "172.31.78.216 node-216" >> /etc/hosts
  echo "172.31.78.217 node-217" >> /etc/hosts
fi
