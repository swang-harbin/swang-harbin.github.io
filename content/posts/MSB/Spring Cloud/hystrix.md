---
title: Hystrix
date: '2020-07-04 00:00:00'
tags:
- MSB
- Spring Cloud
- Hystrix
- Java
---
# Hystrix

## 相关概念

### 熔断

微服务相互调用时，如果某个服务依赖的服务失效（网络延时，服务异常，负载过大服务响应等问题），就会造成微服务级联异常。所以要隔离坏的服务，不让坏服务拖垮其他服务。

简而言之就是 consumer 对某个 provider 服务重复调用几次都失败之后，就不再调用该服务了，下次再调用该 provider 的时候，consumer 就不再向该 provider 发送请求，直接通过降级等机制给客户返回结果。

### 舱壁模式

舱壁模式（Bulkhead）隔离每个工作负载或服务的关键资源，如连接池，内存和 CPU，硬盘。每个工作单元都有独立的连接池，内存，CPU。

使用舱壁避免了单个服务消耗掉所有资源，从而导致其他服务出现故障的场景。
这种模式主要是通过防止由一个服务引起的级联故障来增加系统的弹性。

思路：可以对每个请求设置单独的连接池，配置线程数，超过线程数的根据拒绝策略进行处理，可以保证某个接口瘫痪后，不会影响别的接口

### 雪崩效应

每个服务发出一个 HTTP 请求都会在服务中开启一个新线程。而下游服务挂了或者网络不可达，通常线程会阻塞住，直到 Timeout。如果并发量多一点，这些阻塞的线程就会占用大量的资源，很有可能把自己本身这个微服务所在的机器资源耗尽，导致自己也挂掉。

如果服务提供者响应非常缓慢，那么服务消费者调用此提供者就会一直等待，直到提供者响应或超时。在高并发场景下，此种情况，如果不做任何处理，就会导致服务消费者的资源耗竭甚至整个系统的崩溃。一层一层的崩溃，导致所有的系统崩溃。

雪崩：由基础服务故障导致级联故障的现象。

描述的是：提供者不可用导致消费者不可用，并将不可用逐渐放大的过程。像滚雪球一样，不可用的服务越来越多。影响越来越恶劣。

雪崩的三个流程

1. 服务提供者不可用
2. 重试会导致网络流量加大，更影响服务提供者
3. 导致服务消费者不可用。服务消费者一直等待返回，一直占用系统资源。（不可用的范围被逐渐放大）

服务不可用的原因

- 服务器宕机
- 网络故障
- 程序异常
- 负载过大，导致服务提供者响应慢
- 缓存击穿导致服务超负荷运行

### 容错机制

1. 为网络请求设置超时。

   必须为网络请求设置超时。一般的调用一般在几十毫秒内响应。如果服务不可用，或者网络有问题，那么响应时间会变很长。长到几十秒。

   每一次调用，对应一个线程或进程，如果响应时间长，那么线程就长时间得不到释放，而线程对应着系统资源，包括 CPU，内存，得不到释放的线程越多，资源被消耗的越多，最终导致系统崩溃。

   因此必须设置超时时间，让资源尽快释放。

2. 使用断路器模式。

   想一下家里的保险丝，跳闸。如果家里有短路或者大功率电器使用，超过电路负载时，就会跳闸，如果不跳闸，电路烧毁，波及到其他家庭，导致其他家庭也不可用。通过跳闸保护电路安全，当短路问题，或者大功率问题被解决，在合闸。

   自己家里电路，不影响整个小区每家每户的电路。

### 断路器

如果对某个微服务请求有大量超时（说明该服务不可用），再让新的请求访问该服务就没有意义，只会无谓的消耗资源。例如设置了超时时间 1s，如果短时间内有大量的请求无法在 1s 内响应，就没有必要去请求依赖的服务了。

1. 断路器是对容易导致错误的操作的代理。这种代理能统计一段时间内的失败次数，并依据次数决定是正常请求依赖的服务还是直接返回。

2. 断路器可以实现快速失败，如果它在一段时间内检测到许多类似的错误（超时），就会在之后的一段时间，强迫对该服务的调用快速失败，即不再请求所调用的服务。这样对于消费者就无须再浪费 CPU 去等待长时间的超时。

3. 断路器也可自动诊断依赖的服务是否恢复正常。如果发现依赖的服务已经恢复正常，那么就会恢复请求该服务。通过重置时间来决定断路器的重新闭合。

   这样就实现了微服务的“自我修复”：当依赖的服务不可用时，打开断路器，让服务快速失败，从而防止雪崩。当依赖的服务恢复正常时，又恢复请求。

