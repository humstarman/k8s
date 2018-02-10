#!/bin/bash

SVC=$1
if [ -z "$SVC" ]; then
  echo "$(date) - $0 - [ERROR] - no service input!"
  exit 1 
fi

GROUP=$2
if [ -z "$GROUP" ]; then
  echo "$(date) - $0 - [WARN] - need ansible group, default is 'all'"
  GROUP="all" 
fi

ansible $GROUP -m shell -a "systemctl daemon-reload"
ansible $GROUP -m shell -a "systemctl enable $SVC"
ansible $GROUP -m shell -a "systemctl start $SVC"
