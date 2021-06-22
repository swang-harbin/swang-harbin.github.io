---
title: 普通用户安装MySQL
date: '2020-07-13 00:00:00'
updated: '2020-07-13 00:00:00'
tags:
- MySQL
- Linux
categories:
- Database
---

# 普通用户安装MySQL

[官方文档](https://dev.mysql.com/doc/refman/5.7/en/source-installation.html)

将mysql安装到`/home/normal/software/mysql`目录下

解压二进制包, 移动文件

```bash
tar -zxvf mysql-5.7.30-el7-x86_64.tar.gz
mv ./mysql-5.7.30-el7-x86_64 /home/normal/softwore/mysql
```

创建data, conf, log目录

```bash
mkdir data conf log
```

初始化

```bash
bin/mysqld --defaults-file=/home/normal/software/mysql/conf/my.cnf --initialize
```

配置文件

```ini
[mysqld]
port=3306
basedir=/home/normal/software/mysql
datadir=/home/normal/software/mysql/data
pid-file=/home/normal/software/mysql/mysql.pid
socket=/home/normal/software/mysql/mysql.sock
log_error=/home/normal/software/mysql/error.log
character_set_server=utf8mb4
lower_case_table_names=1

[mysql]
default-character-set=utf8mb4
```

后台启动mysqld服务

```bash
nohup ./bin/mysqld_safe --defaults-file=./conf/my.cnf 2>&1 1>>log/mysql.log &
```

查看随机生成的密码, 文件对应配置文件中的*log_error*

```bash
cat /home/normal/software/mysql/error.log
```

使用mysql客户端登录, 需要使用-S指定sock文件位置, 对应在配置文件中*socket*的配置

```bash
./bin/mysql -uroot -p -S /home/normal/software/mysql/mysql.sock
```

修改root用户密码, 开启root用户远程访问

```mysql
ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';
CREATE USER 'root'@'%' IDENTIFIED BY 'root';
GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION;
```

配置环境变量

```bash
vi ~/.bash_profile
# 添加
export PATH=/home/normal/software/mysql/bin:$PATH
```

使环境变量生效

```bash
source ~/.bash_profile
```
