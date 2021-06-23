---
title: MySQL 设置大小写及字符集
date: '2020-05-08 00:00:00'
tags:
- MySQL
---

# MySQL 设置大小写及字符集

## MySQL 设置不区分表名大小写

Windows 默认不区分，Linux 默认区分。0 代表区分，1 代表不区分。

```properties
[mysqld]
lower_case_table_names=1
```

## MySQL 设置默认字符集

查看默认字符集

```mysql
show variables like 'character_set%'
```

设置默认字符集

```properties
[mysql]
default-character-set=utf8mb4
[mysqld]
character_set_server=utf8mb4
```

重启服务

```bash
systemctl restart mysqld
```

