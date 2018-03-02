FROM lowyard/openjdk-8-jdk 

MAINTAINER Lue Young <lueyoung7@163.com>

ENV etcd_ver v3.3.0

COPY build /opt

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime
RUN (echo '9ol.8ik,';sleep 1;echo '9ol.8ik,') | passwd root

# uncompress & rename svc
RUN mkdir -p /opt && \
    cd /opt && \
    cat etcd-${etcd_ver}-linux-amd64.tar.gz | \
        tar -zx && \
    rm etcd-${etcd_ver}-linux-amd64.tar.gz && \
    ln -s etcd-${etcd_ver}-linux-amd64 etcd && \
    echo Etcd ${etcd_ver} installed in /opt

ADD entrypoint.sh /
