---
title: Spring 注解：方法，构造器位置的自动装配
date: '2020-02-21 00:00:00'
tags:
- Spring
- Spring Annotation
- Java
---

# Spring 注解：方法，构造器位置的自动装配

[Spring 注解系列目录](spring-anno-table.md)

`@Autowired` 可以标注在：构造器，参数，方法，属性

## 将 `@Autowired` 标注在方法上

创建 Car.java 类

```java
package icu.intelli.bean;

import org.springframework.stereotype.Component;

@Component
public class Boss {
}
```

创建 Boss.java 类，包含一个 Car 属性，并将 `@Autowired` 标注在 setCar 方法上（注，可以标注在任意方法上）

```java
package icu.intelli.bean;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class Boss {

    private Car car;

    public Car getCar() {
        return car;
    }

    @Autowired
    // 标在方法上，Spring 容器创建当前对象，就会调用该方法，完成赋值
    // 方法使用的参数，自定义类型的值从 ioc 容器中获取
    public void setCar(Car car) {
        this.car = car;
    }

    @Override
    public String toString() {
        return "Boss{" +
                "car=" + car +
                '}';
    }
}
```

修改 MainConfig 将 Car 和 Boos 扫描到容器

```java
@Configuration
@ComponentScan({"icu.intelli.bean"})
public class MainConfig {

}
```

IOCTest

```java
package icu.intelli.;

import icu.intelli.bean.Boss;
import icu.intelli.bean.Car;
import icu.intelli.config.MainConfig;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

public class IOCTest {

    public static void main(String[] args) {
        // 获取 IOC 容器
        AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfig.class);
        // 打印 boss
        Boss boss = applicationContext.getBean(Boss.class);
        System.out.println(boss);
        // 打印 IOC 容器中的 car 对象
        Car car = applicationContext.getBean(Car.class);
        System.out.println(car);
    }
}
```

程序输出

```
Boss{car=icu.intelli.bean.Car@10d59286}
icu.intelli.bean.Car@10d59286
```

可知，向 Boss 中注入的 Car 是 IOC 容器中的 car

## 将 `@Autowired` 标注有参构造器上

修改 Boss.java，将 `@Autowird` 标注在有参构造器上

```java
package icu.intelli.bean;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class Boss {

    private Car car;

    // 构造器要用的组件（参数），也是从容器中获取
    // 如果只有一个有参构造器，这个有参构造器的 @Autowired 可以省略，参数位置的组件还是从 IOC 容器中获取
    @Autowired
    public Boss(Car car) {
        this.car = car;
        System.out.println("Boss 的有参构造器...");
    }

    public Car getCar() {
        return car;
    }

    public void setCar(Car car) {
        this.car = car;
    }

    @Override
    public String toString() {
        return "Boss{" +
                "car=" + car +
                '}';
    }
}
```

运行 IOCTest，程序输出

```
Boss 的有参构造器...
Boss{car=icu.intelli.bean.Car@24b1d79b}
icu.intelli.bean.Car@24b1d79b
```

可知，Spring 调用了 Boss 的有参构造器创建对象，并且使用的参数是从 IOC 容器中获取的

## 将 `@Autowired` 标注在参数上

### 标注在有参构造上

修改 Boss.java，将 `@Autowired` 标注在有参构造的参数位置

```java
package icu.intelli.bean;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class Boss {

    private Car car;
    
    public Boss(@Autowired Car car) {
        this.car = car;
        System.out.println("Boss 的有参构造器...");
    }

    public Car getCar() {
        return car;
    }

    public void setCar(Car car) {
        this.car = car;
    }

    @Override
    public String toString() {
        return "Boss{" +
                "car=" + car +
                '}';
    }
}
```

执行 IOCTest 输出

```
Boss 的有参构造器...
Boss{car=icu.intelli.bean.Car@5123a213}
icu.intelli.bean.Car@5123a213
```

与标注在有参构造上相同，在创建 Boss 对象时，调用其有参构造，并使用 IOC 容器中的组件进行赋值

### 标注在普通方法参数上

修改 Boss.java，将 `@Autowired` 标注在 setCar 方法上

```java
package icu.intelli.bean;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class Boss {

    private Car car;

    public Car getCar() {
        return car;
    }

    public void setCar(@Autowired Car car) {
        this.car = car;
    }

    @Override
    public String toString() {
        return "Boss{" +
                "car=" + car +
                '}';
    }
}
```

运行 IOCTest 输出

```
Boss{car=null}
icu.intelli.bean.Car@704921a5
```

并没有对 car 进行赋值

### 标注在 `@Bean` 创建 bean 的方法参数上

修改 Boss.java，不使用 `@Component` 注解加入到容器

```java
package icu.intelli.bean;

public class Boss {

    private Car car;

    public Car getCar() {
        return car;
    }

    public void setCar(Car car) {
        this.car = car;
    }

    @Override
    public String toString() {
        return "Boss{" +
                "car=" + car +
                '}';
    }
}
```

修改 MainConfig，使用 `@Bean` 方式添加 Boss 对象

```java
@Configuration
@ComponentScan({"icu.intelli.bean"})
public class MainConfig {

    @Bean
    // 此处参数里的 @Autowired 可以省略
    public Boss boss(Car car) {
        Boss boss = new Boss();
        // 设置 car
        boss.setCar(car);
        return boss;
    }
}
```

执行 IOCTest，程序输出

```
Boss{car=icu.intelli.bean.Car@77846d2c}
icu.intelli.bean.Car@77846d2c
```

`@Bean`+ 方法参数，默认不写 `@Autowired`，也可以自动装配，注意使用 set 方法
