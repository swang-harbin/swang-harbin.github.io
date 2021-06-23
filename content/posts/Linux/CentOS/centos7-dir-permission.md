---
title: CentOS 修改文件或目录权限
date: '2019-10-28 00:00:00'
tags:
- Linux
- CentOS
---
# CentOS修改文件或目录权限

类型 | root用户 | 组用户 | 当前用户
---|--- | --- | --- 
-（文件）|rwx() | rwx | rwx 
d（目录）|rwx | rwx | rwx 

rwx 从左到右分别为 1、2、4

chmod 753

root用户权限  |  组用户权限 | 当前用户权限
--- | --- | --- |
7=1+2+4 | 5=1+0+4 | 6=1+2+0
r + w + x | r + x | r + w