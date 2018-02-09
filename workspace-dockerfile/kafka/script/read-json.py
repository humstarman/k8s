#!/usr/bin/python

import os
import sys
from optparse import OptionParser
import logging  
import logging.handlers  
import time
import json
 
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
    parser.add_option("-f","--field",action="store",type="string",dest="field",default="",help="the field to get")
    parser.add_option("-e","--exist",action="store",type="string",dest="exist",default="",help="if the directory existed")
    parser.add_option("-j","--json",action="store",type="string",dest="json",default="",help="the input json")
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
        if options.json == "":
            #logger.error("need the input in term of JSON, using -j/--json to specify.")
            return
        return func(*args,**kwargs)
    return wrapper

def ret_val(data,fields):
    logger.debug(data)
    logger.debug(fields)
    if len(fields) == 1:
        print data[fields[0]]
        return
    else:
        ret_val(data[fields[0]],fields[1:])

@timer
@checker
def main():
    logger.debug(options.json)
    data = json.loads(options.json)
    logger.debug(data)
    if options.field != "":
        logger.debug(options.field)
        fields = options.field.strip().split("/")
        logger.debug(fields)
        try:
            ret_val(data,fields)
        except:
            print ''
    elif options.exist != "":
        if "errorCode" in data: print "no"
        else: print "yes"
    else: pass
        

if __name__ == "__main__":
    main()
