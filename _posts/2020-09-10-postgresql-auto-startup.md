---
layout: post
title: Linux设置PostgreSQL开机自启
subheading: 
author: swang-harbin
categories: database
banner: 
tags: PostgreSQL
---

# PostgreSQL设置开机自启动

[PG11. server-start](https://www.postgresql.org/docs/11/server-start.html)

官网的可能要在编译时指定了`--with-systemd`才能用, 具体原因未知

整个野的

添加 **/etc/systemd/system/postgresql.service**

```shell
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

