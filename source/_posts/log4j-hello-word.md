---
title: log4j的HelloWorld程序
date: '2019-12-12 00:00:00'
updated: '2019-12-12 00:00:00'
tags:
- log4j
- java
categories:
- java
---

# log4j的HelloWorld程序

## 一. Log4J日志简介

Log4J(log for java)是java主流的日志框架, 提供各种类型, 各种存储, 各种格式, 多样化的日志服务; 在爬虫领域, 主要用于记录爬虫的执行过程, 方便排查爬虫执行错误问题.

2015年8月5日, 宣布Log4j 1.x 任期结束, 推荐使用 [Apache log4j 2](http://logging.apache.org/log4j/2.x/index.html)

## 二. Hello World

### 2.1 引入依赖

```xml
<dependency>
    <groupId>log4j</groupId>
    <artifactId>log4j</artifactId>
    <version>1.2.17</version>
</dependency>
```

## 2.2 配置文件

log4j.properties

```properties
log4j.rootLogger=DEBUG, Console, File

# Console
log4j.appender.Console = org.apache.log4j.ConsoleAppender
log4j.appender.Console.layout = org.apache.log4j.PatternLayout
log4j.appender.Console.layout.ConversionPattern = %d [%t] %-5p [%c] - %m%n

# File
log4j.appender.File = org.apache.log4j.FileAppender
log4j.appender.File.file = D:\\log\\log
log4j.appender.File.layout = org.apache.log4j.PatternLayout
log4j.appender.File.layout.ConversionPattern = %d [%t] %-5p [%c] - %m%n
```

## 2.3 测试程序

```java
public class HelloWorld {

    // 获取一个logger实例
    private static Logger logger = Logger.getLogger(HelloWorld.class);

    public static void main(String[] args) {
        logger.info("普通info信息");
        logger.debug("调试debug信息");
        logger.error("报错error信息");
        logger.warn("警告warn信息");
        logger.fatal("致命fatal信息");

        logger.error("报错信息", new IllegalArgumentException("非法参数"));
    }
}
```

输出

```
2019-12-12 21:52:32,920 [main] INFO  [cc.ccue.HelloWorld] - 普通info信息
2019-12-12 21:52:32,921 [main] DEBUG [cc.ccue.HelloWorld] - 调试debug信息
2019-12-12 21:52:32,921 [main] ERROR [cc.ccue.HelloWorld] - 报错error信息
2019-12-12 21:52:32,921 [main] WARN  [cc.ccue.HelloWorld] - 警告warn信息
2019-12-12 21:52:32,921 [main] FATAL [cc.ccue.HelloWorld] - 致命fatal信息
2019-12-12 21:52:32,923 [main] ERROR [cc.ccue.HelloWorld] - 报错信息
java.lang.IllegalArgumentException: 非法参数
	at cc.ccue.HelloWorld.main(HelloWorld.java:17)
```
