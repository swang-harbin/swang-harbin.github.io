---
title: Spring 注解：@Import 给容器中快速导入一个组件
date: '2020-02-18 00:00:00'
tags:
- Spring
- Spring Annotation
- Java
---

# Spring 注解：`@Import` 给容器中快速导入一个组件

[Spring 注解系列目录](spring-anno-table.md)

## `@Import` 的基本使用

**`@Import(要导入到容器中的组件)`，容器中就会自动注册这个组件，id 默认是全类名.**

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
        // 获取 IOC 容器
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
        // 获取 IOC 容器
        ApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfig.class);

        // 获取容器中所有对象的名字
        String[] beanDefinitionNames = applicationContext.getBeanDefinitionNames();
        for (String beanDefinitionName : beanDefinitionNames) {
            System.out.println(beanDefinitionName);
        }
    }
}
```

**使用 `@Import`**

创建 Red 和 Blue 两个类

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

修改 MainConfig.java, 添加 `@Import`，向容器中注入 Red 和 Blue 两个类的对象

```java
package icu.intelli.config;

import icu.intelli.bean.Blue;
import icu.intelli.bean.Red;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;

/**
 * @Import 可接收一个 Class<?>[]
 */
@Import({Red.class, Blue.class})
@Configuration
public class MainConfig {

}
```

测试输出如下，Red 和 Blue 对象的名称是其全类名

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

## `@Import` 使用 `ImportSelector`

创建 Yellow 和 Green 两个类

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

创建 MyImportSelector 实现 ImportSelector 接口，返回包含 Yellow 和 Green 类的全类名的数组

```java
package icu.intelli.condition;

import org.springframework.context.annotation.ImportSelector;
import org.springframework.core.type.AnnotationMetadata;

// 自定义逻辑，返回需要注入容器的组件
public class MyImportSelector implements ImportSelector {

    /**
     * @param importingClassMetadata 标注 @Import 注解的类的所有注解信息
     * @return 需要注入到容器中的组件全类名
     */
    public String[] selectImports(AnnotationMetadata importingClassMetadata) {
        // 方法不要返回 null, 否则会出现 NullPointerException
        // 返回包含 Yellow 和 Green 类的全类名的数组即可将其添加到 IOC 容器中
        return new String[]{"icu.intelli.bean.Yellow", "icu.intelli.bean.Green"};
    }
}
```

修改 MainConfig.java，在 `@Import` 注解中添加 MyImportSelector 类

```java
@Import({Red.class, Blue.class, MyImportSelector.class})
@Configuration
public class MainConfig {
}
```

执行 IOCTest，程序输出如下，可见已将 Yellow 和 Green 注入到 IOC 容器中

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

## `@Import` 使用 `ImportBeanDefinitionRegistrar`

创建 RainBow 类

```java
package icu.intelli.bean;

public class RainBow {
}
```

创建 MyImportBeanDefinitionRegistrar 类实现 ImportBeanDefinitionRegistrar 接口

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
     * @param importingClassMetadata 当前标注 @Import 注解的类的所有注解信息
     * @param registry BeanDefinitionRegistry 注册类，把所有需要注册到容器中的 bean，调用
     */
    public void registerBeanDefinitions(AnnotationMetadata importingClassMetadata, BeanDefinitionRegistry registry) {
        // 判断容器中是否包含名称为 icu.intelli.bean.Red 和 icu.intelli.bean.Blue 组件
        boolean red = registry.containsBeanDefinition("icu.intelli.bean.Red");
        boolean blue = registry.containsBeanDefinition("icu.intelli.bean.Blue");
        if (red && blue){
            // 指定 Bean 的定义信息：Bean 的类型，Bean 的 Scope 等信息
            RootBeanDefinition beanDefinition = new RootBeanDefinition(RainBow.class);
            // 将该 Bean 注册到容器中，beanName 为 rainBow
            registry.registerBeanDefinition("rainBow", beanDefinition);
        }
    }
}
```

修改 MainConfig.java, 将 MyImportBeanDefinitionRegistrar 添加到 `@Import` 注解中

```java
@Import({Red.class, Blue.class, MyImportSelector.class, MyImportBeanDefinitionRegistrar.class})
@Configuration
public class MainConfig {
}
```

运行 IOCTest，程序输出如下，已将 rainBow 注册到 IOC 容器中

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
