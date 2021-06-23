---
title: MySQL server has gone away
date: '2019-09-06 00:00:00'
tags:
- Exception
- MySQL
---

# 错误-MySQL server has gone away

## 出现原因:

使用 Navicat 导入大 sql 文件时，报 MySQL server has gone away 错误。由于 `max_allowed_packet` 的值过小。该值的作用是限制 MySQL 服务接收到的包的大小。

## 解决方法

1. cmd 登录到 mysql
2. 输入 `show global variables like 'max_allowed_packet';` 查看 `max_allowed_packet` 的大小
3. 输入 `set global max_allowed_packet=4194304;` 修改 `max_allowed_packet` 的大小

## 注意事项

1. 需要在 root 用户权限下才可以修改成功
2. 命令行中的修改只对当前有效，重启 MySQL 服务后恢复默认值，可以在配置文件中添加 `max_allowed_packet=4M` 来达到永久有效的目的
3. `max_allowed_packet` 的大小必须为 1024 的整数倍

