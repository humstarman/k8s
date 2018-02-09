#!/usr/bin/python

import os
import sys
from optparse import OptionParser
import etcd
import logging  
import logging.handlers  
import etcd
import commands
import uuid
from random import choice
 
def set_logger(name=""):
    name = sys.argv[0].strip().split(r"/")[-1].strip().split('.')[0] if name == "" else name
    LOG_DIR=options.LD
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
    parser.add_option("-e","--etcd",action="store",type="string",dest="ETCD",default="/etc/etcd",help="the directory of etcd info")
    parser.add_option("-a","--alias",action="store",type="string",dest="alias",default="",help="the alias of the cluster")
    parser.add_option("-i","--ip",action="store",type="string",dest="ip",default="",help="Todo")
    parser.add_option("--etc",action="store",type="string",dest="etc",default="/etc/self",help="the dir of etc")
    parser.add_option("--ll",action="store",type="string",dest="LL",default="INFO",help="the log level")
    parser.add_option("--ld",action="store",type="string",dest="LD",default="/mnt/log",help="the dir to store log")
    parser.add_option("--cll",action="store",type="string",dest="CLL",default="INFO",help="the console log level")
    parser.add_option("--fll",action="store",type="string",dest="FLL",default="DEBUG",help="the file log level")
    parser.add_option("--ttl",action="store",type="int",dest="ttl",default="1000",help="a larger ttl")
    parser.add_option("--loop_num",action="store",type="int",dest="LOOP_NUM",default="5",help="a loop number for watch the flag")
    parser.add_option("--loop_interval",action="store",type="int",dest="LOOP_INTERVAL",default="1",help="a loop interval for watch the flag")
    parser.add_option("--timeout",action="store",type="int",dest="TIMEOUT",default="30",help="the threshold of timeout in raft used to elect leader")
    parser.add_option("--timeout_upper",action="store",type="int",dest="MAX_TIMEOUT",default="1000",help="the upper bound of timeout in raft used to elect leader")
    parser.add_option("--inactivation",action="store",type="int",dest="INACTIVATION",default="3",help="the upper bound of timeout in raft used to elect leader")
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

def mkdir(dir_name):
    # [ -e /register ] || mkdir -p /register
    try:
        client.read(dir_name).dir
    except:
        # mkdir
        client.write(dir_name, None, dir=True)

def save_uuid(v):
    afile = os.path.join(options.etc,"uuid")
    if os.path.exists(afile): os.remove(afile)
    with open(afile,'w') as f:
        f.write(v)

def checker(func):
    def wrapper(*args,**kwargs):
        if options.ip == "":
            logger.error("need to input the IP address, using -i/--ip to specify.")
            return
        if options.alias == "":
            logger.error("need to input the ALIAS info, using -a/--alias to specify.")
            return
        return func(*args,**kwargs)
    return wrapper

def prepare(func):
    def wrapper(*args,**kwargs):
        # mkdir -p /etc/self
        if not os.path.exists(options.etc):
            os.mkdir(options.etc)
            logger.debug("mkdir: %s" % options.etc)
        # rm /etc/self/uuid
        afile = os.path.join(options.etc,"uuid")
        if os.path.exists(afile): 
            os.remove(afile)
            logger,debug("rm: %s" % afile)
        return func(*args,**kwargs)
    return wrapper

@checker
@prepare
def main():
    logger.debug(options.LD)
    #pool = ThreadPool()
    #pool.map()
    #pool.close()
    #pool.join()
    # wait 4 the change
    #try: client.read('/nodes/n2', wait=True, timeout=2)
    #except etcd.EtcdWatchTimedOut: print 1
    try:
        client.read('/register/%s' % options.ip, wait=True, timeout=options.ttl)
    except:
        logger.error("raise EtcdWatchTimedOut error, and exit")
        cmd = "kill -9 $(ps aux | grep root | awk -F ' ' '{print $2}')"
        os.system(cmd)
    # eraser the register info
    # moved, cause that in sidecar refresh the above value with a small ttl, 
    # then the value vanished 
    #client.delete('/register/%s' % options.ip)
    # write the detail info
    ip = options.ip
    description = str(uuid.uuid1())
    logger.debug("UUID: %s" % description)
    mkdir("/%s" % options.alias)
    # mk home dir & set a larger ttl
    #client.write("/%s/%s" % (options.alias,options.ip), None, dir=True)
    mkdir("/%s/%s" % (options.alias,options.ip))
    client.write("/%s/%s" % (options.alias,options.ip), None, dir=True, prevExist=True, ttl=options.ttl)
    ## put ip address
    client.write("/%s/%s/ip" % (options.alias,options.ip), ip)
    ## put uuid info
    client.write("/%s/%s/uuid" % (options.alias,options.ip), description)
    save_uuid(description)
    
if __name__ == "__main__":
    main()
