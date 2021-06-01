---
title: SpringAnnotation-19-@Autowired,@Qualifier,@Primary自动装配
date: '2020-02-21 00:00:00'
updated: '2020-02-21 00:00:00'
tags:
- spring-annotation
- spring
- java
categories:
- java
---

# SpringAnnotation-19-@Autowired,@Qualifier,@Primary自动装配

## 一. @Autowired

**1. 容器中只有一个BookService类型的bean时**

BookController

```java
import zone.wwwww.service.BookService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;

@Controller
public class BookController {

    // 自动注入bookService
    @Autowired
    private BookService bookService;
    
    // 打印bookService
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

MainConfig, 将BookService和BookController扫描到容器中

```java
@Configuration
// 将Service和Controller扫描到容器
@ComponentScan({"zone.wwwww.controller", "zone.wwwww.service"})
public class MainConfig {

}
```

IOCTest

```java
import zone.wwwww.config.MainConfig;
import zone.wwwww.controller.BookController;
import zone.wwwww.service.BookService;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

public class IOCTest {

    public static void main(String[] args) {
        // 获取IOC容器
        AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfig.class);
        // 获取bookController
        BookController bean = applicationContext.getBean(BookController.class);
        // 调用printBookService方法
        bean.printBookService();

        // 获取容器中的bookService
        BookService bean1 = applicationContext.getBean(BookService.class);
        System.out.println(bean1);
    }
}
```

运行结果

```
zone.wwwww.service.BookService@4d339552
zone.wwwww.service.BookService@4d339552
```

**结论: 当容器中只有一个同一类型的bean时, Spring对标注了@Autowired的属性根据类型进行装配**

**2. 容器中有多个个BookService类型的bean时**

修改BookService添加lable属性并添加getter和setter方法, 重写toString方法, 已做区分

```java
import org.springframework.stereotype.Service;

// bean名称默认为类名首字母小写(bookService)
@Service
public class BookService {
    // 默认lable为1
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

在MainConfig中注入一个新的BookService, 名称为bookService2, lable为1

```java
import zone.wwwww.service.BookService;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;


@Configuration
// 将Service和Controller扫描到容器
@ComponentScan({"zone.wwwww.controller", "zone.wwwww.service"})
public class MainConfig {

    @Bean("bookService2")
    public BookService bookService() {
        BookService bookService = new BookService();
        bookService.setLable("2");
        return bookService;
    }
}
```

此时BookController为

```java
import zone.wwwww.service.BookService;
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
import zone.wwwww.config.MainConfig;
import zone.wwwww.controller.BookController;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

public class IOCTest {

    public static void main(String[] args) {
        // 获取IOC容器
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

> 可知, 此时向BookController中注入的是名为bookService的Bean.

将BookController中的`private BookService bookService`修改为`private BookService bookService2`

测试IOCTest输出

```
BookService{lable='2'}
```

**结论: 当容器中有多个同一类型的bean时, Spring对标注了@Autowired的属性根据属性名进行装配**

## 二. @Qualifier

当容器中存在多个统一类型的bean时, 可以使用@Qualifier指定bean名称为属性注入指定的bean

修改BookController, 使用@Qualifier指定注入名为bookService的bean

```java
import zone.wwwww.service.BookService;
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

执行IOCTest输出

```
BookService{lable='1'}
```

## 三. @Primary

让Spring进行自动装配的时候, 默认使用首选的Bean装配, 也可以使用@Qualifier准确指定需要装配哪个bean

修改MainConfig, 对bookService2添加@Primary注解

```java
@Configuration
// 将Service和Controller扫描到容器
@ComponentScan({"zone.wwwww.controller", "zone.wwwww.service"})
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

修改BookController, 此时BookService的属性名与@Primary注解标注的Bean名称不相同

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

执行IOCTest输出

```
BookService{lable='2'}
```

> Spring注入了@Primary标注的bean

修改BookController, 使用@Qualifier指定注入的bean

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

## 四. 总结

Spring利用依赖注入(DI), 完成对IOC容器中各个组件的依赖关系赋值

1. @Autowired: 自动注入
   1. 默认优先按照类型去容器中找对应的组件, 找到即进行赋值
   2. 如果找到多个相同的组件, 再将属性的名称作为组件id去容器中查找
   3. 可以结合@Qualifier指定需要装配的组件的id, 而不是使用属性名
   4. 自动装配默认一定要对属性赋值, 如果容器中没有该类型的bean就会报错; 可以通过指定@Autowired的required属性为false, 使得如果容器中没有相应的bean, 就不装配
   5. 可以使用@Primary注解, 将bean设定为首选, 此时@Autowired默认装配首选Bean
