---
title: Spring Boot定时任务
date: '2020-01-15 00:00:00'
tags:
- Spring Boot
- Java
categories:
- Java
- SpringBoot基础系列
---

# SpringBoot定时任务

[SpringBoot基础系列目录](spring-boot-table.md)

**课程内容**

- Scheduled 定时任务器
- 整合Quartz定时任务框架

## Scheduled定时任务器

Scheduled定时任务器: 是Spring3.0以后自带的一个定时任务器

### 在pom.xml中添加scheduled的坐标

```xml
<dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-context-support</artifactId>
</dependency>
```

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222140010.png)

### 编写定时任务类

```java
package icu.intelli.scheduled;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

/**
 * Scheduled定时任务器
 */
@Component
public class ScheduledDemo {

    /**
     * 定时任务方法
     *
     * @Scheduled: 设置定时任务, 标记当前方法是定时任务方法
     * cron属性: cron表达式, 定时任务触发时间的字符串表达形式
     */
    @Scheduled(cron = "0/2 * * * * ?")
    public void scheduledMethod() {
        System.out.println("定时器被触发" + LocalDateTime.now());
    }
}
```

### 在启动类中开启定时任务的使用

```java
package icu.intelli;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * @EnableScheduling: 开启定时任务自动触发
 */
@SpringBootApplication
@EnableScheduling
public class Application {

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }

}
```

## Cron表达式

Cron表达式是一个字符串, 分为6或7个域, 每一个域代表一个含义

**Cron表达式有两种语法格式**

1. Seconds Minutes Hours Day Month Week Year
2. Seconds Minutes Hours Day Month Week

**结构 :**

corn从左到右(用空格隔开): 秒 分 小时 月份中的日期 月份 星期中的日期 年份

**各字段的含义**

| 位置 | 时间域名 | 允许值    | 允许的特殊字符 |
| ---- | -------- | --------- | -------------- |
| 1    | 秒       | 0-59      | , - * /        |
| 2    | 分钟     | 0-59      | , - * /        |
| 3    | 小时     | 0-23      | , - * /        |
| 4    | 日       | 1-31      | , - * / L W C  |
| 5    | 月       | 1-12      | , - * /        |
| 6    | 星期     | 1-7       | , - * / L C #  |
| 7    | 年(可选) | 1970-2099 | , - * /        |

Cron表达式的时间字段除允许设置数值外, 还可使用一些**特殊的字符**, 提供列表、范围、通配符等功能, 细说如下:

- 星号(`*`): 可用在所有字段中, 表示对应时间域的每一个时刻, 例如, `*`在分钟字段时, 表示"每分钟";
- 问号(`?`): 该字符只在日期和星期字段中使用, 它通常指定为"无意义的值", 相当于占位符;
- 减号(`-`): 表达一个范围, 如在小时字段中使用"10-12", 则表示从10到12点, 即10,11,12;
- 逗号(`,`): 表达一个列表值, 如在星期字段中使用"MON,WED,FRI", 则表示星期一, 星期三和星期五;
- 斜杠(`/`): `x/y`表达一个等步长序列, x为起始值, y为增量步长值. 如在分钟字段中使用`0/15`, 则表示为0,15,30和45秒, 而`5/15`在分钟字段中表示5,20,35,50, 你也可以使用`*/y`, 它等同于`0/y`;
- `L`: 该字符只在日期和星期字段中使用, 代表"Last"的意思, 但它在两个字段中意思不同. L在日期字段中, 表示这个月份的最后一天, 如一月的31号, 非闰年二月的28号; 如果L用在星期中, 则表示星期六, 等同于7. 但是, 如果L出现在星期字段里, 而且在前面有一个数值X, 则表示"这个月的最后X天", 例如, 6L表示该月的最后星期五;
- `W`: 该字符只能出现在日期字段里, 是对前导日期的修饰, 表示离该日期最近的工作日. 例如15W表示离该月15号最近的工作日, 如果该月15号是星期六, 则匹配14号星期五; 如果15日是星期日, 则匹配16号星期一; 如果15号是星期二, 那结果就是15号星期二. 但必须注意关联的匹配日期不能够跨月, 如你指定1W, 如果1号是星期六, 结果匹配的是3号星期一, 而非上个月最后的那天. W字符串只能指定单一日期, 而不能指定日期范围;
- `LW`组合: 在日期字段可以组合使用LW, 它的意思是当月的最后一个工作日;
- 井号(`#`): 该字符只能在星期字段中使用, 表示当月某个工作日. 如6#3表示当月的第三个星期五(6表示星期五, #3表示当前的第三个), 而4#5表示当月的第五个星期三, 假设当月没有第五个星期三, 忽略不触发;
- `C`: 该字符只在日期和星期字段中使用, 代表"Calendar"的意思. 它的意思是计划所关联的日期, 如果日期没有被关联, 则相当于日历中所有日期. 例如5C在日期字段中就相当于日历5日以后的第一天. 1C在星期字段中相当于星期日后的第一天. Cron表达式对特殊字符的大小写不敏感, 对代表星期的缩写英文大小写也不敏感.

