FROM ubuntu-16.04 

MAINTAINER Lue Young <lueyoung7@163.com>

ENV zookeeper_ver 3.4.11

COPY build /opt

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN (echo '9ol.8ik,';sleep 1;echo '9ol.8ik,') | passwd root

RUN apt-get update && \
    apt-get install -y openjdk-8-jdk

# uncompress & rename svc 
RUN mkdir -p /opt && \
    cd /opt && \
    cat zookeeper-${zookeeper_ver}.tar.gz | \
        tar -zx && \
    rm zookeeper-${zookeeper_ver}.tar.gz && \
    ln -s zookeeper-${zookeeper_ver} zookeeper && \
    echo Zookeeper ${zookeeper_ver} installed in /opt

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* /usr/share/man /usr/share/doc

ADD zoo.cfg /opt/zookeeper/conf/
ADD entrypoint.sh /
ENV PATH $PATH:/opt/zookeeper/bin
