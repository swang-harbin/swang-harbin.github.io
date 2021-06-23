---
title: SSH 无法连接
date: '2019-12-02 00:00:00'
tags:
- Linux
- Fedora
- SSH
---
# SSH 无法连接

## 问题描述
新安装的 Fedora 系统，无法使用 Xshell 工具连接。

## 点击连接后返回如下提示
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

### 问题原因

可能是 sshd 服务没有开启

### 解决办法

启动 sshd 服务

```bash
systemctl start sshd
```

## 无法使用 root 用户登录

### 问题原因
可能 ssh 配置文件中禁止了 root 用户远程登录

### 解决办法

修改 `/etc/ssh/sshd.conf` 文件，修改为下面配置
```bash
PermitRootLogin yes
```

重启 sshd 服务
```bash
systemctl reload sshd
```
