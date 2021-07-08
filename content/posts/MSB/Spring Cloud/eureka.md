---
title: Eureka
date: '2021-01-06 09:50:00'
tags:
- MSB
- Spring Cloud
- Eureka
- Java
---
# Eureka

## Eureka 介绍

1. 背景：在传统应用中，组件之间的调用，通过有规范的约束的接口来实现，从而实现不同模块间良好的协作。但是被拆分成微服务后，每个微服务实例的网络地址都可能动态变化，数量也会变化，使得原来硬编码的地址失去了作用。需要一个中心化的组件来进行服务的登记和管理。
2. 概念：实现服务治理，即管理所有的服务信息和状态。
3. 注册中心好处：不用关心有多少提供方。
4. 注册中心有哪些：Eureka，Nacos，Consul，Zookeeper 等。

5. 服务注册与发现包括两部分，一个是服务器端，另一个是客户端。
   - Server 是一个公共服务，为 Client 提供服务注册和发现的功能，维护注册到自身的 Client 的相关信息，同时提供接口给 Client 获取注册表中其他服务的信息，使得动态变化的 Client 能够进行服务间的相互调用。
   - Client 将自己的服务信息通过一定的方式登记到 Server 上，并在正常范围内维护自己信息一致性，方便其他服务发现自己，同时可以通过 Server 获取到自己依赖的其他服务信息，完成服务调用，还内置了负载均衡器，用来进行基本的负载均衡。

