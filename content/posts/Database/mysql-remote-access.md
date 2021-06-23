---
title: 远程访问 MySQL
date: '2019-10-26 00:00:00'
tags:
- MySQL
---

# 远程访问 MySQL

## 旧版本

### 添加指定 IP 访问

`GRANT ALL ON *.* TO 用户名@'IP 地址' IDENTIFIED BY '密码';`

```mysql
use mysql;
GRANT ALL ON *.* to root@'10.60.160.12' IDENTIFIED BY 'root';
FLUSH PRIVILEGES;
```

### 添加指定 IP 段访问

`GRANT ALL ON *.* TO 用户名@'[xxx.xxx.xxx](http://xxx.xxx.xxx/).%' IDENTIFIED BY '密码';`

```mysql
use mysql;
GRANT ALL ON *.* to root@'10.60.160.%' IDENTIFIED BY 'root';
FLUSH PRIVILEGES;
```

### 添加任意 IP 访问

`GRANT ALL ON *.* TO 用户名@'%' IDENTIFIED BY '密码';`

```mysql
use mysql;
GRANT ALL ON *.* TO root@'%' IDENTIFIED BY 'root';
FLUSH PRIVILEGES;
```

## 新版本

新版本的 MySQL 将创建用户和赋予权限分开了，因此使用上方命令会报错:

> You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'IDENTIFIED BY 'root'' at line 1

需要使用如下命令:

### 创建用户

`CREATE USER '用户名'@'访问主机' IDENTIFIED BY '密码';`

```mysql
CREATE USER 'root'@'%' IDENTIFIED BY 'root';
```

### 赋予权限

`GRANT 权限列表 ON 数据库 TO '用户名'@'访问主机';`

```mysql
GRANT ALL ON *.* TO 'root'@'%';
```

### 撤销权限

`REVOKE 权限列表 ON 数据库 FROM '用户名'@'访问主机';`

```mysql
REVOKE ALL ON *.* FROM 'root'@'%';
```

### 删除用户

`DROP USER '用户名'@'访问主机';`

```mysql
DROP USER root@'%';
```

## 参考资料

[mysql 数据库添加某个 IP 访问](https://blog.csdn.net/xiao90713/article/details/82563903)
