---
title: CentOS7 安装绿色版 MySQL57
date: '2019-12-09 00:00:00'
tags:
- MySQL
- CentOS
---

# CentOS7 安装绿色版 MySQL57

## 创建用户和组

```bash
# groupadd mysql
# useradd -r -g mysql -s /bin/false mysql
```

因为这个用户只需要有所有权，不需要登录，`useradd` 使用 `-r -s /bin/false` 选项创建一个不能登录服务主机的用户。如果 `useradd` 命令不支持这些，可以忽略它们。用户名和组名也可以不叫 mysql

## 压缩包下载

[MySQL Product Archives](https://downloads.mysql.com/archives/community/)

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222184621.png)

### 解压

```shell
# tar -zxvf mysql-VERSION-OS.tar.gz
```

**文件夹介绍**

| 文件夹        | 内容                              |
| ------------- | --------------------------------- |
| bin           | mysqld 服务，客户端和实用程序      |
| docs          | MySQL 信息手册                     |
| man           | Unix 手册页                       |
| include       | 包含（头）文件                      |
| lib           | 库                                |
| share         | 数据库安装时的错误信息，字典和 SQL |
| support-files | 其他支持文件                      |

**可选：创建连接**

```shell
# ln -s full-path-to-mysql-VERSION-OS mysql
```

**可选：添加 bin 到环境变量**

在 /etc/profile 中添加

```shell
export PATH=$PATH:/usr/local/mysql/bin
```

## 初始化数据文件夹

在 mysql 文件夹中创建存储 mysql 数据的文件夹，将所有权赋给 mysql 和 mysql 组，并设置一个适当的目录权限

```shell
# mkdir data
# chown mysql:mysql data
# chmod 750 data
```

## [// TODO](https://dev.mysql.com/doc/refman/5.7/en/data-directory-initialization.html)

[Post Installation Setup](https://dev.mysql.com/doc/mysql-secure-deployment-guide/5.7/en/secure-deployment-post-install.html)
