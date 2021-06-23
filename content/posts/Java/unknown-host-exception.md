---
title: java.Net.UnknownHostException 异常处理方法
date: '2019-11-21 00:00:00'
tags:
- Exception
- Java
---

# java.Net.UnknownHostException 异常处理方法

## 出错原因

在 CentOS7 中运行项目时，出现如下图错误

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222160553.png)

因为 CentOS7 根据 /etc/hosts 配置文件查找主机名，而此时设置的 hostname 没有对应到本机 ip, Java 的 `InetAddress.getLocalHost()` 方法通过本地方法（native）来获取本地主机名，因为本地配置的问题，导致 Java 程序报错。

## 解决方法

使用 `hostname` 查看本机主机名

如果 hostname 不是本机的网卡 ip, 则证明可能有问题，需要在 /etc/hosts 配置文件中添加下列信息

```bash
# <IP 地址> <hostname1> <hostname2>
# 例如
127.0.0.1 localhost localhost.admin
```

## 相关操作命令

修改本机 hostname

```bash
hostname <new hostname>
```

# 参考文档

[java.Net.UnknownHostException 异常处理方法](https://blog.csdn.net/m0_37664906/article/details/76977464)
