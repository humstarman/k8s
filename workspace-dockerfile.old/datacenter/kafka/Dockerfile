FROM ubuntu-16.04 

MAINTAINER Lue Young <lueyoung7@163.com>

# kafka_2.11-1.0.1.tgz
ENV kafka_ver 1.0.1 
ENV scala_ver 2.11 

COPY build /opt

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN (echo '9ol.8ik,';sleep 1;echo '9ol.8ik,') | passwd root

RUN apt-get update && \
    apt-get install -y openjdk-8-jdk scala

# uncompress & rename svc
RUN mkdir -p /opt && \
    cd /opt && \
    cat kafka_${scala_ver}-${kafka_ver}.tgz | \
      tar -zx && \
    rm kafka_${scala_ver}-${kafka_ver}.tgz && \
    ln -s kafka_${scala_ver}-${kafka_ver} kafka && \
    echo Kafka ${scala_ver}-${kafka_ver} installed in /opt

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* /usr/share/man /usr/share/doc

ADD entrypoint.sh /
ADD server.properties /opt/kafka/config/ 
ENV PATH $PATH:/opt/kafka/bin
