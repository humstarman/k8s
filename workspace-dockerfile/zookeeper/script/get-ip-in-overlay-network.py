#!/usr/bin/python

import sys
import commands

# $1: net id
# $2: the ret of $(hostname --all-ip-address)

def get_ip_from_eth():
  for i in xrange(10):
    ip_from_eth = commands.getoutput(r"ifconfig eth%d | grep 'inet addr' | awk -F ':' '{print $2}' | awk -F ' ' '{print $1}'" % i).strip()
    if "error" in ip_from_eth: pass
    else: return ip_from_eth

def main():
  target = sys.argv[1]
  ips = []
  for ip in sys.argv[2:]:
    if target in ip:
      ips.append(ip)
  if len(ips) == 1:
    return ips[0]
  else:
    return get_ip_from_eth()

if __name__ == "__main__":
  print main()
