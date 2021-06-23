---
title: Spring 注解：向容器中注册组件的方式总结
date: '2020-02-18 00:00:00'
tags:
- Spring
- Spring Annotation
- Java
---

# Spring 注解：向容器中注册组件的方式总结

[Spring 注解系列目录](spring-anno-table.md)

1. 包扫描 + 组件标注注解（`@Controller`/`@Service`/`@Repository`/`@Component`）【仅适用于自己写的类】

2. `@Bean`【可用于导入第三包里面的组件】

3. `@Import`【快速给容器中导入一个组件】

   ```java
   public @interface Import {
   /**
    * {@link Configuration}, {@link ImportSelector}, {@link ImportBeanDefinitionRegistrar}
    * or regular component classes to import.
    */
   Class<?>[] value();
   }
   ```

   1. `{@link Configuration}`：Configuration 为需要注入到容器中的类，Spring 会自动将这个组件注入到容器，id 默认是全类名。id 默认是全类名。
   2. `{@link ImportSelector}`：将返回数组中包含的组件注入到容器中，SpringBoot 中使用该方式较多
   3. `{@link ImportBeanDefinitionRegistrar}`：手动注册 Bean 到容器中

4. 使用 Spring 提供的 FactoryBean

   1. 默认获取的是工厂 Bean 调用 `getObject()` 方法创建的对象
   2. 要获取工厂 Bean 本身，需要给 id 前面加一个 `&` 标识
