#!/bin/bash

SVC=$1

if [ -z "$SVC" ]; then
  SVC="haproxy"
fi

#ps aux | grep -v $0 | grep -v grep | grep "$SVC"
#ps aux | grep -v -E "$0|grep" | grep "$SVC"
#COUNT=$(ps aux | grep -v $0 | grep -v grep | grep "$SVC" | wc -l)
COUNT=$(ps aux | grep -v -E "$0|grep" | grep "$SVC" | wc -l)
#echo $COUNT
if [ "$COUNT" -gt 0 ]; then
  exit 0
else
  exit 1
fi
