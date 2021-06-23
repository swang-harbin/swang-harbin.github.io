---
title: Frdora 启动页面出现多个内核选项
date: '2020-04-29 00:00:00'
tags:
- Linux
- Fedora
---
# Frdora 启动页面出现多个内核选项

## 问题描述

Fedora 开机启动时，开机页面包含多个不同版本的内核

## 解决办法

首先查看当前系统的 Linux 内核版本
```bash
$ uname -r
```

查看系统中已安装的所有内核
```bash
$ sudo rpm -qa | grep ^kernel
```

删除旧版本内核
```bash
$ sudo dnf remove kernel-
```

重启电脑
```bash
$ reboot
```
