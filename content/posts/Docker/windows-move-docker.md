---
title: Windows10移动Docker
date: '2019-11-07 00:00:00'
tags:
- Docker
---
# Windows10移动Docker

## 关闭Hyper-V虚拟化
如果启动过Docker需要先关闭Hyper-V，防止Docker镜像文件被系统占用

## 停止Docker服务
停止Docker Desktop Service(com.docker.service)

## 移动文件
C:\Program File\Docker 移动到另一个地方，例如D:\Program File（x86）\Docker

## 修改注册表
- 打开注册表

  ```shell
  Win+R -> regedit
  ```

- 修改注册表值

  ```
  \HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\com.docker.service
  的ImagePath值为新路径下com.docker.service的路径，例如：D:\Program File（x86）\Docker\com.docker.service
  ```

## 启动服务
启动Docker Desktop Service服务
