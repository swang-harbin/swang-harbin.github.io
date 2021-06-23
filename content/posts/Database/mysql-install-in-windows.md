---
title: Windows 安装绿色版 MySQL
date: '2019-11-20 00:00:00'
tags:
- MySQL
---

# Windows 安装绿色版 MySQL

## 下载压缩包

[MySQL 绿色版官方下载地址](https://downloads.mysql.com/archives/community/)

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222184323.png)

解压后得到

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222184341.png)

## 新建 my.ini 配置文件

在 bin 文件夹的同级目录新建一个 my.ini 文件，一定要修改 basedir 和 datadir 为正确的位置，否则之后的服务会启动失败

8.0.17 或 5.7.27 版本的 my.ini

```ini
[mysqld]
# 设置端口
port=3306
# 设置 mysql 的安装目录
basedir="D:\\Program Files (x86)\\MySQL\\mysql-8.0.17-winx64"
# 设置 mysql 数据库的数据的存放目录
datadir="D:\\Program Files (x86)\\MySQL\\mysql-8.0.17-winx64\\data"
# 允许最大连接数
max_connections=200
# 允许连接失败的次数。这是为了防止有人从该主机试图攻击数据库系统
max_connect_errors=10
# 服务端使用的字符集默认为 UTF8
character-set-server=utf8mb4
# 创建新表时将使用的默认存储引擎
default-storage-engine=INNODB
# 默认使用 mysql_native_password 插件认证
default_authentication_plugin=mysql_native_password

# 5.7.27 需要添加下面这个
explicit_defaults_for_timestamp=true
[mysql]
# 设置 mysql 客户端默认字符集
default-character-set=utf8mb4
[client]
# 设置 mysql 客户端连接服务端时默认使用的端口
port=3306
default-character-set=utf8mb4
```

5.6.45 版本的 my.ini

```ini
[mysql]
# 设置 mysql 客户端默认字符集
default-character-set=utf8

[client]
# 设置 mysql 客户端连接服务端时默认使用的端口
port=3306
default-character-set=utf8

[mysqld]
# 设置端口
port=3306
# 设置 mysql 的安装目录
basedir="D:\\Program Files (x86)\\MySQL\\mysql-5.6.45-winx64"
# 设置 mysql 数据库的数据的存放目录
datadir="D:\\Program Files (x86)\\MySQL\\mysql-5.6.45-winx64\\data"
# 允许最大连接数
max_connections=200
# 允许连接失败的次数。这是为了防止有人从该主机试图攻击数据库系统
max_connect_errors=10
# 服务端使用的字符集默认为 UTF8
character-set-server=utf8
# 创建新表时将使用的默认存储引擎
default-storage-engine=INNODB
# 默认使用 mysql_native_password 插件认证
default_authentication_plugin=mysql_native_password

sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES
```

## 安装并配置启动 MySQL 服务

[MySQL 官方说明](https://dev.mysql.com/doc/refman/8.0/en/windows-start-service.html)

### 法 1（8.0.17 和 5.7.27 版本适用）

设置好环境变量（略）或移动到 bin 目录下，以管理员身份运行 cmd 窗口

1. 安装 mysqld 服务

   服务名可选，默认为 mysql

   ```bash
   mysqld install [服务名]
   ```

2. 初始化 MySQL

   ```bash
   mysqld --initialize --console
   ```

   此时会打印出系统随机生成的密码，注意保存，在第一次登录时需要使用

3. 启动 MySQL 服务

   ```bash
   net start [服务名]
   ```

4. 修改密码

   ```mysql
   mysql -uroot -p 初始密码;
   
   ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'new password';
   ```

其他相关命令

```bash
# 停止服务
net stop [服务名]
# 移除 mysql 服务
mysqld --remove [服务名]
```

### 法 2（5.5.62 版本适用）

1. 安装 mysqld 服务

   服务名可选，默认为 mysql

   ```bash
   mysqld install [服务名]
   ```

2. 启动 MySQL 服务

   ```bash
   net start [服务名]
   ```

3. 初始化密码

   ```mysql
   mysqladmin -u root password 密码
   ```

   
