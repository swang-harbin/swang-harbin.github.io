---
title: Spring Boot 与日志
date: '2019-12-16 00:00:00'
tags:
- Spring Boot
- Java
---

# Spring Boot 与日志

[Spring Boot 基础系列目录](spring-boot-table.md)

## 日志框架介绍

市面上的日志框架：JUL、JCL、Jboss-logging、logback、log4j、log4j2、slf4j……

| 日志门面（日志的抽象层）| 日志实现                    |
| ------------------------- | --------------------------- |
| JCL、SLF4j、jboss-logging | log4j、JUL、log4j2、Logback |

JCL：2014 年最后更新，jboss-logging：只有特定框架使用；log4j、logback、slf4j 是同一个人写的，logback 对 log4j 性能问题的改进，log4j2 适配的框架少；因此选择 slf4j 和 logback。

SpringBoot：底层是 Spring 框架，Spring 框架默认使用 JCL

**SpringBoot 选用 slf4j 和 logback **

## slf4j 的使用

### 如何在系统中使用 slf4j

以后开发的时候，日志记录方法的调用，不应该直接调用日志的实现，而是应调用日志的抽象；

给系统里面导入 slf4j 的 jar 和 logback 的 jar

[slf4j 用户手册](http://www.slf4j.org/manual.html)

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

**slf4j 适配各种 log 实现框架**

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222011406.png)

每一个日志的实现框架都有自己的配置文件，使用 slf4j 后，**配置文件还是用日志实现框架的**

### 遗留问题

A 系统（slf4j + logback）：依赖 Spring（commons-logging），Hibernate（jboss-logging），Mybatis

统一日志记录，即使别的框架，也要一起统一使用 slf4j 进行输出

[legacy APIs](http://www.slf4j.org/legacy.html)

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222011804.png)

**如何让系统中所有的日志都统一到 slf4j**

1. 将系统中其他日志框架先排除出去；
2. 用中间包来替换原有的日志框架；
3. 导入 slf4j 其他的实现。

## SpringBoot 日志关系

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter</artifactId>
</dependency>
```

SpringBoot 使用它来做日志记录

```xml
xml<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-logging</artifactId>
</dependency>
```

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222012013.png)

总结

1. springBoot 底层也是使用 slf4j+logback 的方式进行日志记录
2. SpringBoot 也把其他的日志都替换成了 slf4j
3. 引入中间替换包
4. 如果我们要引入其他框架，一定要把这个框架的默认日志依赖移除掉 Spring 框架用的是 commons-logging

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

SpringBoot 能自动适配所有的日志，而且底层使用 slf4j+logback 的方式记录日志，引入其他框架的时候，只需要把这个框架依赖的日志框架排除掉;

## 日志使用

### 默认配置

SpringBoot 默认帮我们配置好了日志

测试类

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
        logger.trace("这是 trace 日志……");
        logger.debug("这是 debug 日志……");
        // SpringBoot 默认使用的是 info 级别
        // 没有指定级别的就用 SpringBoot 默认规定的级别：root 级别
        logger.info("这是 info 日志……");
        logger.warn("这是 warn 日志……");
        logger.error("这是 error 日志……");
    }
}
```

配置文件 application.properties

```properties
# 指定某个包的日志记录级别
logging.level.icu.intelli=trace

# 不指定路径在当前项目下生成 springboot.log 日志
# 可以指定完整路径
logging.file.name=D:/log/springboot.log

# 在当前磁盘的根路径下创建 spring 文件夹和里面的 log 文件夹，使用 spring.log 作为默认文件
# 指定 logging.file.name 后 logging.file.path 即失效
# 1.x 版本为 logging.file 和 logging.path
logging.file.path=D:/log

# 在控制台输出的文件格式
logging.pattern.console=%d{yyyy-MM-dd} [%thread] %-5level %logger{50} - %msg%n

# 指定文件中日志输出的格式
logging.pattern.file=%d{yyyy-MM-dd} === [%thread] === %-5level === %logger{50} === %msg%n
```

### 指定配置

[官方对日志的说明](https://docs.spring.io/spring-boot/docs/2.2.2.RELEASE/reference/html/spring-boot-features.html#boot-features-logging)

在类路径下放上每个日志框架自己的配置文件即可；SpringBoot 就不使用默认的配置了

| Logging System         | Customization                                                |
| ---------------------- | ------------------------------------------------------------ |
| Logback                | logback-spring.xml, logback-spring.groovy, logback.xml or logback.grooy |
| Log4j2                 | log4j2-spring.xml or log4j2.xml                              |
| JDK（Java Util Logging）| logging.properties                                           |

logback.xml：直接被日志框架识别

**logback-spring.xml**：日志框架就不直接加载日志的配置项，由 SpringBoot 解析日志配置，可以使用 SpringBoot 的 profile 高级特性

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

## 切换日志框架

可以按照 slf4j 的日志适配图，进行相关的切换

切换为 log4j2 时，可以使用 springboot 提供的 spring-boot-start-log4j2

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
