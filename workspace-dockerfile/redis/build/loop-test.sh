#!/bin/bash

I=0
touch /tmp/test.log
while true 
do
  echo "in loop"
  I=$[$I+1]
  echo $I >> /tmp/test.log
  ping -c 10 127.0.0.1 >/dev/null 2>&1
done
