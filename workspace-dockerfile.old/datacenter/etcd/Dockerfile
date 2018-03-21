FROM ubuntu-16.04 

MAINTAINER Lue Young <lueyoung7@163.com>

ENV etcd_ver v3.3.2

COPY build /opt

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime
RUN (echo '9ol.8ik,';sleep 1;echo '9ol.8ik,') | passwd root

RUN apt-get update && \
    apt-get install -y openjdk-8-jdk

# uncompress & rename svc
RUN mkdir -p /opt && \
    cd /opt && \
    cat etcd-${etcd_ver}-linux-amd64.tar.gz | \
        tar -zx && \
    rm etcd-${etcd_ver}-linux-amd64.tar.gz && \
    ln -s etcd-${etcd_ver}-linux-amd64 etcd && \
    echo Etcd ${etcd_ver} installed in /opt

RUN apt-get clean && \ 
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* /usr/share/man /usr/share/doc

ADD entrypoint.sh /
