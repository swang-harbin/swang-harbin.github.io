---
title: Spring Boot自定义starters
date: '2019-12-22 00:00:00'
updated: '2019-12-22 00:00:00'
tags:
- Spring Boot
- Java
categories:
- [Java, SpringBoot基础系列]
---

# Spring Boot自定义starters

[SpringBoot基础系列目录](spring-boot-table.md)

## 介绍

starter : 场景启动器

1. 这个场景需要使用到的依赖是什么

2. 如何编写自动配置

   ```java
   @Configuration // 指定这个类是一个配置类
   @ConditionalOnXXX // 在指定条件成立的条件下, 自动配置类生效
   @AutoConfigureAfter  // 指定自动配置类的顺序
   
   @Bean // 给容器中添加组件
   
   @ConfigurationProperties // 注解在相关的xxxProperties类上来绑定相关的配置
   
   @EnableConfigurationProperties // 让xxxProperties生效并加入到容器中
   
   自动配置类要能加载
   将需要启动就加载的自动配置类, 配置在/META-INF/spring.factories中
   org.springframework.boot.autoconfigure.EnableAutoConfiguration=\
   org.springframework.boot.autoconfigure.admin.SpringApplicationAdminJmxAutoConfiguration,\
   org.springframework.boot.autoconfigure.aop.AopAutoConfiguration,\
   org.springframework.boot.autoconfigure.amqp.RabbitAutoConfiguration
   ```

   

3. 模式

启动器只用来做依赖导入, 专门来写一个自动配置模块, 启动器依赖于自动配置模块, 别人只需要引入启动器(starter)即可

- 启动器模块是一个空JAR文件, 仅提供辅助性依赖管理, 这些依赖可能用于自动装配或者其他类库
- 命名规约:
  - 官方命名空间
    - 前缀: "spring-boot-starter-"
    - 模式: spring-boot-start-模块名
    - 举例: spring-boot-starter-web, spring-boot-starter-actuator
  - 自定义命名空间
    - 后缀: "-spring-boot-starter"
    - 模式: 模块-spring-boot-starter
    - 举例: mybatis-spring-boot-starter

## 编写starter

### 创建一个空工程

IDEA : File -> New -> Project -> Empty Project

Project name: intelli-spring-boot-starter

### 创建一个Maven工程

IDEA : File -> New -> Project -> Spring Initializr

Group: icu.intelli Artifact: intelli-spring-boot-starter-autoconfigurer Packaging: Jar Package: icu.intelli.starter

什么模块都不需要选择

### 添加依赖关系

在intelli-spring-boot-starter项目的pom文件中添加

```xml
<dependencies>
    <!-- 引入自动配置模块 -->
    <dependency>
        <groupId>icu.intelli.starter</groupId>
        <artifactId>intelli-spring-boot-starter-autoconfigurer</artifactId>
        <version>0.0.1-SNAPSHOT</version>
    </dependency>
    <dependencies>
```

此时, 当我们使用我们自定义的starter时, 会自动将该starter的自动配置包导入到工程中, 从而该自动配置生效

### 修改intelli-sprig-boot-starter-autoconfigurer

清理多余的目录结构, 保留如下即可:

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222135241.png)

修改pom.xml, 保留如下属性和依赖即可

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>1.5.10.RELEASE</version>
        <relativePath/> <!-- lookup parent from repository -->
    </parent>
    <groupId>icu.intelli.starter</groupId>
    <artifactId>intelli-spring-boot-starter-autoconfigurer</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <name>intelli-spring-boot-starter-autoconfigurer</name>
    <description>Demo project for Spring Boot</description>
    <properties>
        <java.version>1.8</java.version>
    </properties>
    <dependencies>
        <!--引入spring-boot-starter；所有starter的基本配置-->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter</artifactId>
        </dependency>
    </dependencies>
</project>
```

### 添加自定义starter的自动配置代码

#### 添加HelloService

```java
public class HelloService {

    HelloProperties helloProperties;

    public HelloProperties getHelloProperties() {
        return helloProperties;
    }

    public void setHelloProperties(HelloProperties helloProperties) {
        this.helloProperties = helloProperties;
    }

    public String sayHelloCcue(String name) {
        return helloProperties.getPrefix() + "-" + name + helloProperties.getSuffix();
    }
}
```

#### 添加HelloProperties

```java
@ConfigurationProperties(prefix = "intelli.hello") // 绑定配置文件中以intelli.hello开头的配置
public class HelloProperties {

    private String prefix;
    private String suffix;

    public String getPrefix() {
        return prefix;
    }

    public void setPrefix(String prefix) {
        this.prefix = prefix;
    }

    public String getSuffix() {
        return suffix;
    }

    public void setSuffix(String suffix) {
        this.suffix = suffix;
    }
}
```

#### 添加HelloServiceAutoConfiguration

```java
@Configuration
@ConditionalOnWebApplication // web应用才生效
@EnableConfigurationProperties(HelloProperties.class)
public class HelloServiceAutoConfiguration {

    @Autowired
    HelloProperties helloProperties;

    @Bean
    public HelloService helloService() {
        HelloService service = new HelloService();
        service.setHelloProperties(helloProperties);
        return service;
    }
}
```

#### 添加/META-INF/spring.factories

```properties
org.springframework.boot.autoconfigure.EnableAutoConfiguration=\
icu.intelli.starter.HelloServiceAutoConfiguration
```

#### 测试

将intelli-spring-boot-starter-autoconfigurer和intelli-spring-boot-starter依次install到Maven仓库

创建新项目测试自定义的starter: File -> New -> Project -> Spring Initializr

Group: icu.intelli Artifact: spring-boot-08-starter-test Packaging: Jar Package: icu.intelli

选中Web模块

Project name: spring-boot-08-starter-test

引入自定义的starter

```xml
<dependency>
    <groupId>icu.intelli.starter</groupId>
    <artifactId>intelli-spring-boot-starter</artifactId>
    <version>1.0-SNAPSHOT</version>
</dependency>
```

创建Controller

```java
@RestController
public class HelloController {

    @Autowired
    HelloService helloService;

    @GetMapping("/hello")
    public String hello() {
        return helloService.sayHelloCcue("haha");
    }
}
```

编辑配置文件

```properties
intelli.hello.prefix=CCUE
intelli.hello.suffix=HELLO WORLD
```

访问http://localhost:8080/hello, 返回

```
CCUE-hahaHELLO WORLD
```