---
title: MySQL设置大小写及字符集
date: '2020-05-08 00:00:00'
updated: '2020-05-08 00:00:00'
tags:
- MySQL
categories:
- database
---

# MySQL设置大小写及字符集

## MySQL设置不区分表名大小写

Windows默认不区分, Linux默认区分. 0代表区分, 1代表不区分

```cnf
[mysqld]
lower_case_table_names=1
```

## MySQK设置默认字符集

查看默认字符集

```mysql
show variables like 'character_set%'
```

设置默认字符集

```cnf
[mysql]
default-character-set=utf8
[mysqld]
character_set_server=utf8
```

重启服务

```shell
systemctl restart mysqld
```

