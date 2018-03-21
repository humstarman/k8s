FROM ubuntu-16.04 

COPY build /opt

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN (echo '9ol.8ik,';sleep 1;echo '9ol.8ik,') | passwd root

ENV hadoop_ver 2.7.5 
ENV spark_ver 2.2.1

# Get Hadoop from US Apache mirror and extract just the native
# libs. (Until we care about running HDFS with these containers, this
# is all we need.)
RUN mkdir -p /opt && \
    cd /opt && \
    #tar -zxf hadoop-${hadoop_ver}.tar.gz hadoop-${hadoop_ver}/lib/native && \
    cat hadoop-${hadoop_ver}.tar.gz | \
        tar -zx hadoop-${hadoop_ver}/lib/native && \
    rm -f hadoop-${hadoop_ver}.tar.gz && \
    ln -s hadoop-${hadoop_ver} hadoop && \
    echo Hadoop ${hadoop_ver} native libraries installed in /opt/hadoop/lib/native

# Get Spark from US Apache mirror.
RUN mkdir -p /opt && \
    cd /opt && \
    #tar -zxf spark-${spark_ver}-bin-hadoop2.7.tgz && \
    cat spark-${spark_ver}-bin-hadoop2.7.tgz | \
        tar -zx && \
    rm -f spark-${spark_ver}-bin-hadoop2.7.tgz && \
    ln -s spark-${spark_ver}-bin-hadoop2.7 spark && \
    echo Spark ${spark_ver} installed in /opt

# Add the GCS connector.
RUN mv /opt/gcs-connector-latest-hadoop2.jar /opt/spark/lib

# if numpy is installed on a driver it needs to be installed on all
# workers, so install it everywhere
RUN apt-get update && \
    apt-get install -y curl && \
    apt-get install -y openjdk-8-jdk && \
    apt-get install -y python-numpy && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* /usr/share/man /usr/share/doc

ADD log4j.properties /opt/spark/conf/log4j.properties
ADD start-common.sh start-worker start-master /
ADD core-site.xml /opt/spark/conf/core-site.xml
ADD spark-defaults.conf /opt/spark/conf/spark-defaults.conf
ENV PATH $PATH:/opt/spark/bin
