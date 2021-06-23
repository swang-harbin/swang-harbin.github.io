---
title: Linux 安装 PostGIS3
date: '2020-07-03 00:00:00'
tags:
- PostGIS
- PostgreSQL
---

# 源码方式安装 PostGIS3.0.1

PostGIS 是以插件的形式安装到 PostgreSQL 中的，因此需要首先安装 PostgreSQL，参考[CentOS 安装 PostgreSQL12.2](./postgresql-install-in-centos.md)

## 包管理器安装

略

## 源码方式安装

解压 Postgis 源码包

```bash
tar -zxvf postgis-3.0.1.tar.gz
cd postgis-3.0.1
./configure --prefix=/path/to/postgresql --with-pgconfig=/path/to/postgresql/bin/pg_config
```

- `--prefix=PREFIX`: PostGIS 安装的位置
- `--with-pgconfig=FILE1`: PostgreSQL 提供了一个名为 pg_config 的文件，用于使 PostGIS 这样的插件能够定位到 PostgreSQL 的安装目录。

```bash
make all
make install
```

登录 postgres，使用如下命令安装 postgis 插件

```bash
create extension postgis;

select postgis_full_version();
```

[官方安装文档](http://www.postgis.net/docs/postgis_installation.html)
