---
title: Spring注解-使用InitializingBean和DisposableBean接口初始化或销毁Bean
date: '2020-02-19 00:00:00'
updated: '2020-02-19 00:00:00'
tags:
- Spring
- Spring Annotation
- Java
categories:
- [Java, Spring注解系列]
---
# Spring注解-使用InitializingBean和DisposableBean接口初始化或销毁Bean

[跳到Spring注解系列目录](spring-anno-table.md)

创建Cat类, 实现InitializingBean和disposableBean接口, 使用@Component注解, 练习使用@ComponentScan来将其扫描到容器中

```java
package icu.intelli.bean;

import org.springframework.beans.factory.DisposableBean;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.stereotype.Component;

@Component
public class Cat implements InitializingBean, DisposableBean {

    public Cat() {
        System.out.println("cat constructor...");
    }

    /**
     * InitializingBean的方法, 在对象初始化后执行
     *
     * @throws Exception
     */
    public void afterPropertiesSet() throws Exception {
        System.out.println("cat afterPropertiesSet...");
    }

    /**
     * DisposableBean的方法, 在Bean被销毁时(容器关闭前)执行
     *
     * @throws Exception
     */
    public void destroy() throws Exception {
        System.out.println("cat destroy...");
    }
}
```

修改MainConfig, 使用@ComponentScan将icu.intelli.bean中的组件扫描到容器中

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
cat constructor...
cat afterPropertiesSet...
IOC容器创建完成...
cat destroy...
IOC容器已关闭...
```
