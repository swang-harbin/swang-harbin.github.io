---
title: Spring注解-@Lazy懒加载
date: '2020-02-18 00:00:00'
tags:
- Spring
- Spring Annotation
- Java
---

# Spring注解-@Lazy懒加载

[跳到Spring注解系列目录](spring-anno-table.md)

由上一篇可知, 单实例bean默认在容器启动时即创建

懒加载, 使得容器在启动时不创建对象, 而是在第一次使用(获取)该Bean时创建对象, 并初始化.

MainConfig.class

```java
@Configuration
public class MainConfig {

    @Lazy
    @Bean("person")
    public Person person() {
        System.out.println("给容器中添加Person...");
        return new Person("张三", 25);
    }
}
```

IOCTest

```java
public class IOCTest {
    public static void main(String[] args) {
        // 获取IOC容器
        ApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfig.class);
        System.out.println("IOC容器创建完成...");
        
        Object bean = applicationContext.getBean("person");
        System.out.println("完成首次获取Person...");
        Object bean2 = applicationContext.getBean("person");
    }
}
```

测试类输出

```
IOC容器创建完成...
给容器中添加Person...
完成首次获取Person...
```
