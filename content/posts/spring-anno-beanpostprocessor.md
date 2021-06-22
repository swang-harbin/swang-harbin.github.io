---
title: Spring注解-BeanPostProcessor后置处理器
date: '2020-02-19 00:00:00'
tags:
- Spring
- Spring Annotation
- Java
categories:
- Java
- Spring注解系列
---
# Spring注解-BeanPostProcessor后置处理器

[跳到Spring注解系列目录](spring-anno-table.md)

在Dog和Cat类上均添加@Component注解

创建MyBeanPostProcessor实现BeanPostProcessor接口

```java
package icu.intelli.bean;

import org.springframework.beans.BeansException;
import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.stereotype.Component;

/**
 * 后置处理器: 初始化前后进行处理工作
 *
 * @Component 将后置处理器加入到容器里
 */
@Component
public class MyBeanPostProcessor implements BeanPostProcessor {

    /**
     * @param bean
     * @param beanName
     * @return
     * @throws BeansException
     */
    public Object postProcessBeforeInitialization(Object bean, String beanName) throws BeansException {
        System.out.println("MyBeanPostProcessor.postProcessBeforeInitialization()..." + beanName + "=>" + bean);
        return bean;
    }

    /**
     * @param bean
     * @param beanName
     * @return
     * @throws BeansException
     */
    public Object postProcessAfterInitialization(Object bean, String beanName) throws BeansException {
        System.out.println("MyBeanPostProcessor.postProcessAfterInitialization()..." + beanName + "=>" + bean);
        return bean;
    }
}
```

MainConfig使用@ComponentScan将Dog, Cat, MyBeanPostProcessor均扫描到容器中

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

执行IOCTest, 程序输出

```
MyBeanPostProcessor.postProcessBeforeInitialization()...org.springframework.context.event.internalEventListenerProcessor=>org.springframework.context.event.EventListenerMethodProcessor@2e3fc542
MyBeanPostProcessor.postProcessAfterInitialization()...org.springframework.context.event.internalEventListenerProcessor=>org.springframework.context.event.EventListenerMethodProcessor@2e3fc542
MyBeanPostProcessor.postProcessBeforeInitialization()...org.springframework.context.event.internalEventListenerFactory=>org.springframework.context.event.DefaultEventListenerFactory@4524411f
MyBeanPostProcessor.postProcessAfterInitialization()...org.springframework.context.event.internalEventListenerFactory=>org.springframework.context.event.DefaultEventListenerFactory@4524411f
MyBeanPostProcessor.postProcessBeforeInitialization()...mainConfig=>icu.intelli.config.MainConfig$$EnhancerBySpringCGLIB$$47e607b3@401e7803
MyBeanPostProcessor.postProcessAfterInitialization()...mainConfig=>icu.intelli.config.MainConfig$$EnhancerBySpringCGLIB$$47e607b3@401e7803
cat constructor...
MyBeanPostProcessor.postProcessBeforeInitialization()...cat=>icu.intelli.bean.Cat@704d6e83
cat afterPropertiesSet...
MyBeanPostProcessor.postProcessAfterInitialization()...cat=>icu.intelli.bean.Cat@704d6e83
dog constructor...
MyBeanPostProcessor.postProcessBeforeInitialization()...dog=>icu.intelli.bean.Dog@10a035a0
dog postConstruct...
MyBeanPostProcessor.postProcessAfterInitialization()...dog=>icu.intelli.bean.Dog@10a035a0
IOC容器创建完成...
dog preDestroy...
cat destroy...
IOC容器已关闭...
```

- cat constructor... : 创建cat对象
- MyBeanPostProcessor.postProcessBeforeInitialization()...cat=>icu.intelli.bean.Cat@704d6e83 cat afterPropertiesSet... : 在cat初始化之前执行
- cat afterPropertiesSet... : 在cat初始化之后执行
- MyBeanPostProcessor.postProcessAfterInitialization()...cat=>icu.intelli.bean.Cat@704d6e83 : 在cat初始化之后, 并在afterPropertiesSet之后执行
- cat destroy... : cat被销毁时执行

没有定义初始化和销毁方法, 后置处理器也会执行