6. [Eureka](https://github.com/Netflix/Eureka) 是 Netflix 开源的组件，包含 Eureka Server（注册中心）和 Eureka Client（服务提供者/消费者）两部分。是一个 RESTful 风格的服务，是一个用于服务发现和注册的基础组件，是搭建 Spring Cloud 微服务的前提之一，它屏蔽了 Server 和 Client 的交互细节，使得开发者将精力放到业务上。
7. Eureka Server A 从 Eureka Server B 同步信息，则 Eureka Server B 是 Eureka Server A 的 peer。

### Eureka Server 的功能

1. 服务注册表：记录各个微服务信息，例如服务名称，IP，端口等

   提供查询 API（查询可用的服务实例）和管理 API（用于服务的注册和下线）

2. 服务注册与发现：

   - 注册：将服务注册到注册中心
   - 发现：查询可用服务列表及其网络地址

3. 服务检查：定时检测已注册服务，如果发现某实例长时间无法访问，就从注册表中移除

### Eureka Client 的功能

1. 注册：每个实例启动时，将自己的网络地址等信息注册到注册中心，注册中心会存储（在内存中）这些信息
2. 拉取服务注册表：服务消费者从注册中心查询服务提供者的网络地址，并通过该地址调用服务提供者，为了避免每次都查询注册表信息，所以 Eureka Client 会定时去 Eureka Server 拉取注册表信息缓存到本地
3. 心跳：各个服务会定期向注册中心发送心跳信息，如果注册中心长时间没有接受到服务的心跳信息，就会将该服务下线
4. 调用：实际的服务调用，通过注册表，解析服务名和具体地址的对应关系，找到具体的服务地址，进行实际的调用。

## Eureka 原理

![image-20210106000330262](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210106000330.png)

1. Eureka Client 向 Eureka Server 进行注册并拉取 Eureka Server 中的注册表信息
2. consumer 根据拉取到本地的注册表信息调用 provider
3. Eureka Client 定时向 Eureka Server 发送心跳
4. Eureka Client 定时从 Eureka Server 拉取新的注册表
5. Eureka Server 的 peer 间同步注册表
6. Eureka Client 可以主动下线，也可以通过 Eureka Server 对其进行下线

### 注册服务 Registry

Eureka Client/Server 向 Eureka Server 注册自己，注册在第一次心跳发生时提交

### 续约，心跳 Renew

Eureka Client 默认每 30 秒向 Eureka Server 发送一次心跳来进行续租，告诉 Eureka Server 该 Eureka Client 是活动的。

默认情况下，如果 90 秒内 Eureka Server 没有接收到某个 Eureka Client 的心跳，就会将其从服务注册表中删除

### 拉取注册表 Fetch Registry

Eureka Client 从 Eureka Server 拉取注册表并将其缓存到本地，之后客户端使用本地的缓存来查找其他服务。

拉取注册表分为增量更新和全量更新，在服务注册时，会将该服务添加到 recentRegisteredQueue 和 registry 中，recentRegisteredQueue 中保存的服务信息默认 3 分钟会失效

- 增量更新：Eureka Client 默认每 30 秒从 Eureka Server 的 recentRegisteredQueue 中获取更新，如果获取失败会进行增量更新
- 全量更新：Eureka Client 从 Eureka Server 的 registry 获取所有服务注册信息

增量更新时，由于每 30 秒拉取一次，而失效时间为 3 分钟，所以会拉取到重复的信息，Eureka Client 会自动处理重复的信息。

在获得增量后，Eureka Client 通过比较数据库中返回的实例计数与服务器协调信息，如果由于某种原因信息不匹配，则再次获取整个注册表信息。

### 服务下线 Cancel

Eureka Client 在关闭时向 Eureka Server 发起下线请求，这将从服务器的实例注册表中删除该 Client，从而有效的将实例从通信量中取出。

也可以通过 Eureka Server 提供的 RESTful 服务接口手动对 Eureka Client 进行下线

### 同步延迟 Time Lag

来自 Eureka 客户端的所有操作可能需要一段时间才能反映到 Eureka 服务器上，然后反映到其他 Eureka 客户端上。这是因为 eureka 服务器上的有效负载缓存，它会定期刷新以反映新信息。Eureka 客户端还定期地获取增量。因此，更改传播到所有 Eureka 客户机可能需要 2 分钟。

### 通讯机制 Communication mechanism

所有对 Eureka Server 的操作都是通过其提供的 RESTful 接口进行的

默认情况下 Eureka 使用 Jersey 和 Jackson 以及 JSON 完成节点间的通讯

## Eureka Server 注册中心搭建

### [Eureka Server 单节点搭建](https://cloud.spring.io/spring-cloud-static/spring-cloud-netflix/2.1.5.RELEASE/single/spring-cloud-netflix.html#spring-cloud-eureka-server-standalone-mode)

1. pom.xml 引入依赖

   ```xml
   <dependency>
       <groupId>org.springframework.cloud</groupId>
       <artifactId>spring-cloud-starter-netflix-eureka-server</artifactId>
   </dependency>
   ```
   
2. application.yml

   ```yaml
   server:
     port: 7900
   eureka: 
     client:
       # 是否将自己注册到 Eureka Server，默认为 true，由于当前就是 server，故而设置成 false，表明该服务不会向 eureka 注册自己的信息
       register-with-eureka: false
       # 是否从 eureka server 获取注册信息，由于单节点，不需要同步其他节点数据，用 false
       fetch-registry: false
       # 设置服务注册中心的 URL，用于 client 和 server 端交流
       service-url:
         defaultZone: http://${eureka.instance.hostname}:${server.port}/eureka/
     instance:
       hostname: localhost
   ```

   如果 service-url 为空，且 register-with-eureka，fetch-registry 为 true，则会报错：Cannot execute request on any known server，因为 eureka server 同时也是一个 eureka client，它会尝试注册自己，所以要有一个注册中心 url 去注册。

3. 代码

   ```java
   // 在 SpringBoot 启动类上添加注解，标识该服务为服务注册中心
   @EnableEurekaServer
   ```

### [Eureka Server 高可用（集群）搭建](https://cloud.spring.io/spring-cloud-static/spring-cloud-netflix/2.1.5.RELEASE/single/spring-cloud-netflix.html#spring-cloud-eureka-server-peer-awareness)

高可用：可以运行多个 Eureka Server 实例并进行相互注册。Eureka Server 节点之间会彼此增量的同步信息，从而保证节点中数据一致

#### Eureka Server 双节点

双节点 Eureka Server 相互注册，组成集群环境

1. 准备

   准备 2 个节点部署 eureka server，也可以单机部署

   修改本机 host 文件，绑定主机名。单机部署时使用 IP 地址会有问题，相同主机要使用不同的主机名进行配置

2. 配置文件

```yaml
spring:
  application:
    name: eureka-server
eureka:
  client:
    # 是否将自己注册到 Eureka Server，默认为 true，需要
    register-with-eureka: true
    # 是否从 eureka server 获取注册信息，默认为 true，需要
    fetch-registry: true
---
# 节点 1
spring:
  profiles: 7901
server:
  port: 7901
eureka:
  client:
    # 设置服务注册中心的 URL，用于 client 和 server 端交流
    service-url:
      # 此节点应向其他节点发起请求
      defaultZone: http://ek2.com:7902/eureka/
  instance:
    # 主机名，必填，需要和 peer 的 service-url 中配置的域名一致
    hostname: ek1.com
---
# 节点 2
spring:
  profiles: 7902
server:
  port: 7902
eureka:
  client:
    # 设置服务注册中心的 URL，用于 client 和 server 端交流
    service-url:
      # 此节点应向其他节点发起请求
      defaultZone: http://ek1.com:7901/eureka/
  instance:
    # 主机名，必填，需要和 peer 的 service-url 中配置的域名一致
    hostname: ek2.com
```

3. 效果

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210105172014.png)

