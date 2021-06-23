---
title: Spring Boot 入门
date: '2019-12-16 00:00:00'
tags:
- Spring Boot
- Java
---

# Spring Boot 入门

[Spring Boot 基础系列目录](spring-boot-table.md)

## Spring Boot 简介

简化 Spring 应用开发的一个框架；整个 Spring 技术栈的一个大整合；J2EE 开发的一站式解决方案

## 微服务

2014 年，[martin fowler](https://martinfowler.com/)

微服务：架构风格

一个应用应该是一组小型服务；可以通过 HTTP 的方式进行互通

单体应用：ALL IN ONE 

微服务：每一个功能元素最终都是一个可独立替换和独立升级的一个单元 

[详细参照微服务文档](https://martinfowler.com/microservices/)

## 环境要求

### Maven 设置

给 Maven 的 settings.xml 配置文件的 profiles 标签添加，设置 Maven 编译时使用的 JDK 版本

```xml
<profile>
    <id>jdk-1.8</id>
    <activation>
        <activeByDefault>true</activeByDefault>
        <jdk>1.8</jdk>
    </activation>
    <properties>
        <maven.compiler.source>1.8</maven.compiler.source>
        <maven.compiler.target>1.8</maven.compiler.target>
        <maven.compiler.compilerVersion>1.8</maven.compiler.compilerVersion>
    </properties>
</profile>
```

## Spring Boot HelloWorld

一个功能：浏览器发送一个 hello 请求，服务器接收请求并处理，响应 Hello World 字符串

### 创建一个 Maven 工程

创建 Maven 工程，`packing` 设置为 `jar`

### 导入 Spring Boot 相关依赖

```xml
<!-- Inherit defaults from Spring Boot -->
<parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>2.2.1.RELEASE</version>
</parent>

<!-- Add typical dependencies for a web application -->
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
</dependencies>
```

### 编写一个主程序：启动一个 Spring Boot 应用

```java
/**
 * @SpringBootApplication 来标注一个主程序类，说明这是一个 Spring Boot 应用
 */
@SpringBootApplication
public class HelloWorldMainApplication {

    public static void main(String[] args) {
        // Spring 应用启动起来
        SpringApplication.run(HelloWorldMainApplication.class, args);
    }
}
```

### 编写相关的 Controller、Service

```java
@Controller
public class HelloController {

    @ResponseBody
    @RequestMapping("/hello")
    public String hello(){
        return "Hello World!";
    }

}
```

### 运行主程序测试

### 简化部署

导入 Spring Boot 的 Maven 插件后，使用 Maven 的 package 命令即可将应用打成 jar

```xml
<!-- Package as an executable jar -->
<build>
    <plugins>
        <plugin>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-maven-plugin</artifactId>
        </plugin>
    </plugins>
</build>
```

使用 `java -jar xxx.jar` 直接运行

## Hello World 探究

### POM 文件

#### 父项目

```xml
<parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>2.2.1.RELEASE</version>
</parent>

<!-- spring-boot-starter-parent 的父项目是 -->
<parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-dependencies</artifactId>
    <version>2.2.1.RELEASE</version>
    <relativePath>../../spring-boot-dependencies</relativePath>
</parent>
<!-- 它来真正管理 Spring Boot 应用里面的所有依赖版本，所以叫 Spring Boot 的版本仲裁中心 -->
```

以后我们导入依赖，默认是不需要写版本的；（没有在 dependencies 里面管理的依赖依然需要声明版本号）

#### 导入的启动器（依赖）

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>
```

**spring-boot-starter-web**：spring-boot 场景启动器；该启动器导入了 web 模块正常运行所依赖的组件

Spring Boot 将所有的功能场景都抽取出来，做成一个个的 starter（启动器），只需要在项目里面引入这些 starter，相关场景的所有依赖都会自动导入进来。要用什么功能就导入什么场景的启动器

### 主程序类，主入口类

```java
/**
 * @SpringBootApplication 来标注一个主程序类，说明这是一个 Spring Boot 应用
 */
@SpringBootApplication
public class HelloWorldMainApplication {

    public static void main(String[] args) {
        // Spring 应用启动起来
        SpringApplication.run(HelloWorldMainApplication.class, args);
    }
}
```

**@SpringBootApplication**：标注在某个类上，说明这个类是 SpringBoot 的主配置类，Spring Boot 就应该运行这个类的 main 方法来启动 SpringBoot 应用

```java
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Inherited
@SpringBootConfiguration
@EnableAutoConfiguration
@ComponentScan(excludeFilters = { @Filter(type = FilterType.CUSTOM, classes = TypeExcludeFilter.class),
		@Filter(type = FilterType.CUSTOM, classes = AutoConfigurationExcludeFilter.class) })
public @interface SpringBootApplication {
```

**@SpringBootConfiguration**：标注在某个类上，表示这是一个 Spring Boot 配置类

- **@Configuration**：是 Spring 的注解，原始 Spring 开发中的配置文件替换为配置类，被 `@Component` 标注，也是一个组件

**@EnableAutoConfiguration**：开启自动配置功能。

- 以前需要配置的东西，Spring Boot 会自动配置

  ```java
  @AutoConfigurationPackage
  @Import(AutoConfigurationImportSelector.class)
  public @interface EnableAutoConfiguration {
  ```

  - **@AutoConfigurationPackage**：自动配置包

  - **@Import(AutoConfigurationPackages.Registrar.class)**

    Spring 的底层注解 `@Import`，给容器中导入一个组件；导入的组件由 `AutoConfigurationPackages.Registrar.class` 指定

    将主配置类（`@SpringBootApplication` 标注的类）的所在包及其所有子包里面的所有组件扫描到 Spring 容器。

    - **@Import(AutoConfigurationImportSelector.class)**

      ```java
      AutoConfigurationImportSelector：自动配置引入的选择器
      ```

      将所有需要导入的组件以全类名的方式返回，这些组件就会被添加到 Spring 容器中

      会给容器中导入非常多的自动配置类（xxxAutoConfiguration）；就是给容器中导入这个场景需要的所有组件，并配置好这些组件;

      有了自动配置类，免去了手动编写配置注入功能组件等的工作

`SpringFactoriesLoader.loadFactoryNames(EnableAutoConfiguration.class, classLoader;`

Spring Boot 在启动的时候从类路径下的 `META-INF/spring.factories` 中获取 `EnableAutoConfiguration` 指定的值，将这些值作为自动配置类导入到容器中，自动配置类就生效了，帮我们进行自动配置工作；以前需要我们自己配置的东西，自动配置类都做了。

J2EE 的整体整合解决方案和自动配置都在 spring-boot-autoconfigure-2.x.x.RELEASE.jar;

![image-20210222003132759](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222004235.png)

## 使用 Spring Initializer 快速创建 Spring Boot 项目

IDE 都支持使用 Spring 的项目创建向导快速创建一个 Spring Boot 项目

选择我们需要的模块；想到会联网创建 Spring Boot 项目

默认生成的 Spring Boot 项目：

- 主程序已经生成好了，我们只需要写我们自己的逻辑
- resources 文件夹中目录结构
  - static：保存所有的静态资源：js css images
  - templates：保存所有的模板页面；（Spring Boot 默认 jar 包使用嵌入式的 Tomcat，默认不支持 jsp 页面）；可以使用模板引擎（freemarker，thymeleaf）
  - application.properties：Spring Boot 应用的配置文件，可以修改一些默认配置
