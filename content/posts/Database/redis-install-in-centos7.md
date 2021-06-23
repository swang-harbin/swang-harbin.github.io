---
title: CentOS7 安装 Redis
date: '2019-11-21 00:00:00'
tags:
- Redis
- CentOS
---

# CentOS7 安装 Redis

## 下载 Redis

[Redis 官网](https://redis.io/)

## 安装 gcc 和 make

因为 redis 是用 c 编写的，所以首先安装 gcc 和 make

```
yum install gcc-c++
yum install make
```

## 解压安装 Redis

1. 创建 redis 目录，在该目录下解压 redis-x.x.x.tar.gz，切换到 redis-x.x.x 目录，使用 `make` 命令进行编译 

   ![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222192740.png)

2. 安装 redis 移动到 redis-x.x.x/src 目录下，使用下面命令安装，通过 `PREFIX` 指定将编译得到的文件存放到哪

```bash
make install PREFIX=../../
```

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222192754.png)

安装成功在 redis 目录下出现 bin 文件夹，该文件夹中包含 `redis-server`，`redis-cli`等可执行程序

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222192806.png)

将 redis.conf 从 redis-x.x.x 文件夹中移动到 bin 目下，删除不需要的目录和文件

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222192819.png)

## 相关命令

设置 redis 后台启动，修改 redis.conf

```conf
daemonize yes
```

启动 redis

```bash
./redis-server <配置文件>

./redis-server ./redis.conf
```

redis-cli 的使用

```bash
redis-cli -h host -p port -a password

例如
redis-cli -h 127.0.0.1 -p 6379
```
