---
title: Spring注解-使用FactoryBean接口注册组件
date: '2020-02-18 00:00:00'
tags:
- Spring
- Spring Annotation
- Java
categories:
- Java
- Spring注解系列
---

# Spring注解-使用FactoryBean接口注册组件

[跳到Spring注解系列目录](spring-anno-table.md)

创建Color.java类

```java
package icu.intelli.bean;

public class Color {
}
```

创建ColorFactoryBean类实现FactoryBean接口

```java
package icu.intelli.bean;

import org.springframework.beans.factory.FactoryBean;

// 创建一个Spring定义的FactoryBean
public class ColorFactoryBean implements FactoryBean<Color> {

    // 返回一个Color对象, 这个对象会添加到容器中
    public Color getObject() throws Exception {
        System.out.println("调用了ColorFactoryBean.getObject()...");
        return new Color();
    }

    public Class<?> getObjectType() {
        return Color.class;
    }

    // 是否单例, true: 单实例, 在容器中保存一份; false: 多实例, 每次获取都创建一个新对象(通过调用getObject方法)
    public boolean isSingleton() {
        return false;
    }
}
```

修改MainConfig, 将ColorFactoryBean注册到容器中

```java
package icu.intelli.config;

import icu.intelli.bean.ColorFactoryBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class MainConfig {

    @Bean
    public ColorFactoryBean colorFactoryBean(){
        return new ColorFactoryBean();
    }
}
```

修改IOCTest

```java
package icu.intelli;

import icu.intelli.config.MainConfig;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

public class IOCTest {
    public static void main(String[] args) {
        // 获取IOC容器
        ApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfig.class);

        // 获取容器中所有对象的名字
        String[] beanDefinitionNames = applicationContext.getBeanDefinitionNames();
        for (String beanDefinitionName : beanDefinitionNames) {
            System.out.println(beanDefinitionName);
        }

        // 根据bean名称获取colorFactoryBean
        Object bean1 = applicationContext.getBean("colorFactoryBean");
        System.out.println("bean1的类型为: " + bean1.getClass());
        // 根据bean名称获取colorFactoryBean
        Object bean2 = applicationContext.getBean("colorFactoryBean");
        System.out.println("bean1 == bean2: " + (bean1 == bean2));

        // 添加&前缀, 获取容器中ColorFactoryBean的实例
        Object bean3 = applicationContext.getBean("&colorFactoryBean");
        System.out.println("bean3的类型为: " + bean3.getClass());

    }
}
```

运行IOCTest, 结果如下

```
org.springframework.context.annotation.internalConfigurationAnnotationProcessor
org.springframework.context.annotation.internalAutowiredAnnotationProcessor
org.springframework.context.annotation.internalRequiredAnnotationProcessor
org.springframework.context.annotation.internalCommonAnnotationProcessor
org.springframework.context.event.internalEventListenerProcessor
org.springframework.context.event.internalEventListenerFactory
mainConfig
colorFactoryBean
调用了ColorFactoryBean.getObject()...
bean1的类型为: class icu.intelli.bean.Color
调用了ColorFactoryBean.getObject()...
bean1 == bean2: false
bean3的类型为: class icu.intelli.bean.ColorFactoryBean
```

**分析**

由于ColorFactoryBean中isSingleton返回false, 因此使用多例模式, 执行了两次getObject()方法, 两个对象bean1与bean2不相等

直接通过beanName:colorFactoryBean获取到的bean类型为Color类型

如果需要获取ColorFactoryBean类型的对象, 需要在beanName前添加一个&前缀, 即&colorFactoryBean. 是因为在BeanFactory接口中包含如下变量

```java
public interface BeanFactory {
	/**
	 * Used to dereference a {@link FactoryBean} instance and distinguish it from
	 * beans <i>created</i> by the FactoryBean. For example, if the bean named
	 * {@code myJndiObject} is a FactoryBean, getting {@code &myJndiObject}
	 * will return the factory, not the instance returned by the factory.
	 */
	String FACTORY_BEAN_PREFIX = "&";
}
```



