FROM ubuntu-16.04 

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN (echo '9ol.8ik,';sleep 1;echo '9ol.8ik,') | passwd root

ENV hadoop_ver 2.7.5 
ENV spark_ver 2.3.0
ENV ftp_server 172.31.78.216:2121

RUN apt-get update && \
    apt-get install -y curl && \
    apt-get install -y openjdk-8-jdk && \
    apt-get install -y python-numpy
# Get Hadoop from US Apache mirror and extract just the native
# libs. (Until we care about running HDFS with these containers, this
# is all we need.)
RUN mkdir -p /opt && \
    cd /opt && \
    #tar -zxf hadoop-${hadoop_ver}.tar.gz hadoop-${hadoop_ver}/lib/native && \
    curl ftp://${ftp_server}/hadoop-${hadoop_ver}.tar.gz | \
        tar -zx hadoop-${hadoop_ver}/lib/native && \
    ln -s hadoop-${hadoop_ver} hadoop && \
    echo Hadoop ${hadoop_ver} native libraries installed in /opt/hadoop/lib/native

# Get Spark from US Apache mirror.
RUN mkdir -p /opt && \
    cd /opt && \
    #tar -zxf spark-${spark_ver}-bin-hadoop2.7.tgz && \
    curl ftp://${ftp_server}/spark-${spark_ver}-bin-hadoop2.7.tgz | \
        tar -zx && \
    ln -s spark-${spark_ver}-bin-hadoop2.7 spark && \
    echo Spark ${spark_ver} installed in /opt

# Add the GCS connector.
#RUN mv /opt/gcs-connector-latest-hadoop2.jar /opt/spark/lib
RUN mkdir -p /opt/spark/lib && \
    cd /opt/spark/lib && \
    curl -O ftp://${ftp_server}/gcs-connector-latest-hadoop2.jar
    #curl -o gcs-connector-latest-hadoop2.jar ftp://${ftp_server}/gcs-connector-latest-hadoop2.jar

# if numpy is installed on a driver it needs to be installed on all
# workers, so install it everywhere\
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* /usr/share/man /usr/share/doc

ADD log4j.properties /opt/spark/conf/log4j.properties
ADD start-common.sh start-worker start-master /
ADD core-site.xml /opt/spark/conf/core-site.xml
ADD spark-defaults.conf /opt/spark/conf/spark-defaults.conf
ENV PATH $PATH:/opt/spark/bin
