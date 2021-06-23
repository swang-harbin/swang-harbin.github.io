---
title: Spring 注解：使用 InitializingBean 和 DisposableBean 接口初始化或销毁 Bean
date: '2020-02-19 00:00:00'
tags:
- Spring
- Spring Annotation
- Java
---
# Spring 注解：使用 InitializingBean 和 DisposableBean 接口初始化或销毁 Bean

[Spring 注解系列目录](spring-anno-table.md)

创建 Cat 类，实现 InitializingBean 和 disposableBean 接口，使用 `@Component` 注解，练习使用 `@ComponentScan` 来将其扫描到容器中

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
     * InitializingBean 的方法，在对象初始化后执行
     *
     * @throws Exception
     */
    public void afterPropertiesSet() throws Exception {
        System.out.println("cat afterPropertiesSet...");
    }

    /**
     * DisposableBean 的方法，在 Bean 被销毁时（容器关闭前）执行
     *
     * @throws Exception
     */
    public void destroy() throws Exception {
        System.out.println("cat destroy...");
    }
}
```

修改 MainConfig, 使用 `@ComponentScan` 将 `icu.intelli.bean` 中的组件扫描到容器中

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
cat constructor...
cat afterPropertiesSet...
IOC 容器创建完成...
cat destroy...
IOC 容器已关闭...
```
