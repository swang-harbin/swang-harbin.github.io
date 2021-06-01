---
title: SpringAnnotation-03-@Scope设置组件作用域
date: '2020-02-18 00:00:00'
updated: '2020-02-18 00:00:00'
tags:
- spring-annotation
- spring
- java
categories:
- java
---

# SpringAnnotation-03-@Scope设置组件作用域

**Scope的值可以取4种 :**

- prototype: 多实例, 每次从容器中获取对象时, 均创建一个新的实例
- singleton: 单实例(默认值)

> 以下两种仅在web项目中可取 :

- request: 同一次请求创建一个实例
- session: 同一个session创建一个实例

## 设置scope的值

### 注解版

向容器中注入person对象, 将其设置为多实例

```java
package zone.wwwww.config;

import zone.wwwww.bean.Person;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Scope;

@Configuration
public class MainConfig {

    /**
     * @return
     * @see ConfigurableBeanFactory#SCOPE_PROTOTYPE prototype
     * @see ConfigurableBeanFactory#SCOPE_SINGLETON singleton
     * @see org.springframework.web.context.WebApplicationContext#SCOPE_REQUEST request
     * @see org.springframework.web.context.WebApplicationContext#SCOPE_SESSION session
     * <p>
     * prototype: 多实例
     * singleton: 单实例(默认值)
     * request: 同一次请求创建一个实例
     * session: 同一个session创建一个实例
     */
    @Scope("prototype")
    @Bean("person")
    public Person person() {
        return new Person("张三", 25);
    }
}
```

测试类IOCTest

```java
package zone.wwwww;

import zone.wwwww.config.MainConfig;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

public class IOCTest {
    public static void main(String[] args) {
        // 获取IOC容器
        ApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfig.class);
        Object bean = applicationContext.getBean("person");
        Object bean2 = applicationContext.getBean("person");
        System.out.println(bean.equals(bean2));
    }
}
```

测试类输出

```shell
false
```

### 配置文件版

修改beans.xml, 在bean标签中添加scope属性

```xml
<!-- scope包含prototype和singleton, 默认值为singleton, web项目应该包含另外两个, 未测试-->
<bean id="person" class="zone.wwwww.bean.Person" scope="prototype">
    <property name="age" value="18"></property>
    <property name="name" value="zhangsan"></property>
</bean>
```

测试类IOCTest

```java
package zone.wwwww;

import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;

public class IOCTest {
    public static void main(String[] args) {
        // 获取IOC容器
        ApplicationContext applicationContext = new ClassPathXmlApplicationContext("classpath:beans.xml");

        Object bean = applicationContext.getBean("person");
        Object bean2 = applicationContext.getBean("person");
        System.out.println(bean.equals(bean2));
    }
}
```

测试类输出

```
false
```

## singleton和prototype创建对象的时机

**scope为singleton时, IOC容器启动就会调用方法创建对象放到IOC容器中, 以后每次获取就是直接从容器中拿(map.get()).**

MainConfig.class

```java
@Configuration
public class MainConfig {
    @Scope
    @Bean("person")
    public Person person() {
        System.out.println("给容器中添加Person...");
        return new Person("张三", 25);
    }
}
```

IOCTest

```java
public class IOCTest {
    public static void main(String[] args) {
        // 获取IOC容器
        ApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfig.class);
    }
}
```

测试类输出

```
给容器中添加Person...
```

**scope为prototype时, IOC容器启动时并不会调用方法创建对象放在容器中, 而是在每次获取时调用方法创建对象, 并且每次获取都会调用一遍.**

修改MainConfig

```java
@Configuration
public class MainConfig {
    @Scope("prototype")
    @Bean("person")
    public Person person() {
        System.out.println("给容器中添加Person...");
        return new Person("张三", 25);
    }
}
```

执行该IOCTest

```java
public class IOCTest {
    public static void main(String[] args) {
        // 获取IOC容器
        ApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfig.class);
    }
}
```

程序并没有输出`给容器中添加Person...`

修改IOCTest, 获取person对象

```java
public class IOCTest {
    public static void main(String[] args) {
        // 获取IOC容器
        ApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfig.class);
        System.out.println("IOC容器创建完成...");
        // 创建对象
        Object bean = applicationContext.getBean("person");
        Object bean2 = applicationContext.getBean("person");
    }
}
```

程序输出

```
IOC容器创建完成...
给容器中添加Person...
给容器中添加Person...
```
