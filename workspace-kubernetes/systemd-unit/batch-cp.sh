#!/bin/bash

SVC=$1
if [ -z "$SVC" ]; then
  echo "$(date) - $0 - [ERROR] - service is needed!"
  exit 1
fi

DEST=$2
if [ -z "$DEST" ]; then
  DEST=/etc/systemd/system/$SVC.service
fi
echo $DEST

NET="172.31.78."
HOSTS="215 216 217"
for HOST in $HOSTS; do
  FILE="$SVC.service.$HOST"
  #echo $FILE
  REMOTE=${NET}${HOST}
  echo $REMOTE
  ansible $REMOTE -m copy -a "src=./$FILE dest=$DEST" 
done
