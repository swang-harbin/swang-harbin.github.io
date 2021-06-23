---
title: Spring 注解：@ComponentScan 包扫描 & 指定扫描规则
date: '2020-02-18 00:00:00'
tags:
- Spring
- Spring Annotation
- Java
---
# Spring 注解：`@ComponentScan` 包扫描 & 指定扫描规则

[Spring 注解系列目录](spring-anno-table.md)

创建 BookController，BookService，BookDao，并分别使用`@Controller`，`@Service`，`@Repository`注解标注

- BookController

    ```java
    package icu.intelli.controller;

    import org.springframework.stereotype.Controller;

    @Controller
    public class BookController {
    }
    ```

- BookService

    ```java
    package icu.intelli.service;

    import org.springframework.stereotype.Service;

    @Service
    public class BookService {
    }
    ```

- BookDao

    ```java
    package icu.intelli.dao;
    
    import org.springframework.stereotype.Repository;
    
    @Repository
    public class BookDao {
    }
    ```

## 注解版

在 MainConfig 类上添加 `@ComponentScan` 注解

```java
package icu.intelli.config;

import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;

@Configuration
// 扫描 icu.intelli 及其子包，将被@Controller，@Service，@Repository，@Component 标注的组件扫描到容器
@ComponentScan(value = "icu.intelli")
public class MainConfig {

}
```

测试类

```java
import icu.intelli.config.MainConfig;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

public class IOCTest {
    public static void main(String[] args) {
        // 获取 IOC 容器
        ApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfig.class);
        // 获取容器中所有 Bean 的名字
        String[] beanDefinitionNames = applicationContext.getBeanDefinitionNames();
        for (String beanDefinitionName : beanDefinitionNames) {
            System.out.println(beanDefinitionName);
        }
    }
}
```

控制台输出

```
org.springframework.context.annotation.internalConfigurationAnnotationProcessor
org.springframework.context.annotation.internalAutowiredAnnotationProcessor
org.springframework.context.annotation.internalRequiredAnnotationProcessor
org.springframework.context.annotation.internalCommonAnnotationProcessor
org.springframework.context.event.internalEventListenerProcessor
org.springframework.context.event.internalEventListenerFactory
mainConfig
bookController
bookDao
bookService
person
```

## 配置文件版

beans.xml 中添加 `context:component-scan` 标签

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd">

    <!-- 包扫描，只要标注了@Controller，@Service，@Repository，@Component -->
    <context:component-scan base-package="icu.intelli"/>

    <bean id="person" class="icu.intelli.bean.Person">
    <property name="age" value="18"></property>
    <property name="name" value="zhangsan"></property>
    </bean>
</beans>
```

测试类

```java
package icu.intelli;

import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;

public class IOCTest {
    public static void main(String[] args) {
        // 获取 IOC 容器
        ApplicationContext applicationContext = new ClassPathXmlApplicationContext("classpath:beans.xml");
        // 获取容器中所有 Bean 的名字
        String[] beanDefinitionNames = applicationContext.getBeanDefinitionNames();
        for (String beanDefinitionName : beanDefinitionNames) {
            System.out.println(beanDefinitionName);
        }
    }
}
```

```bash
bookController
bookDao
bookService
org.springframework.context.annotation.internalConfigurationAnnotationProcessor
org.springframework.context.annotation.internalAutowiredAnnotationProcessor
org.springframework.context.annotation.internalRequiredAnnotationProcessor
org.springframework.context.annotation.internalCommonAnnotationProcessor
org.springframework.context.event.internalEventListenerProcessor
org.springframework.context.event.internalEventListenerFactory
person
```

## `@ComponentScan` 使用 `excludeFilters` 属性排除指定类

### 注解版

修改 MainConfig，修改 `@ComponentScan` 注解

```java
package icu.intelli.config;

import icu.intelli.bean.Person;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.FilterType;
import org.springframework.stereotype.Controller;
import org.springframework.stereotype.Service;

@Configuration
// 扫描 icu.intelli 包及其所有子包，过滤掉被 Controller 注解和 Service 注解标注的类
@ComponentScan(value = "icu.intelli", excludeFilters = {
// FilterType 包含 ANNOTATION，ASSIGNABLE_TYPE，ASPECTJ，REGEX，CUSTOM，默认值是 ANNOTATION
@ComponentScan.Filter(type = FilterType.ANNOTATION, classes = {Controller.class, Service.class})
})
public class MainConfig {

