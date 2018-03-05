#!/bin/bash

NAMESPACE=filtre
CONFIGMAP=haproxy-config

create_cm(){
  kubectl create configmap $CONFIGMAP -n $NAMESPACE \
  --from-file=white.ip.lst=./white.ip.lst \
  --from-file=test.lst=./test.lst \
  --from-file=haproxy.cfg=./haproxy.cfg \
  --from-file=watch.lst=./watch.lst
}
rm_cm(){
  kubectl delete configmap $CONFIGMAP -n $NAMESPACE
}

if [ "-d" == "$1" ]; then
  rm_cm
  exit 0
elif [ "-r" == "$1" ]; then
  rm_cm
fi
create_cm
