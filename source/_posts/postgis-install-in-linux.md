---
title: Linux安装PostGIS3
date: '2020-07-03 00:00:00'
updated: '2020-07-03 00:00:00'
tags:
- PostGIS
- PostgreSQL
categories:
- Database
---

# 源码方式安装PostGIS3.0.1

PostGIS是以插件的形式安装到PostgreSQL中的, 因此需要首先安装PostgreSQL, 参考[CentOS安装PostgreSQL12.2](./postgresql-install-in-centos.md)

## 包管理器安装

略

## 源码方式安装

解压Postgis源码包

```shell
tar -zxvf postgis-3.0.1.tar.gz
cd postgis-3.0.1
./configure --prefix=/path/to/postgresql --with-pgconfig=/path/to/postgresql/bin/pg_config
```

- `--prefix=PREFIX`: PostGIS安装的位置
- `--with-pgconfig=FILE1`: PostgreSQL提供了一个名为pg_config的文件，用于使PostGIS这样的插件能够定位到PostgreSQL的安装目录。

```shell
make all
make install
```

登录postgres, 使用如下命令安装postgis插件

```shell
create extension postgis;

select postgis_full_version();
```

[官方安装文档](http://www.postgis.net/docs/postgis_installation.html)
