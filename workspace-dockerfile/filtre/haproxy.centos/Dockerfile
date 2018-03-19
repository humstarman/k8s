FROM centos-7:min 

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

RUN yum makecache && \
    yum install -y haproxy && \
    yum clean all && \
    rm -rf /var/cache/yum

ADD liveness-probe.sh / 
RUN chmod +x /liveness-probe.sh
