---
title: Spring注解-@Value属性赋值
date: '2020-02-20 00:00:00'
tags:
- Spring
- Spring Annotation
- Java
categories:
- Java
- Spring注解系列
---

# Spring注解-@Value属性赋值

[跳到Spring注解系列目录](spring-anno-table.md)

修改MainConfig, 向容器中注入Person对象

```java
import icu.intelli.bean.Person;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class MainConfig {

    @Bean
    public Person person() {
        return new Person();
    }
}
```

使用IOCTest获取该Bean

```java
import icu.intelli.bean.Person;
import icu.intelli.config.MainConfig;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

public class IOCTest {

    public static void main(String[] args) {
        // 获取IOC容器
        AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfig.class);
        Person person = (Person) applicationContext.getBean("person");
        System.out.println(person);
    }
}
```

输出结果:

```
Person{name='null', age=null}
```

修改Person类, 添加@Value注解

```java
package icu.intelli.bean;

import org.springframework.beans.factory.annotation.Value;

public class Person {

    // 使用@Value赋值:
    // 1. 基本类型数值
    // 2. SpEL: #{}
    // 3. ${}: 取出配置文件中的值(在运行环境变量里面的值)
    @Value("张三")
    private String name;
    @Value("#{22-2}")
    private Integer age;

    public Person() {
    }

    public Person(String name, Integer age) {
        this.name = name;
        this.age = age;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Integer getAge() {
        return age;
    }

    public void setAge(Integer age) {
        this.age = age;
    }

    @Override
    public String toString() {
        return "Person{" +
                "name='" + name + '\'' +
                ", age=" + age +
                '}';
    }
}
```

执行IOCTest, 输出

```
Person{name='张三', age=20}
```

**配置文件版**

beans.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd">

    <bean id="person" class="icu.intelli.bean.Person">
        <property name="name" value="张三"/>
        <property name="age" value="#{20-2}"/>
    </bean>
</beans>
```

IOCTest

```java
package icu.intelli;

import icu.intelli.bean.Person;
import org.springframework.context.support.ClassPathXmlApplicationContext;

public class IOCTest {
    public static void main(String[] args) {
        // 获取IOC容器
        ClassPathXmlApplicationContext applicationContext = new ClassPathXmlApplicationContext("classpath:beans.xml");

        Person person = (Person) applicationContext.getBean("person");
        System.out.println(person);

    }
}
```

输出结果

```
Person{name='张三', age=18}
```
