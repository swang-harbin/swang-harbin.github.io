---
title: Linux 设置 PostgreSQL 开机自启
date: '2020-09-10 00:00:00'
tags:
- PostgreSQL
---

# PostgreSQL 设置开机自启动

[PG11 server-start](https://www.postgresql.org/docs/11/server-start.html)

官网的可能要在编译时指定了 `--with-systemd` 才能用，具体原因未知

整个野的

添加 /etc/systemd/system/postgresql.service

```properties
[Unit]
Description=PostgreSQL database server
Documentation=man:postgres(1)

[Service]
Type=forking
User=postgres
Group=postgres
ExecStart=/usr/local/pgsql/bin/pg_ctl start -D /usr/local/pgsql/data
ExecReload=/usr/local/pgsql/bin/pg_ctl restart -D /usr/local/pgsql/data
ExecStop=/usr/local/pgsql/bin/pg_ctl stop -D /usr/local/pgsql/data
TimeoutSec=0

[Install]
WantedBy=multi-user.target
```

