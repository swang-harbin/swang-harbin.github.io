---
title: Spring注解-@Bean指定初始化和销毁方法
date: '2020-02-19 00:00:00'
updated: '2020-02-19 00:00:00'
tags:
- Spring
- Spring Annotation
- Java
categories:
- [Java, Spring注解系列]
---

# Spring注解-@Bean指定初始化和销毁方法

[跳到Spring注解系列目录](spring-anno-table.md)

**环境准备**

创建Car类, 并添加init和destroy方法

```java
package icu.intelli.bean;

public class Car {

    public Car() {
        System.out.println("car constructor...");
    }

    public void init() {
        System.out.println("car init...");
    }

    public void destroy() {
        System.out.println("car destroy...");
    }
}
```

## 注解版

编辑MainConfig配置类, 并在@Bean注解中使用initMethod和destroyMethod指定初始化和销毁方法

```java
package icu.intelli.config;

import icu.intelli.bean.Car;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class MainConfig {

    // 指定initMethod和destroyMethod
    @Bean(initMethod = "init", destroyMethod = "destroy")
    public Car car() {
        return new Car();
    }
}
```

编辑IOCTest

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
car constructor...
car init...
IOC容器创建完成...
car destroy...
IOC容器已关闭...
```

## 配置文件版

编辑beans.xml, 在bean标签中添加init-method和destroy-method属性

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd">

    <bean id="car" class="icu.intelli.bean.Car" init-method="init" destroy-method="destroy"></bean>

</beans>
```

修改IOCTest

```java
package icu.intelli;

import org.springframework.context.support.ClassPathXmlApplicationContext;

public class IOCTest {
    public static void main(String[] args) {
        // 获取IOC容器
        ClassPathXmlApplicationContext applicationContext = new ClassPathXmlApplicationContext("classpath:beans.xml");
        System.out.println("IOC容器创建完成...");

        // 关闭IOC容器
        applicationContext.close();
        System.out.println("IOC容器已关闭...");
    }
}
```

执行IOCTest输出

```
car constructor...
car init...
IOC容器创建完成...
car destroy...
IOC容器已关闭...
```

