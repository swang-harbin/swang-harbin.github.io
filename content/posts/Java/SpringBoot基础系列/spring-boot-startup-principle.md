---
title: Spring Boot 启动配置原理
date: '2019-12-18 00:00:00'
tags:
- Spring Boot
- Java
---

# Spring Boot 启动配置原理

[Spring Boot 基础系列目录](spring-boot-table.md)

SpringBoot 1.5.9 版本

## 几个重要的事件回调机制

配置在 META-INF/spring.factories

- ApplicationContextInitializer
- SpringApplicationRunListener

只需要放在 IOC 容器中的

- ApplicationRunner
- CommandLineRunner

## 启动流程

### 创建 SpringApplication 对象

```java
initialize(sources)

private void initialize(Object[] sources) {
    // 保存主配置类
	if (sources != null && sources.length > 0) {
		this.sources.addAll(Arrays.asList(sources));
	}
	// 判断当前应用是否是 web 应用
	this.webEnvironment = deduceWebEnvironment();
	// 从类路径下找到 META-INF/spring.factories 配置的所有 ApplicationContestInitializer 并保存起来
	setInitializers((Collection) getSpringFactoriesInstances(
			ApplicationContextInitializer.class));
	// 从类路径下找到 META-INF/spring.factories 配置的所有 ApplicationListener 并保存起来
	setListeners((Collection) getSpringFactoriesInstances(ApplicationListener.class));
	// 从多个配置类中找到有 main 方法的主配置类
	this.mainApplicationClass = deduceMainApplicationClass();
}
```

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222134758.png)

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222134810.png)

### 运行 run 方法

```java
public ConfigurableApplicationContext run(String... args) {
    // 开始和停止的监听
    StopWatch stopWatch = new StopWatch();
    stopWatch.start();
    // 空的 IOC 容器
    ConfigurableApplicationContext context = null;
    FailureAnalyzers analyzers = null;
    // 与做 awt 应用相关的
    configureHeadlessProperty();
    // 获取 SpringApplicationRunListener；从类路径下 META-INF/spring.factories 中获取所有的监听器
    SpringApplicationRunListeners listeners = getRunListeners(args);
    // 回调所有的 SpringApplicationRunListener 的 starting 方法
    listeners.starting();
    try {
        // 封装命令行参数
        ApplicationArguments applicationArguments = new DefaultApplicationArguments(
            args);
        // 准备环境
        ConfigurableEnvironment environment = prepareEnvironment(listeners,
                                                                 applicationArguments);
        // 创建环境完成后回调 SpringApplicationRunListener 的 environmentPrepared(environment); 表示环境准备完成
        Banner printedBanner = printBanner(environment);
        // 创建 ApplicationContext，决定创建 Web 的 IOC 还是普通的 IOC
        context = createApplicationContext();
        analyzers = new FailureAnalyzers(context);
        // 准备上下文环境，将 environment 保存到 ioc 中，而且 applyInitializers(context)
        // applyInitializers：回调之前保存的所有 ApplicationContestInitializer 的所有 initialize 方法
        // 回调所有 ApplicationListener 的 contextPrepared(context) 方法
        prepareContext(context, environment, listeners, applicationArguments,
                       printedBanner);
        // prepareContext 运行完成以后回调所有 ApplicationListener 的 contextLoaded() 方法

        // 刷新容器：ioc 容器初始化的过程，如果是 web 应用还会创建嵌入式的 Tomcat
        // 扫描，创建，加载所有组件的地方(配置类，组件，自动配置等均在这添加到容器)
        refreshContext(context);
        // 从 ioc 容器中获取所有的 ApplicationRunner 和 CommandLineRunner 进行回调
        // ApplicationRunner 先回调，CommandLineRunner 再回调
        afterRefresh(context, applicationArguments);
        // 所有的 SpringApplicationRunListener 回调 finished 方法
        listeners.finished(context, null);
        stopWatch.stop();
        if (this.logStartupInfo) {
            new StartupInfoLogger(this.mainApplicationClass)
                .logStarted(getApplicationLog(), stopWatch);
        }
        // 整个 SpringBoot 应用启动完成后返回启动的 IOC 容器
        return context;
    }
    catch (Throwable ex) {
        handleRunFailure(context, listeners, analyzers, ex);
        throw new IllegalStateException(ex);
    }
}
```

