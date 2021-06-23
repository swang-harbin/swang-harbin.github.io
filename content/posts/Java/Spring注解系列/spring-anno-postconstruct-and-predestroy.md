---
title: Spring 注解：使用 @PostConstruct 和 @PreDestroy
date: '2020-02-19 00:00:00'
tags:
- Spring
- Spring Annotation
- Java
---

# Spring 注解：使用 `@PostConstruct` 和 `@PreDestroy`

[Spring 注解系列目录](spring-anno-table.md)

创建 Dog 类，标注 `@Component` 注解，可取消 Cat 类上的 `@Component`

```java
package icu.intelli.bean;

import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;

@Component
public class Dog {

    public Dog() {
        System.out.println("dog constructor...");
    }

    /**
     * 在对象创建并赋值之后调用
     */
    @PostConstruct
    public void init() {
        System.out.println("dog postConstruct...");
    }

    /**
     * 容器移除对象之前调用
     */
    @PreDestroy
    public void destroy() {
        System.out.println("dog preDestroy...");
    }

}
```

MainConfig.java

```java
package icu.intelli.config;

import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;


@ComponentScan("icu.intelli.bean")
@Configuration
public class MainConfig {

}
```

IOCTest.java

```java
package icu.intelli;

import icu.intelli.config.MainConfig;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

public class IOCTest {
    public static void main(String[] args) {
        // 获取 IOC 容器
        AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfig.class);
        System.out.println("IOC 容器创建完成...");

        // 关闭 IOC 容器
        applicationContext.close();
        System.out.println("IOC 容器已关闭...");
    }
}
```

执行 IOCTest 输出

```
dog constructor...
dog postConstruct...
IOC 容器创建完成...
dog preDestroy...
IOC 容器已关闭...
```
