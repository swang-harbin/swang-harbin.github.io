---
title: Feign
date: '2020-07-04 00:00:00'
tags:
- MSB
- Feign
- Java
---
# Feign

## Feign 简介

OpenFeign 是 Netflix 开发的声明式、模板化的 HTTP 请求客户端。可以更加便捷、优雅地调用 http api。

OpenFeign 会根据带有注解的函数信息构建出网络请求的模板，在发送网络请求之前，OpenFeign 会将函数的参数值设置到这些请求模板中。

feign 主要是构建微服务消费端。只要使用 OpenFeign 提供的注解修饰定义网络请求的接口类，就可以使用该接口的实例发送 RESTful 的网络请求。还可以集成 Ribbon 和 Hystrix，提供负载均衡和断路器。

英文表意为“假装，伪装，变形”，是一个 Http 请求调用的轻量级框架，可以以 Java 接口注解的方式调用 Http 请求，而不用像 Java 中通过封装 HTTP 请求报文的方式直接调用。通过处理注解，将请求模板化，当实际调用的时候，传入参数，根据参数再应用到请求上，进而转化成真正的请求，这种请求相对而言比较直观。Feign 封装 了 HTTP 调用流程，面向接口编程，回想第一节课的 SOP。

## Feign 和 OpenFeign 关系

### Feign

Feign 是 Spring Cloud 组件中的一个轻量级 RESTful 的 HTTP 服务客户端，Feign 内置了 Ribbon 用来做客户端负载均衡。Feign 的使用方式是：使用 Feign 的注解定义接口，调用这个接口，就可以调用服务注册中心的服务

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-feign</artifactId>
</dependency>
```

### OpenFeign

OpenFeign 是 Spring Cloud 在 Feign 的基础上支持了 SpringMVC 的注解，如 `@RequestMapping` 等。OpenFeign 的 `@FeignClient` 可以解析 SpringMVC 的 `@RequestMapping` 注解下的接口，并通过动态代理的方式产生实现类，实现类中做负载均衡并调用其他服务

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-openfeign</artifactId>
</dependency>
```

## OpenFeign 和 RestTemplate 区别

RestTemplate 需要在编码的时候写死发送请求的 url，同时可以手动对请求头等信息进行修改。更自由，贴近 HttpClient，方便调用其他的第三方 http 服务。

OpenFeign 使用注解 + 接口的方式发送请求，自动创建发送请求的代码，不需要手动编写，因此也就不能手动对请求进行相关的修改。更面向对象一些，更优雅

## OpenFeign 的使用

1. 引入依赖

```xml
<!-- openfeign starter -->
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-openfeign</artifactId>
</dependency>
```

2. 在启动类上启动 OpenFeign

```java
@EnableFeignClients
```

3. 创建一个接口

```java
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * 单独使用 OpenFeign 时，在 FeignClient 注解的 url 中指定生产者的 url 前缀，name 自定义即可
 * <p>
 * 结合 Eureka 使用 OpenFeign 时，在 FeignClient 中只需要指定 name 为服务生产者的服务名即可。
 * <p>
 * 不需要写发送请求时的具体实现代码，当调用该接口的方法时，通过反射即可自动生成子类实现
 *
 * @author wangshuo
 * @date 2021/01/09
 */
@Component
// @FeignClient(name = "xxoo", url = "http://localhost:8080")
@FeignClient(name = "eureka-provider")
public interface UserService {

    /**
     * 此处使用 RequestMapping 系列注解指定生产者的 EndPoint 即可，
     * OpenFeign 会向 FeignClient 中 url 和该 EndPoint 拼接后的 url 发送请求
     *
     * @return 响应结果
     */
    @GetMapping("/getHi")
    String getHi();

}
```

4. 在 Controller 中直接调用上方接口的方法即可

```java
import com.example.eurekaconsumer.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/consumer/open-feign")
public class ConsumerOpenFeignController {

    @Autowired
    private UserService userService;

    @GetMapping("/hi")
    public String getHi() {
        // 调用接口的方法即可发送请求
        return userService.getHi();
    }

}
```

**Feign 默认集成了 Ribbon，所以会自动进行负载均衡**

## 原理简介

