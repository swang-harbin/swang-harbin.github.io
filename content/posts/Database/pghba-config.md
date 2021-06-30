---
title: pg_hba.conf 文件说明
date: '2019-12-06 00:00:00'
tags:
- PostgreSQL
---

# pg_hba.conf 配置文件说明

## TYPE

表示主机类型，值可能为

- local：表示是 unix-domain 的 socket 连接
- host：表示 TCP/IP 的 socket 连接
- hostssl：表示 SSL 加密的 TCP/IP socket

## DATABASE

表示数据库名称，值可能为

- all：全部数据库
- sameuser：
- samerole：
- replication：
- 指定数据库名称：多个数据库用逗号（,）分隔

## USER

表示用户名称，值可能为

- all：
- 用户名：多个用户名用逗号（,）分隔

## ADDRESS

## METHOD

## 参考文档

[pg_hba.conf 文件说明与配置](https://blog.csdn.net/hmxz2nn/article/details/83717663)

[官方文档](https://www.postgresql.org/docs/11/auth-pg-hba-conf.html)