FROM lowyard/openjdk-8-jdk

MAINTAINER Lue Young <lueyoung7@163.com>

ENV zookeeper_ver 3.4.11

COPY build /opt

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN (echo '9ol.8ik,';sleep 1;echo '9ol.8ik,') | passwd root

# uncompress & rename svc 
RUN mkdir -p /opt && \
    cd /opt && \
    cat zookeeper-${zookeeper_ver}.tar.gz | \
        tar -zx && \
    rm zookeeper-${zookeeper_ver}.tar.gz && \
    ln -s zookeeper-${zookeeper_ver} zookeeper && \
    echo Zookeeper ${zookeeper_ver} installed in /opt

ADD zoo.cfg /opt/zookeeper/conf/
ADD entrypoint.sh /
ENV PATH $PATH:/opt/zookeeper/bin
