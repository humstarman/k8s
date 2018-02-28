#!/bin/bash

DistributorID=$(lsb_release -i | awk -F ' ' '{print $3}' | tail -n 1)
GlusterVer=3.12

echo $DistributorID


if [ "CentOS" == "$DistributorID" ]; then
  yum install centos-release-gluster -y
  yum install -y glusterfs glusterfs-server glusterfs-fuse glusterfs-rdma glusterfs-geo-replication glusterfs-devel
elif [ "Ubuntu" == "$DistributorID" ]; then
  add-apt-repository -y ppa:gluster/glusterfs-$GlusterVer
  apt-get update
  apt install -y glusterfs-server glusterfs-client
else
  echo "$(date) - $0 - [ERROR] - unknown Distributor ID."
  exit 1
fi
