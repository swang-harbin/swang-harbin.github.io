---
title: 远程访问PostgreSQL
date: '2019-12-06 00:00:00'
updated: '2019-12-06 00:00:00'
tags:
- PostgreSQL
categories:
- Database
---

# 远程访问PostgreSQL

修改**pg_hba.conf**和**postgresql.conf**文件,

**pg_hba.conf**文件在默认在`/var/lib/pgsql/10/data/pg_hba.conf`,

**postgresql.conf**文件默认在`postgresql.conf`,

可以通过`find / -name filename`从/目录查找filename文件.

pg_hba.conf :

```
# 在ipv4下添加
host all all 0.0.0.0/0 trust
```

postgresql.conf :

```properties
listen_addresses='*'
```

如果不设置可能会报如下错误

>  could not connect to server: Connection refused (0x0000274D/10061)Is the server running on host"localhost" (127.0.0.1) and acceptingTCP/IP connections on port 5432?
