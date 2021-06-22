---
title: 将Nginx设置为开机启动
date: '2020-08-31 00:00:00'
tags:
- Nginx
---
# 将Nginx设置为开机启动

源码方式安装的默认会去使用sbin同级的conf下的nginx.conf配置文件, nginx.service中PIDFile的路径需要与nginx.conf中的pid一致, 否则会出现timeout, 找不到pidfile等错误.

https://www.nginx.com/resources/wiki/start/topics/examples/systemd/