**断路器状态转换的逻辑**

1. 关闭状态：正常情况下，断路器关闭，可以正常请求依赖的服务。

2. 打开状态：当一段时间内，请求失败率达到一定阈值，断路器就会打开。服务请求不会去请求依赖的服务。调用方直接返回。不发生真正的调用。重置时间过后，进入半开模式。

3. 半开状态：断路器打开一段时间后，会自动进入“半开模式”，此时，断路器允许一个服务请求访问依赖的服务。如果此请求成功（或者成功达到一定比例），则关闭断路器，恢复正常访问。否则，则继续保持打开状态。

断路器的打开，能保证服务调用者在调用异常服务时，快速返回结果，避免大量的同步等待，减少服务调用者的资源消耗。并且断路器能在打开一段时间后继续侦测请求执行结果，判断断路器是否能关闭，恢复服务的正常调用。

### 降级

在整体资源不够的时候，适当放弃部分服务，把主要的资源投放到核心服务中，待渡过难关后，再重启已关闭的服务，保证了系统核心服务的稳定。

当服务停掉后，自动进入 fallback 替换主方法。用 fallback 方法代替主方法执行并返回结果，对失败的服务进行降级。当调用服务失败次数在一段时间内超过了断路器的阈值时，断路器将打开，不再进行真正的调用，而是快速失败，直接执行 fallback 逻辑。服务降级保护了服务调用者的逻辑。

### 熔断和降级对比

共同点：

1. 为了防止系统崩溃，保证主要功能的可用性和可靠性。
2. 用户体验到某些功能不能用。

不同点

1. 熔断由下级故障触发，主动惹祸。
2. 降级由调用方从负荷角度触发，无辜被抛弃。

## Hystrix 简介

Hystrix 是一个容错组件。实现了超时机制和断路器模式。用于隔离远程系统，服务或者第三方库，防止级联失败，从而提升系统的可用性与容错性。

虽然 Ribbon 也有超时和重试机制，但是其该机制并不全面。

**Hystrix 的主要功能**

1. 为系统提供保护机制。在依赖的服务出现高延迟或失败时，为系统提供保护和控制。
2. 防止雪崩。
3. 包裹请求：使用 HystrixCommand（或 HystrixObservableCommand）包裹对依赖的调用逻辑，每个命令在独立线程中运行。
4. 跳闸机制：当某服务失败率达到一定的阈值时，Hystrix 可以自动跳闸，停止请求该服务一段时间。
5. 资源隔离：Hystrix 为每个请求都的依赖都维护了一个小型线程池，如果该线程池已满，发往该依赖的请求就被立即拒绝，而不是排队等候，从而加速失败判定。防止级联失败。
6. 快速失败：Fail Fast。同时能快速恢复。侧重点是：不去真正的请求服务，而是直接失败。
7. 监控：Hystrix 可以实时监控运行指标和配置的变化，提供近实时的监控、报警、运维控制。
8. 回退机制：fallback，当请求失败、超时、被拒绝，或当断路器被打开时，执行回退逻辑。回退逻辑我们自定义，提供优雅的服务降级。
9. 自我修复：断路器打开一段时间后，会自动进入“半开”状态，可以进行打开，关闭，半开状态的转换。前面有介绍。

## Hystrix 独立使用

1. 引入依赖

   ```xml
   <!-- hystrix starter -->
   <dependency>
       <groupId>org.springframework.cloud</groupId>
       <artifactId>spring-cloud-netflix-hystrix</artifactId>
   </dependency>
   ```

