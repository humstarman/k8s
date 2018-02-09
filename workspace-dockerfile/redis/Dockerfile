FROM lowyard/redis-base:4.0.7 

MAINTAINER Lue Young <lueyoung7@163.com>

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN (echo '9ol.8ik,';sleep 1;echo '9ol.8ik,') | passwd root

ADD redis.conf /opt/redis/
ADD entrypoint.sh /
