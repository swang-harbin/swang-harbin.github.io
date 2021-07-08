---
title: Spring 注解：自动装配总结
date: '2020-02-21 00:00:00'
tags:
- Spring
- Spring Annotation
- Java
---

# Spring 注解：自动装配总结

[Spring 注解系列目录](spring-anno-table.md)

## Spring 利用依赖注入（DI），完成对 IOC 容器中各个组件的依赖关系赋值

`@Autowired`：自动注入

1. 默认优先按照类型去容器中找对应的组件，找到即进行赋值
2. 如果找到多个相同的组件，再将属性的名称作为组件 id 去容器中查找
3. 可以结合 `@Qualifier` 指定需要装配的组件的 id，而不是使用属性名
4. 自动装配默认一定要对属性赋值，如果容器中没有该类型的 bean 就会报错；可以通过指定 `@Autowired` 的 required 属性为 false，使得如果容器中没有相应的 bean，就不装配
5. 可以使用 `@Primary` 注解，将 bean 设定为首选，此时 `@Autowired` 默认装配首选 Bean

## Spring 也支持 Java 规范的自动装配注解

- `@Resource`：JSR250 定义

  可以和`@Autowired` 一样实现自动装配；默认是按照属性名进行装配，可以使用 name 属性指定名称

  不支持 `@Primary` 功能和 `@Autowired` 的 require=false 功能

- `@Inject`：JSR330 定义

  需要导入 javax.inject 的包，和 `@Autowired` 功能一样，支持 `@Primary` 功能，但是不支持 `require=false` 的功能

## `@Autowired` 和 `@Resource`，`@Inject` 区别

`@Autowired` 是 Spring 定义的，`@Resource` 和 `@Inject` 是 Java 定义的

AutowiredAnnotationBeanPostProcessor：解析完成自动装配功能

## `@Autowired` 可以标注的不同位置

`@Autowired` 可以标注在：构造器，参数，方法，属性;

- 标注在属性位置
- 标注在方法位置
  - 标在方法上，Spring 容器创建当前对象，就会调用该方法，完成赋值
  - 方法的参数，自定义类型的值从 ioc 容器中获取
- 标注在构造器位置
  - 默认加在 ioc 容器中的组件，容器启动会调用无参构造器创建对象，在进行初始化赋值等操作.
  - 可以标在有参构造器上，此时构造器要用的组件（参数），也是从容器中获取
  - 如果组件中只有一个有参构造器，可以省略 `@Autowired` 注解，效果不变
- 标注在参数位置
  - 可以标注在有参构造器参数上，效果与标注在有参构造器上一样
  - 可以标注在 `@Bean` 标注的方法的参数上，会从 ioc 容器中获取该参数的值，可通过 set 方法为返回的 bean 赋值

## 自定义组件想要使用 Spring 容器底层的一些组件

例如向自定义组件中注入 ApplicationContext，BeanFactory 等

只需要让自定义组件实现 xxxAware 接口即可，在创建对象的时候，会调用该接口规定的方法，注入 Spring 容器底层的组件

**Aware 接口的子接口：**

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210116002846.png)

- ApplicationContextAware：注入 IOC 容器
- ApplicationEventPublisherAware：注入事件派发器
- BeanClassLoaderAware：注入类加载器
- ......

**xxxAware 功能的实现是 xxxAwareProcessor 完成的**

## `@Profile` 注解的使用

`@Profile` 指定组件在哪个环境的情况下才能被注册到容器中，默认不指定，则在任何环境下均注册这个组件

1. 加了环境标识的 bean，只有这个环境被激活的时候才能被注册到容器中。默认是 default 环境
2. 写在配置类上，只有是指定环境的时候，整个配置类里面的所有配置才会开始生效
3. 没有标注环境标识的 bean，在任何环境下都是加载的

**激活环境的方式：**

1. 在启动时添加动态参数
2. 使用代码创建 applicaitonContext 的方式设置