1. 主程序入口添加 `@EnableFeignClients` 注解开启对 Feign Client 扫描加载处理。根据 Feign Client 的开发规范，定义接口并加`@FeignClient`注解。
2. 当程序启动时，会进行包扫描，扫描所有 `@FeignClient` 注解的类，并将这些信息注入 Spring IoC 容器中。当定义的 Feign 接口中的方法被调用时，通过 JDK 的代理方式，来生成具体的 `RequestTemplate`。当生成代理时，Feign 会为每个接口方法创建一个 `RequestTemplate` 对象，该对象封装了 HTTP 请求需要的全部信息，如请求参数名、请求方法等信息都在这个过程中确定。
3. 然后由 `RequestTemplate` 生成 `Request`，然后把这个 `Request` 交给 client 处理，这里指的 Client 可以是 JDK 原生的 `URLConnection`、Apache 的 `Http Client` ，也可以是 `Okhttp`。最后 Client 被封装到 `LoadBalanceClient` 类，这个类结合 Ribbon 负载均衡发起服务之间的调用。

## 优化硬编码问题

**UserService 中的方法需要根据服务提供者提供的 API 文档写，是硬编码的，如何优化？**

- 如果服务提供者提供的接口，需要被其他语言进行调用，那么提供 API 文档是非常有必要的。

- 如果提供的接口只需要被 Java 使用，那么就可以抽象出一个单独的工程，专门记录其提供的 api 接口信息，在消费方和提供方只需要引入该工程的 jar，既可以解决双方的硬编码问题，又可以规范双方的代码编写。

1. 新建 user-api 工程，包含 Spring Web 依赖即可

   ```xml
   <dependency>
       <groupId>org.springframework.boot</groupId>
       <artifactId>spring-boot-starter-web</artifactId>
   </dependency>
   ```

2. 新建一个接口类

   ```java
   package com.example.userapi.api;
   
   import org.springframework.web.bind.annotation.GetMapping;
   
   /**
    * @author wangshuo
    * @date 2021/01/09
    */
   public interface UserApi {
   
       /**
        * 调用服务提供者的接口
        *
        * @return 响应结果
        */
       @GetMapping("/getHi")
       String getHi();
   
   }
   ```

3. 将该 user-api 工程打包，并在 consumer 和 provider 中引用它

   ```xml
   <!-- 引入自定义 API -->
   <dependency>
       <groupId>com.example</groupId>
       <artifactId>user-api</artifactId>
       <version>0.0.1-SNAPSHOT</version>
   </dependency>
   ```

4. consumer 中的 Service 继承该接口

   ```java
   package com.example.eurekaconsumer.service;
   
   import com.example.userapi.api.UserApi;
   import org.springframework.cloud.openfeign.FeignClient;
   import org.springframework.stereotype.Component;
   
   /**
    * 继承抽象出来的 UserApi 接口即可
    *
    * @author wangshuo
    * @date 2021/01/09
    */
   @Component
   @FeignClient(name = "eureka-provider")
   public interface UserService extends UserApi {
   
   }
   ```

5. provider 中的 Controller 实现该接口

   ```java
   package com.example.eurekaprovider.controller;
   
   import com.example.eurekaprovider.HealthStatusService;
   import com.example.userapi.api.UserApi;
   import org.springframework.beans.factory.annotation.Autowired;
   import org.springframework.beans.factory.annotation.Value;
   import org.springframework.web.bind.annotation.PathVariable;
   import org.springframework.web.bind.annotation.PostMapping;
   import org.springframework.web.bind.annotation.RestController;
   
   /**
    * @author wangshuo
    * @date 2021/01/05
    */
   @RestController
   public class ProviderController implements UserApi {
   
       @Value("${server.port}")
       private String port;
   
       @Override
       public String getHi() {
           return "Hi! 我的 port 是 : " + port;
       }
   }
   ```

通过该种方式将 provider 的 EndPoint 提取了出来，在 provider 工程中不需要硬编码写死 RequestMapping 中的 url。

该方法还体现了面向接口编程的思想，在修改 user-api 后，会强制 consumer 和 provider 进行修改/重写，并包含提示信息。

仅是 Java 工程进行调用时，只需要把依赖引入即可，不需要提供 API 文档。当需要其他语言进行调用的时候，可以再使用 swagger 等工具生成 API 文档，这两种方式并不冲突。

**缺点：**Consumer 和 Provider 的耦合性提高了

## OpenFeign 多参数请求

在标记 `@FeignClient` 的接口方法中**必须**添加 `@RequestParam` 注解，否则 OpenFeign 不能正确解析参数

### GET 请求

#### 普通参数

```java
@Component
@FeignClient(name = "eureka-provider")
public interface UserService {
    @GetMapping("/string")
    String getWithParam(@RequestParam("id") String id);
}
```

#### Map 接收

```java
@Component
@FeignClient(name = "eureka-provider")
public interface UserService {
    @GetMapping("/map")
    Map<String, Object> getWithMapParam(@RequestParam Map<String, Object> map);
}
```

