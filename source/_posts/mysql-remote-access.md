---
title: 远程访问MySQL
date: '2019-10-26 00:00:00'
updated: '2019-10-26 00:00:00'
tags:
- MySQL
categories:
- database
---

# 远程访问MySQL

## 一. 添加指定IP访问

> GRANT ALL ON *.* TO 用户名@'IP地址' IDENTIFIED BY '密码';

```mysql
use mysql;
GRANT ALL ON *.* to root@'10.60.160.12' IDENTIFIED BY 'root';
FLUSH PRIVILEGES;
```

## 二. 添加指定IP段访问

> GRANT ALL ON *.* TO 用户名@'[xxx.xxx.xxx](http://xxx.xxx.xxx/).%' IDENTIFIED BY '密码';

```mysql
use mysql;
GRANT ALL ON *.* to root@'10.60.160.%' IDENTIFIED BY 'root';
FLUSH PRIVILEGES;
```

## 三. 添加任意IP访问

> GRANT ALL ON *.* TO 用户名@'%' IDENTIFIED BY '密码';

```mysql
use mysql;
GRANT ALL ON *.* TO root@'%' IDENTIFIED BY 'root';
FLUSH PRIVILEGES;
```

## 注意:

新版本的MySQL将创建用户和赋予权限分开了, 因此使用上方命令会报错:

```
You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'IDENTIFIED BY 'root'' at line 1
```

需要使用如下命令:

### 创建用户

> CREATE USER '用户名'@'访问主机' IDENTIFIED BY '密码';

例如:

```mysql
CREATE USER 'root'@'%' IDENTIFIED BY 'root';
```

### 赋予权限

> GRANT 权限列表 ON 数据库 TO '用户名'@'访问主机';

例如:

```mysql
GRANT ALL ON *.* TO 'root'@'%';
```

### 撤销权限

> REVOKE 权限列表 ON 数据库 FROM '用户名'@'访问主机';

例如:

```mysql
REVOKE ALL ON *.* FROM 'root'@'%';
```

### 删除用户

> DROP USER '用户名'@'访问主机';

例如:

```mysql
DROP USER root@'%';
```

## 参考资料

[mysql数据库添加某个IP访问](https://blog.csdn.net/xiao90713/article/details/82563903)
