#!/bin/bash

:(){
  FILES=$(find /var/env -name "*.env")

  if [ -n "$FILES" ]
  then
  for FILE in $FILES
  do
    [ -f $FILE ] && source $FILE
  done
  fi
};:

#echo $(hostname -f)
cd /tmp && \
echo $HOSTNAME > index.html && \
nohup python -m SimpleHTTPServer 8080 &

