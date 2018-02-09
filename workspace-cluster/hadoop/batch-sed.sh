#!/bin/bash

FROM=hadoop
TO=hadoop

FILES=$(ls ./)

if [ -n "$FILES" ]; then
  for FILE in $FILES; do
    sed -i "s/$FROM/$TO/g" $FILE
  done
fi