#### Eureka Server 多节点（3 个以上）

配置文件

```yaml
spring:
  application:
    name: eureka-server
eureka:
  client:
    # 是否将自己注册到 Eureka Server，默认为 true，需要
    register-with-eureka: true
    # 是否从 eureka server 获取注册信息，默认为 true，需要
    fetch-registry: true
    # 设置服务注册中心的 URL，用于 client 和 server 端交流
    service-url:
      # 3 个以上 Eureka Server 集群，需要把所有的 Eureka Server URL 都写上（注意逗号后不能有空格）
      defaultZone: http://ek1.com:7901/eureka/,http://ek2.com:7902/eureka/,http://ek3.com:7903/eureka/
---
# 节点 1
spring:
  profiles: 7901
server:
  port: 7901
eureka:
  instance:
    # 主机名，必填，需要和 peer 的 service-url 中配置的域名一致
    hostname: ek1.com
---
# 节点 2
spring:
  profiles: 7902
server:
  port: 7902
eureka:
  instance:
    # 主机名，必填，需要和 peer 的 service-url 中配置的域名一致
    hostname: ek2.com
---
# 节点 3
spring:
  profiles: 7903
server:
  port: 7903
eureka:
  instance:
    # 主机名，必填，需要和 peer 的 service-url 中配置的域名一致
    hostname: ek3.com
```

效果图

![image-20210105173227847](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210105173228.png)

## Eureka Client 服务注册

1. pom.xml 中引入

   ```xml
   <dependency>
       <groupId>org.springframework.cloud</groupId>
       <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
   </dependency>
   ```

2. 配置文件

   ```yaml
   spring:
     application:
       name: eureka-provider
   server:
     port: 9090
   eureka:
     client:
       # 因为是 Eureka Client，所以需要向 Eureka Server 注册
       register-with-eureka: true
       # 从 Eureka Server 拉取服务注册表
       fetch-registry: true
       # Eureka Server 的 URL
       service-url:
         # 如果有多个 Eureka Server 使用逗号隔开
         defaultZone: http://localhost:7900/eureka/
     instance:
       hostname: localhost
   ```

## Eureka Client consumer 调用 provider

## Eureka Server RESTful 服务调用

