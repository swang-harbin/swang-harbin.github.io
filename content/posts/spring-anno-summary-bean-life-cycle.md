---
title: Spring注解-Bean的生命周期总结
date: '2020-02-19 00:00:00'
tags:
- Spring
- Spring Annotation
- Java
categories:
- Java
- Spring注解系列
---

# Spring注解-Bean的生命周期总结

[跳到Spring注解系列目录](spring-anno-table.md)

**bean的生命周期 :**

> bean创建---初始化---销毁

**Spring框架默认使用容器管理bean的生命周期, 我们可以自定义初始化和销毁方法; 容器在bean进行到当前生命周期时, 来调用我们自定义的初始化和销毁方法**

1. 指定初始化和销毁方法
   - 配置文件方式: 指定init-method和destroy-method
   - 注解方式: 在@Bean注解中指定initMethod和destroyMethod属性
   
2. 通过Bean实现InitializingBean或DisposableBean接口定义初始化或销毁逻辑

3. 使用JSR250(Java Specification Requests, Java规范提案)提供的原生注解
   - @PostConstruct: 在bean创建完成并且属性赋值完成后, 来执行初始化
   - @PreDestroy: 在容器销毁bean之前, 通知我们进行清理工作
   
4. BeanPostProcess接口: bean后置处理器, 在bean初始化前后进行一些处理工作

   ```java
   public interface BeanPostProcessor {
   
       // 在bean初始化之前调用
   	Object postProcessBeforeInitialization(Object bean, String beanName) throws BeansException;
   	
       // 在bean初始化之后调用
   	Object postProcessAfterInitialization(Object bean, String beanName) throws BeansException;
   }
   ```

## Spring中, bean的整个生命周期

1. 构造方法(对象创建时)
   - 单实例: 在容器启动的时候创建对象
   - 多实例: 在每次获取的时候创建对象
2. 初始化前执行MyBeanPostProcessor.postProcessBeforeInitialization()
3. 初始化:

   对象创建完成, 并赋值好, 调用初始化方法

4. 初始化后执行MyBeanPostProcessor.postProcessAfterInitialization()
5. 销毁:
   - 单实例: 在容器关闭的时候
   - 多实例: 容器不会管理这个bean; 容器不会调用销毁方法
