---
title: Spring Boot与Docker
date: '2019-12-17 00:00:00'
updated: '2019-12-17 00:00:00'
tags:
- Spring Boot
- Java
categories:
- [Java, SpringBoot基础系列]
---

# Spring Boot与Docker

[SpringBoot基础系列目录](spring-boot-table.md)

## 简介

**Docker**是一个开源的应用容器引擎

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222133657.png)

Docker支持将软件编译成一个镜像, 然后在镜像中对各种软件做好配置, 将镜像发布出去, 其他使用者可以直接使用这个镜像.

运行中的这个镜像称为容器, 容器启动时非常快速的.

## Docker核心概念

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222133741.png)

**Docker主机(Host) :** 安装了Docker程序的机器(Docker是直接安装在操作系统上的)

**Docker客户端(Client) :** 连接Docker主机进行操作

**Docker仓库(Registry) :** 用来保存各种打包好的软件镜像

**Docker镜像(Images) :** 软件打包好的镜像, 放在仓库中

**Docker容器(Container) :** 镜像启动后的实例称为一个容器, 是独立运行的一个或一组应用

**使用Docker的步骤 :**

1. 安装Docker
2. 去Docker仓库找到这个软件对应的镜像
3. 直接使用docker运行这个镜像, 这个镜像就会生成一个容器
4. 对容器的启动停止就是对软件的启动停止

## 安装Docker

### 安装虚拟机

1. 安装VirtualBox或VMWare

2. 导入linux虚拟机文件

3. 启动linux虚拟机

4. 使用客户端连接linux虚拟机

5. 设置虚拟网络 桥接网络=选好网卡=接入网线

6. 设置好网络后使用命令重启虚拟机网络

   ```shell
   systemctl restart network
   ```

7. 查看linux的ip地址

   ```shell
   ifconfig
   ```

8. 使用客户端连接

### 在Linux上安装Docker

1. 查看CentOS版本:

Docker要求CentOS系统的内核版本高于3.10 `uname -a`

1. 升级软件包及内核(选做)

   ```shell
   yum update
   ```

2. 安装Docker

   ```shell
   yum install docker
   ```

3. 启动Docker

   ```shell
   systemctl start docker
   ```

4. 设置Docker开机自启

   ```shell
   systemctl enable docker
   ```

5. 停止Docker

   ```shell
   systemctl stop docker
   ```

## 常用操作

### 镜像操作

| 操作 | 命令                   | 说明                                                    |
| ---- | ---------------------- | ------------------------------------------------------- |
| 检索 | docker search 关键字   | 我们经常去docker hub上检索镜像的详细信息, 如镜像的TAG   |
| 拉取 | docker pull 镜像名:tag | :tag是可选的, tag表示标签, 多为软件的版本, 默认是latest |
| 列表 | docker images          | 查看所有本地镜像                                        |
| 删除 | docker rmi image-id    | 删除指定的本地镜像                                      |

### 容器操作

| 操作     | 命令                                                         | 说明                                                       |
| -------- | ------------------------------------------------------------ | ---------------------------------------------------------- |
| 运行     | docker run --name container-name -d image-name               | --name: 自定义容器名 -d: 后台运行 image-name: 指定镜像模板 |
| 列表     | docker ps                                                    | 查看运行中的容器 加上-a可以查看所有容器                    |
| 停止     | docker stop container-name/container-id                      | 停止指定名称或id的容器                                     |
| 启动     | docker start container-name/container-id                     | 启动指定名称/id的容器                                      |
| 删除     | docker rm container-id                                       | 删除指定id的容器                                           |
| 端口映射 | -p 6379:6379 eg.docker run -d -p 6379:6379 --name myredis [docker.io/redis](http://docker.io/redis) | -p: 主机端口映射到容器内部的端口 主机端口:docker内部端口   |
| 容器日志 | docker logs container-name/container-id                      | null                                                       |
| 更多命令 | [官方文档](http:)                                            |                                                            |

软件镜像 --> 运行镜像 --> 产生容器(正在运行的软件)

**步骤 :**

1. 搜索镜像

   ```shell
   docker search tomcat
   ```

2. 拉取镜像

   ```shell
   docker pull tomcat
   ```

3. 根据镜像启动容器

   ```shell
   docker run --name mytomcat -d tomcat:latest
   ```

4. 查看运行中的容器

   ```shell
   docker ps
   ```

5. 停止运行中的容器

   ```shell
   docker stop 容器id
   ```

6. 查看所有的容器

   ```shell
   docker ps -a
   ```

7. 启动容器

   ```shell
   docker start 容器id
   ```

8. 删除容器

   ```shell
   docker stop 容器id
   docker rm 容器id
   ```

9. 启动一个做了端口映射的tomcat

   ```shell
   docker run -d -p 8888:8080 tomcat
   ```

10. 为了演示简单关闭了linux防火墙

    ```shell
    systemctl status firewalld
    systemctl stop firewalld
    ```

11. 查看容器日志

    ```shell
    docker logs 容器id
    ```

### 安装MySQL

拉取镜像

```shell
docker pull mysql
```

错误的启动

```shell
docker run --name msql01 -d mysql

错误日志
[root@iZ2ze7jsh4toa7ztb73ei2Z ~]# docker logs 364d3b95d995
2019-12-18 02:58:39+00:00 [Note] [Entrypoint]: Entrypoint script for MySQL Server 8.0.18-1debian9 started.
2019-12-18 02:58:40+00:00 [Note] [Entrypoint]: Switching to dedicated user 'mysql'
2019-12-18 02:58:40+00:00 [Note] [Entrypoint]: Entrypoint script for MySQL Server 8.0.18-1debian9 started.
2019-12-18 02:58:40+00:00 [ERROR] [Entrypoint]: Database is uninitialized and password option is not specified
	You need to specify one of MYSQL_ROOT_PASSWORD, MYSQL_ALLOW_EMPTY_PASSWORD and MYSQL_RANDOM_ROOT_PASSWORD
```

必须指定以上三个参数中的一个

正确的启动

```shell
docker run --name mysql1  -p 3306:3306 -e MYSQL_ROOT_PASSWORD=123456 -d mysql
```

几个其他的高级操作

```shell
指定配置文件
docker run --name container-name -v /my/custom:/etc/mysql/conf.d -e MYSQL_ROOT_PASSWORD=my-secret-pwd -d mysql:tag
把主机的/my/custom文件夹挂载到mysql docker容器的/etc/mysql/conf.d文件夹里面
改mysql的配置文件就只需要把mysql配置文件放在主机的/conf/custom下即可

不用cnf文件配置mysql
docker run --name container-name -e MYSQL_ROOT_PASSWORD=my-secret-pwd -d mysql:tag --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
使用--mysql-propertie-key=mysql-properties-val指定mysql的一些参数
```

剩余安装: redis rabbitmq elasticsearch
