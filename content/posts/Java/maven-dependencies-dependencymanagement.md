---
title: Maven 的 dependencies 和 dependencyManagement 区别
date: '2021-06-21 19:48:31'
tags:
- Java
- Maven
---

# Maven 的 dependencies 和 dependencyManagement 区别

`<dependencyManagement>` 仅是声明依赖，通常在顶级父模块中做版本管理。在父模块中使用 `<dependencyManagement` 标签声明依赖，其子模块不会自动引入 `dependencyManagement` 中的依赖，需要在子模块中手动引入才可以

`<dependencies>` 是真实的引入了依赖，子模块会继承父模块 `<dependencies>` 中的依赖

## 常用方式

1. 在顶级父模块的 pom 中使用 `<dependencyManagement>` 和 `<properties>` 声明依赖和版本号，进行依赖的版本控制

   ```xml
   <!-- 在 properties 中设置版本号，进行统一的版本管理 -->
   <properties>
       <commons-lang3.version>3.11</commons-lang3.version>
       <selenium.version>3.141.59</selenium.version>
       <lombok.version>1.18.20</lombok.version>
   </properties>  
   
   <!-- 引入需要给所有模块使用的依赖，不需要指定 version 了，因为在 dependencyManagement 中已经指定了 -->
   <dependencies>
       <dependency>
           <groupId>org.projectlombok</groupId>
           <artifactId>lombok</artifactId>
           <scope>provided</scope>
       </dependency>
   </dependencies>
   
   <!-- 在 dependencyManagement 中声明依赖和版本，并不会引入到当前模块和其子模块中 -->
   <dependencyManagement>
       <dependencies>
           <!-- commons-lang3 工具包 -->
           <dependency>
               <groupId>org.apache.commons</groupId>
               <artifactId>commons-lang3</artifactId>
               <version>${commons-lang3.version}</version>
           </dependency>
           <!-- selenium 模拟浏览器进行自动化-->
           <dependency>
               <groupId>org.seleniumhq.selenium</groupId>
               <artifactId>selenium-java</artifactId>
               <version>${selenium.version}</version>
           </dependency>
           <!-- selenium chrome 驱动-->
           <dependency>
               <groupId>org.seleniumhq.selenium</groupId>
               <artifactId>selenium-chrome-driver</artifactId>
               <version>${selenium.version}</version>
           </dependency>
           <!-- lombok -->
           <dependency>
               <groupId>org.projectlombok</groupId>
               <artifactId>lombok</artifactId>
               <version>${lombok.version}</version>
           </dependency>
       </dependencies>
   </dependencyManagement>
   ```

2. 在子模块的 pom 中只需要使用 `<dependencies>` 引入需要的依赖即可，并且不需要指定版本号

   ```xml
   <!-- 子模块只需要引入自己需要的依赖即可，并且不需要指定版本号，会自动使用父模块中指定的版本，通过父模块进行统一的版本管理 -->
   <dependencies>
       <dependency>
           <groupId>org.apache.commons</groupId>
           <artifactId>commons-lang3</artifactId>
       </dependency>
   </dependencies>
   ```
