---
title: MySQL在Linux上区分大小写
date: '2019-11-21 00:00:00'
updated: '2019-11-21 00:00:00'
tags:
- MySQL
categories:
- Database
---

# MySQL在Linux上区分大小写

## 错误提示

找不到database.TABLE这个表

## 查找原因

查看**lower_case_table_names**属性

```mysql
show variables like 'lower%';
```

`0`代表区分大小写, `1`代表不区分大小写

**注意:**

在linux系统, 默认设置如下:

- 数据库名与表名是严格区分大小写的;
- 列明与列的别名在所有情况下均是忽略大小写的;
- 变量名也是严格区分大小写的;

在windows系统, 默认设置如下:

- 均不区分大小写

## 解决办法

使用root用户登录, 编辑**/etc/my.cnf**文件, 在**[mysqld]**下加入如下代码

```properties
lower_case_table_names=1
```

重新启动数据库

```bash
systemctl restart mysqld mysql
```

## 参考文档

[MySQL填坑系列--Linux平台下MySQL区分大小写问题](https://blog.csdn.net/yuanxiang01/article/details/80813133)
