#!/bin/bash

# 开启 指定 volume 的配额
gluster volume quota k8s-volume enable

# 限制 指定 volume 的配额
gluster volume quota k8s-volume limit-usage / 1TB

# 设置 cache 大小, 默认32MB
gluster volume set k8s-volume performance.cache-size 4GB

# 设置 io 线程, 太大会导致进程崩溃
gluster volume set k8s-volume performance.io-thread-count 16

# 设置 网络检测时间, 默认42s
gluster volume set k8s-volume network.ping-timeout 10

# 设置 写缓冲区的大小, 默认1M
gluster volume set k8s-volume performance.write-behind-window-size 1024MB
