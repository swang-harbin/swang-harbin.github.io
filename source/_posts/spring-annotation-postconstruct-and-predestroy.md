---
title: SpringAnnotation-11-使用@PostConstruct和@PreDestroy
date: '2020-02-19 00:00:00'
updated: '2020-02-19 00:00:00'
tags:
- spring-annotation
- spring
- java
categories:
- java
---

# SpringAnnotation-11-使用@PostConstruct和@PreDestroy

创建Dog类, 标注Component注解, 可取消Cat类上的@Component

```java
package zone.wwwww.bean;

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

```
package zone.wwwww.config;

import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;


@ComponentScan("zone.wwwww.bean")
@Configuration
public class MainConfig {

}
```

IOCTest.java

```java
package cc.ccue;

import zone.wwwww.config.MainConfig;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

public class IOCTest {
    public static void main(String[] args) {
        // 获取IOC容器
        AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfig.class);
        System.out.println("IOC容器创建完成...");

        // 关闭IOC容器
        applicationContext.close();
        System.out.println("IOC容器已关闭...");
    }
}
```

执行IOCTest输出

```
dog constructor...
dog postConstruct...
IOC容器创建完成...
dog preDestroy...
IOC容器已关闭...
```

