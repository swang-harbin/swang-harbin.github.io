---
title: 远程连接Kong的Admin API
date: '2019-12-09 00:00:00'
updated: '2019-12-09 00:00:00'
tags:
- Kong
categories:
- Kong
---
# 远程连接Kong的Admin API

当通过另一台机器访问Kong的Admin API时, 会访问不到, 这里有两种解决方法

## 法1. 修改kong的配置文件kong.conf
修改admin_listen的值, 添加所需端口(或直接改为0.0.0.0)
```properties
admin_listen=0.0.0.0:8001,0.0.0.0:8444 ssl
```
重启kong服务

## 法2. 配置环境变量

在/etc/profile中添加
```shell
export KONG_ADMIN_LISTEN=0.0.0.0:8001,0.0.0.0:8444 ssl
```
执行source命令
```shell
source /etc/profile
```
重启kong服务

## 参考文档
[kong的端口简介以及如何远程连接kong的管理端口](https://blog.csdn.net/wtfk233/article/details/100561415)
