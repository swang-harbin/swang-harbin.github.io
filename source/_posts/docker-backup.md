---
title: Docker备份与迁移
date: '2020-04-20 00:00:00'
updated: '2020-04-20 00:00:00'
tags:
- Docker
categories:
- Docker
---
# Docker备份与迁移

以下列出三种方式, 请根据实际需求选择其中的一种即可

## 方式一: 将容器提交为一个镜像

根据容器的改变创建一个新镜像

- 语法: `docker commit [OPTIONS] CONTAINER [REPOSITORY[:TAG]]`
- Options:
  - `-a, --author string`: 作者 (例如: "John Hannibal Smith <hannibal@a-team.com>")
  - `-c, --change list`: 将Dockerfile指令应用于创建的映像
  - `-m, --message string`: 提交描述
  - `-p, --pause`: 提交期间暂停容器(默认为true)

**示例 :**

提交容器为镜像
```shell
docker commit old-container-id new-image-name
```

此时使用`docker images`即可查看到刚提交的镜像


## 方式二: 将容器导出为文件

**导出容器的文件系统为一个tar压缩包**

- 语法: `docker export [OPTIONS] CONTAINER`
- Options:
  - `-o, --output string`: 写到文件而不是STDOUT

**导入tar包内容来创建文件系统映像**

- 语法: `docker import [OPTIONS] file|URL|- [REPOSITORY[:TAG]]`
- Options:
  - `-c, --change list`: 将Dockerfile指令应用于创建的映像
  - `-m, --message string`: 为引入的镜像设置描述信息

**示例 :**

将容器导出为tar包
```shell
docker export -o /path/to/outfile.tar container-id
```

将已导出的tar包恢复成镜像
```shell
docker import /path/to/outfile.tar new-image-name
```

## 方式三: 将容器所用的镜像或镜像导出为文件

**保存一个或多个镜像到tar压缩文件**

- 语法:	`docker save [OPTIONS] IMAGE [IMAGE...]`
- Save one or more images to a tar archive (默认输出到STDOUT)
- Options:
  - `-o, --output string`: 保存为一个文件, 而不是输出到STDOUT

**从tar压缩包或STDIN加载一个镜像**

- 语法: `docker load [OPTIONS]`
- Options:
  - `-i, --input string`: 从文件中加载, 而不是STDIN
  - `-q, --quiet`     Suppress the load output

**示例 :**

将容器所用的镜像导出为tar包
```shell
docker save -o /path/to/outfile.tar postgres:10
```

将导出的tar包引入为镜像
```shell
docker load -i /path/to/outfile.tar 
```