**总结**

- run()
  - 准备环境
    - 执行 ApplicationContextInitializer.initialize()
    - 监听器 SpringApplicationRunListener 回调 contextPrepared
    - 加载主配置类定义信息
    - 监听器 SpringApplicationRunListener 回调 contextLoaded
  - 刷新启动 IOC 容器
    - 扫描加载所有容器中的组件
    - 包括从/META-INF/spring.factories 中获取所有的 EnableAutoConfiguration 组件
  - 回调容器中所有的 ApplicationRunner，CommandLineRunner 的 run 方法
  - 监听器 SpringApplicationRunListener 回调 finished

### 事件监听机制

**1. 创建实现 ApplicationContextInitializer 接口的类**

```java
public class HelloApplicationContextInitialier implements ApplicationContextInitializer<ConfigurableApplicationContext> {
    @Override
    public void initialize(ConfigurableApplicationContext applicationContext) {
        System.out.println("HelloApplicationContextInitialier...initialize..." + applicationContext);
    }
}
```

**2. 创建实现 SpringApplicationRunListener 接口的类**

```java
public class HelloSpringApplicationRunListener implements SpringApplicationRunListener {
    @Override
    public void starting() {
        System.out.println("HelloSpringApplicationRunListener...strting...");
    }

    @Override
    public void environmentPrepared(ConfigurableEnvironment environment) {
        Object o = environment.getSystemProperties().get("os.name");
        System.out.println("HelloSpringApplicationRunListener...environmentPrepared..." + o);
    }

    @Override
    public void contextPrepared(ConfigurableApplicationContext context) {
        System.out.println("HelloSpringApplicationRunListener...contextPrepared...");
    }

    @Override
    public void contextLoaded(ConfigurableApplicationContext context) {
        System.out.println("HelloSpringApplicationRunListener...contextLoaded...");

    }

    @Override
    public void finished(ConfigurableApplicationContext context, Throwable exception) {
        System.out.println("HelloSpringApplicationRunListener...finished...");
    }
}
```

**3. 创建实现 ApplicationRunner 接口的类，并将其添加到容器中**

```java
@Component
public class HelloApplicationRunner implements ApplicationRunner {
    @Override
    public void run(ApplicationArguments args) throws Exception {
        System.out.println("ApplicationArguments...run...");
    }
}
```

**4. 创建实现 CommandLineRunner 接口的类，并将其添加到容器中**

```java
@Component
public class HelloCommandLineRunner implements CommandLineRunner {
    @Override
    public void run(String... args) throws Exception {
        System.out.println("HelloCommandLineRunner...run...");
    }
}
```

**5. 在根目录下创建 /META-INFO/spring.factories，配置自定义的 SpringApplicationRunListener 和 ApplicationContextInitializer**

```properties
org.springframework.boot.SpringApplicationRunListener=\
icu.intelli.listener.HelloSpringApplicationRunListener

org.springframework.context.ApplicationContextInitializer=\
icu.intelli.listener.HelloApplicationContextInitialier
```

**6. 启动 SpringBoot 应用会报错**

```
Exception in thread "main" java.lang.IllegalArgumentException: Cannot instantiate interface org.springframework.boot.SpringApplicationRunListener : icu.intelli.listener.HelloSpringApplicationRunListener
xxxxxxxxx
Caused by: java.lang.NoSuchMethodException: icu.intelli.listener.HelloSpringApplicationRunListener.<init>(org.springframework.boot.SpringApplication, [Ljava.lang.String;)
xxxxxxxxx
```

需要在 HelloSpringApplicationRunListener 中添加一个有参的构造，可以参照 SpringApplicationRunListener 接口的其他实现类

**7. 在 HelloSpringApplicationRunListener 中添加有参构造**

```java
public HelloSpringApplicationRunListener(SpringApplication application, String[] args) {}
```

**8. 重新启动 SpringBoot 应用**

