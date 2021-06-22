---
title: CentOS7防火墙相关命令
date: '2019-10-26 00:00:00'
tags:
- Linux
- CentOS
categories:
- Linux
- CentOS
---
# CentOS7防火墙相关命令

## 防火墙相关命令

查看防火墙状态

```bash
systemctl status firewalld
或
firewall-cmd --state
```
查看防火墙版本

```bash
firewall-cmd --version
```

开启防火墙

```bash
systemctl start firewalld
```

关闭防火墙

```bash
systemctl stop firewalld
```

刷新防火墙配置

```bash
firewall-cmd --reload
或
systemctl reload firewalld
```

重启防火墙

```bash
systemctl restart firewalld
```

设置为开机自启

```bash
systemctl enable firewalld
```

取消开机自启

```bash
systemctl disable firewalld
```

## 端口相关命令

查看所有开放端口

```bash
firewall-cmd --zone=public --list-ports
```

查看端口情况

```bash
firewall-cmd --list-all
```
开放端口

```bash
firewall-cmd --zone=public --add-port=8080/tcp --permanent
```

关闭端口

```bash
firewall-cmd --zone=public --remove-port=8080/tcp --permanent
```

开放多个端口

```bash
firewall-cmd --zone=public --add-port=8000-8003/tcp
```

允许指定ip访问某一端口,允许192.168.142.166访问6379端口

```bash
firewall-cmd --add-rich-rule="rule family="ipv4" source address="192.168.142.166" port protocol="tcp" port="6379" accept" --permanent
```
```bash
firewall-cmd --add-rich-rule="rule family="ipv4" source address="192.168.0.233" accept" --permanent
```

允许指定ip段访问某一端口,允许192.168.142.0-192.168.142.10范围内的ip访问6379端口

```bash
firewall-cmd --add-rich-rule="rule family="ipv4" source address="192.168.142.0/10" port protocol="tcp" port="6379" accept" --permanent
```

删除某个IP

```bash
firewall-cmd --permanent --remove-rich-rule="rule family="ipv4" source address="192.168.1.51" accept" --permanent
```

重载防火墙配置

```bash
firewall-cmd --reload
```

## 参考文档
- [CentOS7服务管理(重启,停止,自动启动命令)](https://www.cnblogs.com/lywJ/p/10710591.html)
- [CentOS7 Firewall常用命令汇总，开放端口及查看已开放的端口](https://blog.csdn.net/lvqingyao520/article/details/81075094)
- [centos7 firewall指定IP与端口访问（常用）](https://www.cnblogs.com/caidingyu/p/11008160.html)
