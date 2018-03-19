#!/bin/bash

FTP_SERVER=$1
if [ -z "$FTP_SERVER" ]; then
  echo "[ERROR] - input the info of ftp server, in term of IP:PORT"
  exit 0
fi

MARKER="ENV ftp_server"
TO="$MARKER $FTP_SERVER"

DOCKERFILES=$(find ./ -name "Dockerfile*" -type f)

for DOCKERFILE in $DOCKERFILES; do
  sed -i "/${MARKER}/ c $TO" $DOCKERFILE
done
