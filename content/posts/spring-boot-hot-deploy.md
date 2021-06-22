---
title: Spring Boot热部署
date: '2020-01-20 00:00:00'
tags:
- Spring Boot
- Java
categories:
- Java
- SpringBoot基础系列
---

# Spring Boot热部署

[SpringBoot基础系列目录](spring-boot-table.md)

## SpringBoot的热部署方式

**2种**

- SpringLoader插件
- DevTools工具

## SpringLoader的使用

### 项目准备

1. pom.xml种添加web和thymeleaf的启动器

   ```xml
   <dependency>
       <groupId>org.springframework.boot</groupId>
       <artifactId>spring-boot-starter-thymeleaf</artifactId>
   </dependency>
   
   <dependency>
       <groupId>org.springframework.boot</groupId>
       <artifactId>spring-boot-starter-web</artifactId>
   </dependency>
   ```

2. 创建Controller

   ```java
   @Controller
   public class UserController {
   
       @RequestMapping("/show")
       public String showPage() {
           System.out.println("showPage...");
           return "index";
       }
   }
   ```

3. 编写页面, 放在resources下的templates中

   ```html
   <!DOCTYPE html>
   <html lang="en">
   <head>
       <meta charset="UTF-8">
       <title>Title</title>
   </head>
   <body>
       <span th:text="Hello...."></span>
   </body>
   </html>
   ```

### 使用SpringLoader进行项目的热部署

#### 方式一: 以Maven插件方式使用SpringLoader

**pom.xml中添加SpringLoader插件**

```xml
<build>
    <plugins>
        <plugin>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-maven-plugin</artifactId>
            <dependencies>
                <dependency>
                    <groupId>org.springframework</groupId>
                    <artifactId>springloaded</artifactId>
                    <version>1.2.5.RELEASE</version>
                </dependency>
            </dependencies>
        </plugin>
    </plugins>
</build>
```

**要使插件生效, 需要使用maven的命令来启动**

```shell
spring-boot:run
```

我使用SpringBoot2.2.1, 提示不存在springloaded这个插件, 暂不清楚原因.

**SpringLoader缺陷 :**

- 只能对Java代码做热部署处理, 但是对页面代码无能为力
- 使用springloader热部署程序是在系统后台以进程的形式运行, 使用idea或eclipse并不能彻底将其关闭, 所以再次启动会出现端口占用问题, 需要在任务管理器中手动关闭该进程.

**此方式很坑, 不建议使用**

#### 方式二: 在项目中直接使用jar包的形式

视频使用的springboot1.X, eclipse, 将springloaded的jar包放在了lib目录下, 我使用springboot2.x, idea使用在pom.xml中引入依赖的方式, 设置不生效. 配上原示例:

Run Configuration -> VM arguments添加

```shell
-javaagent:springloaded-1.2.8.RELEASE.jar -noverify
```

该方式可以直接通过eclipse关闭. 依旧只能热部署Java代码

## DevTools工具

### SpringLoader于DevTools的区别

SpringLoader: 在部署项目时, 使用的是热部署的方式 DevTools: 在部署项目时, 使用的是重新部署的方式

### DevTools的使用

pom.xml中添加依赖

视频使用的springboot1.X, eclipse, , 我使用springboot2.x, idea使用在pom.xml中引入依赖的方式, 设置不生效. 配上原示例:

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-devtools</artifactId>
    <!-- 表示当前依赖不像下传递 -->
    <optional>true</optional>
</dependency>
```

网上说需要IDEA开启如下配置

1. 开启Build Project Auto... 

   ![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222135815.png)

2. Ctrl + Alt + Shift + / --> Register

   勾选 `compiler.automake.allow.when.app.running`

3. application.properties中添加

   ```properties
   spring.devtools.restart.enabled=true
   spring.freemarker.cache = false
   spring.thymeleaf.cache=false
   ```

本人试验依旧不生效
