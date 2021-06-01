---
title: SpringAnnotation-23-@Profile自动装配
date: '2020-02-21 00:00:00'
updated: '2020-02-21 00:00:00'
tags:
- spring-annotation
- spring
- java
categories:
- java
---

# SpringAnnotation-23-@Profile自动装配

Profile介绍: Spring为我们提供的可以根据当前环境, 动态的激活和切换一系列组件的功能

@Profile: 指定组件在哪个环境的情况下才被注册到容器中, 如果不指定, 在任何环境下都能注册这个组件

此处以数据源为例进行测试

## 一. 环境搭建

1. 引入连接池和连接器依赖

```xml
<dependency>
    <groupId>com.mchange</groupId>
    <artifactId>c3p0</artifactId>
    <version>0.9.5.5</version>
</dependency>

<dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
    <version>5.1.48</version>
</dependency>
```

1. 创建数据库配置文件db.properties

```properties
db.user=root
db.password=root
db.driverClass=com.mysql.jdbc.Driver
```

1. 修改MainConfig配置类

```java
package zone.wwwww.config;

import com.mchange.v2.c3p0.ComboPooledDataSource;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.EmbeddedValueResolverAware;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;
import org.springframework.util.StringValueResolver;

import javax.sql.DataSource;
import java.beans.PropertyVetoException;

/**
* 配置多个数据源
*/
@Configuration
// 1. 引入外部配置文件, 将其属性添加到运行环境中
@PropertySource("classpath:/db.properties")
public class MainConfig implements EmbeddedValueResolverAware {

    // 1. 使用@Value自动设置环境中的变量值
    @Value("${db.user}")
    private String user;

    private String driverClass;

    @Bean("testDataSource")
    // 使用@Value自动设置环境中的变量值, 可标注在参数上
    public DataSource dataSourceTest(@Value("${db.password}") String pwd) throws PropertyVetoException {
        ComboPooledDataSource dataSource = new ComboPooledDataSource();
        dataSource.setUser(user);
        dataSource.setPassword(pwd);
        dataSource.setJdbcUrl("jdbc:mysql://localhost:3306/test");
        dataSource.setDriverClass(driverClass);
        return dataSource;
    }

    @Bean("devDataSource")
    public DataSource dataSourceDev(@Value("${db.password}") String pwd) throws PropertyVetoException {
        ComboPooledDataSource dataSource = new ComboPooledDataSource();
        dataSource.setUser(user);
        dataSource.setPassword(pwd);
        dataSource.setJdbcUrl("jdbc:mysql://localhost:3306/dev");
        dataSource.setDriverClass(driverClass);
        return dataSource;
    }

    @Bean("proDataSource")
    public DataSource dataSourceProd(@Value("${db.password}") String pwd) throws PropertyVetoException {
        ComboPooledDataSource dataSource = new ComboPooledDataSource();
        dataSource.setUser(user);
        dataSource.setPassword(pwd);
        dataSource.setJdbcUrl("jdbc:mysql://localhost:3306/prod");
        dataSource.setDriverClass(driverClass);
        return dataSource;
    }

    public void setEmbeddedValueResolver(StringValueResolver resolver) {
        // 使用StringValueResolver解析环境中的变量值
        this.driverClass = resolver.resolveStringValue("${db.driverClass}");
    }
}
```

1. IOCTest测试, 输出容器中的多个数据源

```java
package cc.ccue;

import zone.wwwww.config.MainConfig;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

import javax.sql.DataSource;

public class IOCTest {

    public static void main(String[] args) {
        // 获取IOC容器
        AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfig.class);

        String[] namesForType = applicationContext.getBeanNamesForType(DataSource.class);

        for (String s : namesForType) {
            System.out.println(s);
        }
    }
}
```

程序输出

```
testDataSource
devDataSource
proDataSource
```

## 二. 使用@Profile指定环境

修改MainConfig.java, 为三个DataSource添加@Profile注解

```java
package zone.wwwww.config;

import com.mchange.v2.c3p0.ComboPooledDataSource;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.EmbeddedValueResolverAware;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.context.annotation.PropertySource;
import org.springframework.util.StringValueResolver;

import javax.sql.DataSource;
import java.beans.PropertyVetoException;

@Configuration
@PropertySource("classpath:/db.properties")
public class MainConfig implements EmbeddedValueResolverAware {

    @Value("${db.user}")
    private String user;

    private String driverClass;

    @Profile("test")
    @Bean("testDataSource")
    public DataSource dataSourceTest(@Value("${db.password}") String pwd) throws PropertyVetoException {
        ComboPooledDataSource dataSource = new ComboPooledDataSource();
        dataSource.setUser(user);
        dataSource.setPassword(pwd);
        dataSource.setJdbcUrl("jdbc:mysql://localhost:3306/test");
        dataSource.setDriverClass(driverClass);
        return dataSource;
    }

    @Profile("dev")
    @Bean("devDataSource")
    public DataSource dataSourceDev(@Value("${db.password}") String pwd) throws PropertyVetoException {
        ComboPooledDataSource dataSource = new ComboPooledDataSource();
        dataSource.setUser(user);
        dataSource.setPassword(pwd);
        dataSource.setJdbcUrl("jdbc:mysql://localhost:3306/dev");
        dataSource.setDriverClass(driverClass);
        return dataSource;
    }

    @Profile("prod")
    @Bean("proDataSource")
    public DataSource dataSourceProd(@Value("${db.password}") String pwd) throws PropertyVetoException {
        ComboPooledDataSource dataSource = new ComboPooledDataSource();
        dataSource.setUser(user);
        dataSource.setPassword(pwd);
        dataSource.setJdbcUrl("jdbc:mysql://localhost:3306/prod");
        dataSource.setDriverClass(driverClass);
        return dataSource;
    }

    public void setEmbeddedValueResolver(StringValueResolver resolver) {
        this.driverClass = resolver.resolveStringValue("${db.driverClass}");
    }
}
```