2. 测试类

   ```java
   import com.netflix.hystrix.HystrixCommand;
   import com.netflix.hystrix.HystrixCommandGroupKey;
   
   import java.util.concurrent.ExecutionException;
   import java.util.concurrent.Future;
   
   /**
    * Hystrix 独立使用，脱离 SpringCloud
    * <p>
    * 先执行 run 方法中的业务逻辑，如果业务逻辑出现异常，就会执行 getFallback 方法。
    *
    * @author wangshuo
    * @date 2021/01/12
    */
   public class AloneHystrixTest extends HystrixCommand<String> {
   
   
       protected AloneHystrixTest(HystrixCommandGroupKey group) {
           super(group);
       }
   
       @Override
       protected String run() {
           System.out.println("执行逻辑");
           int i = 1 / 0;
           return "run success";
       }
   
       @Override
       protected String getFallback() {
           return "getFallback";
       }
   
       public static void main(String[] args) {
   
   //        AloneHystrixTest aloneHystrixTest = new AloneHystrixTest(HystrixCommandGroupKey.Factory.asKey("ext"));
           /*
            * execute()：以同步阻塞方式执行 run()。以 demo 为例，调用 execute() 后，
            * hystrix 先创建一个新线程运行 run()，
            * 	接着调用程序要在 execute() 调用处一直阻塞着，直到 run() 运行完成
            */
   //        System.out.println("result:" + aloneHystrixTest.execute());
   
           /*
            * queue()：以异步非阻塞方式执行 run()。以 demo 为例，
            * 	一调用 queue() 就直接返回一个 Future 对象，
            * 	同时 hystrix 创建一个新线程运行 run()，
            * 	调用程序通过 Future.get() 拿到 run() 的返回结果，
            * 	而 Future.get() 是阻塞执行的
            */
           Future<String> futureResult = new AloneHystrixTest(HystrixCommandGroupKey.Factory.asKey("ext")).queue();
           String result = "";
           try {
               result = futureResult.get();
           } catch (InterruptedException e) {
               e.printStackTrace();
           } catch (ExecutionException e) {
               e.printStackTrace();
           }
   
           System.out.println("程序结果：" + result);
       }
   }
   ```

## Hystrix 结合 RestTemplate

1. 引入依赖

   ```xml
   <!-- 引入 hystrix 依赖 -->
   <dependency>
       <groupId>org.springframework.cloud</groupId>
       <artifactId>spring-cloud-starter-netflix-hystrix</artifactId>
   </dependency>
   ```

2. 启动类上添加 `@EnableCircuitBreaker` 或 `@EnableHystrix` 注解

3. 调用的方法上使用 `@HystrixCommand` 将方法纳入到 hystrix 监控中

   ```java
   package com.example.eurekaconsumer.service;
   
   import com.netflix.hystrix.contrib.javanica.annotation.HystrixCommand;
   import org.springframework.beans.factory.annotation.Autowired;
   import org.springframework.stereotype.Service;
   import org.springframework.web.client.RestTemplate;
   
   /**
    * @author wangshuo
    * @date 2021/01/12
    */
   @Service
   public class RestTemplateService {
   
       @Autowired
       private RestTemplate restTemplate;
       /**
        * HystrixCommand 注解的 fallbackMethod 属性优先级高于 defaultFallback 属性
        * fallbackMethod 指定方法的形参和返回值必须与原方法一致
        * defaultFallback 指定方法不能包含行参，并且返回值必须与原方法一致
        */
       @HystrixCommand(fallbackMethod = "fallback")
       public String hystrixFallback(Integer millis) {
           String url = "http://eureka-provider/provider/restTemplate/hystrix-fallback?millis={1}";
           return restTemplate.getForObject(url, String.class, millis);
       }
   
       /**
        * 可在形参出添加 Throwable 对象，用于接收 consumer/provider 抛出的异常，根据不同的异常类型，进行相应的降级处理
        */
       public String fallback(Integer millis, Throwable throwable) {
           return "降级了……";
       }
   
   }
   ```

如果没有 `@HystrixCommand` 注解，添加如下依赖

```xml
<dependency>
    <groupId>com.netflix.hystrix</groupId>
    <artifactId>hystrix-javanica</artifactId>
</dependency>
```

## Hystrix 结合 Feign

### 方法级

1. 添加依赖

   ```xml
   <!-- 引入 hystrix 依赖 -->
   <dependency>
       <groupId>org.springframework.cloud</groupId>
       <artifactId>spring-cloud-starter-netflix-hystrix</artifactId>
   </dependency>
   ```

2. Feign 自带 Hystrix，但是默认是关闭的。先打开 Hystrix

   ```yaml
   feign:
     hystrix:
       enabled: true
   ```

3. 新建一个类实现 `UserService` 接口，重写所有方法。当 Feign 调用这些方法出现异常后，就会执行该实现类的方法中的业务逻辑。

   ```java
   import com.example.eurekaconsumer.service.UserService;
   import org.springframework.stereotype.Component;
   
   import java.util.Map;
   
   /**
    * @author wangshuo
    * @date 2021/01/12
    */
   @Component
   public class UserServiceFallback implements UserService {
   
       @Override
       public String readTimeout(Integer seconds) {
           return "降级了……";
       }
       
   	// 省略其他方法……
   }
   ```

4. 在 `@FeignClient` 注解中使用 `fallback` 属性，指定该类

   ```java
   @FeignClient(name = "eureka-provider", fallback = UserServiceFallback.class)
   ```

此时请求 `readTimeout` 接口，如果发生异常就会执行 `UserServiceFallback` 的 `readTimeout` 方法中的降级逻辑

