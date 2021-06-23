---
title: 源码方式编译安装 nginx
date: '2020-05-10 00:00:00'
tags:
- Nginx
---
# 源码方式编译安装 nginx

## 下载 nginx 源码包

http://nginx.org/en/download.html

## 解压，编译，安装

### 解压

```bash
tar -zxvf nginx-1.16.1.tar.gz
cd nginx-1.16.1/
```

### 检查系统环境信息，并生成 MAKEFILE 文件
```bash
./configure --prefix=/path/to/install/nginx
```
可以不指定 `--prefix`, 默认将 nginx 安装到 */usr/local* 目录下

### 编译安装
```bash
make
make install
```
