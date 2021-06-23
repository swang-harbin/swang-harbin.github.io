---
title: Spring 注解：BeanPostProcessor 在 Spring 底层的使用
date: '2020-02-19 00:00:00'
tags:
- Spring
- Spring Annotation
- Java
---
# Spring 注解：BeanPostProcessor 在 Spring 底层的使用

[Spring 注解系列目录](spring-anno-table.md)

Spring 底层通过使用 BeanPostProcessor 实现 bean 赋值，注入其他组件，`@Autowired`，生命周期注释功能，`@Async` 等等功能。

[Interface] BeanPostProcessor

- [Class] ApplicationContextAwareProcessor

  通过让一个组件类实现 ApplicationContextAware 接口，可以将 IOC 容器注入到该类中

  ```java
  package icu.intelli.bean;
  
  import org.springframework.beans.BeansException;
  import org.springframework.context.ApplicationContext;
  import org.springframework.context.ApplicationContextAware;
  import org.springframework.stereotype.Component;
  
  @Component
  public class Dog implements ApplicationContextAware {
  
      private ApplicationContext applicationContext;
  
      // 当该组件被 Spring 初始化时，会调用该方法将 IOC 容器（ApplicationContext）注入到该类中
      public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
          this.applicationContext = applicationContext;
      }
  }
  ```

- [Class] BeanValidationPostProcessor

  对 JSR-303 进行验证的后置处理器

- [Interface] DestructionAwareBeanPostProcessor

  - [Class] InitDestroyAnnotationBeanPostProcessor

    对组件中的 `@PostConstruct`，`@PreDestroy` 进行处理，执行由这两个注解标注的方法

- [Interface] MergedBeanDefinitionPostProcessor

  - [Class] AutowiredAnnotationBeanPostProcessor

    对组件中的 `@Autowire` 注解进行处理，使其生效
