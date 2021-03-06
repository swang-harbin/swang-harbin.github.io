---
layout: post
title: Windows安装绿色版MongoDB
subheading: 
author: swang-harbin
categories: database
banner: 
tags: MongoDB
---

# Windows安装绿色版MongoDB

## 一.下载MongoDB.zip

- [MongoDB官方下载地址](https://www.mongodb.com/download-center/community)
- [MongoDB官方安装教程](https://docs.mongodb.com/manual/tutorial/install-mongodb-on-windows/)

## 二.解压

使用的MongoDB版本为mongodb-win32-x86_64-2012plus-4.2.1.zip

解压后得到

 ![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222193328.png)

## 三.创建存放数据和日志的文件夹和文件

1. 在bin的同级目录下创建data和log**文件夹**
2. 在data文件夹中创建db空**文件夹**
3. 在log文件夹下创建mongo.log空**文件**

注:文件路径在何处创建都无所谓,关键在于mongo.config的配置.

## 四.创建mongo.config配置文件

在bin的同级目录创建mongo.config文件,注意修改**dbpath**和**logpath**为正确的位置

```config
# 数据库文件的存放位置
dbpath=D:\Program Files (x86)\MongoDB\mongodb-win32-x86_64-2012plus-4.2.1\data\db

# 日志文件存放的路径
logpath=D:\Program Files (x86)\MongoDB\mongodb-win32-x86_64-2012plus-4.2.1\log\mongo.log
```

其他配置说明

```config
# 数据库文件的存放位置
dbpath=D:\Program Files (x86)\MongoDB\mongodb-win32-x86_64-2012plus-4.2.1\data\db

# 日志文件存放的路径
logpath=D:\Program Files (x86)\MongoDB\mongodb-win32-x86_64-2012plus-4.2.1\log\mongo.log
 
# 是否追加方式写入日志，默认True
logappend=true
 
# 设置绑定ip
bind_ip=127.0.0.1

# 设置端口
port=27017
 
# 是否以守护进程方式运行，默认false
#fork=true
 
#这个选项可以过滤掉一些无用的日志信息，若需要调试使用请设置为false
quiet=false
 
# 启用日志文件，默认启用
journal=true
 
# 启用定期记录CPU利用率和 I/O 等待,默认false
#cpu=true
 
# 是否以安全认证方式运行，默认是不认证的非安全方式
#noauth=true
#auth=true
 
# 详细记录输出，默认false
#verbose=true
 
#用于开发驱动程序时验证客户端请求
#objcheck=true
 
# # 启用数据库配额管理,默认false
#quota=true
 
# 设置oplog日志记录等级，默认0
#   0=off (default)
#   1=W
#   2=R
#   3=both
#   7=W+some reads
#oplog=0
 
# 是否打开动态调试项，默认false
#nocursors=true
 
# 忽略查询提示，默认false
#nohints=true
 
# 禁用http界面，默认为localhost：28017
#nohttpinterface=true
 
# 关闭服务器端脚本，这将极大的限制功能，默认false
#noscripting=true
 
# 关闭扫描表，任何查询将会是扫描失败
#notablescan=true
 
# 关闭数据文件预分配
#noprealloc=true
 
# 为新数据库指定.ns文件的大小，单位:MB
# nssize=<size>
 
# 用于Mongo监控服务器的Accout token。
#mms-token=<token>
 
# Mongo监控服务器的服务器名称。
#mms-name=<server-name>
 
# Mongo监控服务器的Ping间隔时间，即心跳
#mms-interval=<seconds>
 
# Replication Options
 
# 设置主从复制参数
#slave=true # 设置从节点
#source=master.example.com # 指定从节点的主节点
# Slave only: 指定要复制的单个数据库
#only=master.example.com
# or
#master=true # 设置主节点
#source=slave.example.com 
 
# 设置副本集的名字，所有的实例指定相同的名字属于一个副本集
replSet=name
 
#pairwith=<server:port>
 
# 仲裁服务器地址
#arbiter=<server:port>
 
# 默认为false，用于从实例设置。是否自动重新同步
#autoresync=true
 
# 指定的复制操作日志（OPLOG）的最大大小
#oplogSize=<MB>
 
# 限制复制操作的内存使用
#opIdMem=<bytes>
 
# 设置ssl认证
# Enable SSL on normal ports
#sslOnNormalPorts=true
 
# SSL Key file and password
#sslPEMKeyFile=/etc/ssl/mongodb.pem
#sslPEMKeyPassword=pass
 
# path to a key file storing authentication info for connections
# between replica set members
#指定存储身份验证信息的密钥文件的路径
#keyFile=/path/to/keyfile
```

## 五.安装并启动服务

配置好环境变量(略)或在bin目录下以管理员身份运行cmd

1. 安装mongod服务

```shell
mongod --config "[配置文件路径]" --serviceName "[服务名]"
mongod --config "D:\Program Files (x86)\MongoDB\mongodb-win32-x86_64-2012plus-4.2.1\mongo.config" --serviceName MongoDB --install
```

2.启动服务

```shell
net start [服务名]
```

## 参考文档

[Windows安装MongoDB .zip绿色版](https://blog.csdn.net/HTouying/article/details/88428452)