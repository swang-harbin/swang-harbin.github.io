---
title: failed to retrieve PostgreSQL server_version_num
date: '2019-12-09 00:00:00'
tags:
- PostgreSQL
---

# failed to retrieve PostgreSQL server_version_num

## 错误提示

> Error: [PostgreSQL error] failed to retrieve PostgreSQL server_version_num: 致命错误：用户 "kong" Ident 认证失败

## 解决方式

修改 pg_hba.conf

```conf
# host    all             all             127.0.0.1/32            ident
# 将 ident 修改为 trust
host    all             all             127.0.0.1/32            trust
```
