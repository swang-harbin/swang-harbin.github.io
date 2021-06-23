---
title: Spring 注解：@Bean 指定初始化和销毁方法
date: '2020-02-19 00:00:00'
tags:
- Spring
- Spring Annotation
- Java
---

# Spring 注解：`@Bean` 指定初始化和销毁方法

[Spring 注解系列目录](spring-anno-table.md)

**环境准备**

创建 Car 类，并添加 init 和 destroy 方法

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

编辑 MainConfig 配置类，并在 `@Bean` 注解中使用 initMethod 和 destroyMethod 指定初始化和销毁方法

```java
package icu.intelli.config;

import icu.intelli.bean.Car;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class MainConfig {

    // 指定 initMethod 和 destroyMethod
    @Bean(initMethod = "init", destroyMethod = "destroy")
    public Car car() {
        return new Car();
    }
}
```

编辑 IOCTest

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
car constructor...
car init...
IOC 容器创建完成...
car destroy...
IOC 容器已关闭...
```

## 配置文件版

编辑 beans.xml，在 bean 标签中添加 init-method 和 destroy-method 属性

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd">

    <bean id="car" class="icu.intelli.bean.Car" init-method="init" destroy-method="destroy"></bean>

</beans>
```

修改 IOCTest

```java
package icu.intelli;

import org.springframework.context.support.ClassPathXmlApplicationContext;

public class IOCTest {
    public static void main(String[] args) {
        // 获取 IOC 容器
        ClassPathXmlApplicationContext applicationContext = new ClassPathXmlApplicationContext("classpath:beans.xml");
        System.out.println("IOC 容器创建完成...");

        // 关闭 IOC 容器
        applicationContext.close();
        System.out.println("IOC 容器已关闭...");
    }
}
```

执行 IOCTest 输出

```
car constructor...
car init...
IOC 容器创建完成...
car destroy...
IOC 容器已关闭...
```
