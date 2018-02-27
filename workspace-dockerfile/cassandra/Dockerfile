FROM lowyard/openjdk-8-jdk

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN (echo '9ol.8ik,';sleep 1;echo '9ol.8ik,') | passwd root

COPY build /opt

ENV cassandra_ver 3.11.1

RUN mkdir -p /opt && \
    cd /opt && \
    cat apache-cassandra-${cassandra_ver}-bin.tar.gz | \
      tar -zx && \
    rm -f apache-cassandra-${cassandra_ver}-bin.tar.gz && \
    ln -s apache-cassandra-${cassandra_ver} cassandra && \
    echo Cassandra ${cassandra_ver} installed in /opt

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ADD cassandra.yaml /opt/cassandra/conf
ADD start-master.sh /
ADD start-worker.sh /
ENV PATH $PATH:/opt/cassandra/bin
