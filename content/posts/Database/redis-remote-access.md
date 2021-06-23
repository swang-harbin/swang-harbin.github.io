---
title: 远程访问 Redis
date: '2019-10-26 00:00:00'
tags:
- Redis
---

# 远程访问 Redis

允许所有机器连接 redis，注解掉所有 bind，并将 protected-mode 属性设置为 no。

## 配置文件中的 bind 属性说明

1. 默认情况

   未指定 bind（或者 `bind 0.0.0.0`），redis 将监听本服务器上所有可用网络接口地址。

网络接口地址即计算机上每个网卡对应的 IP 地址，每一个网卡都有一个 IP 地址

1. 只允许本机访问

   使用 `bind 127.0.0.1`，127.0.0.1 是一个回环地址（Local Loopback），只有本地才能访问本机的回环地址

2. 指定网卡 IP，其他机器通过该网卡访问

   使用 `bind xxx.xxx.xxx.xxx` 监听一个网络接口，或者使用 `bind xxx.xxx.xxx.xxx xxx.xxx.xxx.xxx` 监听多个网络接口，则其他计算机可以通过绑定的网络接口访问

原文

```shell
# By default, if no "bind" configuration directive is specified, Redis listens
# for connections from all the network interfaces available on the server.
# It is possible to listen to just one or multiple selected interfaces using
# the "bind" configuration directive, followed by one or more IP addresses.

# ~~~ WARNING ~~~ If the computer running Redis is directly exposed to the
# internet, binding to all the interfaces is dangerous and will expose the
# instance to everybody on the internet. So by default we uncomment the
# following bind directive, that will force Redis to listen only into
# the IPv4 loopback interface address (this means Redis will be able to
# accept connections only from clients running into the same computer it
# is running).
```

## protected-mode 属性说明

**作用**: 只有本机可以访问 redis

必须满足三个条件，protected-mode 才生效，否则，其将处于关闭状态

1. protected-mode 属性为 yes
2. 没有 bind 指令
3. 没有设置密码

原文

```shell
# Protected mode is a layer of security protection, in order to avoid that
# Redis instances left open on the internet are accessed and exploited.
#
# When protected mode is on and if:
#
# 1) The server is not binding explicitly to a set of addresses using the
#    "bind" directive.
# 2) No password is configured.
#
# The server only accepts connections from clients connecting from the
# IPv4 and IPv6 loopback addresses 127.0.0.1 and ::1, and from Unix domain
# sockets.
#
# By default protected mode is enabled. You should disable it only if
# you are sure you want clients from other hosts to connect to Redis
# even if no authentication is configured, nor a specific set of interfaces
# are explicitly listed using the "bind" directive.
```

## 限制只有指定的主机可以连接到 redis

只能通过防火墙来控制

## 参考链接

[Redis 的 bind 的误区](https://blog.csdn.net/cw_hello1/article/details/83444013)
