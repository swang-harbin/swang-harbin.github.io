---
title: PostgreSQL psql的使用, SQL语法, 数据类型, 递归SQL用法
date: '2020-05-23 00:00:00'
updated: '2020-05-23 00:00:00'
tags:
- PostgreSQL
categories:
- Database
---

# PostgreSQL psql的使用, SQL语法, 数据类型, 递归SQL用法

## 一. PostgreSQL交互工具的使用

`psql`工具

psql -h ip -p port -U username -d database

两个比较有用的帮助, 再psql shell中输入:

- `\?`: 可以得到psql的一些快捷命令
- `\h command`: 查看某个SQL命令的帮助, 例如`\h create table`

常用的快捷命令:

- `\dt`: 输出当前搜索路径下的表
- `\set VERBOSITY verbose`: 设置详细的打印输入, 例如可以报出问题代码

## 二. PostgreSQL数据类型介绍

查看数据库支持的所有数据类型, 包括自定义类型: `\d pg_type`或`select * from pg_type;`

```shell
                   Table "pg_catalog.pg_type"
     Column     |     Type     | Collation | Nullable | Default 
----------------+--------------+-----------+----------+---------
