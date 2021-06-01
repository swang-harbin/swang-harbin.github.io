---
title: SpringAnnotation-21-方法,构造器位置的自动装配
date: '2020-02-21 00:00:00'
updated: '2020-02-21 00:00:00'
tags:
- spring-annotation
- spring
- java
categories:
- java
---

# SpringAnnotation-21-方法,构造器位置的自动装配

@Autowired: 构造器, 参数, 方法, 属性;

## 一. 将@Autowired标注在方法上

创建Car.java类

```java
package zone.wwwww.bean;

import org.springframework.stereotype.Component;

@Component
public class Boss {
}
```

创建Boss.java类, 包含一个Car属性, 并将@Autowired标注在setCar方法上(注, 可以标注在任意方法上)

```java
package zone.wwwww.bean;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class Boss {

    private Car car;

    public Car getCar() {
        return car;
    }

    @Autowired
    // 标在方法上, Spring容器创建当前对象, 就会调用该方法, 完成赋值
    // 方法使用的参数, 自定义类型的值从ioc容器中获取
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

修改MainConfig将Car和Boos扫描到容器

```java
@Configuration
@ComponentScan({"zone.wwwww.bean"})
public class MainConfig {

}
```

IOCTest

```java
package zone.wwwww.;

import zone.wwwww.bean.Boss;
import zone.wwwww.bean.Car;
import zone.wwwww.config.MainConfig;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

public class IOCTest {

    public static void main(String[] args) {
        // 获取IOC容器
        AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfig.class);
        // 打印boss
        Boss boss = applicationContext.getBean(Boss.class);
        System.out.println(boss);
        // 打印IOC容器中的car对象
        Car car = applicationContext.getBean(Car.class);
        System.out.println(car);
    }
}
```

程序输出

```
Boss{car=zone.wwwww.bean.Car@10d59286}
zone.wwwww.bean.Car@10d59286
```

> 可知, 向Boss中注入的Car是IOC容器中的car

## 二. 将@Autowired标注有参构造器上

修改Boss.java, 将@Autowird标注在有参构造器上

```java
package zone.wwwww.bean;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class Boss {

    private Car car;

    // 构造器要用的组件(参数), 也是从容器中获取
    // 如果只有一个有参构造器, 这个有参构造器的@Autowired可以省略, 参数位置的组件还是从IOC容器中获取
    @Autowired
    public Boss(Car car) {
        this.car = car;
        System.out.println("Boss的有参构造器...");
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

运行IOCTest, 程序输出

```
Boss的有参构造器...
Boss{car=zone.wwwww.bean.Car@24b1d79b}
zone.wwwww.bean.Car@24b1d79b
```

> 可知, Spring调用了Boss的有参构造器创建对象, 并且使用的参数是从IOC容器中获取的

## 二. 将@Autowired标注在参数上

### 2.1 标注在有参构造上

修改Boss.java, 将@Autowired标注在有参构造的参数位置

```java
package zone.wwwww.bean;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class Boss {

    private Car car;
    
    public Boss(@Autowired Car car) {
        this.car = car;
        System.out.println("Boss的有参构造器...");
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

执行IOCTest输出

```
Boss的有参构造器...
Boss{car=zone.wwwww.bean.Car@5123a213}
zone.wwwww.bean.Car@5123a213
```

> 与标注在有参构造上相同, 在创建Boss对象时, 调用其有参构造, 并使用IOC容器中的组件进行赋值

### 2.2 标注在普通方法参数上

修改Boss.java, 将@Autowired标注在setCar方法上

```java
package zone.wwwww.bean;

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

运行IOCTest输出

```
Boss{car=null}
zone.wwwww.bean.Car@704921a5
```

> 并没有对car进行赋值

### 2.3 标注在@Bean创建bean的方法参数上

修改Boss.java, 不使用@Component注解加入到容器

```java
package zone.wwwww.bean;

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

修改MainConfig, 使用@Bean方式添加Boss对象

```java
@Configuration
@ComponentScan({"zone.wwwww.bean"})
public class MainConfig {

    @Bean
    // 此处参数里的@Autowired可以省略
    public Boss boss(Car car) {
        Boss boss = new Boss();
        // 设置car
        boss.setCar(car);
        return boss;
    }
}
```

执行IOCTest, 程序输出

```
Boss{car=zone.wwwww.bean.Car@77846d2c}
zone.wwwww.bean.Car@77846d2c
```

> @Bean+方法参数, 默认不写@Autowired, 也可以自动装配, 注意使用set方法