### 异常级

1. 添加依赖

2. 打开 Hystrix

3. 新建一个实现 `FallbackFactory` 接口的类，泛型中填写标记 `@FeignClient` 注解的类，此处是 `UserService`

   ```java
   package com.example.eurekaconsumer.fallback;
   
   import com.example.eurekaconsumer.service.UserService;
   import com.example.userapi.entity.Person;
   import feign.hystrix.FallbackFactory;
   import org.springframework.stereotype.Component;
   
   import java.util.Map;
   
   /**
    * @author wangshuo
    * @date 2021/01/12
    */
   @Component
   public class UserServiceFallbackFactory implements FallbackFactory<UserService> {
       /**
        * 重写 create 方法，在方法中新建对应接口的对象，并在实现方法中编写降级逻辑。
        * 通过 throwable 对象可以获取到服务抛出的异常信息
        *
        * @param throwable 该对象既可以捕捉 Consumer 抛出的异常，也可以捕捉 Provider 端抛出的异常
        * @return
        */
       @Override
       public UserService create(Throwable throwable) {
           return new UserService() {
               @Override
               public String readTimeout(Integer seconds) {
                   // 可以根据不同的异常类型进行不同的降级处理
                   throwable.printStackTrace();
                   return "降级了...";
               }
               // 省略......
           };
       }
   }
   ```

## 信号量隔离和线程池隔离

默认情况下 hystrix 使用线程池控制请求隔离

### 线程池隔离

线程池隔离技术使用 Hystrix 自己的线程去执行调用。

![image-20210112233917804](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210112233918.png)

用户发送请求到 consumer 端，在 consumer 端使用一个 map（key 为服务 uri，val 是线程池）通过线程池的大小来限定单一 uri 的请求数量，并根据拒绝策略对超出的线程进行处理（排队，丢弃等），从而对 consumer 端不同的接口进行隔离，不会因为某个接口被大量请求而影响到其他接口的响应。

该方式需要对每个 uri 初始化并维护一个线程池，向 provider 发送请求使用的是 hystrix 维护的线程池中的线程。

### 信号量隔离

信号量隔离技术是直接用 tomcat 的线程去调用服务。

![image-20210113173900261](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210113173900.png)

Hystrix 会维护一个 Semaphore（就是一个计数器），用户每向 consumer 发送一个请求，Semaphore 就减一，当其为 0 时，就不处理用户的请求了，向 provider 发送请求的时候，使用的就是 tomcat 的 worker 线程。所以此种方式 hystrix 并没有为每个 uri 都单独创建并维护线程池。

### 线程池和信号量对比

1. 信号量隔离不需要单独创建和维护线程池
2. 线程池方式根据 uri 进行分组，可以根据不同的业务场景设置不同的拒绝策略
3. 线程池方式，如果某个服务的线程池异常了，不会影响到其他服务
4. 线程池方式可以把 tomcat 的 worker 线程和 hystrix 的线程池的线程做成异步（Servlet3.1）的，使得 tomcat 的 worker 线程可以快速被释放，执行其他的业务

代码健壮，不会出任何问题，业务执行计算速度很快的时候可以使用信号量。否则会一直占用 tomcat 的 worker 线程。

### 配置信号量隔离

```yaml
hystrix:
  command:
    default:
      execution:
        isolation:
          strategy: 'SEMAPHORE'
```

## Hystrix 的 Dashboard

1. 添加 dashboard 依赖

   ```xml
   <!-- hystrix dashboard starter -->
   <dependency>
       <groupId>org.springframework.cloud</groupId>
       <artifactId>spring-cloud-starter-netflix-hystrix-dashboard</artifactId>
   </dependency>
   ```

2. 在启动类上添加 `@EnableHystrixDashboard` 注解

3. 添加 actuator 依赖

   ```xml
   <dependency>
       <groupId>org.springframework.boot</groupId>
       <artifactId>spring-boot-starter-actuator</artifactId>
   </dependency>
   ```

4. 开放所有监控端点

   ```yaml
   management:
     endpoints:
       web:
         exposure:
           include: '*'
   ```

5. 访问 `/actuator/hystrix.stream`，然后调用被 hystrix 管理的接口，可以看到输出的监控信息

6. 访问 `/hystrix`，填入 `http://hostname:port/actuator/hystrix.stream`，即可访问图形化的监控页面

7. 修改 hystrix 使用信号量隔离后，可以看到 dashboard 上不显示线程池信息了

## Hystrix 的配置

都在 `HystrixCommandProperties` 类中

