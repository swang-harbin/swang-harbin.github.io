---
title: Spring注解-@Import给容器中快速导入一个组件
date: '2020-02-18 00:00:00'
tags:
- Spring
- Spring Annotation
- Java
categories:
- Java
- Spring注解系列
---

# Spring注解-@Import给容器中快速导入一个组件

[跳到Spring注解系列目录](spring-anno-table.md)

## @Import的基本使用

**@Import(要导入到容器中的组件), 容器中就会自动注册这个组件, id默认是全类名.**

**初始环境**

MainConfig.java

```java
package icu.intelli.config;

import org.springframework.context.annotation.Configuration;

@Configuration
public class MainConfig {

}
```

IOCTest.java

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
    }
}
```

测试输出

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
    }
}
```

**使用@Import**

创建Red和Blue两个类

Red.java

```java
package icu.intelli.bean;

public class Red {
}
```

Blue.java

```java
package icu.intelli.bean;

public class Blue {
}
```

修改MainConfig.java, 添加@Import, 向容器中注入Red和Blue两个类的对象

```java
package icu.intelli.config;

import icu.intelli.bean.Blue;
import icu.intelli.bean.Red;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;

/**
 * @Import 可接收一个Class<?>[]
 */
@Import({Red.class, Blue.class})
@Configuration
public class MainConfig {

}
```

测试输出如下, Red和Blue对象的名称是其全类名

```
org.springframework.context.annotation.internalConfigurationAnnotationProcessor
org.springframework.context.annotation.internalAutowiredAnnotationProcessor
org.springframework.context.annotation.internalRequiredAnnotationProcessor
org.springframework.context.annotation.internalCommonAnnotationProcessor
org.springframework.context.event.internalEventListenerProcessor
org.springframework.context.event.internalEventListenerFactory
mainConfig
icu.intelli.bean.Red
icu.intelli.bean.Blue
```

## @Import使用ImportSelector

创建Yellow和Green两个类

- Yellow.java

  ```java
  package icu.intelli.bean;
  
  public class Yellow {
  }
  ```

- Green.java

  ```java
  package icu.intelli.bean;
  
  public class Green {
  }
  ```

创建MyImportSelector实现ImportSelector接口, 返回包含Yellow和Green类的全类名的数组

```java
package icu.intelli.condition;

import org.springframework.context.annotation.ImportSelector;
import org.springframework.core.type.AnnotationMetadata;

// 自定义逻辑, 返回需要注入容器的组件
public class MyImportSelector implements ImportSelector {

    /**
     * @param importingClassMetadata 标注@Import注解的类的所有注解信息
     * @return 需要注入到容器中的组件全类名
     */
    public String[] selectImports(AnnotationMetadata importingClassMetadata) {
        // 方法不要返回null, 否则会出现NullPointerException
        // 返回包含Yellow和Green类的全类名的数组即可将其添加到IOC容器中
        return new String[]{"icu.intelli.bean.Yellow", "icu.intelli.bean.Green"};
    }
}
```

修改MainConfig.java, 在@Import注解中添加MyImportSelector类

```java
@Import({Red.class, Blue.class, MyImportSelector.class})
@Configuration
public class MainConfig {
}
```

执行IOCTest, 程序输出如下, 可见已将Yellow和Green注入到IOC容器中

```
org.springframework.context.annotation.internalConfigurationAnnotationProcessor
org.springframework.context.annotation.internalAutowiredAnnotationProcessor
org.springframework.context.annotation.internalRequiredAnnotationProcessor
org.springframework.context.annotation.internalCommonAnnotationProcessor
org.springframework.context.event.internalEventListenerProcessor
org.springframework.context.event.internalEventListenerFactory
mainConfig
icu.intelli.bean.Red
icu.intelli.bean.Blue
icu.intelli.bean.Yellow
icu.intelli.bean.Green
```

## @Import使用ImportBeanDefinitionRegistrar

创建RainBow类

```java
package icu.intelli.bean;

public class RainBow {
}
```

创建MyImportBeanDefinitionRegistrar类实现ImportBeanDefinitionRegistrar接口

```java
package icu.intelli.condition;

import icu.intelli.bean.RainBow;
import org.springframework.beans.factory.support.BeanDefinitionRegistry;
import org.springframework.beans.factory.support.RootBeanDefinition;
import org.springframework.context.annotation.ImportBeanDefinitionRegistrar;
import org.springframework.core.type.AnnotationMetadata;

public class MyImportBeanDefinitionRegistrar implements ImportBeanDefinitionRegistrar {

    /**
     *
     * @param importingClassMetadata 当前标注@Import注解的类的所有注解信息
     * @param registry BeanDefinitionRegistry注册类, 把所有需要注册到容器中的bean, 调用
     */
    public void registerBeanDefinitions(AnnotationMetadata importingClassMetadata, BeanDefinitionRegistry registry) {
        // 判断容器中是否包含名称为icu.intelli.bean.Red和icu.intelli.bean.Blue组件
        boolean red = registry.containsBeanDefinition("icu.intelli.bean.Red");
        boolean blue = registry.containsBeanDefinition("icu.intelli.bean.Blue");
        if (red && blue){
            // 指定Bean的定义信息: Bean的类型, Bean的Scope等信息
            RootBeanDefinition beanDefinition = new RootBeanDefinition(RainBow.class);
            // 将该Bean注册到容器中, beanName为rainBow
            registry.registerBeanDefinition("rainBow", beanDefinition);
        }
    }
}
```

修改MainConfig.java, 将MyImportBeanDefinitionRegistrar添加到@Import注解中

```java
@Import({Red.class, Blue.class, MyImportSelector.class, MyImportBeanDefinitionRegistrar.class})
@Configuration
public class MainConfig {
}
```

运行IOCTest, 程序输出如下, 已将rainBow注册到IOC容器中

```
org.springframework.context.annotation.internalConfigurationAnnotationProcessor
org.springframework.context.annotation.internalAutowiredAnnotationProcessor
org.springframework.context.annotation.internalRequiredAnnotationProcessor
org.springframework.context.annotation.internalCommonAnnotationProcessor
org.springframework.context.event.internalEventListenerProcessor
org.springframework.context.event.internalEventListenerFactory
mainConfig
icu.intelli.bean.Red
icu.intelli.bean.Blue
icu.intelli.bean.Yellow
icu.intelli.bean.Green
icu.intelli.bean.RainBow
```
