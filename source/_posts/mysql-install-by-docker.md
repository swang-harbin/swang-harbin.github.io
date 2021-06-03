---
title: Docker安装MySQL
date: '2020-07-01 00:00:00'
updated: '2020-07-01 00:00:00'
tags:
- MySQL
- Docker
categories:
- Database
---

# Docker安装MySQL

[官方文档](https://dev.mysql.com/doc/refman/5.7/en/docker-mysql-more-topics.html)

## 一. 在主机上新建一个目录用来存放mysql的配置文件和数据

```shell
$ mkdir -p /path-on-host-machine/datadir
$ mkdir -p /path-on-host-machine/log
$ mkdir -p /path-on-host-machine/conf
$ touch /path-on-host-machine/conf/my.cnf
```

其中data目录必须为空, my.cnf的内容如下

```cnf
## 必须包含的配置
[mysqld]
user=mysql

# 常用配置

# 设置服务端字符集
character_set_server=utf8mb4
# 不区分表名大小写
lower_case_table_names=1

[mysql]
# 设置客户端字符集
default-character-set=utf8mb4
```

## 二. 运行容器

[docker运行mysql的说明](https://hub.docker.com/_/mysql)

```shell
$ docker run --name some-mysql \
-p 3306:3306 \
-v /path-on-host-machine/conf:/etc/mysql/conf.d \
-v /path-on-host-machine/datadir:/var/lib/mysql \
-v /path-on-host-machine/logdir:/var/log/mysql \
-e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:tag
```

说明:

docker中 **/etc/mysql/my.cnf** 内容如下

```cnf
!includedir /etc/mysql/conf.d/
!includedir /etc/mysql/mysql.conf.d/
```

引入了 */etc/mysql/conf.d/* 和 */etc/mysql/mysql.conf.d/*目录下的配置文件信息, 所以将宿主机上存放自定义配置文件的目录映射到docker中的 */etc/mysql/conf.d/*, mysql即会读取其中的配置文件.

