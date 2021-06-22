---
title: Spring注解-BeanPostProcessor在Spring底层的使用
date: '2020-02-19 00:00:00'
tags:
- Spring
- Spring Annotation
- Java
categories:
- Java
- Spring注解系列
---
# Spring注解-BeanPostProcessor在Spring底层的使用

[跳到Spring注解系列目录](spring-anno-table.md)

Spring底层通过使用BeanPostProcessor实现bean赋值, 注入其他组件, @Autowired, 生命周期注释功能, @Async 等等功能.

[Interface] BeanPostProcessor

- [Class] ApplicationContextAwareProcessor

  > 通过让一个组件类实现ApplicationContextAware接口, 可以将IOC容器注入到该类中

  ```java
  package icu.intelli.bean;
  
  import org.springframework.beans.BeansException;
  import org.springframework.context.ApplicationContext;
  import org.springframework.context.ApplicationContextAware;
  import org.springframework.stereotype.Component;
  
  @Component
  public class Dog implements ApplicationContextAware {
  
      private ApplicationContext applicationContext;
  
      // 当该组件被Spring初始化时, 会调用该方法将IOC容器(ApplicationContext)注入到该类中
      public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
          this.applicationContext = applicationContext;
      }
  }
  ```

- [Class] BeanValidationPostProcessor

  > 对JSR-303进行验证的后置处理器

- [Interface] DestructionAwareBeanPostProcessor

  - [Class] InitDestroyAnnotationBeanPostProcessor

    > 对组件中的@PostConstruct, @PreDestroy进行处理, 执行由这两个注解标注的方法

- [Interface] MergedBeanDefinitionPostProcessor

  - [Class] AutowiredAnnotationBeanPostProcessor

    > 对组件中的@Autowire注解进行处理, 使其生效.

