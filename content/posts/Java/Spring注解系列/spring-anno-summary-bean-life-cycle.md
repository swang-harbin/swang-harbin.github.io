---
title: Spring 注解：Bean 的生命周期总结
date: '2020-02-19 00:00:00'
tags:
- Spring
- Spring Annotation
- Java
---

# Spring 注解：Bean 的生命周期总结

[Spring 注解系列目录](spring-anno-table.md)

**bean 的生命周期：** bean 创建 → 初始化 → 销毁

**Spring 框架默认使用容器管理 bean 的生命周期，我们可以自定义初始化和销毁方法；容器在 bean 进行到当前生命周期时，来调用我们自定义的初始化和销毁方法**

1. 指定初始化和销毁方法
   - 配置文件方式：指定 init-method 和 destroy-method
   - 注解方式：在 `@Bean` 注解中指定 initMethod 和 destroyMethod 属性
   
2. 通过 Bean 实现 InitializingBean 或 DisposableBean 接口定义初始化或销毁逻辑

3. 使用 JSR250（Java Specification Requests，Java 规范提案）提供的原生注解
   - `@PostConstruct`：在 bean 创建完成并且属性赋值完成后，来执行初始化
   - `@PreDestroy`：在容器销毁 bean 之前，通知我们进行清理工作
   
4. BeanPostProcess 接口：bean 后置处理器，在 bean 初始化前后进行一些处理工作

   ```java
   public interface BeanPostProcessor {
   
       // 在 bean 初始化之前调用
   	Object postProcessBeforeInitialization(Object bean, String beanName) throws BeansException;
   	
       // 在 bean 初始化之后调用
   	Object postProcessAfterInitialization(Object bean, String beanName) throws BeansException;
   }
   ```

## Spring 中, bean 的整个生命周期

1. 构造方法（对象创建时）
   - 单实例：在容器启动的时候创建对象
   - 多实例：在每次获取的时候创建对象
2. 初始化前执行 MyBeanPostProcessor.postProcessBeforeInitialization()
3. 初始化

   对象创建完成，并赋值好，调用初始化方法

4. 初始化后执行 MyBeanPostProcessor.postProcessAfterInitialization()
5. 销毁:
   - 单实例：在容器关闭的时候
   - 多实例：容器不会管理这个 bean；容器不会调用销毁方法
