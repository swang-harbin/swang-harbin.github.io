---
title: Docker的网络模式
date: '2020-04-26 00:00:00'
tags:
- Docker
---
# Docker的网络模式

[官方网站](https://docs.docker.com/network/)

使用`docker run`创建Docker容器时, 可以使用`--net`选项指定容器的网络模式.

Docker的网络子系统可使用驱动程序插入。默认情况下，有几个驱动程序，它们提供核心联网功能：
- **bridge(网桥网络)**: 默认的网络驱动程序. 如果未指定, 默认使用该网络类型. **当您的应用程序在需要通信的独立容器中运行时，通常会使用网桥网络**. 请参阅[网桥网络](https://docs.docker.com/network/bridge/)
- **host(主机网络)**: 
- **overlay(覆盖网络)**: 
- **macvlan(Macvlan网络)**:
- **none(禁用网络)**:
- **Network plugins(网络插件)**: 您可以在Docker中安装和使用第三方网络插件.

