#!/usr/bin/python

import sys

def main():
  key = sys.argv[1]
  in_ret = sys.argv[2]
  not_ret = sys.argv[3]
  for ip in sys.argv[4:]:
    if key in ip: return in_ret 
  return not_ret
  

if __name__ == "__main__":
  print main()
