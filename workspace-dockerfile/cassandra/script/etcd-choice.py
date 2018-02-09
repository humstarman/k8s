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
    parser.add_option("-c","--csv",action="store",type="string",dest="csv",default="",help="the input CSV")
    parser.add_option("--ll",action="store",type="string",dest="LL",default="INFO",help="the log level")
    parser.add_option("--log_dir",action="store",type="string",dest="LD",default=r"/tmp",help="the dir to store log")
    parser.add_option("--cll",action="store",type="string",dest="CLL",default="INFO",help="the console log level")
    parser.add_option("--fll",action="store",type="string",dest="FLL",default="DEBUG",help="the file log level")
    (options,args) = parser.parse_args()

    return options

# mk global var: options & logger
options = parse_opts(OptionParser(usage="%prog [options]"))
logger = set_logger()

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
        if options.csv == "":
            #logger.error("need the input in term of JSON, using -j/--json to specify.")
            return
        return func(*args,**kwargs)
    return wrapper

@timer
@checker
def main():
    csv = options.csv
    logger.debug(csv)
    lst = csv.strip().split(',')
    logger.debug(lst)
    print choice(lst)

if __name__ == "__main__":
    main()
