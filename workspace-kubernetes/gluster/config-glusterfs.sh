#!/bin/bash

VOL_FOR_GLUSTER="data1"

sed -i "s/var\/lib/$VOL_FOR_GLUSTER/g" /etc/glusterfs/glusterd.vol

iptables -I INPUT -p tcp --dport 24007 -j ACCEPT

mkdir -p /$VOL_FOR_GLUSTER/gfs_data

systemctl enable glusterd
systemctl start glusterd

