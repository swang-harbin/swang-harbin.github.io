---
title: IDEA远程调试
date: '2020-01-02 00:00:00'
updated: '2020-01-02 00:00:00'
tags:
- IDEA
- java
categories:
- java
---

# IDEA远程调试

## 一.启动远程调试

### 1.1 Tomcat启动远程调试

**Windows修改catalina.bat**

在set local上方添加

```shell
SET CATALINA_OPTS=-server -Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005

# 设置dos窗口的Title
SET TITLE=CustomerTitle
set local
```

**Linux修改catalina.sh, 添加**

```shell
CATALINA_OPTS="-server -Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005"
```

### 1.2 jar包方式启动远程调试

使用如下命令运行jar

```shell
java -Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=5005 -jar  /jar/path/xxx.jar
```

### 1.3 Docker容器环境启动jar包远程调试

## 二.客户端连接远程调试

### 2.1 IDEA

![image-20210222153851719](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222153852.png)

![image-20210222154023346](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222154023.png)

## 参考文档

[Tomcat 开启远程Debug调试](https://www.jianshu.com/p/369398dc2f4a)
