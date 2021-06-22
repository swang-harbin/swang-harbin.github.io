---
title: Spring注解-向容器中注册组件的方式总结
date: '2020-02-18 00:00:00'
tags:
- Spring
- Spring Annotation
- Java
categories:
- Java
- Spring注解系列
---

# Spring注解-向容器中注册组件的方式总结

[跳到Spring注解系列目录](spring-anno-table.md)

1. 包扫描+组件标注注解(@Controller/@Service/@Repository/@Component) [仅适用于自己写的类]

2. @Bean [可用于导入第三包里面的组件]

3. @Import [快速给容器中导入一个组件]

   ```java
   public @interface Import {
   /**
    * {@link Configuration}, {@link ImportSelector}, {@link ImportBeanDefinitionRegistrar}
    * or regular component classes to import.
    */
   Class<?>[] value();
   }
   ```

   1. {@link Configuration} : Configuration为需要注入到容器中的类, Spring会自动将这个组件注入到容器, id默认是全类名. id默认是全类名.
   2. {@link ImportSelector} : 将返回数组中包含的组件注入到容器中, SpringBoot中使用该方式较多
   3. {@link ImportBeanDefinitionRegistrar} : 手动注册Bean到容器中

4. 使用Spring提供的FactoryBean

   1. 默认获取的是工厂Bean调用getObject()方法创建的对象
   2. 要获取工厂Bean本身, 需要给id前面加一个&标识
