#!/usr/bin/python

import os
import sys
from optparse import OptionParser
import etcd
import logging  
import logging.handlers  
import etcd
from random import choice,sample,shuffle
import commands
from time import sleep
from math import ceil
 
def set_logger():
    name = sys.argv[0].strip().split(r"/")[-1].strip().split('.')[0]
    LOG_DIR = r"%s/%s-%d" % (options.LD,options.APP,options.ID)
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
    parser.add_option("-e","--etcd",action="store",type="string",dest="ETCD",default=r"/etc/etcd",help="the directory of etcd info")
    parser.add_option("--ll",action="store",type="string",dest="LL",default="INFO",help="the log level")
    parser.add_option("--log_dir",action="store",type="string",dest="LD",default=r"/mnt/log",help="the dir to store log")
    parser.add_option("--cll",action="store",type="string",dest="CLL",default="INFO",help="the console log level")
    parser.add_option("--fll",action="store",type="string",dest="FLL",default="DEBUG",help="the file log level")
    parser.add_option("--ttl",action="store",type="int",dest="TTL",default="100",help="ttl")
    parser.add_option("--ip",action="store",type="str",dest="IP",default="",help="the ip address of this node")
    parser.add_option("--app",action="store",type="str",dest="APP",default="cassandra",help="todo")
    parser.add_option("--id",action="store",type="int",dest="ID",default="0",help="todo")
    (options,args) = parser.parse_args()

    return options

def get_etcd_client():
    etcd_hosts_file = os.path.join(options.ETCD,"hosts")
    logger.debug(etcd_hosts_file)
    etcd_port_file = os.path.join(options.ETCD,"port")
    logger.debug(etcd_port_file)

    with open(etcd_hosts_file) as f:
        etcd_hosts = f.read().strip()
        logger.debug(etcd_hosts)
    with open(etcd_port_file) as f:
        etcd_port = int(f.read().strip())
        logger.debug(etcd_port)
    etcds = etcd_hosts.strip().split(',')
    etcd_2_connect = choice(etcds)
    logger.debug("Connect to %s ETCD server" % etcd_2_connect)
    client = etcd.Client(
             host=etcd_2_connect,
             port=etcd_port,)

    return client

# mk global var: options & logger
options = parse_opts(OptionParser(usage="%prog [options]"))
logger = set_logger()
client = get_etcd_client()

def refresh_the_ttl():
    app = options.APP
    ip = options.IP
    client.write(r"/%s/nodes/%s" % (app,ip),ip,ttl=options.TTL)
    #client.write(r"/%s/info/%s" % (app,ip),None,dir=True,refresh=True,ttl=options.TTL2)
    client.write(r"/nodes/%s" % ip,None,dir=True,prevExist=True,ttl=options.TTL)
    logger.info("refresh TTl")

def main():
    #parser = OptionParser(usage="%prog [options]")
    #options = parse_opts(parser)

    if "" == options.IP:
        logger.error("Need an ip address to refresh...")
        logger.error("use --ip to set...")
        logger.error("Exit!")
        return 
    
    refresh_the_ttl()
    
if __name__ == "__main__":
    main()
