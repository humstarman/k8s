#!/bin/bash

[ -f $ETC/etcd ] && rm $ETC/etcd
[ -f $ETC/etcd ] || touch $ETC/etcd
[ -e /etc/etcd ] || mkdir /etc/etcd

IPS=""
for IP in "$@"
do 
  IPS+="$IP,"
done

IPS=${IPS%,*}
echo $IPS > $ETC/etcd

echo $IPS > /etc/etcd/hosts
echo "2379" > /etc/etcd/port

