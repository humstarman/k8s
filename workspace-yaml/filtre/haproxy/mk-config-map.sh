#!/bin/bash

NAMESPACE=filtre
CONFIGMAP=haproxy-config

if [ "-d" == "$1" ]; then
  kubectl delete configmap $CONFIGMAP -n $NAMESPACE
  exit 0
fi

kubectl create configmap $CONFIGMAP -n $NAMESPACE \
  --from-file=white.ip.lst=./white.ip.lst \
  --from-file=test.lst=./test.lst \
  --from-file=haproxy.cfg=./haproxy.cfg \
  --from-file=watch.lst=./watch.lst
