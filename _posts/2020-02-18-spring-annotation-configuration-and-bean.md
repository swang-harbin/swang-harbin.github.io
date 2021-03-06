---
layout: post
title: SpringAnnotation-01-@Configuration指定配置类&@Bean注册Bean
subheading: 
author: swang-harbin
categories: java
banner: 
tags: spring-annotation spring java
---

# SpringAnnotation-01-@Configuration指定配置类&@Bean注册Bean

环境:
- spring: 4.3.25.RELEASE
- jdk: 1.8

## 注册Bean

创建一个Person类

```java
package zone.wwwww.config;

public class Person {

    private String name;
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

### 注解方式

创建一个配置类MainConfig

```java
package zone.wwwww.config;

import zone.wwwww.bean.Person;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

// 配置类==配置文件
@Configuration  // 告诉Spring， 这是一个配置类
public class MainConfig {

    // 给容器中注册一个Bean; 类型为返回值类型
    @Bean(value = "person") // id默认是方法名, 可以通过value值指定id
    public Person person() {
        return new Person("lisi", 20);
    }
}
```

测试类

```java
import zone.wwwww.bean.Person;
import zone.wwwww.config.MainConfig;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

public class MainTest {
    public static void main(String[] args) {
        // 获取IOC容器
        ApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfig.class);
        // Person bean = (Person) applicationContext.getBean("person");  // 通过ID获取Bean
        Person bean = applicationContext.getBean(Person.class); // 根据类型获取Bean
        System.out.println(bean);
    }
}
```

```shell
Console:
Person{name='lisi', age=20}
```

### 配置文件方式

需要在类路径下创建一个beans.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd">

    <bean id="person" class="zone.wwwww.bean.Person">
        <property name="age" value="18"></property>
        <property name="name" value="zhangsan"></property>
    </bean>
</beans>
```

测试类

```java
package zone.wwwww;

import zone.wwwww.bean.Person;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;

public class MainTest {
    public static void main(String[] args) {
        // 获取IOC容器
        ApplicationContext applicationContext = new ClassPathXmlApplicationContext("classpath:beans.xml");
        Person bean = (Person) applicationContext.getBean("person");  // 通过ID获取Bean
        // Person bean = applicationContext.getBean(Person.class); // 根据类型获取Bean
        System.out.println(bean);
    }
}
```

```shell
Console: 
Person{name='zhangsan', age=18}
```