    @Bean(value = "person")
    public Person person() {
        return new Person("lisi", 20);
    }
}
```

使用 IOCTest 类测试，控制台输出如下，bookController 和 bookService 并没有扫描到 IOC 容器中

```bash
org.springframework.context.annotation.internalConfigurationAnnotationProcessor
org.springframework.context.annotation.internalAutowiredAnnotationProcessor
org.springframework.context.annotation.internalRequiredAnnotationProcessor
org.springframework.context.annotation.internalCommonAnnotationProcessor
org.springframework.context.event.internalEventListenerProcessor
org.springframework.context.event.internalEventListenerFactory
mainConfig
bookDao
person
```

### 配置文件版

修改 beans.xml，在 `context:component-scan` 标签中添加 `context:exclude-filter` 标签

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:context="http://www.springframework.org/schema/context"
xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd http://www.springframework.org/schema/context https://www.springframework.org/schema/context/spring-context.xsd">

    <context:component-scan base-package="icu.intelli">
        <!-- 排除被 Controller 和 Service 注解标记的类 -->
        <!-- type 类型包括 annotation，assignable，aspectj，regex，custom-->
        <context:exclude-filter type="annotation" expression="org.springframework.stereotype.Controller"/>
        <context:exclude-filter type="annotation" expression="org.springframework.stereotype.Service"/>
    </context:component-scan>
    
    <bean id="person" class="icu.intelli.bean.Person">
        <property name="age" value="18"></property>
        <property name="name" value="zhangsan"></property>
    </bean>
</beans>
```

使用 IOCTest 类测试，控制台输出如下，bookController 和 bookService 并没有扫描到 IOC 容器中

```bash
bookDao
org.springframework.context.annotation.internalConfigurationAnnotationProcessor
org.springframework.context.annotation.internalAutowiredAnnotationProcessor
org.springframework.context.annotation.internalRequiredAnnotationProcessor
org.springframework.context.annotation.internalCommonAnnotationProcessor
org.springframework.context.event.internalEventListenerProcessor
org.springframework.context.event.internalEventListenerFactory
person
```

## `@ComponentScan` 使用 includeFilters 属性引入指定类

### 注解版

修改 MainConfig，修改 `@ComponentScan` 注解，使用 `includeFilters` 属性，并将 `useDefaultFilters` 属性设置为 `false`

```java
package icu.intelli.config;

import icu.intelli.bean.Person;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.FilterType;
import org.springframework.stereotype.Controller;
import org.springframework.stereotype.Service;

@Configuration
// 扫描 icu.intelli 包及其所有子包，扫描时只扫描被 Controller 注解和 Service 注解标注的类
@ComponentScan(value = "icu.intelli", includeFilters = {
// FilterType 包含 ANNOTATION，ASSIGNABLE_TYPE，ASPECTJ，REGEX，CUSTOM，默认值是 ANNOTATION
@ComponentScan.Filter(type = FilterType.ANNOTATION, classes = {Controller.class, Service.class})
},
// 不使用默认的扫描规则
useDefaultFilters = false)
public class MainConfig {

    @Bean(value = "person")
    public Person person() {
        return new Person("lisi", 20);
    }
}
```

使用 IOCTest 类测试，控制台输出如下，bookController 和 bookService 被扫描到 IOC 容器中，而 bookDao 没有被扫描到 IOC 容器

```bash
org.springframework.context.annotation.internalConfigurationAnnotationProcessor
org.springframework.context.annotation.internalAutowiredAnnotationProcessor
org.springframework.context.annotation.internalRequiredAnnotationProcessor
org.springframework.context.annotation.internalCommonAnnotationProcessor
org.springframework.context.event.internalEventListenerProcessor
org.springframework.context.event.internalEventListenerFactory
mainConfig
bookController
bookService
person
```

### 配置文件版

修改 beans.xml，在 `context:component-scan` 标签中添加 `use-default-filters="false"` 属性和 `context:include-filter` 标签

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:context="http://www.springframework.org/schema/context"
xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd http://www.springframework.org/schema/context https://www.springframework.org/schema/context/spring-context.xsd">

    <!-- use-default-filters="false"，不使用默认的扫描规则 -->
    <context:component-scan base-package="icu.intelli" use-default-filters="false">
        <!-- 只扫描被 Controller 和 Service 注解标注的类 -->
        <context:include-filter type="annotation" expression="org.springframework.stereotype.Controller"/>
        <context:include-filter type="annotation" expression="org.springframework.stereotype.Service"/>
    </context:component-scan>
    
    <bean id="person" class="icu.intelli.bean.Person">
        <property name="age" value="18"></property>
        <property name="name" value="zhangsan"></property>
    </bean>
