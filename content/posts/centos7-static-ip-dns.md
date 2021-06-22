---
title: CentOS7设置静态IP和DNS解析
date: '2019-10-24 00:00:00'
tags:
- Linux
- CentOS
categories:
- Linux
- CentOS
---
# CentOS7设置静态IP和DNS解析

## 寻找网卡对应的配置文件
```bash
cd /etc/sysconfig/network-scripts/
```
> ifcfg-xxx(xxx为网卡名称)

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
BOOTPROTO="dhcp"    # 网卡引导协议,dhcp自动获取IP地址,static使用静态IP地址
DEFROUTE="yes"  # default route 是否设置为默认路由
IPV4_FAILURE_FATAL="no" # 是否开启IPV4致命错误检测,如果ipv4配置失败会禁用设备
IPV6INIT="yes"  # IPV6是否自动初始化
IPV6_AUTOCONF="yes" # IPV6是否自动配置
IPV6_DEFROUTE="yes" # IPV6是否可以为默认路由
IPV6_FAILURE_FATAL="no" # 是否开启IPV6致命错误检测,如果IPV6配置失败会禁用设备
IPV6_ADDR_GEN_MODE="stable-privacy" # IPV6地址生成模型
NAME="ens33"    # 网卡物理设备名称
UUID="5e1647e0-5c6e-467d-ab2f-4fdc6e810422" # 通用唯一识别码, 每一个网卡都会有, 不能重复, 否两台linux只有一台网卡可用
DEVICE="ens33"  # 网卡设备名称,必须和NAME值一样
ONBOOT="yes"    #是否开启自动启动网络连接
```
#### 其他参数

```bash
NM_CONTROLLED="yes" # 是否可以由Network Manager托管
HWADDR=""   # MAC地址
PREFIX=24   # 子网掩码24位
IPADDR=""   # IP地址
NETMASK=""  # 子网掩码
GATEWAY=""  # 设置网关
DNS1=""     # 首选DNS
DNS2=""     # 次要DNS
DNS3=""     # 第三个DNS,最多设置三个DNS
BROADCAST=  # 广播
BRIDGE=     # 设置桥接网卡
USERCTL="no"    # 是否允许非root用户控制该设备
MASTER="bond1"    # 指定主名称
SLAVE       # 指定该接口是一个接合界面的组件
NETWORK     # 网络地址
ARPCHECK="yes"  # 检测
PEERDNS     # 是否允许DHCP获取的DNS覆盖本地的DNS
PEEROUTES   # 是否从DHCP获取用于定义接口的默认网关的信息的路由表条目
```
## 重启网卡服务
```bash
systemctl restart network.service
```

## 参考文档
- [centOS7ifcfg-eth0配置详解](https://blog.csdn.net/u013457387/article/details/80704962)
- [CentOS7配置网卡为静态IP，如果你还学不会那真的没有办法了！](https://www.cnblogs.com/sunlong88/articles/9195909.html)
