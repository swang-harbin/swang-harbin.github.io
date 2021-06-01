---
title: SpringAnnotation-25-AOP功能测试
date: '2020-02-22 00:00:00'
updated: '2020-02-22 00:00:00'
tags:
- spring-annotation
- spring
- java
categories:
- java
---


SpringAnnotation-25-AOP功能测试

**AOP :** 指在程序运行期间动态的将某段代码切入到指定方法指定位置进行运行的编程方式.(底层使用动态代理)

**相关名词解释**

1. Proxy(代理): 为目标对象生成代理对象. 即在不改变原始代码的情况下, 通过代理对象对原始对象的功能进行增强. Spring主要使用JDK动态代理和CGLIB代理.
2. Target(目标对象): 被代理的对象, 需要增强的对象, 即真正的业务逻辑类.
3. Joinpoint(连接点): 目标对象中所有可以增强的方法
4. Advice(通知/增强): 具体的增强方法, 例如日志记录等.
5. Pointcut(切入点): 带有通知的连接点, 即目标对象中需要被增强的方法.
6. Aspect(切面): 通常是一个类, 里面定义了切入点和通知.
7. Weaving(织入): 将增强添加到目标对象的连接点的过程. Spring使用运行时织入, AspectJ使用编译期织入和类加载期织入
8. Introduction(引入): 对目标对象声明额外属性和方法的过程.

从原始代码的所有方法(连接点)中, 选择指定的方法(切入点), 组合成一个切面类(切面), 在不改变原始业务类(目标对象)代码的情况下, 通过切面创建(代理)对象(引入), 在指定业务方法执行的某一时刻添加(织入)日志记录等功能(通知/增强).

## 一. Spring使用AOP的步骤

1. 导入aop模块: spring-aspects

```xml
<dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-aspects</artifactId>
    <version>4.3.25.RELEASE</version>
</dependency>
```

1. 定义业务逻辑类(MathCalculator): 在业务逻辑运行时将日志进行打印(方法之前, 方法运行结束, 方法出现异常, ...)

```java
package zone.wwwww.aop;

public class MathCalculator {

    public int div(int i, int j) {
        System.out.println("MathCalculator.div()...");
        return i / j;
    }
}
```

1. 定义一个日志切面类

切面类中的方法需要动态感知MathCalculator.div()运行到哪里了, 然后动态执行.

**通知方法 :**

