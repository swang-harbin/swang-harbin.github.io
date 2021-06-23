---
title: Spring 注解：@Scope 设置组件作用域
date: '2020-02-18 00:00:00'
tags:
- Spring
- Spring Annotation
- Java
---

# Spring 注解：`@Scope` 设置组件作用域

[Spring 注解系列目录](spring-anno-table.md)

**Scope 的值可以取 4 种 :**

- prototype：多实例，每次从容器中获取对象时，均创建一个新的实例
- singleton：单实例（默认值）

以下两种仅在 web 项目中可取：

- request：同一次请求创建一个实例
- session：同一个 session 创建一个实例

## 设置 scope 的值

### 注解版

1. 向容器中注入 person 对象，将其设置为多实例

   ```java
   package icu.intelli.config;
   
   import icu.intelli.bean.Person;
   import org.springframework.context.annotation.Bean;
   import org.springframework.context.annotation.Configuration;
   import org.springframework.context.annotation.Scope;
   
   @Configuration
   public class MainConfig {
   
       /**
        * @return
        * @see ConfigurableBeanFactory#SCOPE_PROTOTYPE prototype
        * @see ConfigurableBeanFactory#SCOPE_SINGLETON singleton
        * @see org.springframework.web.context.WebApplicationContext#SCOPE_REQUEST request
        * @see org.springframework.web.context.WebApplicationContext#SCOPE_SESSION session
        * <p>
        * prototype：多实例
        * singleton：单实例（默认值）
        * request：同一次请求创建一个实例
        * session：同一个 session 创建一个实例
        */
       @Scope("prototype")
       @Bean("person")
       public Person person() {
           return new Person("张三", 25);
       }
   }
   ```

2. 测试类 IOCTest

   ```java
   package icu.intelli;
   
   import icu.intelli.config.MainConfig;
   import org.springframework.context.ApplicationContext;
   import org.springframework.context.annotation.AnnotationConfigApplicationContext;
   
   public class IOCTest {
       public static void main(String[] args) {
           // 获取 IOC 容器
           ApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfig.class);
           Object bean = applicationContext.getBean("person");
           Object bean2 = applicationContext.getBean("person");
           System.out.println(bean.equals(bean2));
       }
   }
   ```

3. 测试类输出

   ```
   false
   ```

### 配置文件版

1. 修改 beans.xml，在 bean 标签中添加 scope 属性

   ```xml
   <!-- scope 包含 prototype 和 singleton，默认值为 singleton，web 项目应该包含另外两个，未测试-->
   <bean id="person" class="icu.intelli.bean.Person" scope="prototype">
       <property name="age" value="18"></property>
       <property name="name" value="zhangsan"></property>
   </bean>
   ```

2. 测试类 IOCTest

   ```java
   package icu.intelli;
   
   import org.springframework.context.ApplicationContext;
   import org.springframework.context.support.ClassPathXmlApplicationContext;
   
   public class IOCTest {
       public static void main(String[] args) {
           // 获取 IOC 容器
           ApplicationContext applicationContext = new ClassPathXmlApplicationContext("classpath:beans.xml");
   
           Object bean = applicationContext.getBean("person");
           Object bean2 = applicationContext.getBean("person");
           System.out.println(bean.equals(bean2));
       }
   }
   ```

3. 测试类输出

   ```
   false
   ```

## singleton 和 prototype 创建对象的时机

**scope 为 singleton 时，IOC 容器启动就会调用方法创建对象放到 IOC 容器中，以后每次获取就是直接从容器中拿（map.get()）**

1. MainConfig.class

   ```java
   @Configuration
   public class MainConfig {
       @Scope
       @Bean("person")
       public Person person() {
           System.out.println("给容器中添加 Person...");
           return new Person("张三", 25);
       }
   }
   ```

2. IOCTest

   ```java
   public class IOCTest {
       public static void main(String[] args) {
           // 获取 IOC 容器
           ApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfig.class);
       }
   }
   ```

3. 测试类输出

   ```
   给容器中添加 Person...
   ```

**scope 为 prototype 时，IOC 容器启动时并不会调用方法创建对象放在容器中，而是在每次获取时调用方法创建对象，并且每次获取都会调用一遍**

1. 修改 MainConfig

   ```java
   @Configuration
   public class MainConfig {
       @Scope("prototype")
       @Bean("person")
       public Person person() {
           System.out.println("给容器中添加 Person...");
           return new Person("张三", 25);
       }
   }
   ```

2. 执行该 IOCTest

   ```java
   public class IOCTest {
       public static void main(String[] args) {
           // 获取 IOC 容器
           ApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfig.class);
       }
   }
   ```

3. 程序并没有输出 `给容器中添加 Person...`

4. 修改 IOCTest，获取 person 对象

   ```java
   public class IOCTest {
       public static void main(String[] args) {
           // 获取 IOC 容器
           ApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfig.class);
           System.out.println("IOC 容器创建完成...");
           // 创建对象
           Object bean = applicationContext.getBean("person");
           Object bean2 = applicationContext.getBean("person");
       }
   }
   ```

5. 程序输出

   ```
   IOC 容器创建完成...
   给容器中添加 Person...
   给容器中添加 Person...
   ```

