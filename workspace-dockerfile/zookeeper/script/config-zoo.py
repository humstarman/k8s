#!/usr/bin/python

import os
import sys
from optparse import OptionParser
import logging  
import logging.handlers  
from random import choice,sample,shuffle
import commands
from time import sleep
from math import ceil
 
def set_logger():
    name = sys.argv[0].strip().split(r"/")[-1].strip().split('.')[0]
    LOG_DIR = r"%s/%s-%d" % (options.LD,options.APP,options.ID)
    os.system(r"[ -e %s ] || mkdir -p %s" % (LOG_DIR,LOG_DIR))
    LOG_FILE = os.path.join(LOG_DIR,"%s.log" % name)
    logger = logging.getLogger("%s" % name)

    logger.setLevel(logging.INFO)
    if options.LL.upper() in ["DEBUG",]:
        logger.setLevel(logging.DEBUG)       
    elif options.LL.upper() in ["INFO",]:
        logger.setLevel(logging.INFO) 
    elif options.LL.upper() in ["WARN","WARNING"]:
        logger.setLevel(logging.WARN)  
    elif options.LL.upper() in ["ERROR",]:
        logger.setLevel(logging.ERROR)  
    elif options.LL.upper() in ["CRITICAL",]:
        logger.setLevel(logging.CRITICAL)  
    else:
        pass
    
    #fh = logging.FileHandler(LOG_FILE)
    fh = logging.handlers.RotatingFileHandler(LOG_FILE, maxBytes = 1024*1024, backupCount = 5) 
    ch = logging.StreamHandler()  
    
    #fmt = "%(asctime)s-%(name)s-%(levelname)s-%(message)s-[%(filename)s:%(lineno)d]"
    fmt = '%(asctime)s - %(name)s - %(filename)s:%(lineno)s - %(levelname)s - %(message)s'
    formatter = logging.Formatter(fmt)

    fh.setFormatter(formatter)   
    ch.setFormatter(formatter)

    logger.addHandler(fh)   
    logger.addHandler(ch)

    return logger

def parse_opts(parser):
    parser.add_option("--ll",action="store",type="string",dest="LL",default="INFO",help="the log level")
    parser.add_option("--log_dir",action="store",type="string",dest="LD",default=r"/mnt/log",help="the dir to store log")
    parser.add_option("--cll",action="store",type="string",dest="CLL",default="INFO",help="the console log level")
    parser.add_option("--fll",action="store",type="string",dest="FLL",default="DEBUG",help="the file log level")
    parser.add_option("--ttl",action="store",type="int",dest="TTL",default="100",help="ttl")
    parser.add_option("--ip",action="store",type="str",dest="IP",default="",help="the ip address of this node")
    parser.add_option("--id",action="store",type="int",dest="ID",default="0",help="the id of this node")
    parser.add_option("--info",action="store",type="str",dest="INFO",default="",help="the info get from /$app/zk")
    parser.add_option("--app",action="store",type="str",dest="APP",default="kafka",help="todo")
    parser.add_option("--hosts",action="store",type="str",dest="HOSTS",default=r"/etc/hosts",help="todo")
    parser.add_option("--zoocfg",action="store",type="str",dest="ZOOCFG",default=r"/usr/local/zoo.cfg",help="todo")
    (options,args) = parser.parse_args()

    return options

# mk global var: options & logger
options = parse_opts(OptionParser(usage="%prog [options]"))
logger = set_logger()

def main():
    ip_id_string = options.INFO
    logger.debug("IP - ID string:")
    logger.debug(ip_id_string)
    ip_id_lst = ip_id_string.strip().split(',')
    logger.debug("IP - ID lst:")
    logger.debug(ip_id_lst)
    
    with open(options.HOSTS,"a+") as f1, open (options.ZOOCFG,"a+") as f2:
        for i in xrange(len(ip_id_lst)):
            _ip = ip_id_lst[i]
            _id = i+1
            string1 = "%s\t%s-%d\n" % (_ip,options.APP,_id)
            f1.write(string1)
            string2 = "server.%d=%s:2888:3888\n" % (_id,_ip) 
            f2.write(string2)
    
if __name__ == "__main__":
    main()
