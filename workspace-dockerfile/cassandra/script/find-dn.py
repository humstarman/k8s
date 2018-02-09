#!/usr/bin/python

import sys

def main():
  #print len(sys.argv)
  ret = []
  if len(sys.argv) == 3:
    previous = sys.argv[1].strip().split(',')
    now = sys.argv[2].strip().split(',')
    ret = [i for i in now if i in previous]
  
  print ' '.join(ret)

if __name__ == "__main__":
  main()
