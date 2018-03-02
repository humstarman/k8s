#!/bin/bash

FROM=v1.9.2
TO=v1.9.3
DEST=/usr/local/bin
ARCHIVE=/opt/app/k8s-bin

if [ ! -d $ARCHIVE-$TO ]; then
  echo "========="
  echo "prepare $TO k8s bin"
  echo "and put the components in DIR: $ARCHIVE-$TO"
  echo "========="
  exit 1
fi

COMPONENTS=$(ls $ARCHIVE-$TO)
echo $COMPONENTS
[ -d $ARCHIVE-$FROM ] || mkdir $ARCHIVE-$FROM
for COMPONENT in $COMPONENTS; do
  cp $DEST/$COMPONENT $ARCHIVE-$FROM
  if [ "kubectl" != "$COMPONENT" ]; then
    systemctl stop $COMPONENT
  fi
done

cp $ARCHIVE-$TO/* $DEST
for COMPONENT in $COMPONENTS; do
  if [ "kubectl" != "$COMPONENT" ]; then
    systemctl start $COMPONENT
  fi
done