### POST 请求

#### 普通参数

```java
@Component
@FeignClient(name = "eureka-provider")
public interface UserService {
    @PostMapping("/string")
    String postWithParam(@RequestParam("id") String id);
}
```

#### Map 接收

可以用 RequestParam 从 URL 中传参，也可以使用 RequestBody 中 Body 中传参

```java
@Component
@FeignClient(name = "eureka-provider")
public interface UserService {
    @PostMapping("/url-map")
    Map<String, Object> postWithMapParam(@RequestBody Map<String, Object> map);
}
```

或

```java
@Component
@FeignClient(name = "eureka-provider")
public interface UserService {
    @PostMapping("/body-map")
    Map<String, Object> postWithMapParam(@RequestParam Map<String, Object> map);
}
```

#### 对象传参

```java
@Component
@FeignClient(name = "eureka-provider")
public interface UserService {
    @PostMapping("/obj")
    Person postWithObj(@RequestBody Person person);
}
```

`@ReuqestParam` 和 `@RequestBody` 在 Consumer 和 Provider 中单纯的按照 SpringMVC 的使用方式（在部分场景下可以省略），在标有 `@FeignClient` 的接口中，是给 FeignClient 用的，所以一定要按照 OpenFeign 的规则标记完整。

## 自定义 Feign 配置

Feign 默认的配置类是 `org.springframework.cloud.openfeign.FeignClientsConfiguration`，定义了 Feign 默认的编码器，解码器等。

可以使用 `@FeignClient` 的 `configuration` 属性自定义 Feign 配置。自定义的配置优先级高于默认的 `FeignClientsConfiguration`

```java
/**
 * 此处如果使用 @Configuration 被扫描到容器中，就会对所有的 FeignClient 生效
 * 不使用 @Configuration，通过 FeignClient 注解的 configuration 属性单独指定，则仅对指定的 FeignClient 生效
 */
// @Configuration
public class FeignConfig {
    // 自定义的 Feign 配置
}
```

## Feign 压缩

开启压缩可以有效节约网络资源，但是会增加 CPU 压力，建议把最小压缩的文档大小适度调大一点，进行 gzip 压缩。一般不需要设置压缩，如果系统流量浪费比较多，可以考虑一下。

```yaml
feign:
  compression:
    request:
      enabled: true
    response:
      enabled: true
```

选择性的对指定类型进行压缩

```yaml
feign:
  compression:
    request:
      enabled: true
      mime-types: 
      - text/xml
      min-request-size: 2048
```

## Feign 日志

```yaml
feign:
  client:
    config:
      service-valuation:
        logger-level: basic
```

logger-level 有 4 种选项：

- none：不记录任何日志，默认值
- basic：仅记录请求方法，url，响应状态码，执行时间。
- headers：在 basic 基础上，记录 header 信息
- full：记录请求和响应的 header，body，元数据。

```yaml
logging:
  level:
    # 指定某个类的日志级别。该初指定为 debug 后，上方 feign 的 logger-level 就只会对该类 debug 级别的日志做出响应
    package.Class: debug
```

## Feign 超时和重试机制

Feign 默认支持 Ribbon，Ribbon 的重试机制和 Feign 的重试机制有冲突，所以源码中默认关闭 Feign 的重试机制，使用 Ribbon 的重试机制

**超时机制**

```yaml
ribbon:
  # 连接超时时间（ms）
  ConnectTimeout: 1000
  # 业务逻辑超时时间（ms）
  ReadTimeout: 2000
```

**超时重试机制**

当服务请求超时后，Ribbon 会根据其重试机制进行重试调用。默认情况下，如果只有一个 provider 的实例，其会重试调用该 provider 一次；如果有多个 provider 的实例，会先重试调用该 provider 一次，如果还超时，就会调用 provider 的 1 个负载均衡实例一次，如果还超时，就会返回超时异常。

```yaml
ribbon:
  # 同一台实例最大重试次数，不包括首次调用
  MaxAutoRetries: 1
  # 重试负载均衡其他的实例最大重试次数，不包括首次调用
  MaxAutoRetriesNextServer: 1
  # 是否所有操作都重试，所有操作指 GET 和 POST 请求，建议配置为 false，仅对 GET 请求进行重试，因为 POST 是更新操作，重试可能会出问题
  OkToRetryOnAllOperations: false
```

如果某次请求调用时，某个实例调用失败了，那么在 6 秒内如果又接收到了该请求，就不会去调用之前调用失败的实例了。6 秒后会恢复对该实例的调用