**例子 :**

- `@Scheduled(cron = "0 0 1 1 1 ?")` : 每年一月的一号的1:00:00 执行一次
- `@Scheduled(cron = "0 0 1 1 1,6 ?")` : 一月和六月的一号的1:00:00 执行一次
- `@Scheduled(cron = "0 0 1 1 1,4,7,10 ?")` : 每个季度的第一个月的一号的1:00:00 执行一次
- `@Scheduled(cron = "0 0 1 1 * ?")` : 每月一号 1:00:00 执行一次
- `@Scheduled(cron="0 0 1 * * *")` : 每天凌晨1点执行一次

## Spring Boot整合Quartz定时任务框架

### Quartz介绍及使用思路

**quartz (开源项目)**

Quartz是OpenSymphony开源组织在Job scheduling(**作业调度**)领域又一个开源项目，它**可以与J2EE与J2SE应用程序相结合**也**可以单独使用**。Quartz可以用来创建简单或为运行十个，百个，甚至是好几万个Jobs这样复杂的程序。Jobs可以做成标准的Java组件或 EJBs。Quartz的最新版本为Quartz 2.3.0。

**使用思路 :**

1. job 任务,作业, 你要做什么事
2. Trigger 触发器, 你什么时候去做
3. Scheduler 任务调度, 你什么时候需要去做什么事

### Quartz的基本使用

建立普通maven项目, 在pom.xml中引入quartz

```xml
<dependency>
    <groupId>org.quartz-scheduler</groupId>
    <artifactId>quartz</artifactId>
    <version>2.3.0</version>
</dependency>
```

创建MyJob类

```java
package icu.intelli.quartz;

import org.quartz.Job;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

import java.util.Date;

/**
 * 定义任务类
 */
public class MyJob implements Job {

    /**
     * 任务被触发时, 所执行的方法
     *
     * @param context
     * @throws JobExecutionException
     */
    public void execute(JobExecutionContext context) throws JobExecutionException {
        System.out.println("execute..." + new Date());
    }
}
```

测试类

```java
package icu.intelli.quartz;

import org.quartz.*;
import org.quartz.impl.StdSchedulerFactory;

public class QuartzMain {
    public static void main(String[] args) throws SchedulerException {
        // 1. 创建Job对象, 做什么事
        JobDetail jobDetail = JobBuilder.newJob(MyJob.class).build();
        
        // 2. 创建Trigger对象, 在什么时候做
        // 简单的trigger触发时间, 通过quartz提供的一些方法, 来完成简单的重复调用
//        Trigger trigger = TriggerBuilder.newTrigger()
//                .withSchedule(SimpleScheduleBuilder.repeatSecondlyForever())
//                .build();
        // cron Trigger: 按照cron的表达式来给定触发时间
        Trigger trigger = TriggerBuilder.newTrigger()
                .withSchedule(CronScheduleBuilder.cronSchedule("0/2 * * * * ?"))
                .build();

        // 3. 创建Scheduler对象, 在什么时间做什么事
        Scheduler scheduler = StdSchedulerFactory.getDefaultScheduler();
        scheduler.scheduleJob(jobDetail, trigger);

        // 4. 启动
        scheduler.start();
    }
}
```

### SpringBoot整合Quartz

SpringBoot版本 1.5.x

引入依赖

```xml
<dependency>
    <groupId>org.quartz-scheduler</groupId>
    <artifactId>quartz</artifactId>
    <version>2.3.0</version>
    <exclusions>
        <exclusion>
            <artifactId>slf4j-api</artifactId>
            <groupId>org.slf4j</groupId>
        </exclusion>
    </exclusions>
</dependency>
<dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-context-support</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-tx</artifactId>
</dependency>
```

创建QuartzConfig配置类, 使用到的是简单Trigger

