#!/usr/bin/python

import sys

def main():
  target = sys.argv[1]
  for ip in sys.argv[2:]:
    if target in ip:
      return ip

if __name__ == "__main__":
  print main()
