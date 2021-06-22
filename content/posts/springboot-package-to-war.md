---
title: SpringBoot项目打war包
date: '2020-08-25 00:00:00'
tags:
- JAVA
- Spring Boot
categories:
- Spring Boot
---
**步骤 :** 

其实就是将SpringBoot工程修改为了Maven Web工程, 然后添加了一个SpringBootServletInitializer的子类, 在外置tomcat启动后, 自动启动SpringBoot工程.

1. 必须创建一个war项目: jar项目可以修改pom.xml中的`<packaging>war</packaging>`

   ```xml
   <groupId>cc.ccue</groupId>
   <artifactId>spring-boot-jpa-demo</artifactId>
   <version>1.0-SNAPSHOT</version>
   <packaging>war</packaging>
   ```
2. 创建好目录结构: 

   - IDEA可通过Project Structure快速创建, 手动创建的也需要进入Project Structure将web根目录和web.xml设置好

   ![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609143024.png)


   ![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609143025.png)

3. 将嵌入式的tomcat指定为provided

   ```xml
   <dependency>
       <groupId>org.springframework.boot</groupId>
       <artifactId>spring-boot-starter-tomcat</artifactId>
       <scope>provided</scope>
   </dependency>
   ```

4. 必须编写一个SpringBootServletInitializer的子类, 并调用configure方法

   ```java
   public class ServletInitializer extends SpringBootServletInitializer {
   
       @Override
       protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
           // 需要传入SpingBoot应用的主程序
           return application.sources(Application.class);
       }
   
   }
   ```

5. IDEA通过*Edit Configurations...*添加tomcat容器, 并将当前项目设置进去

6. 启动外置tomcat就可以使用(此处直接运行Application.java使用的还是嵌入式的tomcat)
