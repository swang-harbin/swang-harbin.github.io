---
title: Dubbo部署在Docker中使用宿主机IP进行注册
date: '2020-03-19 00:00:00'
tags:
- Dubbo
- Docker
---
# dubbo部署在docker中使用宿主机进行注册

**环境说明 :**

- dubbo版本2.8.5
- provider部署在虚拟机中安装的docker容器中
- customer部署在主机
- 使用redis作为注册中心, 部署在主机


## 解决方法

修改docker容器/etc/host文件, 将hostname对应的那一行ip修改为虚拟机ip

例如 : 
将
```bash
172.1.0.2 foikjen2idio
```
修改为
```bash
192.168.122.234 foikjen2idio
```

## 解释说明

需了解dubbo如何获取provider的的ip和端口, 并将其存入注册中心

参考RedisRegistry类等


## 其他解决方案(未测试):

1. 设置容器的IP与主机IP在同一网段内，使容器IP可直接访问(会占用大量的IP地址，且IP会限制在同一网段，在生产环境中往往不可能)。
2. 通过复杂的iptables路由规则，通过多层桥接方式打通网络(此法是可行的，也是今后要考虑的，但是操作起来略麻烦)。
3. 对Dubbo进行扩展，扩展dubbo protocol配置，增加配置项publish host、 publish port，对应主机的ip和port，并且在注册服务时将主机的ip和port写到注册中心。（这种方法需要对Dubbo进行扩展，不太建议）


## 参考文档

[Dubbo在docker容器中遇到的跨主机通信问题](https://blog.iwannarun.cn/2016/12/21/dubbo-e5-9c-a8docker-e5-ae-b9-e5-99-a8-e4-b8-ad-e9-81-87-e5-88-b0-e7-9a-84-e8-b7-a8-e4-b8-bb-e6-9c-ba-e9-80-9a-e4-bf-a1-e9-97-ae-e9-a2-98/)
