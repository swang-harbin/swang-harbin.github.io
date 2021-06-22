---
title: Spring Boot配置文件
date: '2019-12-16 00:00:00'
tags:
- Spring Boot
- Java
categories:
- Java
- SpringBoot基础系列
---

# Spring Boot配置文件

[SpringBoot基础系列目录](spring-boot-table.md)

## 配置文件

Spring Boot使用一个全局的配置文件, 配置文件名是固定的;

- application.properties
- application.yml

配置文件的作用 : 修改SpringBoot自动配置的默认值;

YAML(YAML Ain't Markup Language)

- YAML A Markup Language : 是一种标记语言
- YAML isn't Markup Language : 不是标记语言

标记语言 :

- 以前的配置文件, 大多都是用xxx.xml文件
- YAML : 以数据为中心, 比json, xml等更适合做配置文件

```yaml
# YAML配置例子
server:
  port: 8081
# 注意: port:与8081之间需要有一个空格

# XML配置的例子
#<server>
#    <port>8081</port>
#</server>
```

## YAML语法:

### 基本语法

k:(空格)v : 表示一堆键值对(空格必须有)

以**空格**的缩进来控制层级关系; 只要左对齐的一列数据, 都是同一层级的

```yaml
server: 
  port: 8081
  path: /hello
```

属性和值也是大小写敏感的

### 值的写法

#### 字面量 : 普通的值(数字, 字符串, 布尔)

`k: v `: 字面量直接来写, 字符串默认不用加上单双引号

`""`(双引号) : 不会转义字符串里面的特殊字符, 特殊字符会作为本身想表示的意思

```yaml
# 输出: zhangsan 换行 lisi
name: "zhangsan \n lisi"
```

`''`(单引号) : 会转义特殊字符, 特殊字符最终只是一个普通的字符串数据

```yaml
# 输出: zhangsan \n lisi
name: 'zhangsan \n lisi'
```

#### 对象(属性和值), Map(键值对) :

`k: v` : 在下一行来写对象的属性和值的关系, 注意缩进

```yaml
# 对象还是k: v的方式
friends:
  lastName: zhangsan
  age: 20
```

行内写法:

```yaml
friends: {lastName: zhangsan,age: 10}
```

#### 数组(List, Set) :

用`-`值表示数组中的一个元素

```yaml
pets:
  - cat
  - dog
  - pig
```

行内写法

```yaml
pets: {cat,dog,pig}
```

### 配置文件值注入

配置文件

```yaml
person:
  lastName: zhangsan
  age: 20
  boss: false
  birth: 2019/11/27
  maps: {k1: v1, k2: 12}
  lists:
    - lisi
    - zhaoliu
  dog:
    name: 小狗
    age: 2
```

javaBean

```java
/**
 * 将配置文件中配置的每一个属性的值, 映射到这个组件中
 * @ConfigurationProperties 告诉SpringBoot将本类中的所有属性和配置文件中相关的配置进行绑定
 * prefix = "person" : 和配置文件中哪个下面的所有属性进行一一映射
 *
 * 只有这个组件是容器中的组件, 才能使用容器提供的@ConfigurationProperties功能
 */
@Component
@ConfigurationProperties(prefix = "person")
public class Person {
    private String lastName;
    private Integer age;
    private Boolean boss;
    private Date birth;

    private Map<String, String> maps;
    private List<Object> lists;
    private Dog dog;
```

我们可以导入配置文件处理器, 以后编写配置就有提示了

```xml
<!--导入配置文件处理器, 配置文件进行绑定就会有提示-->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-configuration-processor</artifactId>
    <optional>true</optional>
</dependency>
```

`lastName: 张三` 和 `last-name: 张三` 是一样的

#### properties配置乱码问题

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222005022.png)

#### @Value获取值和@ConfigurationProperties获取值比较

| -                  | @ConfigurationProperties | @Value     |
| ------------------ | ------------------------ | ---------- |
| 功能               | 批量注入配置文件中的属性 | 一个个指定 |
| 松散绑定(松散语法) | 支持                     | 不支持     |
| SpEL               | 不支持                   | 支持       |
| JSR303数据校验     | 支持                     | 不支持     |
| 复杂类型封装       | 支持                     | 不支持     |

配置文件yml还是properties他们都能获取到值

如果, 只是在某个业务逻辑中需要获取一下某个属性的值, 用`@Value`

如果, 专门编写了一个JavaBean来和配置文件进行映射, 我们就直接使用`@ConfigurationProperties`

#### 配置文件注入值数据校验

```java
@Component
@ConfigurationProperties(prefix = "person")
@Validated
public class Person {

    /**
     * <bean class="Person"
     *      <property name="lastName" value="字面量/${key}从环境变量,配置文件中获取值/#{SpEL}"></property>
     */
    // @Value("${person.lastName}")
    // lastName必须为邮箱格式
    @Email
    private String lastName;
    @Value("#{11 * 2}")
    private Integer age;
    @Value("true")
    private Boolean boss;
```

#### @PropertySource和@ImportResource

`@ConfigurationProperties`注解默认从全局配置文件中获取值

**@PropertySource** : 加载指定的配置文件

```java
@Component
@ConfigurationProperties(prefix = "person")
@PropertySource(value = {"classpath:person.properties"})
public class Person {
```

**@ImportResource** : 导入Spring的配置文件, 让配置文件里面的内容生效

Spring Boot里面如果没有Spring的配置文件(application.yml/application.properties), 我们自己编写的配置文件, 也不能自动识别, 想让Spring的配置生效, 加载进来, 把`@ImportResource`标注在一个配置类上

```java
// 导入Spring的配置文件让其生效
@ImportResource(value = {"classpath:beans.xml"})
```

SpringBoot推荐使用全注解的方式给容器中添加组件:

- 原始xml方式

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd">

    <bean id="helloService" class="icu.intelli.springboot.bean.HelloService"></bean>
</beans>
```

1. 配置类就相当于Spring配置文件
2. 使用`@Bean`给容器中添加组件

```java
/**
 * @Configuration 指明当前类是一个配置类, 就是来替代之前的Spring配置文件
 */
@Configuration
public class MyAppConfig {

    // 将方法的返回值添加到容器中, 容器中这个组件默认的id就是方法名
    @Bean
    public HelloService helloService(){
        System.out.println("配置类给容器中添加组件了...");
        return new HelloService();
    }
}
```

## 配置文件占位符

### 随机数

```properties
$(random.value), $(random.int), $(random.long)
$(random.int(10)), $(random.int[1024, 65536])
```

### 占位符获取之前配置的值, 如果没有可以使用:获取默认值

```properties
person.last-name=张三${random.uuid}
person.age=${random.int}
person.birth=2017/12/15
person.boss=false
person.maps.k1=v1
person.maps.k2=v2
person.lists=a,b,c
person.dog.name=${person.hello:hello}_dog
person.dog.age=15
```

## Profile

Profile是Spring对不同环境提供不同配置功能的支持, 可以通过激活, 指定参数等方式快速切换环境

### 多Profile文件

在主配置文件编写的时候, 文件名可以是application-{profile}.properties/yml

默认使用application.properties/yml的配置

### yml支持多文档块方式

```yaml
server:
  port: 8081
spring:
  profiles:
    active: dev
```
