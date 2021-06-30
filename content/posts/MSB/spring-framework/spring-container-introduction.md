---
title: Spring 容器
date: '2020-07-04 00:00:00'
tags:
- MSB
- 源码
- Spring
- Java
---
# Spring 容器

## Spring 介绍

1. Spring 是什么？

   > 框架 生态。

2. 为什么阅读源码？

   > 要学习它的扩展性。

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2020/20201218134322.png)



Spring 包含两大特性，IOC 和 AOP，需要搞清楚 IOC，才能学习 AOP。

DI 是实现 IOC 的手段

IOC 容器：用于存放 Bean 对象

## 基础回顾

### 配置文件创建 Bean 的方式

#### 1. 通过无参构造器创建，set 方法赋值

```xml
<beans>
	<bean id="xx" class="xx" abstract init-method scope dependon...>
    	<propertie name="xx", value="xx" />
    	<propertie name="xx", value="xx" />
    </bean>
</beans>
```

#### 2. 通过有参构造器创建

```xml
<beans>
	<bean id="xx" class="xxx" abstract init-method scope dependon...>
    	<constructor name="xx" value="xx" />
    	<constructor name="xx" value="xx" />
    </bean>
</beans>
```

### 获取 Bean 的方式

```java
// 使用指定配置文件加载 ApplicationContext，ApplicaitonContext 中一定包含配置文件中配置的 Bean 对象
ApplicationContext ac = new ClassPathXmlApplicationContext("applicationContext.xml");
Xxx xxx = ac.getBean(Xxx.class);
xxx.method();
```

## 分析 xml 转化为 Bean 的过程

我们需要将 xml 中定义的信息加载到 IOC 容器中，然后通过 IOC 容器获取相应的 Bean。

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2020/20201218113005.png)

xml 中使用 bean 标签配置的其实是 Bean 的 BeanDefinition 信息，通过 BeanDefinition 将相应的 Bean 进行实例化

## 容器

Spring 中的 IOC 容器，其实就是多个 Map，因为使用 Map 可以更灵活快速的获取到对应的 Bean 对象。其中 Map 的 Key 和 Value 可以有以下类型

```
// getBean 方法可以根据 Bean 的名称和类型获取 Bean
Key: String	Val: Object
Key: class Val: Object
// 三级缓存时用到的
Key: String Val: ObjectFactory
// 用于获取对象的定义信息
Key: String Val: BeanDefinition
```

### 配置文件向 Bean 转化的详细流程（Bean 的生命周期）

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2020/20201218170257.png)

#### 1. xml -> BeanDefinition

xml/properties/yaml 中存储的是 bean 的定义信息，为了便于统一使用，我们需要把它解析成 BeanDefinition 类型的对象，这样在后续使用 Bean 的时候统一处理 BeanDefinition 类型的对象就可以了。

而为了便于扩展，比如说要支持 json 格式的配置文件，抽象出一个 BeanDefinitionReader 类型的接口，用于定义配置文件的转换规则。

转换后的 BeanDefinition 对象还可以通过 BeanFactoryPostProcessor 接口的实现类对其进行增强处理，例如设置是否懒加载等。

```java
public class MyBeanFactoryPostProcessor implements BeanFactoryPostProcessor {
	@Override
	public void postProcessBeanFactory(ConfigurableListableBeanFactory beanFactory) throws BeansException {
		BeanDefinition a = beanFactory.getBeanDefinition("A");
		System.out.println("增强 BeanDefinition...");
	}
}
```

#### 2. BeanDefinition → 实例化 Bean 对象

通过 BeanDefinition 对象，使用反射来对相应的 Bean 对象进行实例化操作。

**思考问题**

1. 为什么使用反射而不使用 new？

   因为反射更加灵活，可以获取到对象上的属性，方法，注解等信息。

#### 3. 实例化 Bean 对象 → 初始化 Bean 对象

1. 首先通过对象的 set 方法给对象的属性赋值
2. 如果实现了 Aware 接口，则调用 Aware 接口中定义的方法
3. 调用 BeanPostProcessor 类的 before 方法，对 Bean 对象前置增强
4. 调用 init-method
5. 调用 BeanPostProcessor 类的 after 方法，对 Bean 对象进行后置增强
6. 最终创建出完整的 Bean 对象，此时就可通过 ApplicationContext 的 getBean 方法获取相应对象了

**思考问题**

1. 在容器运行过程中，需要动态改变 Bean 的定义信息，怎么办？

   例如在创建数据库连接对象时，需要替换 SPEL 表达式代表的值

   ```xml
   <property name="url" value="${jdbc.url}" />
   ```

   > 此处就是通过使用 BeanFactoryPostProcessor 来进行处理的，同时 AOP 的动态代理，使用的 AbstractAutoProxyCreator 类也是实现了 BeanPostProcessor 接口

2. BeanFactoryPostProcessor 和 BeanPostProcessor 区别

   >  都是后置处理器/增强器，BeanFactoryPostProcessor 用来增强 BeanDefinition 信息，BeanPostProcessor 用来增强 Bean 的信息

3. 实例化和初始化的区别

   > 实例化：在堆中开辟一片空间，给属性赋默认值（例如 int 为 0，String 为 null）
   >
   > 初始化：给实例化后的对象设置属性值，然后执行构造方法，然后执行初始化方法（init-method）

4. 容器对象和普通对象的理解

   > 容器对象相当于内置对象，是容器自己需要的对象；普通对象是我们自定义的对象，写在 xml 中的。

5. Aware 接口的作用

   > 当 Spring 容器创建自定义对象时，如果需要使用到容器对象，此时可通过让自定义对象实现相应 Aware 接口的方法，来进行注入，从而满足需求。
   >
   > 例如：ApplicationContextAware，EnvironmentAware，BeanNameAware。

6. 在初始化的不同的阶段要处理不同的工作，应该怎么办？

   > 观察者模式：监听器，监听事件，多播器（广播器）

## 常用接口

- BeanFactory：IOC 容器的入口

  - DefaultListableBeanFactory
  - AutowireCapableBeanFactory

- BeanDefinitionReader：定义配置文件的解析规则

- BeanDefinition：配置文件中的 bean 标签会被封装为该类型的对象

- BeanFactoryPostProcessor：对 BeanDefinition 进行增强

- BeanDefinitionRegistry：用来对容器中的 BeanDefinition 进行增删改查操作

- Aware：用于向普通对象中注入容器对象

- BeanPostProcessor：在执行普通对象的 init-method 前后进行增强处理

- Environment：包含系统的环境和配置信息

  - StandardEnvironment
    - System.getenv();
    - System.getProperties();

- FactoryBean：自定义普通对象的创建流程

  > FactoryBean 和 BeanFactory 的区别？
  >
  > 都是用来创建对象的。当使用 BeanFactory 的时候，必须要遵循完整的创建过程，该过程是由 Spring 来管理控制的；而使用 FactoryBean 只需要调用 getObject 就可以返回具体的对象，整个对象的创建过程是由用户自己来控制的，更加灵活。实现 FactoryBean 的类，在容器已经创建结束后，首次调用 getBean 方法是才会创建出来。

