---
layout: post
title: pg_hba.conf文件说明
subheading: 
author: swang-harbin
categories: database
banner: 
tags: PostgreSQL
---

# pg_hba.conf配置文件说明

## 一. TYPE

表示主机类型, 值可能为 :

- local : 表示是unix-domain的socket连接
- host : 表示TCP/IP的socket连接
- hostssl : 表示SSL加密的TCP/IP socket

## 二. DATABASE

表示数据库名称, 值可能为 :

- all : 全部数据库
- sameuser :
- samerole :
- replication :
- 指定数据库名称 : 多个数据库用逗号(,)分隔

## 三. USER

表示用户名称, 值可能为 :

- all :
- 用户名 : 多个用户名用逗号(,)分隔
- 

## 四. ADDRESS

## 五. METHOD

## 参考文档

[pg_hba.conf文件说明与配置](https://blog.csdn.net/hmxz2nn/article/details/83717663)

[官方文档](https://www.postgresql.org/docs/11/auth-pg-hba-conf.html)