#!/bin/bash

cp ./switch-on-kernel-modules.sh /usr/local/bin
cp mod-for-glusterfs.service /etc/systemd/system
systemctl daemon-reload
systemctl enable mod-for-glusterfs.service
systemctl start mod-for-glusterfs.service
