#!/bin/bash

if [ "$1" == "" ]
then
  echo "Need a parameter of cmd..."
  echo "Exit!"
  exit
fi
CMD=$1

if [ "$2" == "" ]
then
  TIME=2
else
  TIME=$2
fi

while true
do
  $CMD
  sleep $TIME
done
