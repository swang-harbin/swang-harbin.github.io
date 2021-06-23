---
title: SpringBoot 项目打 war 包
date: '2020-08-25 00:00:00'
tags:
- JAVA
- Spring Boot
---
# SpringBoot 项目打 war 包

**步骤** 

其实就是将 SpringBoot 工程修改为了 Maven Web 工程，然后添加了一个 SpringBootServletInitializer 的子类，在外置 tomcat 启动后，自动启动 SpringBoot 工程。

1. 必须创建一个 war 项目：jar 项目可以修改 pom.xml 中的 `<packaging>war</packaging>`

   ```xml
   <groupId>cc.ccue</groupId>
   <artifactId>spring-boot-jpa-demo</artifactId>
   <version>1.0-SNAPSHOT</version>
   <packaging>war</packaging>
   ```
2. 创建好目录结构：

   IDEA 可通过 Project Structure 快速创建，手动创建的也需要进入 Project Structure 将 web 根目录和 web.xml 设置好

   ![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609143024.png)


   ![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609143025.png)

3. 将嵌入式的 tomcat 指定为 provided

   ```xml
   <dependency>
       <groupId>org.springframework.boot</groupId>
       <artifactId>spring-boot-starter-tomcat</artifactId>
       <scope>provided</scope>
   </dependency>
   ```

4. 必须编写一个 SpringBootServletInitializer 的子类，并调用 configure 方法

   ```java
   public class ServletInitializer extends SpringBootServletInitializer {
   
       @Override
       protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
           // 需要传入 SpingBoot 应用的主程序
           return application.sources(Application.class);
       }
   
   }
   ```

5. IDEA 通过 *Edit Configurations...* 添加 tomcat 容器，并将当前项目设置进去

6. 启动外置 tomcat 就可以使用（此处直接运行 Application.java 使用的还是嵌入式的 tomcat）
