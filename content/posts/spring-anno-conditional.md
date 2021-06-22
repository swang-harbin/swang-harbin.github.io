---
title: Spring注解-@Conditional按照条件注册Bean
date: '2020-02-18 00:00:00'
tags:
- Spring
- Spring Annotation
- Java
categories:
- Java
- Spring注解系列
---

# Spring注解-@Conditional按照条件注册Bean

[跳到Spring注解系列目录](spring-anno-table.md)

Conditional, 按照一定的条件进行判断, 满足条件才往容器中注册bean, 既可以放在方法上, 也可以放在类上

## 注解在方法上

MainConfig.java, 向容器中添加两个Person类的对象, bill和linus

```java
@Configuration
public class MainConfig {
    @Bean("bill")
    public Person person01() {
        return new Person("Bill Gates", 62);
    }

    @Bean("linus")
    public Person person02() {
        return new Person("linus", 48);
    }
}
```

IOCTest.java, 输出系统名称和所有在容器中的Person类对象

```java
public class IOCTest {
    public static void main(String[] args) {
        // 获取IOC容器
        ApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfig.class);

        Environment environment = applicationContext.getEnvironment();
        // 动态获取操作系统的名称
        String property = environment.getProperty("os.name");
        System.out.println("操作系统的名称为: " + property);

        // 获取容器中所有Person类对象的名字
        String[] namesForType = applicationContext.getBeanNamesForType(Person.class);
        for (String name : namesForType) {
            System.out.println(name);
        }
        // 获取容器中Person类型的对象
        Map<String, Person> beansOfType = applicationContext.getBeansOfType(Person.class);
        System.out.println(beansOfType);

    }
}
```

此时, 程序输出如下, 包含bill和linus

```
操作系统的名称为: Linux
bill
linus
{bill=Person{name='Bill Gates', age=62}, linus=Person{name='linus', age=48}}
```

**现在有一需求, 若系统为Windos则, 向容器中注入bill; 若系统为Linux, 则向容器中注入linus.**

如下可知, @Conditional中需要放置Condition类型的数组

```java
public @interface Conditional {
	/**
	 * All {@link Condition}s that must {@linkplain Condition#matches match}
	 * in order for the component to be registered.
	 */
	Class<? extends Condition>[] value();
}
```

因此, 创建LinuxCondition和WindowsCondition, 实现Condition接口

LinuxCondition.java

```java
package icu.intelli.condition;

import org.springframework.beans.factory.config.ConfigurableListableBeanFactory;
import org.springframework.beans.factory.support.BeanDefinitionRegistry;
import org.springframework.context.annotation.Condition;
import org.springframework.context.annotation.ConditionContext;
import org.springframework.core.env.Environment;
import org.springframework.core.type.AnnotatedTypeMetadata;

/**
 * 判断系统是否时Linux
 */
public class LinuxCondition implements Condition {

    /**
     * @param context  判断条件能使用的上下文(环境)
     * @param metadata 注释信息
     * @return
     */
    public boolean matches(ConditionContext context, AnnotatedTypeMetadata metadata) {

        // 1. 能获取到ioc使用的beanfactory
        ConfigurableListableBeanFactory beanFactory = context.getBeanFactory();

        //2. 获取类加载器
        ClassLoader classLoader = context.getClassLoader();

        // 3. 获取当前环境信息
        Environment environment = context.getEnvironment();

        // 4. 获取到bean定义的注册类
        BeanDefinitionRegistry registry = context.getRegistry();

        // 是否Linux系统, Unix Linux
        return environment.getProperty("os.name").contains("nux");
    }
}
```

WindosCondition.java

```java
package icu.intelli.condition;

import org.springframework.context.annotation.Condition;
import org.springframework.context.annotation.ConditionContext;
import org.springframework.core.env.Environment;
import org.springframework.core.type.AnnotatedTypeMetadata;

/**
 * 判断系统是否为Windos
 */
public class WindowsCondition implements Condition {

    public boolean matches(ConditionContext context, AnnotatedTypeMetadata metadata) {

        Environment environment = context.getEnvironment();

        // 是否Windows系统, Windows
        return environment.getProperty("os.name").contains("indows");
    }
}
```

修改MainConfig, 添加@Conditional注解

```java
package icu.intelli.config;

import icu.intelli.bean.Person;
import icu.intelli.condition.LinuxCondition;
import icu.intelli.condition.WindowsCondition;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Conditional;
import org.springframework.context.annotation.Configuration;

@Configuration
public class MainConfig {

    /**
     * @Conditional({Condition}), 按照一定的条件进行判断, 满足条件才将bean注册到容器中
     */
    @Conditional({WindowsCondition.class})
    @Bean("bill")
    public Person person01() {
        return new Person("Bill Gates", 62);
    }

    @Conditional({LinuxCondition.class})
    @Bean("linus")
    public Person person02() {
        return new Person("linus", 48);
    }
}
```

执行IOCTest, 程序输出

```
os.name: Linux
linus
{linus=Person{name='linus', age=48}}
```

修改VM options`-Dos.name="Windows 10"`, 执行IOCTest, 程序输出

```
os.name: Windows 10
bill
{bill=Person{name='Bill Gates', age=62}}
```

## 注解在类上

修改MainConfig.java

```java
/**
* 注解在类上, 只有符合条件, 这个类中的bean注册才能生效
*/
@Conditional({LinuxCondition.class})
@Configuration
public class MainConfig {

    @Conditional({WindowsCondition.class})
    @Bean("bill")
    public Person person01() {
        return new Person("Bill Gates", 62);
    }

    @Conditional({LinuxCondition.class})
    @Bean("linus")
    public Person person02() {
        return new Person("linus", 48);
    }
}
```

执行IOCTest, 程序输出

```
os.name: Windows 10
{}
```

取消对VM option的修改, 执行IOCTest, 程序输出

```
os.name: Linux
linus
{linus=Person{name='linus', age=48}}
```
