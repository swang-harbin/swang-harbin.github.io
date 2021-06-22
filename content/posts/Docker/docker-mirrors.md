---
title: Docker设置阿里云镜像地址
date: '2019-10-19 00:00:00'
tags:
- Docker
---
# Docker设置阿里云镜像地址

## 获取阿里云容器镜像服务地址
- 登录阿里云容器镜像服务:[容器镜像服务](https://cr.console.aliyun.com)
- 点击镜像加速器,得到加速器地址

## 修改daemon配置文件
修改/etc/docker/daemon.json,如果没有就新建,将如下内容写入
```json
{
  "registry-mirrors": ["https://xxx.mirror.aliyuncs.com"]
}
```

## 重启daemon
```bash
systemctl daemon-reload
```

## 重启Docker
```bash
systemctl restart docker
```

## 测试
```bash
docker info
```
