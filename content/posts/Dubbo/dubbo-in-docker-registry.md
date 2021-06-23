---
title: Dubbo 部署在 Docker 中使用宿主机 IP 进行注册
date: '2020-03-19 00:00:00'
tags:
- Dubbo
- Docker
---
# Dubbo 部署在 Docker 中使用宿主机进行注册

**环境说明**

- dubbo 版本 2.8.5
- provider 部署在虚拟机中安装的 Docker 容器中
- customer 部署在主机
- 使用 redis 作为注册中心，部署在主机


## 解决方法

修改 docker 容器 /etc/host 文件，将 hostname 对应的那一行 IP 修改为虚拟机 IP

例如：将 `172.1.0.2 foikjen2idio` 修改为 `192.168.122.234 foikjen2idio`

## 解释说明

需了解 Dubbo 如何获取 provider 的 IP 和端口，并将其存入注册中心

参考 RedisRegistry 类等


## 其他解决方案（未测试）:

1. 设置容器的 IP 与主机 IP 在同一网段内，使容器 IP 可直接访问（会占用大量的 IP 地址，且 IP 会限制在同一网段，在生产环境中往往不可能）。
2. 通过复杂的 iptables 路由规则，通过多层桥接方式打通网络（此法是可行的，也是今后要考虑的，但是操作起来略麻烦）。
3. 对 Dubbo 进行扩展，扩展 dubbo protocol 配置，增加配置项 publish host、publish port，对应主机的 IP 和 Port，并且在注册服务时将主机的 IP 和 Port 写到注册中心。（这种方法需要对 Dubbo 进行扩展，不太建议）


## 参考文档

[Dubbo 在 docker 容器中遇到的跨主机通信问题](https://blog.iwannarun.cn/2016/12/21/dubbo-e5-9c-a8docker-e5-ae-b9-e5-99-a8-e4-b8-ad-e9-81-87-e5-88-b0-e7-9a-84-e8-b7-a8-e4-b8-bb-e6-9c-ba-e9-80-9a-e4-bf-a1-e9-97-ae-e9-a2-98/)
