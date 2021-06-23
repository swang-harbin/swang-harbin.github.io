---
title: configure，make，make install 介绍
date: '2020-05-10 00:00:00'
tags:
- Linux
---
# configure，make，make install 介绍

## configure（配置）

`configure` 是一个可执行脚本，主要用来测试系统环境，并生成 Makefile 文件。包含多种选项，可通过 `./configure  --help` 查看。最常用的选项是 `./configure --prefix=/path/to/install`，指定应用安装位置，如不指定，通常默认安装在 */usr/local* 目录下


## make（编译）

根据 `Makefile` 脚本编译源代码。

## make install（安装）

将编译后的程序，依赖库，文档等拷贝到指定目录（*/path/to/install*）

## 其他常用命令

- `make all` 或 `make world`：编译所有文件，可能包含文档等
- `make clean`：删除所有被 make 创建的文件
- `make distclean`：同时删除 ./configure 和 make 产生的临时文件
- `make check`：测试编译好的软件
- `make uninstall`：卸载已安装应用，需要 Makefile 中指定了安装路径
