FROM 172.31.78.217:5000/ubuntu-16.04 

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN (echo '9ol.8ik,';sleep 1;echo '9ol.8ik,') | passwd root

RUN apt-get install -y haproxy
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ADD liveness-probe.sh / 
RUN chmod +x /liveness-probe.sh
