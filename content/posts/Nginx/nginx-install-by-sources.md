---
title: 源码方式编译安装nginx
date: '2020-05-10 00:00:00'
tags:
- Nginx
---
# 源码方式编译安装nginx

## 下载nginx源码包

http://nginx.org/en/download.html

## 解压, 编译, 安装

### 解压

```bash
tar -zxvf nginx-1.16.1.tar.gz
cd nginx-1.16.1/
```

### 检查系统环境信息, 并生成MAKEFILE文件
```bash
./configure --prefix=/path/to/install/nginx
```
可以不指定`--prefix`, 默认将nginx安装到*/usr/local*目录下

### 编译安装
```bash
make
make install
```
