---
title: Spring注解-@PropertySource加载外部配置文件
date: '2020-02-20 00:00:00'
tags:
- Spring
- Spring Annotation
- Java
categories:
- Java
- Spring注解系列
---

# Spring注解-@PropertySource加载外部配置文件

[跳到Spring注解系列目录](spring-anno-table.md)

为Person类添加nickName字段及其getter和setter方法, 并重写toString方法

```java
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

    private String nickName;

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

    public String getNickName() {
        return nickName;
    }

    public void setNickName(String nickName) {
        this.nickName = nickName;
    }

    @Override
    public String toString() {
        return "Person{" +
                "name='" + name + '\'' +
                ", age=" + age +
                ", nickName='" + nickName + '\'' +
                '}';
    }
}
```

执行IOCTest, 输出

```
Person{name='张三', age=20, nickName='null'}
```

在类路径下添加配置文件person.properties

```properties
person.nickName=小张三
```

**注解版**

导入person.properties配置文件, 修改MainConfig

```java
import icu.intelli.bean.Person;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;

// 使用@PropertySource读取外部配置文件中的属性, 保存到运行环境变量中, 使用${}即可获取到该值
@PropertySource({"classpath:/person.properties"})
@Configuration
public class MainConfig {

    @Bean
    public Person person() {
        return new Person();
    }
}
```

使用@Value注解给nickName属性赋值

```java
public class Person {

    // 使用@Value赋值:
    // 1. 基本类型数值
    // 2. SpEL: #{}
    // 3. ${}: 取出配置文件中的值(在运行环境变量里面的值)
    @Value("张三")
    private String name;
    @Value("#{22-2}")
    private Integer age;
    @Value("${person.nickName}")
    private String nickName;
```

测试IOCTest输出

```
Person{name='张三', age=20, nickName='小张三'}
```

**配置文件版**

修改beans.xml, 导入person.properties配置文件, 并使用property标签给nickName属性赋值

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd http://www.springframework.org/schema/context https://www.springframework.org/schema/context/spring-context.xsd">

    <!-- 引入外部配置文件, 注意需要引入context的名称空间 -->
    <context:property-placeholder location="classpath:/person.properties"/>

    <bean id="person" class="icu.intelli.bean.Person">
        <property name="name" value="张三"/>
        <property name="age" value="#{20-2}"/>
        <!-- 使用${}给nickName字段赋值 -->
        <property name="nickName" value="${person.nickName}"/>
    </bean>
</beans>
```

测试IOCTest输出

```
Person{name='张三', age=18, nickName='小张三'}
```

## 通过ConfigurableEnvironment获取运行环境变量中的值

IOCTest

```java
import icu.intelli.bean.Person;
import icu.intelli.config.MainConfig;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.core.env.ConfigurableEnvironment;

public class IOCTest {

    public static void main(String[] args) {
        // 获取IOC容器
        AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfig.class);
        ConfigurableEnvironment environment = applicationContext.getEnvironment();
        String nickName = environment.getProperty("person.nickName");
        System.out.println(nickName);
    }
}
```

测试输出

```
小张三
```

## PropertySources

PropertySource

```java
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Repeatable(PropertySources.class)
public @interface PropertySource {
```

PropertySources

```java
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface PropertySources {

	PropertySource[] value();

}
```

可以使用多个PropertySource引入多个配置文件, 也可以使用PropertySources引入多个PropertySource
