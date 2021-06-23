---
title: 远程连接 Kong 的 Admin API
date: '2019-12-09 00:00:00'
tags:
- Kong
---
# 远程连接 Kong 的 Admin API

当通过另一台机器访问 Kong 的 Admin API 时，会访问不到，这里有两种解决方法

## 法一：修改 kong 的配置文件 kong.conf
修改 admin_listen 的值，添加所需端口（或直接改为 `0.0.0.0`）
```properties
admin_listen=0.0.0.0:8001,0.0.0.0:8444 ssl
```
重启 kong 服务

## 法二：配置环境变量

在 /etc/profile 中添加
```shell
export KONG_ADMIN_LISTEN=0.0.0.0:8001,0.0.0.0:8444 ssl
```
执行 source 命令
```shell
source /etc/profile
```
重启 kong 服务

## 参考文档
[kong 的端口简介以及如何远程连接 kong 的管理端口](https://blog.csdn.net/wtfk233/article/details/100561415)
