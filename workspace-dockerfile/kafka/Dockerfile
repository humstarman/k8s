FROM lowyard/scala-2.11.6-6

MAINTAINER Lue Young <lueyoung7@163.com>

ENV kafka_ver 2.11-1.0.0 

COPY build /opt

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN (echo '9ol.8ik,';sleep 1;echo '9ol.8ik,') | passwd root

# uncompress & rename svc
RUN mkdir -p /opt && \
    cd /opt && \
    cat kafka_${kafka_ver}.tgz | \
      tar -zx && \
    rm kafka_${kafka_ver}.tgz && \
    ln -s kafka_${kafka_ver} kafka && \
    echo Kafka ${kafka_ver} installed in /opt

ADD entrypoint.sh /
ENV PATH $PATH:/opt/kafka/bin
