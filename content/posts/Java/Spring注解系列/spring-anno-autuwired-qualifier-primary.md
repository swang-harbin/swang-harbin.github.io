---
title: Spring 注解：@Autowired，@Qualifie，@Primary 自动装配
date: '2020-02-21 00:00:00'
tags:
- Spring
- Spring Annotation
- Java
---

# Spring 注解：`@Autowired`，`@Qualifier`，`@Primary` 自动装配

[Spring 注解系列目录](spring-anno-table.md)

## `@Autowired`

1. 容器中只有一个 BookService 类型的 bean 时

   BookController

   ```java
   import icu.intelli.service.BookService;
   import org.springframework.beans.factory.annotation.Autowired;
   import org.springframework.stereotype.Controller;
   
   @Controller
   public class BookController {
   
       // 自动注入 bookService
       @Autowired
       private BookService bookService;
       
       // 打印 bookService
       public void printBookService() {
           System.out.println(this.bookService);
       }
   }
   ```

   BookService

   ```java
   import org.springframework.stereotype.Service;
   
   @Service
   public class BookService {
   
   }
   ```

   MainConfig，将 BookService 和 BookController 扫描到容器中

   ```java
   @Configuration
   // 将 Service 和 Controller 扫描到容器
   @ComponentScan({"icu.intelli.controller", "icu.intelli.service"})
   public class MainConfig {
   
   }
   ```

   IOCTest

   ```java
   import icu.intelli.config.MainConfig;
   import icu.intelli.controller.BookController;
   import icu.intelli.service.BookService;
   import org.springframework.context.annotation.AnnotationConfigApplicationContext;
   
   public class IOCTest {
   
       public static void main(String[] args) {
           // 获取 IOC 容器
           AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfig.class);
           // 获取 bookController
           BookController bean = applicationContext.getBean(BookController.class);
           // 调用 printBookService 方法
           bean.printBookService();
   
           // 获取容器中的 bookService
           BookService bean1 = applicationContext.getBean(BookService.class);
           System.out.println(bean1);
       }
   }
   ```

   运行结果

   ```java
   icu.intelli.service.BookService@4d339552
   icu.intelli.service.BookService@4d339552
   ```

   **结论：当容器中只有一个同一类型的 bean 时，Spring 对标注了 `@Autowired` 的属性根据类型进行装配**

2. 容器中有多个个 BookService 类型的 bean 时

   修改 BookService 添加 lable 属性并添加 getter 和 setter 方法，重写 toString 方法，已做区分

   ```java
   import org.springframework.stereotype.Service;
   
   // bean 名称默认为类名首字母小写（bookService）
   @Service
   public class BookService {
       // 默认 lable 为 1
       private String lable = "1";
   
       public String getLable() {
           return lable;
       }
   
       public void setLable(String lable) {
           this.lable = lable;
       }
   
       @Override
       public String toString() {
           return "BookService{" +
                   "lable='" + lable + '\'' +
                   '}';
       }
   }
   ```

   在 MainConfig 中注入一个新的 BookService，名称为 bookService2，lable 为 1

   ```java
   import icu.intelli.service.BookService;
   import org.springframework.context.annotation.Bean;
   import org.springframework.context.annotation.ComponentScan;
   import org.springframework.context.annotation.Configuration;
   
   
   @Configuration
   // 将 Service 和 Controller 扫描到容器
   @ComponentScan({"icu.intelli.controller", "icu.intelli.service"})
   public class MainConfig {
   
       @Bean("bookService2")
       public BookService bookService() {
           BookService bookService = new BookService();
           bookService.setLable("2");
           return bookService;
       }
   }
   ```

   此时 BookController 为

   ```java
   import icu.intelli.service.BookService;
   import org.springframework.beans.factory.annotation.Autowired;
   import org.springframework.stereotype.Controller;
   
   @Controller
   public class BookController {
   
       @Autowired
       private BookService bookService;
   
       public void printBookService() {
           System.out.println(this.bookService);
       }
   }
   ```

   IOCTest

   ```java
   import icu.intelli.config.MainConfig;
   import icu.intelli.controller.BookController;
   import org.springframework.context.annotation.AnnotationConfigApplicationContext;
   
   public class IOCTest {
   
       public static void main(String[] args) {
           // 获取 IOC 容器
           AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfig.class);
           BookController bean = applicationContext.getBean(BookController.class);
           bean.printBookService();
       }
   }
   ```

   测试输出

   ```
   BookService{lable='1'}
   ```

   可知，此时向 BookController 中注入的是名为 bookService 的 Bean.

   将 BookController 中的`private BookService bookService`修改为`private BookService bookService2`

   测试 IOCTest 输出

   ```
   BookService{lable='2'}
   ```

   **结论：当容器中有多个同一类型的 bean 时，Spring 对标注了 `@Autowired` 的属性根据属性名进行装配**

## `@Qualifier`

当容器中存在多个统一类型的 bean 时，可以使用@Qualifier 指定 bean 名称为属性注入指定的 bean

修改 BookController，使用@Qualifier 指定注入名为 bookService 的 bean

```java
import icu.intelli.service.BookService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Controller;

@Controller
public class BookController {

    @Qualifier("bookService")
    @Autowired
    private BookService bookService2;

    public void printBookService() {
        System.out.println(this.bookService2);
    }
}
```

执行 IOCTest 输出

```
BookService{lable='1'}
```

## `@Primary`

让 Spring 进行自动装配的时候，默认使用首选的 Bean 装配，也可以使用 `@Qualifier` 准确指定需要装配哪个 bean

修改 MainConfig，对 bookService2 添加 `@Primary` 注解

```java
@Configuration
// 将 Service 和 Controller 扫描到容器
@ComponentScan({"icu.intelli.controller", "icu.intelli.service"})
public class MainConfig {

    @Primary
    @Bean("bookService2")
    public BookService bookService() {
        BookService bookService = new BookService();
        bookService.setLable("2");
        return bookService;
    }
}
```

修改 BookController，此时 BookService 的属性名与 `@Primary` 注解标注的 Bean 名称不相同

```java
@Controller
public class BookController {

    @Autowired
    private BookService bookService;

    public void printBookService() {
        System.out.println(this.bookService);
    }
}
```

执行 IOCTest 输出

```
BookService{lable='2'}
```

Spring 注入了 `@Primary` 标注的 bean

修改 BookController，使用 `@Qualifier` 指定注入的 bean

```java
@Controller
public class BookController {

    @Qualifier("bookService")
    @Autowired
    private BookService bookService;

    public void printBookService() {
        System.out.println(this.bookService);
    }
}
```

程序输出

```
BookService{lable='1'}
```

## 总结

Spring 利用依赖注入（DI），完成对 IOC 容器中各个组件的依赖关系赋值

`@Autowired`：自动注入

1. 默认优先按照类型去容器中找对应的组件，找到即进行赋值
2. 如果找到多个相同的组件，再将属性的名称作为组件 id 去容器中查找
3. 可以结合 `@Qualifier` 指定需要装配的组件的 id，而不是使用属性名
4. 自动装配默认一定要对属性赋值，如果容器中没有该类型的 bean 就会报错；可以通过指定 `@Autowired` 的 required 属性为 false，使得如果容器中没有相应的 bean，就不装配
5. 可以使用 `@Primary` 注解，将 bean 设定为首选，此时 `@Autowired` 默认装配首选 Bean

