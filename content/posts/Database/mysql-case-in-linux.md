---
title: MySQL 在 Linux 上区分大小写
date: '2019-11-21 00:00:00'
tags:
- MySQL
---

# MySQL 在 Linux 上区分大小写

## 错误提示

找不到 database.TABLE 这个表

## 查找原因

查看 `lower_case_table_names` 属性

```mysql
show variables like 'lower%';
```

`0` 代表区分大小写，`1` 代表不区分大小写

**注意**

在 linux 系统，默认设置如下

- 数据库名与表名是严格区分大小写的
- 列明与列的别名在所有情况下均是忽略大小写的
- 变量名也是严格区分大小写的

在 windows 系统，默认设置如下

- 均不区分大小写

## 解决办法

使用 root 用户登录，编辑 /etc/my.cnf 文件，在 `[mysqld]` 下加入如下代码

```properties
lower_case_table_names=1
```

重新启动数据库

```bash
systemctl restart mysqld mysql
```

## 参考文档

[MySQL 填坑系列--Linux 平台下 MySQL 区分大小写问题](https://blog.csdn.net/yuanxiang01/article/details/80813133)
