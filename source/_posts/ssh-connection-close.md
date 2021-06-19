---
title: SSH无法连接
date: '2019-12-02 00:00:00'
updated: '2019-12-02 00:00:00'
tags:
- Linux
- Fedora
- SSH
categories:
- [Linux, Fedora]
---
# SSH无法连接

## 问题描述
新安装的Fedora系统, 无法使用Xshell工具连接.

**可能存在两个问题: **

### 点击连接后返回如下提示
```bash
Connecting to 10.1.7.95:22...
Connection established.
To escape to local shell, press 'Ctrl+Alt+]'.
Connection closing...Socket close.

Connection closed by foreign host.

Disconnected from remote host(10.1.7.95) at 15:04:57.

Type `help' to learn how to use Xshell prompt.
[D:\~]$
```

#### 问题原因

可能是sshd服务没有开启

#### 解决办法

启动sshd服务

```bash
systemctl start sshd
```

### 无法使用root用户登录

#### 问题原因
可能ssh配置文件中禁止了root用户远程登录

#### 解决办法

修改```/etc/ssh/sshd.conf```文件, 修改为下面配置
```bash
PermitRootLogin yes
```

重启sshd服务
```bash
systemctl reload sshd
```
