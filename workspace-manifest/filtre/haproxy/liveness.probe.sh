#!/bin/bash
FILES="white.ip.lst test.lst haproxy.cfg"
for FILE in $FILES; do
  if [ ! -f /tmp/$FILE ]; then
    cp /etc/haproxy/$FILE /tmp/$FILE
  else
    DIFF=$(diff /etc/haproxy/$FILE /tmp/$FILE)
    if [ -n "$DIFF" ]; then 
      exit 1
    fi
  fi
done
exit 0
