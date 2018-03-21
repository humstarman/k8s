FROM ubuntu-16.04 


ENV cassandra_ver 3.11.2

ENV ftp_server 172.31.78.216:2121 

RUN mkdir -p /opt && \
    cd /opt && \
    curl ftp://${ftp_server}/apache-cassandra-${cassandra_ver}-bin.tar.gz | \
      tar -zx && \
    ln -s apache-cassandra-${cassandra_ver} cassandra && \
    echo Cassandra ${cassandra_ver} installed in /opt

RUN apt-get clean && \ 
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* /usr/share/man /usr/share/doc

ADD cassandra.yaml /opt/cassandra/conf
ADD start-master.sh /
ADD start-worker.sh /
ENV PATH $PATH:/opt/cassandra/bin
