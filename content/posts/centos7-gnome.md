---
title: CentOS7安装GNOME图形化界面
date: '2019-10-25 00:00:00'
tags:
- Linux
- CentOS
categories:
- Linux
- CentOS
---
# CentOS7安装GNOME图形化界面

## 安装图形化页面包
```bash
yum groupinstall "GNOME Desktop" "Graphical Administration Tools"
```

## 启动图形化页面/默认图形化启动
1. 启动图形化页面

   ```bash
   startx
   ```

   **注意**
   `init 5`命令会要求创建新用户,`startx`直接使用当前用户登录

2. 设置默认图形化启动

   ```bash
   ln -sf /lib/systemd/system/runlevel5.target /etc/systemd/system/default.target
   ```


## 参考文档
[centos7安装图形化界面](https://cloud.tencent.com/developer/article/1197735)
