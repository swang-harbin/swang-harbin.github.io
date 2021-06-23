---
title: PostgreSQL psql 的使用，SQL 语法，数据类型，递归 SQL 用法
date: '2020-05-23 00:00:00'
tags:
- PostgreSQL
---

# PostgreSQL psql 的使用，SQL 语法，数据类型，递归 SQL 用法

## PostgreSQL 交互工具的使用

`psql` 工具

`psql -h ip -p port -U username -d database`

两个比较有用的帮助，在 `psql shell` 中输入：

- `\?`：可以得到 psql 的一些快捷命令
- `\h command`：查看某个 SQL 命令的帮助，例如 `\h create table`

常用的快捷命令

- `\dt`：输出当前搜索路径下的表
- `\set VERBOSITY verbose`：设置详细的打印输入，例如可以报出问题代码

## PostgreSQL 数据类型介绍

查看数据库支持的所有数据类型，包括自定义类型：`\d pg_type` 或 `select * from pg_type;`

```bash
                   Table "pg_catalog.pg_type"
     Column     |     Type     | Collation | Nullable | Default 
----------------+--------------+-----------+----------+---------
```
