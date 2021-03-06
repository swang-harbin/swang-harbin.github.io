---
layout: post
title: Spring Boot与日志
subheading:
author: swang-harbin
categories: java
banner:
tags: spring-boot java
---

# 三. Spring Boot与日志

## 3.1 日志框架介绍

市面上的日志框架: JUL, JCL, Jboss-logging, logback, log4j, log4j2, slf4j...

| 日志门面(日志的抽象层)    | 日志实现                 |
| ------------------------- | ------------------------ |
| JCL, SLF4j, jboss-logging | log4j JUL log4j2 Logback |

JCL: 2014年最后更新, jboss-logging: 只有特定框架使用; log4j, logback, slf4j是同一个人写的, logback对log4j性能问题的改进, log4j2适配的框架少; 因此选择slf4j和logback.

SpringBoot: 底层是Spring框架, Spring框架默认使用JCL;

**SpringBoot选用 slf4j 和 logback **

## 3.2 slf4j的使用

### 3.2.1 如何在系统中使用slf4j

以后开发的时候, 日志记录方法的调用, 不应该直接调用日志的实现, 而是应调用日志的抽象;

给系统里面导入slf4j的jar和 logback的jar

[slf4j用户手册](http://www.slf4j.org/manual.html)

```java
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class HelloWorld {
    public static void main(String[] args) {
        Logger logger = LoggerFactory.getLogger(HelloWorld.class);
        logger.info("Hello World");
    }
}
```

**slf4j适配各种log实现框架 :**

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222011406.png)

每一个日志的实现框架都有自己的配置文件, 使用slf4j后, **配置文件还是用日志实现框架的**

### 3.2.2 遗留问题

A系统(slf4j + logback) : 依赖Spring(commons-logging), Hibernate(jboss-logging), Mybatis

统一日志记录, 即使别的框架, 也要一起统一使用slf4j进行输出,:

[legacy APIs](http://www.slf4j.org/legacy.html)

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222011804.png)

**如何让系统中所有的日志都统一到slf4j :**

1. 将系统中其他日志框架先排除出去;
2. 用中间包来替换原有的日志框架;
3. 导入slf4j其他的实现.

## 3.3 SpringBoot日志关系

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter</artifactId>
</dependency>
```

SpringBoot使用它来做日志记录:

```xml
xml<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-logging</artifactId>
</dependency>
```

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222012013.png)

总结:

1. springBoot底层也是使用slf4j+logback的方式进行日志记录
2. SpringBoot也把其他的日志都替换成了slf4j
3. 引入中间替换包
4. 如果我们要引入其他框架, 一定要把这个框架的默认日志依赖移除掉 Spring框架用的是commons-logging

```xml
<dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-core</artifactId>
    <exclusions>
        <exclusion>
            <groupId>commons-logging</groupId>
            <artifactId>commons-logging</artifactId>
        </exclusion>
    </exclusions>
</dependency>
```

SpringBoot能自动适配所有的日志, 而且底层使用slf4j+logback的方式记录日志, 引入其他框架的时候, 只需要把这个框架依赖的日志框架排除掉;

## 3.4 日志使用

### 3.4.1 默认配置

SpringBoot默认帮我们配置好了日志

测试类:

```java
@SpringBootTest
class ApplicationTests {
    // 记录器
    Logger logger = LoggerFactory.getLogger(getClass());

    @Test
    void contextLoads() {
        // 日志的级别
        // 由低到高 trace<debug<info<warn<error
        // 可以调整需要输出的日志级别
        logger.trace("这是trace日志...");
        logger.debug("这是debug日志...");
        // SpringBoot默认使用的是info级别
        // 没有指定级别的就用SpringBoot默认规定的级别: root级别
        logger.info("这是info日志...");
        logger.warn("这是warn日志...");
        logger.error("这是error日志...");
    }
}
```

配置文件application.properties:

```properties
# 指定某个包的日志记录级别
logging.level.cc.ccue=trace

# 不指定路径在当前项目下生成springboot.log日志
# 可以指定完整路径:
logging.file.name=D:/log/springboot.log

# 在当前磁盘的根路径下创建spring文件夹和里面的log文件夹, 使用spring.log作为默认文件
# 指定logging.file.name后logging.file.path即失效
# 1.x版本为logging.file 和 logging.path
logging.file.path=D:/log

# 在控制台输出的文件格式
logging.pattern.console=%d{yyyy-MM-dd} [%thread] %-5level %logger{50} - %msg%n

# 指定文件中日志输出的格式
logging.pattern.file=%d{yyyy-MM-dd} === [%thread] === %-5level === %logger{50} === %msg%n
```

### 3.4.1 指定配置

[官方对日志的说明](https://docs.spring.io/spring-boot/docs/2.2.2.RELEASE/reference/html/spring-boot-features.html#boot-features-logging)

在类路径下放上每个日志框架自己的配置文件即可1; SpringBoot就不使用默认的配置了

| Logging System         | Customization                                                |
| ---------------------- | ------------------------------------------------------------ |
| Logback                | logback-spring.xml, logback-spring.groovy, logback.xml or logback.grooy |
| Log4j2                 | log4j2-spring.xml or log4j2.xml                              |
| JDK(Java Util Logging) | logging.properties                                           |

logback.xml : 直接被日志框架识别

**logback-spring.xml** : 日志框架就不直接加载日志的配置项, 由SpringBoot解析日志配置, 可以使用SpringBoot的profile高级特性

```xml
<springProfile name="staging">
    <!-- configuration to be enabled when the "staging" profile is active -->
    可以指定某段配置只在某个环境生效
</springProfile>

<springProfile name="dev | staging">
    <!-- configuration to be enabled when the "dev" or "staging" profiles are active -->
</springProfile>

<springProfile name="!production">
    <!-- configuration to be enabled when the "production" profile is not active -->
</springProfile>
```

## 3.5 切换日志框架

可以按照slf4j的日志适配图, 进行相关的切换;

切换为log4j2时, 可以使用springboot提供的spring-boot-start-log4j2

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
    <exclusions>
        <exclusion>
            <artifactId>spring-boot-starter-logging</artifactId>
            <groupId>org.springframework.boot</groupId>
        </exclusion>
    </exclusions>
</dependency>

<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-log4j2</artifactId>
</dependency>
```