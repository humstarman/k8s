#!/bin/bash

NAMESPACE=datacentre
CONFIGMAP=cassandra-driver-scripts

create_cm(){
  kubectl create configmap $CONFIGMAP -n $NAMESPACE \
  --from-file=write.test.py=./write-test.py
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

