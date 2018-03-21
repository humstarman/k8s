#!/bin/bash

VOL_FOR_GLUSTER="data1"

iptables -I INPUT -p tcp --dport 24007 -j ACCEPT

mkdir -p /$VOL_FOR_GLUSTER/gfs_data