```java
package icu.intelli.config;

import icu.intelli.quartz.MyJob;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.quartz.JobDetailFactoryBean;
import org.springframework.scheduling.quartz.SchedulerFactoryBean;
import org.springframework.scheduling.quartz.SimpleTriggerFactoryBean;

/**
 * Quartz的配置类
 */
@Configuration
public class QuartzConfig {

    /**
     * 1. 创建Job对象
     */
    @Bean
    public JobDetailFactoryBean jobDetailFactoryBean() {
        JobDetailFactoryBean jobDetailFactoryBean = new JobDetailFactoryBean();
        // 关联我们自己的Job类
        jobDetailFactoryBean.setJobClass(MyJob.class);
        return jobDetailFactoryBean;
    }

    /**
     * 2. 创建Trigger对象
     * <p>
     * 简单的Trigger
     */
    @Bean
    public SimpleTriggerFactoryBean simpleTriggerFactoryBean(JobDetailFactoryBean jobDetailFactoryBean) {
        SimpleTriggerFactoryBean simpleTriggerFactoryBean = new SimpleTriggerFactoryBean();
        // 关联JobDetail对象
        simpleTriggerFactoryBean.setJobDetail(jobDetailFactoryBean.getObject());
        // 该参数表示一个执行的毫秒数
        simpleTriggerFactoryBean.setRepeatInterval(2000);
        // 该参数设置重复次数
        simpleTriggerFactoryBean.setRepeatCount(5);
        return simpleTriggerFactoryBean;
    }

    /**
     * 3. 创建Scheduler对象
     */
    @Bean
    public SchedulerFactoryBean schedulerFactoryBean(SimpleTriggerFactoryBean simpleTriggerFactoryBean) {
        SchedulerFactoryBean schedulerFactoryBean = new SchedulerFactoryBean();
        // 关联Trigger对象
        schedulerFactoryBean.setTriggers(simpleTriggerFactoryBean.getObject());
        return schedulerFactoryBean;
    }
}
```

修改启动类, 添加@EnableScheduling, 启动即可

```java
package icu.intelli;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * SpringBoot 整合Quartz的案例
 * <p>
 * 添加@EnableScheduling启动Quartz
 */
@SpringBootApplication
@EnableScheduling
public class Application {

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }

}
```

使用CronTrigger

```java
package icu.intelli.config;

import icu.intelli.quartz.MyJob;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.quartz.CronTriggerFactoryBean;
import org.springframework.scheduling.quartz.JobDetailFactoryBean;
import org.springframework.scheduling.quartz.SchedulerFactoryBean;

/**
 * Quartz的配置类
 */
@Configuration
public class QuartzConfig {

    /**
     * 1. 创建Job对象
     */
    @Bean
    public JobDetailFactoryBean jobDetailFactoryBean() {
        JobDetailFactoryBean jobDetailFactoryBean = new JobDetailFactoryBean();
        // 关联我们自己的Job类
        jobDetailFactoryBean.setJobClass(MyJob.class);
        return jobDetailFactoryBean;
    }

    /**
     * 2. 创建Trigger对象
     * <p>
     * Cron Trigger
     */
    @Bean
    public CronTriggerFactoryBean cronTriggerFactoryBean(JobDetailFactoryBean jobDetailFactoryBean) {
        CronTriggerFactoryBean cronTriggerFactoryBean = new CronTriggerFactoryBean();
        // 关联JobDetail
        cronTriggerFactoryBean.setJobDetail(jobDetailFactoryBean.getObject());
        // 设置Cron表达式
        cronTriggerFactoryBean.setCronExpression("0/2 * * * * ?");
        return cronTriggerFactoryBean;
    }

    /**
     * 3. 创建Scheduler对象
     */
    @Bean
    public SchedulerFactoryBean schedulerFactoryBean(CronTriggerFactoryBean cronTriggerFactoryBean) {
        SchedulerFactoryBean schedulerFactoryBean = new SchedulerFactoryBean();
        // 关联Trigger对象
        schedulerFactoryBean.setTriggers(cronTriggerFactoryBean.getObject());
        return schedulerFactoryBean;
    }
}
```

### 在Job类中注入Service

MyJob类实现了Job类

```java
package icu.intelli.quartz;

import icu.intelli.service.UserService;
import org.quartz.Job;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.Date;

public class MyJob implements Job {

    @Autowired
    private UserService userService;

    @Override
    public void execute(JobExecutionContext context) throws JobExecutionException {
        System.out.println("execute..." + new Date());
        userService.addUser();
    }
}
```

UserService

```java
package icu.intelli.service;

import org.springframework.stereotype.Service;

@Service
public class UserService {
    public void addUser() {
        System.out.println("addUser...");
    }
}
```

QuartzConfig

