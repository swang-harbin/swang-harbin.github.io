---
layout: post
title: SpringAnnotation-09-@Bean指定初始化和销毁方法
subheading: 
author: swang-harbin
categories: java
banner: 
tags: spring-annotation spring java
---


# SpringAnnotation-09-@Bean指定初始化和销毁方法

**环境准备**

创建Car类, 并添加init和destroy方法

```java
package zone.wwwww.bean;

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
package zone.wwwww.config;

import zone.wwwww.bean.Car;
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

    <bean id="car" class="zone.wwwww.bean.Car" init-method="init" destroy-method="destroy"></bean>

</beans>
```

修改IOCTest

```java
package cc.ccue;

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