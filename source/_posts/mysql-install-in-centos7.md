---
title: CentOS7安装绿色版MySQL57
date: '2019-12-09 00:00:00'
updated: '2019-12-09 00:00:00'
tags:
- MySQL
- CentOS
categories:
- Database
---

# CentOS7安装绿色版MySQL57

## 创建用户和组

```bash
# groupadd mysql
# useradd -r -g mysql -s /bin/false mysql
```

因为这个用户只需要有所有权, 不需要登录, **useradd**使用 -r 和 -s /bin/false选项创建一个不能登录服务主机的用户. 如果**useradd**命令不支持这些, 可以忽略它们. 用户名和组名也可以不叫mysql

## 压缩包下载

[MySQL Product Archives](https://downloads.mysql.com/archives/community/)

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222184621.png)

### 解压

```shell
# tar -zxvf mysql-VERSION-OS.tar.gz
```

**文件夹介绍** :

| 文件夹        | 内容                              |
| ------------- | --------------------------------- |
| bin           | mysqld服务, 客户端和实用程序      |
| docs          | MySQL信息手册                     |
| man           | Unix 手册页                       |
| include       | 包含(头)文件                      |
| lib           | 库                                |
| share         | 数据库安装时的错误信息, 字典和SQL |
| support-files | 其他支持文件                      |

**可选: 创建连接**

```shell
# ln -s full-path-to-mysql-VERSION-OS mysql
```

**可选: 添加bin到环境变量**

在/etc/profile中添加

```shell
export PATH=$PATH:/usr/local/mysql/bin
```

## 三. 初始化数据文件夹

在mysql文件夹中创建存储mysql数据的文件夹, 将所有权赋给mysql和mysql组, 并设置一个适当的目录权限

```shell
# mkdir data
# chown mysql:mysql data
# chmod 750 data
```

## [// TODO](https://dev.mysql.com/doc/refman/5.7/en/data-directory-initialization.html)

[Post Installation Setup](https://dev.mysql.com/doc/mysql-secure-deployment-guide/5.7/en/secure-deployment-post-install.html)
