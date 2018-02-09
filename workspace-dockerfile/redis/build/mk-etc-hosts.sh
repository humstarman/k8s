#!/bin/bash

[ -f /etc/hosts ] && mv /etc/hosts /etc/hosts.bak
[ -f /etc/hosts ] || touch /etc/hosts

echo -e "127.0.0.1\tlocalhost" > /etc/hosts

IDX=0

for i in "$@"; do
  IDX=$[$IDX+1]
  j=$[$IDX%2]
  if [ "$j" == 1 ]; then
    str="$i"
  else
    echo -e "$str\t$i" >> /etc/hosts
  fi
done

echo '' >> /etc/hosts
echo -e "# The following lines are desirable for IPv6 capable hosts" >> /etc/hosts
echo -e "::1\tlocalhost ip6-localhost ip6-loopback" >> /etc/hosts
echo -e "ff02::1\tip6-allnodes" >> /etc/hosts
echo -e "ff02::2\tip6-allrouters" >> /etc/hosts
