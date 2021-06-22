---
title: Spring注解-@ComponentScan包扫描&指定扫描规则
date: '2020-02-18 00:00:00'
tags:
- Spring
- Spring Annotation
- Java
categories:
- Java
- Spring注解系列
---
# Spring注解-@ComponentScan包扫描&指定扫描规则

[跳到Spring注解系列目录](spring-anno-table.md)

创建BookController, BookService, BookDao, 并分别使用`@Controller`, `@Service`, `@Repository`注解标注

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

### 注解版

在MainConfig类上添加@ComponentScan注解

```java
package icu.intelli.config;

import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;

@Configuration
@ComponentScan(value = "icu.intelli") // 扫描icu.intelli及其子包, 将被@Controller, @Service, @Repository, @Component标注的组件扫描到容器
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
        // 获取IOC容器
        ApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfig.class);
        // 获取容器中所有Bean的名字
        String[] beanDefinitionNames = applicationContext.getBeanDefinitionNames();
        for (String beanDefinitionName : beanDefinitionNames) {
            System.out.println(beanDefinitionName);
        }
    }
}
```

控制台输出

```
Console:
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

### 配置文件版

beans.xml中添加`context:component-scan`标签

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd">

    <!-- 包扫描, 只要标注了@Controller, @Service, @Repository, @Component -->
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
        // 获取IOC容器
        ApplicationContext applicationContext = new ClassPathXmlApplicationContext("classpath:beans.xml");
        // 获取容器中所有Bean的名字
        String[] beanDefinitionNames = applicationContext.getBeanDefinitionNames();
        for (String beanDefinitionName : beanDefinitionNames) {
            System.out.println(beanDefinitionName);
        }
    }
}
```

```shell
Console:
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

## @ComponentScan使用排除excludeFilters属性排除指定类

### 注解版

修改MainConfig, 修改@ComponentScan注解

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
// 扫描icu.intelli包及其所有子包, 过滤掉被Controller注解和Service注解标注的类
@ComponentScan(value = "icu.intelli", excludeFilters = {
// FilterType包含ANNOTATION, ASSIGNABLE_TYPE, ASPECTJ, REGEX, CUSTOM, 默认值是ANNOTATION
@ComponentScan.Filter(type = FilterType.ANNOTATION, classes = {Controller.class, Service.class})
})
public class MainConfig {

    @Bean(value = "person")
    public Person person() {
        return new Person("lisi", 20);
    }
}
```

使用IOCTest类测试, 控制台输出如下, bookController和bookService并没有扫描到IOC容器中

```shell
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

修改beans.xml, 在context:component-scan标签中添加context:exclude-filter标签

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:context="http://www.springframework.org/schema/context"
xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd http://www.springframework.org/schema/context https://www.springframework.org/schema/context/spring-context.xsd">

    <context:component-scan base-package="icu.intelli">
        <!-- 排除被Controller和Service注解标记的类 -->
        <!-- type类型包括annotation, assignable, aspectj, regex, custom-->
        <context:exclude-filter type="annotation" expression="org.springframework.stereotype.Controller"/>
        <context:exclude-filter type="annotation" expression="org.springframework.stereotype.Service"/>
    </context:component-scan>
    
    <bean id="person" class="icu.intelli.bean.Person">
        <property name="age" value="18"></property>
        <property name="name" value="zhangsan"></property>
    </bean>
</beans>
```

使用IOCTest类测试, 控制台输出如下, bookController和bookService并没有扫描到IOC容器中

```shell
bookDao
org.springframework.context.annotation.internalConfigurationAnnotationProcessor
org.springframework.context.annotation.internalAutowiredAnnotationProcessor
org.springframework.context.annotation.internalRequiredAnnotationProcessor
org.springframework.context.annotation.internalCommonAnnotationProcessor
org.springframework.context.event.internalEventListenerProcessor
org.springframework.context.event.internalEventListenerFactory
person
```

## @ComponentScan使用排除includeFilters属性排除指定类

### 注解版

修改MainConfig, 修改@ComponentScan注解, 使用includeFilters属性, 并将useDefaultFilters属性设置为false

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
// 扫描icu.intelli包及其所有子包, 扫描时只扫描被Controller注解和Service注解标注的类
@ComponentScan(value = "icu.intelli", includeFilters = {
// FilterType包含ANNOTATION, ASSIGNABLE_TYPE, ASPECTJ, REGEX, CUSTOM, 默认值是ANNOTATION
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

使用IOCTest类测试, 控制台输出如下, bookController和bookService被扫描到IOC容器中, 而bookDao没有被扫描到IOC容器

```shell
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

修改beans.xml, 在context:component-scan标签中添加use-default-filters="false"属性和context:include-filter标签

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:context="http://www.springframework.org/schema/context"
xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd http://www.springframework.org/schema/context https://www.springframework.org/schema/context/spring-context.xsd">

    <!-- use-default-filters="false", 不使用默认的扫描规则 -->
    <context:component-scan base-package="icu.intelli" use-default-filters="false">
        <!-- 只扫描被Controller和Service注解标注的类 -->
        <context:include-filter type="annotation" expression="org.springframework.stereotype.Controller"/>
        <context:include-filter type="annotation" expression="org.springframework.stereotype.Service"/>
    </context:component-scan>
    
    <bean id="person" class="icu.intelli.bean.Person">
        <property name="age" value="18"></property>
        <property name="name" value="zhangsan"></property>
    </bean>
</beans>
```

使用IOCTest类测试, 控制台输出如下, bookController和bookService被扫描到IOC容器中, 而bookDao没有被扫描到IOC容器

```shell
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

## ComponentScan重复注解

JDK8提供了Repeatable注解, 表明可以在一个类上使用多个ComponentScan, 定义多个过滤规则

```java
@Repeatable(ComponentScans.class)
public @interface ComponentScan {
```

可能需要在pom.xml中指定maven使用的jdk版本

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

此时在Mainonfig上使用多个ComponentScan注解并不会报错

```java
@ComponentScan()
@ComponentScan()
public class MainConfig {
```

如果使用的JDK版本小于8, 可使用ComponentScans注解达到同样的效果

```java
@ComponentScans(value = {
    @ComponentScan(),
    @ComponentScan()
})
public class MainConfig {
```

## FilterType类型

**FilterType包含 :**

- ANNOTATION 按照注解, 默认值
- ASSIGNABLE_TYPE 按照给定的类型, 包括实现类
- ASPECTJ 使用ASPECTJ表达式
- REGEX 使用正则表达式
- CUSTOM 自定义规则

## 自定义(CUSTOM)TypeFilter的使用

### 注解版

定义一个MyTypeFilter实现TypeFilter接口, 输出--->类名, 如果类名中包含"er", 返回true, 否则返回false, 即XxxService, Person等返回true

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

修改Mainnfig, 使用自定义的MyTypeFilter, 注意: 这里使用了useDefaultFilters = false, 所以C@ontroller, @Service, @Repository, @Component注解标注的类此时不会被扫描进来

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

测试类输出, icu.intelli包下的每个类均被MyTypeFilter进行匹配

```shell
--->icu.intelli.bean.Person
