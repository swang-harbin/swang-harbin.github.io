---
title: CentOS7 配置 Java 环境
date: '2019-10-26 00:00:00'
tags:
- Linux
- CentOS
---
# CentOS7 配置 Java 环境

## 修改 /etc/profile
```bash
vim /etc/profile
```
添加如下代码
```bash
# java environment
JAVA_HOME=/xxx/jdk-1.x.x.xx
PATH=$JAVA_HOME/bin:$PATH
CLASSPATH=.:$JAVA_HOME/lib/rt.jar:$JAVA_HOME/lib/tools.jar
export JAVA_HOME PATH CLASSPATH
```

## 刷新配置
```bash
source /etc/profile
```
