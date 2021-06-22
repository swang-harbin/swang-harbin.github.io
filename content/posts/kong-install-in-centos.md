---
title: CentOS安装Kong
date: '2019-12-06 00:00:00'
tags:
- Kong
categories:
- Kong
---
# CentOS安装Kong
[官方文档](https://docs.konghq.com/install/centos/?_ga=2.51988716.410555930.1575358940-2064656638.1575358940)

## 安装kong
通过官方文档可以下载rpm包, 或者设置yum仓库.

### 使用rpm包安装
```bash
 $ sudo yum install epel-release
 $ sudo yum install kong-1.4.1.*.noarch.rpm --nogpgcheck
```

### 使用repository安装
```bash
 $ sudo yum update -y
 $ sudo yum install -y wget
 $ wget https://bintray.com/kong/kong-rpm/rpm -O bintray-kong-kong-rpm.repo
 $ export major_version=`grep -oE '[0-9]+\.[0-9]+' /etc/redhat-release | cut -d "." -f1`
 $ sed -i -e 's/baseurl.*/&\/centos\/'$major_version''/ bintray-kong-kong-rpm.repo
 $ sudo mv bintray-kong-kong-rpm.repo /etc/yum.repos.d/
 $ sudo yum update -y
 $ sudo yum install -y kong
```

### 使用源文件方式安装
[官方文档](https://docs.konghq.com/install/source/)

## 设置配置文件
Kong支持有数据库运行和无数据库运行.

如果使用数据库, 需要在```kong.conf```中设置数据库的信息, 将所有的配置实体, 比如Kong代理的连接和服务存放在数据库中.

如果不使用数据库, 需要使用```kong.conf```配置属性, 并通过一个```kong.yml```来声明实体结构.

### 使用数据库
Kong支持使用PostgreSQL9.5+ 和 Cassandra 3.x.x 作为他的数据存储.

**如果使用PostgreSQL**, 需要提供一个数据库的用户:
```bash
CREATE USER kong;
CREATE DATABASE kong OWNER kong;
```
然后验证配置初始化kong的配置到数据库
```bash
 $ kong migrations bootstrap [-c /path/to/kong.conf]
```

关于数据库的配置信息参考[官方Configuration Reference](https://docs.konghq.com/1.4.x/configuration/#datastore-section)

### 不使用数据库
需要创建一个```kong.yml```, 在当前目录执行以下命令, 创建一个带基本结构的kong.yml, 详细讲解见[使用DB-less模式]()
```bash
 $ kong config init
```

然后修改```kong.conf```文件
```properties
# 设置不使用数据库
database = off
# 指定kong.yml的位置
declarative_config = /path/to/kong.yml
```
然后验证kong的配置并初始化
```bash
 $ kong migrations bootstrap [-c /path/to/kong.conf]
```

## 启动Kong
```bash
 $ kong start [-c /path/to/kong.conf]
```

## 验证

当上述方式均已完成, 会返回一个Kong started消息.

**Kong默认监听的端口** : 

- :8000 : Kong监听该端口, 为了接收客户端发来的HTTP请求, 并且将它发送到上游服务.
- :8443 : 该端口是为了接收HTTPS请求. 这个端口和:8000端口一样, 除了他是监听HTTPS请求. 可以通过配置文件禁用该端口.
- :8001 : 这个端口用来配置Kong监听的Admin API
- :8444 : Admin API监听HTTPS请求

## 其他操作
停止kong
```bash
kong stop [-p /prefix/kong/is/running/at/kong-2.0.2]
```

重载kong
```bash
kong reload
```
