---
title: systemctl常用命令
date: '2019-12-06 00:00:00'
tags:
- Linux
---
# systemctl常用命令

```shell
# 列出当前系统服务的状态
systemctl list-units
# 列出服务的开机状态
systemctl list-unit-files
# 查看指定服务的状态
systemctl status servicename
# 关闭指定服务
systemctl stop servicename
# 开启指定服务
systemctl start servicename
# 从新启动服务
systemctl restart servicename
# 设定指定服务开机开启
systemctl enable servicename
# 设定指定服务开机关闭
systemctl disable servicename
# 使指定服务从新加载配置
systemctl reload servicename
# 查看指定服务的倚赖关系
systemctl list-dependencies servicename
# 冻结指定服务
systemctl mask  servicename
# 启用服务
systemctl unmask servicename
# 开机不开启图形
systemctl set-default multi-user.target
# 开机启动图形
systemctl set-default graphical.target
# 文本界面设定color
setterm
```
