#!/usr/bin/python

import os
import sys
from optparse import OptionParser
import logging  
import logging.handlers  
import time
from random import choice
 
def set_logger():
    name = sys.argv[0].strip().split(r"/")[-1].strip().split('.')[0]
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
    parser.add_option("-i","--ip",action="store",type="string",dest="ip",default="",help="the new node to be added")
    parser.add_option("-c","--cluster",action="store",type="string",dest="cluster",default="",help="cluster ip")
    parser.add_option("-p","--port",action="store",type="string",dest="port",default="6379",help="port to use")
    parser.add_option("--etc",action="store",type="string",dest="etc",default="",help="todo")
    parser.add_option("--ll",action="store",type="string",dest="LL",default="INFO",help="the log level")
    parser.add_option("--log_dir",action="store",type="string",dest="LD",default="/tmp",help="the dir to store log")
    parser.add_option("--cll",action="store",type="string",dest="CLL",default="INFO",help="the console log level")
    parser.add_option("--fll",action="store",type="string",dest="FLL",default="DEBUG",help="the file log level")
    (options,args) = parser.parse_args()

    return options

# mk global var: options & logger
options = parse_opts(OptionParser(usage="%prog [options]"))
logger = set_logger()

def parse_cluster_info():
    afile = os.path.join(options.etc,"cluster-nodes.dat")
    logger.debug("cluster nodes: %s" % afile)
    masters = []
    slaves = []
    with open(afile,'r') as f:
        lines = f.readlines()
        for line in lines:
            logger.debug(line)
            if "master" in line:
                masters.append(line)
            elif "slave" in line:
                slaves.append(line)
            else:
                logger.debug("useless info: %s" %  line)
    return masters,slaves

def count_nodes(masters,slaves):
    if len(masters) > len(slaves):
        return "slave"
    else:
        return "master"

def find_unavailable_masters(lst):
    ret = []
    for e in lst:
        tmp = e.strip().split(' ')
        logger.debug(tmp)
        try: i = tmp.index("slave")
        except: i = tmp.index("myself,slave")
        ret.append(tmp[i+1])
    logger.debug("unavailable masters:")
    logger.debug(ret)
    return ret

def get_master_ids(lst):
    ret = []
    for e in lst:
        tmp = e.strip().split(' ')
        ret.append(tmp[0])
    logger.debug("masters:")
    logger.debug(ret)
    return ret

def find_master_id(masters,slaves):
    unavailable_masters = find_unavailable_masters(slaves)
    master_ids = get_master_ids(masters)
    available_masters = [_ for _ in master_ids if _ not in unavailable_masters] 
    return available_masters[0]

def mk_cmd(flag,masters,slaves):
    if flag == "master":
        #./redis-trib.rb add-node new_node:port node_already_in_cluster:port
        cmd = "$REDIS_HOME/src/redis-trib.rb add-node %s:%s %s:%s" % (options.ip,options.port,options.cluster,options.port)
    elif flag == "slave":
        #./redis-trib.rb add-node --slave --master-id $master_id $new_node:$port $node_already_in_cluster:$port
        master_id = find_master_id(masters,slaves)
        cmd = "$REDIS_HOME/src/redis-trib.rb add-node --slave --master-id %s %s:%s %s:%s" % (master_id,options.ip,options.port,options.cluster,options.port)
    else:
        logger.error("no such flag")
    logger.debug("cmd: %s" % cmd)
    afile = os.path.join(options.etc,"add-node")
    if os.path.exists(afile): os.remove(afile)
    with open(afile,'w') as f:
        f.write(cmd)
    return

def timer(func):
    def wrapper(*args,**kwargs):
        t1 = time.time()
        ret = func(*args,**kwargs)
        t2 = time.time()
        logger.debug("Elapsed: %s sec." % (str(t2-t1)))
        return ret
    return wrapper

def checker(func):
    def wrapper(*args,**kwargs):
        if options.ip == "":
            logger.error("need a node to add, using -i/--ip to specify the IP address fo the new node.")
            return
        return func(*args,**kwargs)
    return wrapper

@timer
@checker
def main():
    masters,slaves = parse_cluster_info()
    flag = count_nodes(masters,slaves)
    mk_cmd(flag,masters,slaves)

if __name__ == "__main__":
    main()
