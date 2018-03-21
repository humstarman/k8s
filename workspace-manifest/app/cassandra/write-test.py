#!/usr/bin/python

import os
import sys
from optparse import OptionParser
import logging  
import logging.handlers  
import commands
import uuid
from cassandra.cluster import Cluster
 
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
    parser.add_option("-c","--cluster",action="store",type="string",dest="cluster",default="",help="Cassandra nodes to connect, if multiple ipunt in term of csv")
    parser.add_option("-p","--port",action="store",type="int",dest="port",default="9042",help="Cassandra port to connect, default is 9042")
    parser.add_option("-k","--keyspace",action="store",type="string",dest="keyspace",default="",help="the keyspace of Cassandra nodes to connect")
    parser.add_option("-t","--table",action="store",type="string",dest="table",default="",help="the table of the keyspace to use")
    parser.add_option("-n","--number",action="store",type="int",dest="n",default="100",help="the number of items ot insert, default is 100")
    parser.add_option("--ll",action="store",type="string",dest="LL",default="INFO",help="the log level")
    parser.add_option("--ld",action="store",type="string",dest="LD",default="/var/log",help="the dir to store log")
    parser.add_option("--cll",action="store",type="string",dest="CLL",default="INFO",help="the console log level")
    parser.add_option("--fll",action="store",type="string",dest="FLL",default="DEBUG",help="the file log level")
    (options,args) = parser.parse_args()

    return options

# mk global var: options & logger
options = parse_opts(OptionParser(usage="%prog [options]"))
logger = set_logger()

def checker(func):
    def wrapper(*args,**kwargs):
        if options.cluster == "":
            logger.error("need to input the IP address, using -c/--cluster to specify.")
            return
        return func(*args,**kwargs)
    return wrapper

@checker
def main():
    cluster = Cluster([options.cluster],port=options.port) 
    session = cluster.connect(options.keyspace)
    create_table_stmt = "CREATE TABLE IF NOT EXISTS %s (key text, value text, PRIMARY KEY(key))" % (options.table,)
    logger.debug("create table stmt: %s" % create_table_stmt)
    session.execute(create_table_stmt)

    for i in xrange(options.n):
        insert_stmt="INSERT INTO %s (key,value) VALUES " % options.table
        session.execute(insert_stmt + "(%s,%s)", \
            (str(uuid.uuid1()),str(uuid.uuid4())))
        logger.debug(i)
    try:
        session.shutdown()
    except:
        pass

if __name__ == "__main__":
    main()
