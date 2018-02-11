#!/bin/bash

DistributorID=$(lsb_release -i | awk -F ' ' '{print $3}' | tail -n 1)

echo $DistributorID
MATCHED="YES"

IF0=$(cat /etc/rc.local | grep "sleep 60 && \/sbin\/iptables -P FORWARD ACCEPT")

if [ "CentOS" == "$DistributorID" ]; then
  cd /etc/yum.repos.d && \
  if [ -f CentOS-Base.repo ]; then mv -f CentOS-Base.repo CentOS-Base.repo.bak; fi && \
  wget -O CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo && \
  yum clean all && \
  yum makecache && \
  cd -
  yum install -y yum-utils \
    device-mapper-persistent-data \
    lvm2
  yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
  yum install -y docker-ce
  
  # rc.local
  if [ -z "$IF0" ]; then
    echo "sleep 60 && /sbin/iptables -P FORWARD ACCEPT" >> /etc/rc.d/rc.local
    chmod +x /etc/rc.d/rc.local
  fi
elif [ "Ubuntu" == "$DistributorID" ]; then
  Codename=$( (lsb_release -a) | awk '{print $2}' | tail -n 1 )
  echo "\
    deb http://mirrors.aliyun.com/ubuntu/ $Codename main multiverse restricted universe
    deb http://mirrors.aliyun.com/ubuntu/ $Codename-backports main multiverse restricted universe
    deb http://mirrors.aliyun.com/ubuntu/ $Codename-proposed main multiverse restricted universe
    deb http://mirrors.aliyun.com/ubuntu/ $Codename-security main multiverse restricted universe
    deb http://mirrors.aliyun.com/ubuntu/ $Codename-updates main multiverse restricted universe
    deb-src http://mirrors.aliyun.com/ubuntu/ $Codename main multiverse restricted universe
    deb-src http://mirrors.aliyun.com/ubuntu/ $Codename-backports main multiverse restricted universe
    deb-src http://mirrors.aliyun.com/ubuntu/ $Codename-proposed main multiverse restricted universe
    deb-src http://mirrors.aliyun.com/ubuntu/ $Codename-security main multiverse restricted universe
    deb-src http://mirrors.aliyun.com/ubuntu/ $Codename-updates main multiverse restricted universe " > /etc/apt/sources.list
  apt-get update
  apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
  apt-get update
  apt-get install -y docker-ce
  
  # rc.local
  if [ -z "$IF0" ]; then
    sed -i "/exit 0/i\sleep 60 && /sbin/iptables -P FORWARD ACCEPT" /etc/rc.local
  fi
else
  echo "$(date) - $0 - [ERROR] - unknown Distributor ID."
  exit 1
fi

iptables -P FORWARD ACCEPT
iptables -F && iptables -X && iptables -F -t nat && iptables -X -t nat
systemctl enable docker
systemctl start docker
