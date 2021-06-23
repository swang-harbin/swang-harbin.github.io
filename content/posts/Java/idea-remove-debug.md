---
title: IDEA 远程调试
date: '2020-01-02 00:00:00'
tags:
- IDEA
- Java
---

# IDEA 远程调试

## 启动远程调试

### Tomcat 启动远程调试

**Windows 修改 catalina.bat**

在 set local 上方添加

```bash
SET CATALINA_OPTS=-server -Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005

# 设置 dos 窗口的 Title
SET TITLE=CustomerTitle
set local
```

**Linux 修改 catalina.sh, 添加**

```bash
CATALINA_OPTS="-server -Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005"
```

### jar 包方式启动远程调试

使用如下命令运行 jar

```bash
java -Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=5005 -jar  /jar/path/xxx.jar
```

### Docker 容器环境启动 jar 包远程调试



## IDEA连接远程调试

![image-20210222153851719](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222153852.png)

![image-20210222154023346](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222154023.png)

## 参考文档

[Tomcat 开启远程 Debug 调试](https://www.jianshu.com/p/369398dc2f4a)
