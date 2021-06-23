---
title: 将 Nginx 设置为开机启动
date: '2020-08-31 00:00:00'
tags:
- Nginx
---
# 将 Nginx 设置为开机启动

源码方式安装的默认会去使用 sbin 同级的 conf 下的 nginx.conf 配置文件，nginx.service 中 PIDFile 的路径需要与 nginx.conf 中的 pid 一致，否则会出现 timeout，找不到 pidfile 等错误。

https://www.nginx.com/resources/wiki/start/topics/examples/systemd/
