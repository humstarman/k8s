#!/bin/python
#coding:utf-8
from pyftpdlib.authorizers import DummyAuthorizer
from pyftpdlib.handlers import FTPHandler
from pyftpdlib.servers import FTPServer
def main():
    #新建一个用户组
    authorizer = DummyAuthorizer()
    #将用户名，密码，指定目录，权限 添加到里面
    authorizer.add_user("root", "root", "/opt/app", perm="elr")#adfmw
    #这个是添加匿名用户
    authorizer.add_anonymous("/opt/app") 
    handler = FTPHandler
    handler.authorizer = authorizer
    #开启服务器
    server = FTPServer(("0.0.0.0", 2121), handler)
    server.serve_forever()
if __name__ == "__main__":
    main()
