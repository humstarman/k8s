#!/bin/bash

export JAVA_HOME=/usr/lib/jvm/jdk
export HADOOP_HOME=/opt/hadoop

export HDFS_DATANODE_USE=root 
export HDFS_DATANODE_SECURE_USER=hdfs 
export HDFS_NAMENODE_USER=root 
export HDFS_SECONDARYNAMENODE_USER=root

export YARN_RESOURCEMANAGER_USER=root
export YARN_NODEMANAGER_USER=root

export HDFS_DATANODE_SECURE_USER=root
