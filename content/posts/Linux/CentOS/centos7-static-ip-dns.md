---
title: CentOS7 设置静态 IP 和 DNS 解析
date: '2019-10-24 00:00:00'
tags:
- Linux
- CentOS
---
# CentOS7 设置静态 IP 和 DNS 解析

## 寻找网卡对应的配置文件
```bash
cd /etc/sysconfig/network-scripts/
```
ifcfg-xxx(xxx 为网卡名称)

## 修改对应网卡参数
```bash
vim ifcfg-xxx
```
### 参数说明

#### 默认参数

```bash
TYPE="Ethernet" # 网络类型
PROXY_METHOD="none" # 代理方式
BROWSER_ONLY="no"   # 只是浏览器
BOOTPROTO="dhcp"    # 网卡引导协议，dhcp 自动获取 IP 地址,static 使用静态 IP 地址
DEFROUTE="yes"  # default route 是否设置为默认路由
IPV4_FAILURE_FATAL="no" # 是否开启 IPV4 致命错误检测，如果 ipv4 配置失败会禁用设备
IPV6INIT="yes"  # IPV6 是否自动初始化
IPV6_AUTOCONF="yes" # IPV6 是否自动配置
IPV6_DEFROUTE="yes" # IPV6 是否可以为默认路由
IPV6_FAILURE_FATAL="no" # 是否开启 IPV6 致命错误检测，如果 IPV6 配置失败会禁用设备
IPV6_ADDR_GEN_MODE="stable-privacy" # IPV6 地址生成模型
NAME="ens33"    # 网卡物理设备名称
UUID="5e1647e0-5c6e-467d-ab2f-4fdc6e810422" # 通用唯一识别码，每一个网卡都会有，不能重复，否两台 linux 只有一台网卡可用
DEVICE="ens33"  # 网卡设备名称，必须和 NAME 值一样
ONBOOT="yes"    #是否开启自动启动网络连接
```
#### 其他参数

```bash
NM_CONTROLLED="yes" # 是否可以由 Network Manager 托管
HWADDR=""   # MAC 地址
PREFIX=24   # 子网掩码 24 位
IPADDR=""   # IP 地址
NETMASK=""  # 子网掩码
GATEWAY=""  # 设置网关
DNS1=""     # 首选 DNS
DNS2=""     # 次要 DNS
DNS3=""     # 第三个 DNS，最多设置三个 DNS
BROADCAST=  # 广播
BRIDGE=     # 设置桥接网卡
USERCTL="no"    # 是否允许非 root 用户控制该设备
MASTER="bond1"    # 指定主名称
SLAVE       # 指定该接口是一个接合界面的组件
NETWORK     # 网络地址
ARPCHECK="yes"  # 检测
PEERDNS     # 是否允许 DHCP 获取的 DNS 覆盖本地的 DNS
PEEROUTES   # 是否从 DHCP 获取用于定义接口的默认网关的信息的路由表条目
```
## 重启网卡服务
```bash
systemctl restart network.service
```

## 参考文档
- [centOS7ifcfg-eth0 配置详解](https://blog.csdn.net/u013457387/article/details/80704962)
- [CentOS7 配置网卡为静态 IP，如果你还学不会那真的没有办法了！](https://www.cnblogs.com/sunlong88/articles/9195909.html)
