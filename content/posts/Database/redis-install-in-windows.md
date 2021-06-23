---
title: Windows 安装 Redis
date: '2019-10-18 00:00:00'
tags:
- Redis
---

# Windows 安装 Redis

## Redis 临时服务

### windows 下 redis 下载地址

https://github.com/MicrosoftArchive/redis/releases

### 启动 redis 服务

cmd 运行

```bash
redis-server.exe redis.windows.conf
```

### 客户端调用

cmd 运行

```bash
redis-cli.exe -h 127.0.0.1 -p 6379
```

## 自定义 Redis 服务/启动多个 Redis

### 复制一份 redis 到另一个目录

### 修改 redis.windows.conf

将 `port 6379` 修改为 `port 6380` 等，指定端口号

### 安装服务

```bash
redis-server.exe --service-install redis.windows.conf --service-name redis6380 --loglevel verbose
```

### 启动服务

```bash
redis-server.exe --service-start --service-name redis6380
```

### 停止服务

```bash
redis-server.exe --serviec-stop --service-name redis6380
```

### 卸载服务

```bash
redis-server.exe --service-uninstall --service-name redis6380
```

## 工具地址

- [Redis Desktop](https://redisdesktop.com/)

## 参考博文

- [【Redis】windows 下 redis 服务的安装](https://www.cnblogs.com/chuankang/p/10308771.html)
