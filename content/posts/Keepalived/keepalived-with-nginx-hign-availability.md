---
title: Keepalived+Nginx高可用
date: '2019-12-19 00:00:00'
tags:
- Keepalived
- Nginx
---
# Keepalived+Nginx高可用

## 简介

### keepalived介绍

[官方说明](https://www.keepalived.org/)

Keepalived是C语言编写的路由软件. 该项目的主要目标是为Linux系统(和基于Linux的基础结构的系统)的负载均衡和高可用提供简单和健壮的设施. 负载均衡框架依赖知名并被广泛应用的[Linux Virtual Server(IPVS)](http://www.linux-vs.org/)核心模块, 提供第4层的负载均衡. Keepalived实现了一组检查器, 根据服务器的健康状态, 自适应维护和管理负载均衡服务池. 另一方面, 通过[VRRP](https://datatracker.ietf.org/wg/vrrp/documents/)协议实现高可用. VRRP是路由故障转移的根本. 另外, Keepalived实现了一组搭载了VRRP的有限状态机, 提供低级别和高速的协议交互. 为了提供快速的网络故障发现能力, Keepalived实现了[BFD](datatracker.ietf.org/wg/bfd/)协议. VRRP状态转换可以根据BFD的提示加快状态转换. Keepalived框架可以独立使用也可以多个一起使用, 以提供弹性基础架构.

### 双机高可用的两种方法

- **Nginx+keepalived 双机 主从 模式**：即前端使用两台服务器，一台主服务器和一台热备服务器，正常情况下，主服务器绑定一个公网虚拟IP，提供负载均衡服务，热备服务器处于空闲状态；当主服务器发生故障时，热备服务器接管主服务器的公网虚拟IP，提供负载均衡服务；但是热备服务器在主机器不出现故障的时候，永远处于浪费状态，对于服务器不多的网站，该方案不经济实惠。

- **Nginx+keepalived 双机 主主 模式：** 即前端使用两台负载均衡服务器，互为主备，且都处于活动状态，同时各自绑定一个公网虚拟IP，提供负载均衡服务；当其中一台发生故障时，另一台接管发生故障服务器的公网虚拟IP（这时由非故障机器一台负担所有的请求）。这种方案，经济实惠，非常适合于当前架构环境。

## 架构及说明

### Nginx+Keepalived 双机 主从模式

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142951.png)

设备 | IP | 说明
--- | --- | --- 
