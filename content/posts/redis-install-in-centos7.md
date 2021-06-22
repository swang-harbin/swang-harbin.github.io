---
title: CentOS7安装Redis
date: '2019-11-21 00:00:00'
tags:
- Redis
- CentOS
categories:
- Database
---

# CentOS7安装Redis

## 下载Redis

[Redis官网](https://redis.io/)

## 安装gcc和make

因为redis是用c编写的, 所以首先安装gcc和make

```
yum install gcc-c++
yum install make
```

## 解压安装Redis

1. 创建redis目录, 在该目录下解压redis-x.x.x.tar.gz, 切换到redis-x.x.x目录, 使用`make`命令进行编译 

   ![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222192740.png)

2. 安装redis 移动到redis-x.x.x/src目录下, 使用下面命令安装, 通过PREFIX指定将编译得到的文件存放到哪

```shell
make install PREFIX=../../
```

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222192754.png)

安装成功在redis目录下出现bin文件夹, 该文件夹中包含redis-server, redis-cli等可执行程序

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222192806.png)

将redis.conf从redis-5.0.7文件夹中移动到bin目下, 删除不需要的目录和文件

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222192819.png)

## 相关命令

设置redis后台启动, 修改redis.conf

```conf
daemonize yes
```

启动redis

```shell
./redis-server <配置文件>

./redis-server ./redis.conf
```

redis-cli的使用

```shell
redis-cli -h host -p port -a password

例如
redis-cli -h 127.0.0.1 -p 6379
```