```properties
## Execution 相关的属性的配置 ##
# 隔离策略，默认是 Thread，可选 Thread｜Semaphore
# thread 通过线程数量来限制并发请求数，可以提供额外的保护，但有一定的延迟。一般用于网络调用
# semaphore 通过 semaphore count 来限制并发请求数，适用于无网络的高并发请求
hystrix.command.default.execution.isolation.strategy
# 命令执行超时时间，默认 1000ms
hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds
# 执行是否启用超时，默认启用 true
hystrix.command.default.execution.timeout.enabled
# 发生超时是是否中断，默认 true
hystrix.command.default.execution.isolation.thread.interruptOnTimeout
# 最大并发请求数，默认 10，该参数当使用 ExecutionIsolationStrategy.SEMAPHORE 策略时才有效。如果达到最大并发请求数，请求会被拒绝。理论上选择 semaphore size 的原则和选择 thread size 一致，但选用 semaphore 时每次执行的单元要比较小且执行速度快（ms 级别），否则的话应该用 thread。
# semaphore 应该占整个容器（tomcat）的线程池的一小部分。
hystrix.command.default.execution.isolation.semaphore.maxConcurrentRequests


## Fallback 相关的属性 ##
# 这些参数可以应用于 Hystrix 的 THREAD 和 SEMAPHORE 策略
# 如果并发数达到该设置值，请求会被拒绝和抛出异常并且 fallback 不会被调用。默认 10
hystrix.command.default.fallback.isolation.semaphore.maxConcurrentRequests 
# 当执行失败或者请求被拒绝，是否会尝试调用 hystrixCommand.getFallback()。默认 true
hystrix.command.default.fallback.enabled

## Circuit Breaker 相关的属性 ##
# 用来跟踪 circuit 的健康性，如果未达标则让 request 短路。默认 true
hystrix.command.default.circuitBreaker.enabled
# 一个 rolling window 内最小的请求数。如果设为 20，那么当一个 rolling window 的时间内（比如说 1 个 rolling window 是 10 秒）收到 19 个请求，即使 19 个请求都失败，也不会触发 circuit break。默认 20
hystrix.command.default.circuitBreaker.requestVolumeThreshold
# 触发短路的时间值，当该值设为 5000 时，则当触发 circuit break 后的 5000 毫秒内都会拒绝 request，也就是 5000 毫秒后才会关闭 circuit。默认 5000
hystrix.command.default.circuitBreaker.sleepWindowInMilliseconds
# 错误比率阀值，如果错误率>=该值，circuit 会被打开，并短路所有请求触发 fallback。默认 50，即为 50%。
hystrix.command.default.circuitBreaker.errorThresholdPercentage
# 强制打开熔断器，如果打开这个开关，那么拒绝所有 request，默认 false
hystrix.command.default.circuitBreaker.forceOpen
# 强制关闭熔断器 如果这个开关打开，circuit 将一直关闭且忽略 circuitBreaker.errorThresholdPercentage
hystrix.command.default.circuitBreaker.forceClosed

## Metrics 相关参数 ##
# 设置统计的时间窗口值的，毫秒值，circuit break 的打开会根据 1 个 rolling window 的统计来计算。若 rolling window 被设为 10000 毫秒，则 rolling window 会被分成 n 个 buckets，每个 bucket 包含 success，failure，timeout，rejection 的次数的统计信息。默认 10000
hystrix.command.default.metrics.rollingStats.timeInMilliseconds
# 设置一个 rolling window 被划分的数量，若 numBuckets＝10，rolling window＝10000，那么一个 bucket 的时间即 1 秒。必须符合 rolling window % numberBuckets == 0。默认 10
hystrix.command.default.metrics.rollingStats.numBuckets
# 执行时是否 enable 指标的计算和跟踪，默认 true
hystrix.command.default.metrics.rollingPercentile.enabled
# 设置 rolling percentile window 的时间，默认 60000
hystrix.command.default.metrics.rollingPercentile.timeInMilliseconds
# 设置 rolling percentile window 的 numberBuckets。逻辑同上。默认 6
hystrix.command.default.metrics.rollingPercentile.numBuckets
# 如果 bucket size＝100，window＝10s，若这 10s 里有 500 次执行，只有最后 100 次执行会被统计到 bucket 里去。增加该值会增加内存开销以及排序的开销。默认 100
hystrix.command.default.metrics.rollingPercentile.bucketSize
# 记录 health 快照（用来统计成功和错误绿）的间隔，默认 500ms
hystrix.command.default.metrics.healthSnapshot.intervalInMilliseconds
```
