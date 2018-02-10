#!/bin/bash

ansible all -m copy -a "src=./daemon.json dest=/etc/docker"
ansible all -m copy -a "src=./docker dest=/etc/bash_completion.d/"
