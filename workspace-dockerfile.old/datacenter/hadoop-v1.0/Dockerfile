FROM lowyard/openjdk-8-jdk

COPY build /opt

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN (echo '9ol.8ik,';sleep 1;echo '9ol.8ik,') | passwd root

ENV hadoop_ver 3.0.0 

RUN cd /usr/lib/jvm && \
    ln -s java-8-openjdk-amd64 jdk

RUN mkdir -p /opt && \
    cd /opt && \
    #tar -zxf hadoop-${hadoop_ver}.tar.gz hadoop-${hadoop_ver}/lib/native && \
    cat hadoop-${hadoop_ver}.tar.gz | \
        tar -zx && \
    rm -f hadoop-${hadoop_ver}.tar.gz && \
    ln -s hadoop-${hadoop_ver} hadoop && \
    echo Hadoop ${hadoop_ver} installed in /opt

RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 0600 ~/.ssh/authorized_keys

RUN mkdir -p ~/hdfs/namenode && \ 
    mkdir -p ~/hdfs/datanode && \
    mkdir -p /opt/hadoop/logs 

RUN apt-get update && \
    apt-get install -y expect && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ADD start-common.sh start-worker start-master /
ADD workers core-site.xml hadoop-env.sh hdfs-site.xml mapred-site.xml yarn-site.xml /opt/hadoop/etc/hadoop/
ADD worker-discovery.sh auto-cp-ssh-id.sh /opt/
RUN /opt/hadoop/bin/hdfs namenode -format
ENV PATH $PATH:/opt/hadoop/bin:/opt/hadoop/sbin
