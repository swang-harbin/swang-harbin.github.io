---
title: Spring Boot 热部署
date: '2020-01-20 00:00:00'
tags:
- Spring Boot
- Java
---

# Spring Boot 热部署

[Spring Boot 基础系列目录](spring-boot-table.md)

## SpringBoot 的热部署方式

**2 种**

- SpringLoader 插件
- DevTools 工具

## SpringLoader 的使用

### 项目准备

1. pom.xml 中添加 web 和 thymeleaf 的启动器

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

2. 创建 Controller

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

3. 编写页面，放在 resources 下的 templates 中

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

### 使用 SpringLoader 进行项目的热部署

#### 方式一：以 Maven 插件方式使用 SpringLoader

**pom.xml 中添加 SpringLoader 插件**

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

**要使插件生效，需要使用 maven 的命令来启动**

```bash
spring-boot:run
```

我使用 SpringBoot 2.2.1, 提示不存在 springloaded 这个插件，暂不清楚原因。

**SpringLoader 缺陷**

- 只能对 Java 代码做热部署处理，但是对页面代码无能为力
- 使用 springloader 热部署程序是在系统后台以进程的形式运行，使用 idea 或 eclipse 并不能彻底将其关闭，所以再次启动会出现端口占用问题，需要在任务管理器中手动关闭该进程。

**此方式很坑，不建议使用**

#### 方式二：在项目中直接使用 jar 包的形式

视频使用的 springboot1.X, eclipse, 将 springloaded 的 jar 包放在了 lib 目录下，我使用 springboot 2.x, idea 使用在 pom.xml 中引入依赖的方式，设置不生效。配上原示例

Run Configuration → VM arguments 添加

```bash
-javaagent:springloaded-1.2.8.RELEASE.jar -noverify
```

该方式可以直接通过 eclipse 关闭。依旧只能热部署 Java 代码

## DevTools 工具

### SpringLoader 与 DevTools 的区别

SpringLoader：在部署项目时，使用的是热部署的方式 DevTools：在部署项目时，使用的是重新部署的方式

### DevTools 的使用

pom.xml 中添加依赖

视频使用的 springboot1.X, eclipse，我使用 springboot2.x, idea 使用在 pom.xml 中引入依赖的方式，设置不生效。配上原示例

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-devtools</artifactId>
    <!-- 表示当前依赖不向下传递 -->
    <optional>true</optional>
</dependency>
```

网上说需要 IDEA 开启如下配置

1. 开启 Build Project Auto...

   ![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222135815.png)

2. <kbd>Ctrl</kbd>+<kbd>Alt</kbd>+<kbd>Shift</kbd>+<kbd>/</kbd> → Register

   勾选 `compiler.automake.allow.when.app.running`

3. application.properties 中添加

   ```properties
   spring.devtools.restart.enabled=true
   spring.freemarker.cache = false
   spring.thymeleaf.cache=false
   ```

本人试验依旧不生效