</beans>
```

使用 IOCTest 类测试，控制台输出如下，bookController 和 bookService 被扫描到 IOC 容器中，而 bookDao 没有被扫描到 IOC 容器

```bash
bookController
bookService
org.springframework.context.annotation.internalConfigurationAnnotationProcessor
org.springframework.context.annotation.internalAutowiredAnnotationProcessor
org.springframework.context.annotation.internalRequiredAnnotationProcessor
org.springframework.context.annotation.internalCommonAnnotationProcessor
org.springframework.context.event.internalEventListenerProcessor
org.springframework.context.event.internalEventListenerFactory
person
```

## `ComponentScan` 重复注解

JDK8 提供了 `@Repeatable` 注解，表明可以在一个类上使用多个 `@ComponentScan`，定义多个过滤规则

```java
@Repeatable(ComponentScans.class)
public @interface ComponentScan {
```

可能需要在 pom.xml 中指定 maven 使用的 jdk 版本

```xml
<build>
    <plugins>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-compiler-plugin</artifactId>
            <configuration>
                <source>1.8</source>
                <target>1.8</target>
            </configuration>
        </plugin>
    </plugins>
</build>
```

此时在 Mainonfig 上使用多个 `@ComponentScan` 注解并不会报错

```java
@ComponentScan()
@ComponentScan()
public class MainConfig {
```

如果使用的 JDK 版本小于 8，可使用 `@ComponentScans` 注解达到同样的效果

```java
@ComponentScans(value = {
    @ComponentScan(),
    @ComponentScan()
})
public class MainConfig {
```

## FilterType 类型

**FilterType 包含：**

- ANNOTATION：按照注解，默认值
- ASSIGNABLE_TYPE：按照给定的类型，包括实现类
- ASPECTJ：使用 ASPECTJ 表达式
- REGEX：使用正则表达式
- CUSTOM：自定义规则

## 自定义（CUSTOM）TypeFilter 的使用

### 注解版

定义一个 MyTypeFilter 实现 TypeFilter 接口，输出`--->类名`，如果类名中包含“er”，返回 true，否则返回 false，即 XxxService，Person 等返回 true

```java
package icu.intelli.typefilter;

import org.springframework.core.io.Resource;
import org.springframework.core.type.AnnotationMetadata;
import org.springframework.core.type.ClassMetadata;
import org.springframework.core.type.classreading.MetadataReader;
import org.springframework.core.type.classreading.MetadataReaderFactory;
import org.springframework.core.type.filter.TypeFilter;

import java.io.IOException;

public class MyTypeFilter implements TypeFilter {
    /**
    * @param metadataReader 读取到当前正在扫描的类信息
    * @param metadataReaderFactory 可以获取到其他任何类信息的
    * @return
    * @throws IOException
    */
    @Override
    public boolean match(MetadataReader metadataReader, MetadataReaderFactory metadataReaderFactory) throws IOException {
        // 获取当前类注解的信息
        AnnotationMetadata annotationMetadata = metadataReader.getAnnotationMetadata();
        // 获取当前正在扫描的类的类信息
        ClassMetadata classMetadata = metadataReader.getClassMetadata();
        // 获取当前类的资源(类的路径)
        Resource resource = metadataReader.getResource();
        String className = classMetadata.getClassName();
        System.out.println("--->" + className);
        return className.contains("er");
    }
}
```

修改 Mainnfig，使用自定义的 MyTypeFilter，注意：这里使用了 useDefaultFilters = false，所以 `@Controller`，`@Service`，`@Repository`，`@Component` 注解标注的类此时不会被扫描进来

```java
package icu.intelli.config;

import icu.intelli.bean.Person;
import icu.intelli.typefilter.MyTypeFilter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.FilterType;

@Configuration
@ComponentScan(basePackages = "icu.intelli",
includeFilters = {
@ComponentScan.Filter(type = FilterType.CUSTOM, classes = {MyTypeFilter.class})
},
useDefaultFilters = false)
public class MainConfig {

    @Bean(value = "person")
    public Person person() {
        return new Person("lisi", 20);
    }
}
```

测试类输出，icu.intelli 包下的每个类均被 MyTypeFilter 进行匹配

```bash
--->icu.intelli.bean.Person
```