**执行IOCTest, 会发现容器中没有任何DataSource**

> 使用了@Profile的bean, 只有对应的环境被激活时, 才能被注册到环境中, 默认是default环境

## 三. 激活指定环境

### 3.1 使用命令行动态参数激活指定环境

在运行时添加虚拟机参数:

```properties
-Dspring.profiles.active=test
```

此时IOCTest输出

```
testDataSource
```

### 3.2 使用代码的方式激活指定profile

修改IOCTest

```java
package cc.ccue;

import zone.wwwww.config.MainConfig;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

import javax.sql.DataSource;

public class IOCTest {

    public static void main(String[] args) {
        /**
         * 因为带参数的AnnotationConfigApplicationContext构造器, 直接注册并刷新容器, 
         * 所以使用不带参数的bean, 添加自己处理代码
         *
         * 	public AnnotationConfigApplicationContext(Class<?>... annotatedClasses) {
         * 		this();
         * 		register(annotatedClasses);
         * 		refresh();
         *  }
         */
//        AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfig.class);

        // 1. 创建一个applicationContext
        AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext();
        // 2. 设置需要激活的环境
        applicationContext.getEnvironment().setActiveProfiles("test", "dev");
        // 3. 注册主配置类
        applicationContext.register(MainConfig.class);
        // 4. 刷新容器
        applicationContext.refresh();

        String[] namesForType = applicationContext.getBeanNamesForType(DataSource.class);

        for (String s : namesForType) {
            System.out.println(s);
        }
    }
}
```

程序输出

```
testDataSource
devDataSource
```

## 四. 标注在类上

**只有是指定环境的时候, 整个配置类中的配置才能生效**

在MainConfig类上添加@Profile("test")注解

```java
package zone.wwwww.config;

import com.mchange.v2.c3p0.ComboPooledDataSource;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.EmbeddedValueResolverAware;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.context.annotation.PropertySource;
import org.springframework.util.StringValueResolver;

import javax.sql.DataSource;
import java.beans.PropertyVetoException;

@Profile("test")
@Configuration
@PropertySource("classpath:/db.properties")
public class MainConfig implements EmbeddedValueResolverAware {

    @Value("${db.user}")
    private String user;

    private String driverClass;

    @Profile("test")
    @Bean("testDataSource")
    public DataSource dataSourceTest(@Value("${db.password}") String pwd) throws PropertyVetoException {
        ComboPooledDataSource dataSource = new ComboPooledDataSource();
        dataSource.setUser(user);
        dataSource.setPassword(pwd);
        dataSource.setJdbcUrl("jdbc:mysql://localhost:3306/test");
        dataSource.setDriverClass(driverClass);
        return dataSource;
    }

    @Profile("dev")
    @Bean("devDataSource")
    public DataSource dataSourceDev(@Value("${db.password}") String pwd) throws PropertyVetoException {
        ComboPooledDataSource dataSource = new ComboPooledDataSource();
        dataSource.setUser(user);
        dataSource.setPassword(pwd);
        dataSource.setJdbcUrl("jdbc:mysql://localhost:3306/dev");
        dataSource.setDriverClass(driverClass);
        return dataSource;
    }

    @Profile("prod")
    @Bean("proDataSource")
    public DataSource dataSourceProd(@Value("${db.password}") String pwd) throws PropertyVetoException {
        ComboPooledDataSource dataSource = new ComboPooledDataSource();
        dataSource.setUser(user);
        dataSource.setPassword(pwd);
        dataSource.setJdbcUrl("jdbc:mysql://localhost:3306/prod");
        dataSource.setDriverClass(driverClass);
        return dataSource;
    }

    public void setEmbeddedValueResolver(StringValueResolver resolver) {
        this.driverClass = resolver.resolveStringValue("${db.driverClass}");
    }
}
```

设置IOCTest中环境为prod

```java
applicationContext.getEnvironment().setActiveProfiles("prod")
```

程序没有任何输出, 因为整个类都没有加载, 所以类中的其他bean也都不会加载
