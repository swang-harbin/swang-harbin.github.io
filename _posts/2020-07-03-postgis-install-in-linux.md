---
layout: post
title: Linux安装PostGIS3
subheading: 
author: swang-harbin
categories: database
banner: 
tags: PostGIS PostgreSQL
---

# 源码方式安装PostGIS3.0.1

PostGIS是以插件的形式安装到PostgreSQL中的, 因此需要首先安装PostgreSQL, 参考[CentOS安装PostgreSQL12.2](2019-12-04-postgresql-install-in-centos.md)

## 一. 包管理器安装

## 二. 源码方式安装

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