- 前置通知(@Before): 在目标方法运行前运行
- 后置通知(@After): 在目标方法运行结束后运行
- 返回通知(@AfterReturning): 在目标方法正常返回之后运行
- 异常通知(@AfterThrowing): 在目标方法运行出现异常后运行
- 环绕通知(@Around): 动态代理, 手动推进目标方法运行(joinPoint.proced()

```java
package zone.wwwww.aop;

public class LogAspects {
    public void logStart() {
        System.out.println("除法运行...参数列表是: {}");
    }

    public void logEnd() {
        System.out.println("除法结束...");
    }

    public void logReturn() {
        System.out.println("除法正常返回...运行结果: {}");
    }

    public void logException() {
        System.out.println("除法异常...异常信息: {}");
    }
}
```

1. 给切面类的目标方法标注何时何地运行(通知注解)

```java
package zone.wwwww.aop;

import org.aspectj.lang.annotation.*;

/**
 * 切面类
 */
public class LogAspects {

    /**
     * 抽取公共的切入点表达式
     * // 1. 本类引用
     * @Pointcut()
     * public void pointCut() { }
     */
    // 2. 其他的切面类引用
    @Pointcut("execution(public int zone.wwwww.aop.MathCalculator.*(..))")
    public void pointCut() {
    }

    // @Before在目标方法之前切入;
    // public int zone.wwwww.aop.MathCalculator.div(int, int) : 切入点表达式, 指定在哪个方法切入
    @Before("pointCut()")
    public void logStart() {
        System.out.println("@Before除法运行...参数列表是: {}");
    }

    // 无论方法正常结束还是异常结束都调用
    @After("pointCut()")
    public void logEnd() {
        System.out.println("@After除法结束...");
    }

    @AfterReturning("pointCut()")
    public void logReturn() {
        System.out.println("@AfterReturning除法正常返回...运行结果: {}");
    }

    @AfterThrowing("pointCut()")
    public void logException() {
        System.out.println("@AfterThrowing除法异常...异常信息: {}");
    }
}
```

1. 将切面类和业务逻辑类(目标方法所在类)都加入到容器中

```java
package zone.wwwww.config;

import zone.wwwww.aop.LogAspects;
import zone.wwwww.aop.MathCalculator;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class MainConfig {

    // 业务逻辑类加入到容器中
    @Bean
    public MathCalculator calculator() {
        return new MathCalculator();
    }

    // 将切面类加入到容器中
    @Bean
    public LogAspects logAspects() {
        return new LogAspects();
    }

}
```

1. 告诉Spring哪个类是切面类, 给切面类上添加@Aspect

```java
/**
 * 切面类
 * 如果同一连接点上有多个切面时, 可以使用@Order注解在切面类上或实现Ordered接口指定切面的优先级, 数字越小优先级越高
 */
@Aspect // 告诉Spring该类是切面类
public class LogAspects {
```

1. 给配置类中加入@EnableAspectJAutoProxy注解, 开启基于注解的AOP模式

在Spring中有很多的@EnableXxx注解来启动某些功能

```java
@EnableAspectJAutoProxy
@Configuration
public class MainConfig {
```

1. AOPTest测试类

```java
package zone.wwwww;

import zone.wwwww.aop.MathCalculator;
import zone.wwwww.config.MainConfig;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

public class AOPTest {

    public static void main(String[] args) {
        AnnotationConfigApplicationContext applicationContext = new AnnotationConfigApplicationContext(MainConfig.class);
        // 注意, 一定要使用从容器中获取的Bean, 自己创建的Bean不支持AOP
        MathCalculator mathCalculator = applicationContext.getBean(MathCalculator.class);
        mathCalculator.div(1, 1);
    }
}
```

程序输出

```
@Before除法运行...参数列表是: {}
MathCalculator.div()...
@After除法结束...
@AfterReturning除法正常返回...运行结果: {}
```

## 二. 在切面类中获取方法的返回值等信息

修改LogAspects, 在切面方法中添加JoinPoint参数

```java
package zone.wwwww.aop;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.*;

/**
 * 切面类
 */
@Aspect // 告诉Spring该类是切面类
public class LogAspects {

    /**
     * 抽取公共的切入点表达式
     * // 1. 本类引用
     *
     * @Pointcut() public void pointCut() { }
     */
    // 2. 其他的切面类引用
    @Pointcut("execution(public int zone.wwwww.aop.MathCalculator.*(..))")
    public void pointCut() {
    }

    // @Before在目标方法之前切入;
    // public int zone.wwwww.aop.MathCalculator.div(int, int) : 切入点表达式, 指定在哪个方法切入
    @Before("pointCut()")
    public void logStart(JoinPoint joinPoint) {
        String methodName = joinPoint.getSignature().getName();
        Object[] methodArgs = joinPoint.getArgs();
        System.out.println(methodName + "@Before...参数列表是: {" + methodArgs + "}");
    }

    // 无论方法正常结束还是异常结束都调用
    @After("pointCut()")
    public void logEnd(JoinPoint joinPoint) {
        String methodName = joinPoint.getSignature().getName();
        System.out.println(methodName + "@After除法结束...");
    }

    // 使用@AfterReturning的resulting参数来指定使用result参数接收方法的返回值
    @AfterReturning(value = "pointCut()", returning = "result")
    public void logReturn(JoinPoint joinPoint, Object result) {
        String methodName = joinPoint.getSignature().getName();
        System.out.println(methodName + "@AfterReturning除法正常返回...运行结果: {" + result + "}");
    }

    // 使用@AfterThrowing的throwing参数来指定使用exception参数接收方法的异常信息
    @AfterThrowing(value = "pointCut()", throwing = "exception")
    public void logException(JoinPoint joinPoint, Exception exception) {
        String methodName = joinPoint.getSignature().getName();
        System.out.println(methodName + "@AfterThrowing除法异常...异常信息: {" + exception + "}");
    }
}
```

注意: 使用@AfterReturning和@AfterThrowing标注的方法参数, JointPoint要放在第一个参数位置, Object和Exception放在第二个参数位置

测试输出

```
div@Before...参数列表是: {[Ljava.lang.Object;@7b98f307}
MathCalculator.div()...
div@After除法结束...
div@AfterReturning除法正常返回...运行结果: {1}
```

## 三. 总结

三步:

1. 将业务逻辑组件和切面类都加入到容器中, 告诉Spring哪个是切面类(@Aspect)
2. 在切面类上的每一个通知方法上标注通知注解, 告诉Spring何时何地运行(切入点表达式)
3. 开启基于注解的AOP模式@EnableAspectJAutoProxy

## 四. 配置文件版AOP

1. 导入依赖

```xml
<dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-aspects</artifactId>
    <version>4.3.25.RELEASE</version>
</dependency>
```

1. 切面类和目标对象

切面类LogAspects

```java
import org.aspectj.lang.JoinPoint;

/**
 * 切面类
 */
public class LogAspects {

    public void logStart(JoinPoint joinPoint) {
        String methodName = joinPoint.getSignature().getName();
        Object[] methodArgs = joinPoint.getArgs();
        System.out.println(methodName + "@Before...参数列表是: {" + methodArgs + "}");
    }

    public void logEnd(JoinPoint joinPoint) {
        String methodName = joinPoint.getSignature().getName();
        System.out.println(methodName + "@After除法结束...");
    }

    public void logReturn(JoinPoint joinPoint, Object result) {
        String methodName = joinPoint.getSignature().getName();
        System.out.println(methodName + "@AfterReturning除法正常返回...运行结果: {" + result + "}");
    }

    public void logException(JoinPoint joinPoint, Exception exception) {
        String methodName = joinPoint.getSignature().getName();
        System.out.println(methodName + "@AfterThrowing除法异常...异常信息: {" + exception + "}");
    }
}
```

目标对象类MathCalculator

```java
public class MathCalculator {

    public int div(int i, int j) {
        System.out.println("MathCalculator.div()...");
        return i / j;
    }
}
```

1. 修改beans.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:aop="http://www.springframework.org/schema/aop"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd http://www.springframework.org/schema/aop https://www.springframework.org/schema/aop/spring-aop.xsd">

    <!-- 配置需要增强的bean -->
    <bean id="mathCalculator" class="zone.wwwww.aop.MathCalculator"/>
    <!-- 配置切面类 -->
    <bean id="logAspects" class="zone.wwwww.aop.LogAspects"/>

    <!-- 配置AOP -->
    <aop:config>
        <!-- 配置切点表达式 -->
        <aop:pointcut id="pointcut" expression="execution(* zone.wwwww.aop.MathCalculator.*(..))"/>
        <!-- 配置切面及通知, 可添加order属性指定切面的优先级-->
        <aop:aspect ref="logAspects">
            <aop:before method="logStart" pointcut-ref="pointcut"/>
            <aop:after method="logEnd" pointcut-ref="pointcut"/>
            <aop:after-returning method="logReturn" pointcut-ref="pointcut" returning="result"/>
            <aop:after-throwing method="logException" pointcut-ref="pointcut" throwing="exception"/>
        </aop:aspect>
    </aop:config>
    
</beans>
```

1. 测试类AOPTest

```java
import zone.wwwww.aop.MathCalculator;
import org.springframework.context.support.ClassPathXmlApplicationContext;

public class AOPTest {

    public static void main(String[] args) {
        ClassPathXmlApplicationContext applicationContext = new ClassPathXmlApplicationContext("classpath:beans.xml");
        MathCalculator mathCalculator = applicationContext.getBean(MathCalculator.class);
        mathCalculator.div(0, 1);
    }
}
```
