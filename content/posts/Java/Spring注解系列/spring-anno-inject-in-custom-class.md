---
title: Spring 注解：向自定义组件中注入 Spring 底层组件及原理
date: '2020-02-21 00:00:00'
tags:
- Spring
- Spring Annotation
- Java
---

# Spring 注解：向自定义组件中注入 Spring 底层组件及原理

[Spring 注解系列目录](spring-anno-table.md)

如需向自定义组件中注入 ApplicationContext，BeanFactory 等 Spring 底层组件，只需要让自定义组件实现 xxxAware 接口即可，在创建对象的时候，会调用该接口规定的方法，注入 Spring 容器底层的组件

## 为 Red 类注入一些 Spring 底层组件

让 red 类实现需要的 xxxAware 接口即可，如需在其他方法中使用，可将其赋值给全局变量

```java
package icu.intelli.bean;

import org.springframework.beans.BeansException;
import org.springframework.beans.factory.BeanNameAware;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.context.EmbeddedValueResolverAware;
import org.springframework.stereotype.Component;
import org.springframework.util.StringValueResolver;

@Component
public class Red implements ApplicationContextAware, BeanNameAware, EmbeddedValueResolverAware {

    private ApplicationContext applicationContext;

    private StringValueResolver stringValueResolver;

    // 获取 ioc 容器
    public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
        System.out.println("传入的 ioc:" + applicationContext);
        this.applicationContext = applicationContext;
    }

    // 获取当前 bean 的名字
    public void setBeanName(String name) {
        System.out.println("当前 bean 的名字" + name);
    }

    // StringValueResolver, 用来解析字符串中的占位符
    public void setEmbeddedValueResolver(StringValueResolver resolver) {
        String str = resolver.resolveStringValue("你好${os.name}, 我是#{300+60}");
        System.out.println("解析后的字符串: " + str);
        this.stringValueResolver = resolver;
    }
}
```

MainConfig

```java
package icu.intelli.config;

import icu.intelli.bean.Boss;
import icu.intelli.bean.Car;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;


@Configuration
@ComponentScan({"icu.intelli.bean"})
public class MainConfig {

}
```

IOCTest

```java
package icu.intelli;

import icu.intelli.config.MainConfig;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

public class IOCTest {

    public static void main(String[] args) {
        // 获取 IOC 容器
        AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfig.class);

        System.out.println("测试类中获取的 ioc 容器: " + applicationContext);
    }
}
```

测试输出

```
当前 bean 的名字 red
解析后的字符串：你好 Linux, 我是 360
传入的 ioc:org.springframework.context.annotation.AnnotationConfigApplicationContext@300ffa5d: startup date [Fri Mar 13 14:19:51 CST 2020]; root of context hierarchy
测试类中获取的 ioc 容器: org.springframework.context.annotation.AnnotationConfigApplicationContext@300ffa5d: startup date [Fri Mar 13 14:19:51 CST 2020]; root of context hierarchy
```

获取到的 IOC 容器就是当前的 SpringIOC 容器

## 原理

**对 xxxAware 接口方法的调用是 xxxAwareProcessor 来完成的**

以 ApplicationContextAware 为例，执行流程如下：

1. 在 Red 类的 setApplicationContext 中打断点, debug 启动

2. 执行 ApplicationContextProcessor 的 postProcessBeforeInitialization 方法

   ```java
   public Object postProcessBeforeInitialization(final Object bean, String beanName) throws BeansException {
       AccessControlContext acc = null;
   
       if (System.getSecurityManager() != null &&
           (bean instanceof EnvironmentAware || bean instanceof EmbeddedValueResolverAware ||
            bean instanceof ResourceLoaderAware || bean instanceof ApplicationEventPublisherAware ||
            bean instanceof MessageSourceAware || bean instanceof ApplicationContextAware)) {
           acc = this.applicationContext.getBeanFactory().getAccessControlContext();
       }
   
       if (acc != null) {
           AccessController.doPrivileged(new PrivilegedAction<Object>() {
               @Override
               public Object run() {
                   invokeAwareInterfaces(bean);
                   return null;
               }
           }, acc);
       }
       else {
           invokeAwareInterfaces(bean);
       }
   
       return bean;
   }
   ```

3. 调用 invokeAwareInterfaces 方法，回调相应的 set 方法注入 Spring 底层 Bean

   ```java
   private void invokeAwareInterfaces(Object bean) {
       if (bean instanceof Aware) {
           if (bean instanceof EnvironmentAware) {
               ((EnvironmentAware) bean).setEnvironment(this.applicationContext.getEnvironment());
           }
           if (bean instanceof EmbeddedValueResolverAware) {
               ((EmbeddedValueResolverAware) bean).setEmbeddedValueResolver(this.embeddedValueResolver);
           }
           if (bean instanceof ResourceLoaderAware) {
               ((ResourceLoaderAware) bean).setResourceLoader(this.applicationContext);
           }
           if (bean instanceof ApplicationEventPublisherAware) {
               ((ApplicationEventPublisherAware) bean).setApplicationEventPublisher(this.applicationContext);
           }
           if (bean instanceof MessageSourceAware) {
               ((MessageSourceAware) bean).setMessageSource(this.applicationContext);
           }
           if (bean instanceof ApplicationContextAware) {
               ((ApplicationContextAware) bean).setApplicationContext(this.applicationContext);
           }
       }
   }
   ```

   