依据官方提供的 RESTful 接口，向 Eureka Server 发送请求，可以对服务进行操作。默认返回 xml 格式，如果需要返回 json，可在请求头添加 `Accept:application/json`

[官方文档](https://github.com/Netflix/eureka/wiki/Eureka-REST-operations)

**常用 RESTful 接口**

| **Operation**                          | **HTTP action**                                              | **Description**                                              |
| -------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 服务状态                               | GET /eureka/status                                           | Output: JSON/XML                                             |
| 注册新实例                             | POST /eureka/v2/apps/**appID**                               | Input: JSON/XML payload<br>HTTP Code: 204 on success         |
| 服务下线                               | DELETE /eureka/v2/apps/**appID**/**instanceID**              | HTTP Code: 200 on success                                    |
| 发送心跳                               | PUT /eureka/v2/apps/**appID**/**instanceID**                 | HTTP Code: <br/>* 200 on success <br/>* 404 if **instanceID** doesn’t exist |
| 查询所有实例                           | GET /eureka/v2/apps                                          | HTTP Code: 200 on success <br/>Output: JSON/XML              |
| 查询指定**appID**的实例                | GET /eureka/v2/apps/**appID**                                | HTTP Code: 200 on success <br/>Output: JSON/XML              |
| 查询指定**appID**/**instanceID**的实例 | GET /eureka/v2/apps/**appID**/**instanceID**                 | HTTP Code: 200 on success <br/>Output: JSON/XML              |
| 指定**instanceID**查询                 | GET /eureka/v2/instances/**instanceID**                      | HTTP Code: 200 on success <br/>Output: JSON/XML              |
| 更改服务状态                           | PUT /eureka/v2/apps/**appID**/**instanceID**/status?value={UP/DOWN} | HTTP Code: <br/>* 200 on success <br/>* 500 on failure       |
| 更新 metadata                           | PUT /eureka/v2/apps/**appID**/**instanceID**/metadata?key=value | HTTP Code: <br/>* 200 on success <br/>* 500 on failure       |

## 元数据

Eureka 的元数据有两种：标准元数据和自定义元数据。

- 标准元数据：主机名、IP 地址、端口号、状态页和健康检查等信息，这些信息都会被发布在服务注册表中，用于服务之间的调用。
- 自定义元数据：可以使用 eureka.instance.metadata-map 配置，这些元数据可以在远程客户端中访问，但是一般不改变客户端行为，除非客户端知道该元数据的含义。

可以在配置文件中对当前服务设置自定义元数据，可后期用户个性化使用（例如自定义负载均衡）

元数据可以配置在 Eureka Server 和 Eureka Client 上

```yaml
eureka:
  instance:
    metadata-map:
      myKey1: myVal1
      myKey2: myVal2
```

可通过 `GET /eureka/status` 查看到自己添加的元数据信息，也可在代码中获取到

## Eureka 机制

### 自我保护机制

Eureka 在 CAP 理论当中属于 AP，也就是说当产生网络分区时，Eureka 保证系统可用性，但不保证数据的一致性

默认情况下，Eureka Server 在 90s 内没有接收到某个微服务的心跳，就会将该微服务下线。但是当网络故障时，微服务与 Eureka Server 间无法正常通信，上述行为就非常危险，因为服务正常，不应该下线。

Eureka Server 的自我保护机制用来解决该问题，当 Eureka Server 在短时间内丢失过多客户端时，就会进入自我保护模式，会保护注册表中剩余的微服务不被注销掉。当网络故障恢复后，退出自我保护模式。

**思想：宁可保留健康的和不健康的，也不盲目注销任何健康的服务**

#### 自我保护机制的触发

Eureka Server 通过一个定时剔除任务来对心跳数不满足条件的服务进行剔除。

```java
// AbstractInstanceRegistry.java
public void evict(long additionalLeaseMs) {
    logger.debug("Running the evict task");
    // 如果 isLeaseExpirationEnabled 为 false 执行剔除逻辑，否则不进行剔除
    if (!isLeaseExpirationEnabled()) {
        logger.debug("DS: lease expiration is currently disabled.");
        return;
    }
    // 服务剔除逻辑
```

```java
// PeerAwareInstanceRegistryImpl.java
@Override
public boolean isLeaseExpirationEnabled() {
    // 如果关闭了自我保护，就返回 true，上方代码就执行自我保护逻辑
    if (!isSelfPreservationModeEnabled()) {
        // The self preservation mode is disabled, hence allowing the instances to expire.
        return true;
    }
    // 如果开启了自我保护，判断最后一分钟续约数是否大于每分钟续约数阈值，大于就进行剔除，否则不进行剔除
    return numberOfRenewsPerMinThreshold > 0 && getNumOfRenewsInLastMin() > numberOfRenewsPerMinThreshold;
}
```

**客户端每分钟续约数量小于客户端总数的 85%时会触发自我保护机制**

自我保护机制触发条件：开启了自我保护机制，并且每分钟心跳次数 `< numberOfRenewsPerMinThreshold` 时，即触发自我保护机制，对之后没有续租的服务也不进行剔除。

`numberOfRenewsPerMinThreshold = expectedNumberOfRenewsPerMin * renewalPercentThreshold`

expectedNumberOfRenewsPerMin：期望的每分钟续约数，默认为某个微服务的实例数 x 2，乘 2 是因为 Client 默认每 30s 向 Server 发送一次心跳，一分钟就是 2 次

renewalPercentThreshold：续约百分比，默认是 0.85

示例：假如某个微服务有 10 个实例，默认情况下，每分钟会向 Server 发送 10 * 2 = 20 个心跳，期望阈值为 0.85，则 20 * 0.85 = 17，即当 Server 每分钟接收该服务心跳数小于 17 时触发自我保护机制。

#### 配置调整

```yaml
eureka:
  server:
    # 是否开启自我保护机制
    enable-self-preservation: true
    # 续约阈值百分比
    renewal-percent-threshold: 0.85
    # 服务剔除时间间隔，默认 60s
    eviction-interval-timer-in-ms: 6000
  instance:
    # 客户端向服务端发送心跳的时间间隔
    lease-renewal-interval-in-seconds: 30
```

## Eureka 健康检查

Eureka Server 默认根据 Eureka Client 定时发送的心跳来判断其是否是健康的，但是这种方式是不准确的，心跳包可能受网络因素的影响，没有发送到 Eureka Server 上，然而此时该服务是正常的；或者服务状态是 UP 的，但是 DB 出现问题，也无法提供正常服务。

使用 Actuator 监控应用，可以更细粒度的来对服务进行健康检查。

### 引入依赖，开启监控

```xml
<!-- Eureka Server 的 starter 中已经包含了该依赖，所以不需要重复引入，Eureka Client 需要引入 -->
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

### EndPoint 介绍

通过 `/actuator` 可查看所有 EndPoint

#### 默认端点

Spring Boot2.x 的 Actuator 默认只暴露了 health 和 info 端点，提供的监控信息无法满足我们的需求

#### 开启所有端点

```yaml
#开启所有端点
management:
  endpoints:
    web:
      exposure:
        include: '*'
```

所有端点开启后的 api 列表

```json
{
    "_links":{
        "self":{
            "href":"http://localhost:8080/actuator",
            "templated":false
        },
        "archaius":{
            "href":"http://localhost:8080/actuator/archaius",
            "templated":false
        },
        "beans":{
            "href":"http://localhost:8080/actuator/beans",
            "templated":false
        },
        "caches-cache":{
            "href":"http://localhost:8080/actuator/caches/{cache}",
            "templated":true
        },
        "caches":{
            "href":"http://localhost:8080/actuator/caches",
            "templated":false
        },
        "health":{
            "href":"http://localhost:8080/actuator/health",
            "templated":false
        },
        "health-path":{
            "href":"http://localhost:8080/actuator/health/{*path}",
            "templated":true
        },
        "info":{
            "href":"http://localhost:8080/actuator/info",
            "templated":false
        },
        "conditions":{
            "href":"http://localhost:8080/actuator/conditions",
            "templated":false
        },
        "configprops":{
            "href":"http://localhost:8080/actuator/configprops",
            "templated":false
        },
        "env":{
            "href":"http://localhost:8080/actuator/env",
            "templated":false
        },
        "env-toMatch":{
            "href":"http://localhost:8080/actuator/env/{toMatch}",
            "templated":true
        },
        "loggers":{
            "href":"http://localhost:8080/actuator/loggers",
            "templated":false
        },
        "loggers-name":{
            "href":"http://localhost:8080/actuator/loggers/{name}",
            "templated":true
        },
        "heapdump":{
            "href":"http://localhost:8080/actuator/heapdump",
            "templated":false
        },
        "threaddump":{
            "href":"http://localhost:8080/actuator/threaddump",
            "templated":false
        },
        "metrics-requiredMetricName":{
            "href":"http://localhost:8080/actuator/metrics/{requiredMetricName}",
            "templated":true
        },
        "metrics":{
            "href":"http://localhost:8080/actuator/metrics",
            "templated":false
        },
        "scheduledtasks":{
            "href":"http://localhost:8080/actuator/scheduledtasks",
            "templated":false
        },
        "mappings":{
            "href":"http://localhost:8080/actuator/mappings",
            "templated":false
        },
        "refresh":{
            "href":"http://localhost:8080/actuator/refresh",
            "templated":false
        },
        "features":{
            "href":"http://localhost:8080/actuator/features",
            "templated":false
        },
        "service-registry":{
            "href":"http://localhost:8080/actuator/service-registry",
            "templated":false
        }
    }
}
```

#### 各端点介绍

##### Health

用于显示系统的状态

```json
{"status":"UP"}
```

##### shutdown

用来关闭节点

开启远程关闭功能

```yaml
management:
  endpoint:
    shutdown:
      enabled: true
```

使用 POST 请求调用返回

```json
{
  "message": "Shutting down, bye..."
}
```

##### beans

获取应用上下文中创建的所有 bean

##### configprops

获取应用中配置的属性信息报告

##### env

获取应用所有可用的环境属性报告

##### mappings

获取应用所有 Spring Web 控制器映射关系（Controller 层的 EndPoints）报告

##### info

获取应用自定义的信息

##### metrics

返回应用的各类重要度量指标信息，例如 jvm 的相关信息

该 EndPoint 并没有返回全量信息，可以通过不同的 key 去加载需要的值

`/metrics/{key}`，例如 `/metrics/jvm.memory.max`

##### threaddump

返回应用程序运行中的线程信息

### 开启手动控制

在 Eureka Client 端配置，将自己真正的健康状态传播给 Eureka Server

```yaml
eureka:
  client:
    healthcheck:
      # 可以上报服务的真实健康状态
      enabled: true
```

### 修改健康状态的 Service

```java
import org.springframework.boot.actuate.health.Health;
import org.springframework.boot.actuate.health.HealthIndicator;
import org.springframework.stereotype.Service;

/**
 * 可通过该 Service 的 setStatus() 方法对该服务进行上线/下线操作，可将其用在具体业务逻辑中，根据异常等信息，自定义服务上下线
 * <p>
 * 对该服务进行状态修改后，通过调用 /actuator/health 可以实时的获取到该服务的状态，
 * 而 Eureka Server 需要等到该服务上传心跳后，才会更新该服务的状态
 *
 * @author wangshuo
 * @date 2021/01/06
 */
@Service
public class HealthStatusService implements HealthIndicator {

    private Boolean status = true;

    @Override
    public Health health() {
        return status ? new Health.Builder().up().build() : new Health.Builder().down().build();
    }

    public void setStatus(Boolean status) {
        this.status = status;
    }

    public Boolean getStatus() {
        return this.status;
    }
}
```

测试用的 Controller

```java
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * @author wangshuo
 * @date 2021/01/05
 */
@RestController
public class ProviderController {

    @Autowired
    HealthStatusService healthStatusService;

    @PostMapping("/health/{status}")
    public String setHealth(@PathVariable("status") Boolean status) {
        healthStatusService.setStatus(status);
        return healthStatusService.getStatus().toString();
    }
}
```

**注意事项**

```yaml
# 如果配置了
server:
  servlet:
    path: /path
# 需要配置
eureka:
  instance:
    statusPageUrlPath: ${server.servlet.path}/actuator/info
    healthCheckUrlPath: ${server.servlet.path}/actuator/health
```

## Eureka 监听事件

- EurekaInstanceCanceledEvent 服务下线事件
- EurekaInstanceRegisteredEvent 服务注册事件
- EurekaInstanceRenewedEvent 服务续约事件
- EurekaRegistryAvailableEvent 注册中心可用事件
- EurekaServerStartedEvent  注册中心启动

```java
import org.springframework.cloud.netflix.eureka.server.event.EurekaInstanceCanceledEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;

// 声明为组件
@Component
public class CustomEvent {
    
	// 声明为监听事件
    @EventListener
    public void listen(EurekaInstanceCanceledEvent e) {
        System.out.println(e.getServerId() + "下线事件");
    }
}
```

## Eureka Server 安全配置

Eureka Server 引入 Spring Security 进行简单地安全验证

1. pom.xml 引入 Spring Security 依赖

   ```xml
   <!-- spring security starter -->
   <dependency>
       <groupId>org.springframework.boot</groupId>
       <artifactId>spring-boot-starter-security</artifactId>
   </dependency>
   ```

2. application.yaml 中添加登录用户名和密码

   ```yaml
   spring:
     security:
       user:
         name: admin
         password: 123456
   ```

3. 修改 Eureka Client 中的 service-url

   ```yaml
   eureka:
     client:
       service-url:
         # 添加上一步中设置的用户名和密码
         defaultZone: http://admin:123456@localhost:7900/eureka/
   ```

4. 关闭 Spring Security 的 CSRF 防护

   Spring Security 默认开启了防止跨域攻击，如果不关闭，Eureka Client 会注册失败，并报如下错误

   > Root name 'timestamp' does not match expected ('instance') for type [simple type, class com.netflix.appinfo.InstanceInfo]

   ```java
   import org.springframework.context.annotation.Configuration;
   import org.springframework.security.config.annotation.web.builders.HttpSecurity;
   import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
   import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
   
   /**
    * @author wangshuo
    * @date 2021/01/06
    */
   @Configuration
   @EnableWebSecurity
   public class WebSecurityConfig extends WebSecurityConfigurerAdapter {
   
       @Override
       protected void configure(HttpSecurity http) throws Exception {
           // 允许 CSRF
           http.csrf().disable();
           super.configure(http);
       }
   }
   ```

## 多网卡选择

服务器有多个网卡，eth0 和 eth1，其中 eth0 是用于内网访问的网卡，eth1 是用于外网访问的网卡。如果 Eureka Client 使用 eth0 注册到了 Eureak Server 上，这样外网的其他服务就无法访问到该服务了。

**解决方案**

```yaml
eureka:
  instance:
    # 表示将自己的 ip 注册到 Eureka Server 上。如果不配置或为 false，表示将操作系统的 hostname 注册到 Eureka Server 上
    prefer-ip-address: true
    # 设置为外部服务能够访问到的 IP
    ip-address: 39.105.30.251
```

通过该方式设置了 ip-address 后，在元数据中查看到的就是此 ip，其他服务就可以通过该 ip 来进行调用了

