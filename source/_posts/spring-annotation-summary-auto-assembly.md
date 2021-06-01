---
title: SpringAnnotation-24-自动装配总结
date: '2020-02-21 00:00:00'
updated: '2020-02-21 00:00:00'
tags:
- spring-annotation
- spring
- java
categories:
- java
---

# SpringAnnotation-24-自动装配总结

## 一. Spring利用依赖注入(DI), 完成对IOC容器中各个组件的依赖关系赋值

1. @Autowired: 自动注入
   1. 默认优先按照类型去容器中找对应的组件, 找到即进行赋值
   2. 如果找到多个相同的组件, 再将属性的名称作为组件id去容器中查找
   3. 可以结合@Qualifier指定需要装配的组件的id, 而不是使用属性名
   4. 自动装配默认一定要对属性赋值, 如果容器中没有该类型的bean就会报错; 可以通过指定@Autowired的required属性为false, 使得如果容器中没有相应的bean, 就不装配
   5. 可以使用@Primary注解, 将bean设定为首选, 此时@Autowired默认装配首选Bean

## 二. Spring也支持Java规范的自动装配注解

- @Resource: JSR250定义

  > 可以和@Autowired一样实现自动装配; 默认是按照属性名进行装配, 可以使用name属性指定名称
  > 不支持@Primary功能和@Autowired的require=false功能

- @Inject: JSR330定义

  > 需要导入javax.inject的包, 和Autowired功能一样, 支持@Primary功能, 但是不支持require=false的功能

## 三. @Autowired和@Resource, @Inject区别

@Autowired是Spring定义的, @Resource和@Inject是Java定义的

AutowiredAnnotationBeanPostProcessor: 解析完成自动装配功能

## 四. @Autowired可以标注的不同位置

@Autowired可以标注在: 构造器, 参数, 方法, 属性;

- 标注在属性位置

- 标注在方法位置:

  > 标在方法上, Spring容器创建当前对象, 就会调用该方法, 完成赋值
  >
  > 方法的参数, 自定义类型的值从ioc容器中获取

- 标注在构造器位置

  > 默认加在ioc容器中的组件, 容器启动会调用无参构造器创建对象, 在进行初始化赋值等操作.
  >
  > 可以标在有参构造器上, 此时构造器要用的组件(参数), 也是从容器中获取
  >
  > 如果组件中只有一个有参构造器, 可以省略@Autowired注解, 效果不变

- 标注在参数位置

  > 可以标注在有参构造器参数上, 效果与标注在有参构造器上一样
  >
  > 可以标注在@Bean标注的方法的参数上, 会从ioc容器中获取该参数的值, 可通过set方法为返回的bean赋值

## 五. 自定义组件想要使用Spring容器底层的一些组件

例如向自定义组件中注入ApplicationContext, BeanFactory等

只需要让自定义组件实现xxxAware接口即可, 在创建对象的时候, 会调用该接口规定的方法, 注入Spring容器底层的组件

**Aware接口的子接口 :**

![](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210116002846.png)

- ApplicationContextAware: 注入IOC容器
- ApplicationEventPublisherAware: 注入事件派发器
- BeanClassLoaderAware: 注入类加载器
- ......

**xxxAware功能的实现是xxxAwareProcessor完成的**

## 六. @Profile注解的使用

@Profile指定组件在哪个环境的情况下才能被注册到容器中, 默认不指定, 则在任何环境下均注册这个组件

1. 加了环境标识的bean, 只有这个环境被激活的时候才能被注册到容器中. 默认是default环境
2. 写在配置类上, 只有是指定环境的时候, 整个配置类里面的所有配置才会开始生效
3. 没有标注环境标识的bean, 在任何环境下都是加载的

**激活环境的方式 :**

1. 在启动时添加动态参数
2. 使用代码创建applicaitonContext的方式设置
