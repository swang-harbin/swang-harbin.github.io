---
title: Windows10 移动 Docker
date: '2019-11-07 00:00:00'
tags:
- Docker
---
# Windows10 移动 Docker

## 关闭 Hyper-V 虚拟化
如果启动过 Docker 需要先关闭 Hyper-V，防止 Docker 镜像文件被系统占用

## 停止 Docker 服务
停止 Docker Desktop Service(com.docker.service)

## 移动文件
`C:\Program File\Docker` 移动到另一个地方，例如 `D:\Program File（x86）\Docker`

## 修改注册表
- 打开注册表

  <kbd>Win</kbd>+<kbd>R</kbd>

  ```cmd
  regedit
  ```

- 修改注册表值

  ```
  \HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\com.docker.service
  的 ImagePath 值为新路径下 com.docker.service 的路径，例如：D:\Program File（x86）\Docker\com.docker.service
  ```

## 启动服务
启动 Docker Desktop Service 服务
