#!/bin/bash

FROM=hadoop
TO=hadoop

FILES=$(ls ./)

for FILE in $FILES; do
  #echo $FILE
  #IF0=$(echo $FILE | awk -F "$FROM" '{print $1}')
  SUFFIX=$(echo $FILE | awk -F "$FROM" '{print $2}')
  #echo $SUFFIX
  if [ -n "$SUFFIX" ]; then
    CHANGED="${TO}${SUFFIX}"
    #echo $CHANGED
    mv $FILE $CHANGED
  fi
done
