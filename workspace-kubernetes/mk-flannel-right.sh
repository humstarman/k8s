#!/bin/bash

ip link delete flannel.1

systemctl restart flanneld
