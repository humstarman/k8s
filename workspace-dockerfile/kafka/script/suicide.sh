#!/bin/bash

echo "- $(date) - $0 - commit suicide!"
kill -9 $(ps aux | grep root | awk -F ' ' '{print $2}')
