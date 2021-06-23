---
title: umount.nfs device is busy 问题
date: '2020-10-22 00:00:00'
tags:
- Linux
---
# umount.nfs device is busy 问题

## 问题描述

使用 `ls` 或者 `df -h` 命令，系统卡死。

使用 `umount /path/to/mount/point` 提示 `umount.nfs: /path/to/mount/point: device is busy`

## 解决方法

尝试使用 `umount -f /path/to/mount/poing`，强制卸载挂载点。

尝试使用 `fuser -mv /path/to/mount/point`，查看正在使用该挂载点的进程，使用 `kill` 命令杀死该进程，再进行 `umount`。或者使用 `fuser -mvk /path/to/mount/point` 直接杀死使用该挂载点的进程。

尝试使用 `umount -l /path/to/mount/point`，等待挂载点空闲时，自动卸载挂载点。