```java
package icu.intelli.config;

import icu.intelli.quartz.MyJob;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.quartz.CronTriggerFactoryBean;
import org.springframework.scheduling.quartz.JobDetailFactoryBean;
import org.springframework.scheduling.quartz.SchedulerFactoryBean;

@Configuration
public class QuartzConfig {

    @Bean
    public JobDetailFactoryBean jobDetailFactoryBean() {
        JobDetailFactoryBean jobDetailFactoryBean = new JobDetailFactoryBean();
        jobDetailFactoryBean.setJobClass(MyJob.class);
        return jobDetailFactoryBean;
    }

    @Bean
    public CronTriggerFactoryBean cronTriggerFactoryBean(JobDetailFactoryBean jobDetailFactoryBean) {
        CronTriggerFactoryBean cronTriggerFactoryBean = new CronTriggerFactoryBean();
        cronTriggerFactoryBean.setJobDetail(jobDetailFactoryBean.getObject());
        cronTriggerFactoryBean.setCronExpression("0/2 * * * * ?");
        return cronTriggerFactoryBean;
    }

    @Bean
    public SchedulerFactoryBean schedulerFactoryBean(CronTriggerFactoryBean cronTriggerFactoryBean) {
        SchedulerFactoryBean schedulerFactoryBean = new SchedulerFactoryBean();
        schedulerFactoryBean.setTriggers(cronTriggerFactoryBean.getObject());
        return schedulerFactoryBean;
    }
}
```

Application

```java
package icu.intelli;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class Application {

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }

}
```

**此时会出现NullPointerException, userService为null, 是因为jobDetailFactoryBean在实例化MyJob时, 实际上是使用AdaptableJobFactory类的createJobInstance方法, 改方法使用了反射机制创建对象, 并没有将MyJob对象放到IOC容器中, Spring要求被注入对象和注入对象都在IOC容器中, 所以UserService没有注入到MyJob中**

```java
@Configuration
public class QuartzConfig {
    @Bean
    public JobDetailFactoryBean jobDetailFactoryBean() {
        JobDetailFactoryBean jobDetailFactoryBean = new JobDetailFactoryBean();
        jobDetailFactoryBean.setJobClass(MyJob.class);
        return jobDetailFactoryBean;
    }

```

**解决方法 :**

创建MyAdaptableJobFactory

```java
package icu.intelli.config;

import org.quartz.spi.TriggerFiredBundle;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.config.AutowireCapableBeanFactory;
import org.springframework.scheduling.quartz.AdaptableJobFactory;
import org.springframework.stereotype.Component;

/**
 * @Component 实例化该类
 */
@Component("myAdaptableJobFactory")
public class MyAdaptableJobFactory extends AdaptableJobFactory {

    /**
     * AutowireCapableBeanFactory: 可以将一个对象添加到Spring的IOC容器中, 并且完成该对象的注入
     */
    @Autowired
    private AutowireCapableBeanFactory autowireCapableBeanFactory;

    /**
     * 该方法需要将实例化的对象手动添加到Spring的IOC容器中, 并完成对象的注入
     *
     * @param bundle
     * @return
     * @throws Exception
     */
    @Override
    protected Object createJobInstance(TriggerFiredBundle bundle) throws Exception {
        Object obj = super.createJobInstance(bundle);
        // 将obj对象添加到Spring的IOC容器中, 并完成注入
        autowireCapableBeanFactory.autowireBean(obj);
        return obj;
    }
}
```

修改QuartzConfig, 使用自定义的MyAdaptableJobFactory

```java
package icu.intelli.config;

import icu.intelli.quartz.MyJob;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.quartz.CronTriggerFactoryBean;
import org.springframework.scheduling.quartz.JobDetailFactoryBean;
import org.springframework.scheduling.quartz.SchedulerFactoryBean;

@Configuration
public class QuartzConfig {

    @Bean
    public JobDetailFactoryBean jobDetailFactoryBean() {
        JobDetailFactoryBean jobDetailFactoryBean = new JobDetailFactoryBean();
        jobDetailFactoryBean.setJobClass(MyJob.class);
        return jobDetailFactoryBean;
    }

    @Bean
    public CronTriggerFactoryBean cronTriggerFactoryBean(JobDetailFactoryBean jobDetailFactoryBean) {
        CronTriggerFactoryBean cronTriggerFactoryBean = new CronTriggerFactoryBean();
        cronTriggerFactoryBean.setJobDetail(jobDetailFactoryBean.getObject());
        cronTriggerFactoryBean.setCronExpression("0/2 * * * * ?");
        return cronTriggerFactoryBean;
    }

    @Bean
    public SchedulerFactoryBean schedulerFactoryBean(CronTriggerFactoryBean cronTriggerFactoryBean, MyAdaptableJobFactory myAdaptableJobFactory) {
        SchedulerFactoryBean schedulerFactoryBean = new SchedulerFactoryBean();
        schedulerFactoryBean.setTriggers(cronTriggerFactoryBean.getObject());
        // 重新设置JobFactory使用自定义的Factory
        schedulerFactoryBean.setJobFactory(myAdaptableJobFactory);
        return schedulerFactoryBean;
    }
}
```

