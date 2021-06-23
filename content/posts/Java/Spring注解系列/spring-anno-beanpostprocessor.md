---
title: Spring 注解：BeanPostProcessor 后置处理器
date: '2020-02-19 00:00:00'
tags:
- Spring
- Spring Annotation
- Java
---
# Spring 注解：BeanPostProcessor 后置处理器

[Spring 注解系列目录](spring-anno-table.md)

在 Dog 和 Cat 类上均添加 `@Component` 注解

创建 MyBeanPostProcessor 实现 BeanPostProcessor 接口

```java
package icu.intelli.bean;

import org.springframework.beans.BeansException;
import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.stereotype.Component;

/**
 * 后置处理器：初始化前后进行处理工作
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

MainConfig 使用 `@ComponentScan` 将 Dog，Cat，MyBeanPostProcessor 均扫描到容器中

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

执行 IOCTest, 程序输出

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
IOC 容器创建完成...
dog preDestroy...
cat destroy...
IOC 容器已关闭...
```

- cat constructor... : 创建 cat 对象
- MyBeanPostProcessor.postProcessBeforeInitialization()...cat=>icu.intelli.bean.Cat@704d6e83 cat afterPropertiesSet... : 在 cat 初始化之前执行
- cat afterPropertiesSet... : 在 cat 初始化之后执行
- MyBeanPostProcessor.postProcessAfterInitialization()...cat=>icu.intelli.bean.Cat@704d6e83 : 在 cat 初始化之后，并在 afterPropertiesSet 之后执行
- cat destroy... : cat 被销毁时执行

没有定义初始化和销毁方法，后置处理器也会执行
