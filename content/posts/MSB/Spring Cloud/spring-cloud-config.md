---
title: Spring Cloud Config
date: '2021-01-17 12:49:00'
tags:
- MSB
- Spring Cloud
- Java
---
# Spring Cloud Config

## 概念

### 为什么需要配置中心

单体应用配置写在配置文件中，没有什么大问题，如果需要切换环境，可以切换不同的 profile，但在微服务中:

1. 微服务比较多。成百上千，配置很多，需要集中管理
2. 管理不同环境的配置
3. 动态调整配置参数时，服务不能停服

### 配置中心介绍

分布式配置中心包括 3 个部分:

1. 存放配置的地方: git，本地文件等
2. config server: 从 1 中读取配置
3. config client: 是 config server 的客户端，用于消费配置

## 服务搭建

### 基于 github

1. 在 github 上创建一个仓库

2. 添加 prd 和 dev 分支

3. 在不同分支创建不同的配置文件

   - 在 master 分支上创建 eureka-consumer-master.yml

     ```yaml
     my-config: "eureka-consumer-master"
     ```

   - 在 prd 分支上创建 eureka-consumer-prd.yml

     ```yaml
     my-config: "eureka-consumer-prd"
     ```

   - 在 dev 分支上创建 eureka-consumer-dev.yml

     ```yaml
     my-config: "eureka-consumer-dev"
     ```

#### 服务端

1. 配置中心服务端依赖

   ```xml
   <!-- 配置中心服务端 -->
   <dependency>
       <groupId>org.springframework.cloud</groupId>
       <artifactId>spring-cloud-config-server</artifactId>
   </dependency>
   ```

2. 配置中心服务端配置文件

   ```yaml
   spring: 
     cloud:
       config:
         server:
           git:
             uri: https://github.com/swang-harbin/spring-cloud-config-center
             username: 
             password: 
             # 默认是秒，因为 git 慢
             timeout: 15
   ```

3. 启动类添加 `@EnableConfigServer` 注解

4. 测试访问 `/eureka-consumer-master.yml`，`/master/eureka-consumer-master.yml`，`/dev/eureka-consumer-dev.yml`，`/prd/eureka-consumer-prd.yml`

**获取配置的规则**

根据前缀匹配，从前缀开始

- /{name}-{profiles}.properties
- /{name}-{profiles}.yml
- /{name}-{profiles}.json
- /{label}/{name}-{profiles}.yml

name: 服务名称

profiles: 环境名称。开发/测试/生产: dev/qa/prd

label: 仓库分支。默认是 master 分支

#### 客户端

1. 引入依赖

   ```xml
   <!-- 配置中心客户端：config-client -->
   <dependency>
       <groupId>org.springframework.cloud</groupId>
       <artifactId>spring-cloud-config-client</artifactId>
   </dependency>
   ```

2. 新建**bootstrap.yml**配置文件，**注意: **此处一定要创建该文件，否则会报找不到属性值的异常。

   **在 SpringCloud 中，bootstrap.yml 最先加载，并且其中的配置不会被 application.yml 覆盖**

   ```yaml
   spring:
     cloud:
       config:
         # 配置中心 uri
         uri:
           - http://localhost:6666
         # 开发环境
         profile: master
         # 分支
         label: master
   ```

3. 测试类

   ```java
   import org.springframework.beans.factory.annotation.Value;
   import org.springframework.web.bind.annotation.RequestMapping;
   import org.springframework.web.bind.annotation.RestController;
   
   @RestController
   @RequestMapping("/consumer/config")
   public class ConfigController {
   
       @Value("${my-config}")
       private String myConfig;
   
       @RequestMapping("/my-config")
       public String getMyConfig() {
           return myConfig;
       }
   }
   ```

4. 访问 `/consumer/config/my-config` 测试即可

#### 通过 Eureka 进行获取

上方的配置方式并没有使用 EurekaServer 和 EurekaClient，配置中心 URI 是写死的主机名和端口，并且没有负载均衡等。所以可以将配置中心服务端也注册到 EurekaServer，让 EurekaClient 通过注册中心获取配置中心的配置。

**注意：**手动配置 URI 和使用 Eureka 相互冲突，所以只能二选一使用

##### 服务端

1. 添加依赖

   ```xml
   <!-- 配置中心服务端 -->
   <dependency>
       <groupId>org.springframework.cloud</groupId>
       <artifactId>spring-cloud-config-server</artifactId>
   </dependency>
   <!-- eureka client starter-->
   <dependency>
       <groupId>org.springframework.cloud</groupId>
       <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
   </dependency>
   ```

2. 配置中心服务端配置文件

   ```yaml
   spring:
     application:
       name: cloud-config-center
     cloud:
       config:
         server:
           git:
             uri: https://github.com/swang-harbin/spring-cloud-config-center
             username: 
             password: 
             # 默认是秒，因为 git 慢
             timeout: 15
   eureka:
     client:
       service-url: 
         defaultZone: http://localhost:7900/eureka
   ```

3. 启动类添加 `@EnableConfigServer` 注解

##### 客户端

1. 引入依赖

   ```xml
   <!-- 配置中心客户端：config-client -->
   <dependency>
       <groupId>org.springframework.cloud</groupId>
       <artifactId>spring-cloud-config-client</artifactId>
   </dependency>
   <!-- eureka client starter-->
   <dependency>
       <groupId>org.springframework.cloud</groupId>
       <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
   </dependency>
   ```

2. 新建 bootstrap.yml 配置文件，**注意: **此处一定要创建该文件，否则会报找不到属性值的异常。

   **在 SpringCloud 中，bootstrap.yml 最先加载，并且其中的配置不会被 application.yml 覆盖**

   ```yaml
   spring:
     cloud:
       config:
         discovery:
           enabled: true
           # 配置中心名称
           service-id: cloud-config-center
         # 开发环境
         profile: dev
         # 分支
         label: dev
   eureka:
     client:
       register-with-eureka: true
       fetch-registry: true
       service-url:
         # EurekaServer 如果设置了密码，需要将该配置也提前到 bootstrap.yml 中进行配置
         defaultZone: http://admin:123456@localhost:7900/eureka/
     instance:
       hostname: localhost
   ```

3. 测试类

   ```java
   import org.springframework.beans.factory.annotation.Value;
   import org.springframework.web.bind.annotation.RequestMapping;
   import org.springframework.web.bind.annotation.RestController;
   
   @RestController
   @RequestMapping("/consumer/config")
   public class ConfigController {
   
       @Value("${my-config}")
       private String myConfig;
   
       @RequestMapping("/my-config")
       public String getMyConfig() {
           return myConfig;
       }
   }
   ```

4. 访问 `/consumer/config/my-config` 测试即可

## 配置刷新

### 手动刷新

1. 在配置中心客户端添加 actuator 依赖

   ```xml
   <dependency>
       <groupId>org.springframework.boot</groupId>
       <artifactId>spring-boot-starter-actuator</artifactId>
   </dependency>
   ```

2. 配置文件中开启 refresh 端点

   ```yaml
   management:
     endpoints:
       web:
         exposure:
           # 此处把端点全开了
           include: '*'
   ```

3. 在需要刷新配置的类上添加 `@RefreshScope` 注解

   ```java
   @RefreshScope
   @RestController
   @RequestMapping("/consumer/config")
   public class ConfigController {
   ```

4. 重启服务，修改 git 上的配置内容，然后访问 `/consumer/config/my-config`，会发现配置并没有更新

5. POST 请求服务的 `/actuator/refresh` 端点，再访问 `/consumer/config/my-config`，可见配置已经更新

**注意事项：** 

手动刷新只能刷新单个微服务（即刷新 9090 端接口的 EurekaConsumer，9091 端口的 EurekaConsumer 的配置不会更新），所以需要手动为每个服务调用 refresh 端点，如果微服务过多，也是灾难，所以需要自动刷新

### 自动刷新

如果需要批量更新（例如把所有 EurekaConsumer 的配置都进行更新），需要通过 ESB。在 Spring Cloud 中使用支持 AMQP 协议的消息队列（RabbitMQ，Kafka）可以更方便的建立 ESB。

**在 [手动刷新](#手动刷新) 的基础上进行如下配置**

1. 安装[RabbitMQ](https://www.rabbitmq.com/)

   - 普通方式

     1. 安装 [erlang](https://www.erlang.org/)

     2. 安装 [RabbitMQ](https://www.rabbitmq.com/)

     3. 开启 RabbitMQ 节点

        ```shell
        rabbitmactl start_app
        ```

     4. 开启 RabbitMQ 管理模块的插件，并配置到 RabbitMQ 节点上

        ```shell
        rabbitmq-plugins enable rabbitmq_management
        ```

   - docker 方式

     ```shell
     docker run -it --rm --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3-management
     ```

2. 通过 http://localhost:15672 访问 RabbitMQ 管理页面，用户名/密码默认均为 guest

3. 在配置中心的客户端添加依赖

   ```xml
   <dependency>
       <groupId>org.springframework.cloud</groupId>
       <artifactId>spring-cloud-starter-bus-amqp</artifactId>
   </dependency>
   ```

4. 配置中心客户端的 bootstrap.yml

   ```yaml
   spring:
     rabbitmq:
       host: localhost
       # 此处端口是 5672，Web 界面的端口号是 15672
       port: 5672
       username: guest
       password: guest
   ```

5. 更新配置，POST 请求 `/actuator/bus-refresh` 即可。查看各个 EurekaConsumer 节点，配置信息均已更改。

   注意，此处请求 `/actuator/refresh`，依旧只能更新单独节点

**按照上述配置，可以刷新某个服务集群的配置。但是这样违背了微服务的单一职责性原则，不应该在每个微服务中设置刷新配置，应该通过配置中心服务端来对各个微服务进行配置更新**

1. 安装 RabbitMQ

2. 在配置中心的服务端添加依赖

   ```xml
   <dependency>
       <groupId>org.springframework.boot</groupId>
       <artifactId>spring-boot-starter-actuator</artifactId>
   </dependency>
   <dependency>
       <groupId>org.springframework.cloud</groupId>
       <artifactId>spring-cloud-starter-bus-amqp</artifactId>
   </dependency>
   ```

3. 在配置中心服务端的 application.yml 中配置 RabbitMQ 并开放 actuator 的端点

   ```yaml
   management:
     endpoints:
       web:
         exposure:
           include: '*'
     endpoint:
       health:
         enabled: true
         show-details: always
   spring:
     rabbitmq:
       host: localhost
       # 此处端口是 5672，Web 界面的端口号是 15672
       port: 5672
       username: guest
       password: guest
   ```

4. 在配置中心客户端添加依赖

   ```xml
   <dependency>
       <groupId>org.springframework.cloud</groupId>
       <artifactId>spring-cloud-starter-bus-amqp</artifactId>
   </dependency>
   ```

5. 在配置中心客户端的 bootstrap.yml 中配置 RabbitMQ

   ```yaml
   spring:
     rabbitmq:
       host: localhost
       # 此处端口是 5672，Web 界面的端口号是 15672
       port: 5672
       username: guest
       password: guest
   ```

6. 在需要刷新配置的类上添加 `@RefreshScope` 注解

7. 重启配置中心服务端和客户端，更新配置，POST 请求配置中心服务端的 `/actuator/bus-refresh` 即可更新所有微服务的配置文件，POST 请求配置中心服务端的 `/actuator/bus-refresh/{destination}` 可以局部刷新微服务。destination 是服务的 ApplicationContextID，可以使用 `**` 进行匹配，例如 `/actuator/bus-refresh/eureka-consumer:**` 即代表刷新所有的 eureka-consumer 服务

### 钩子（webhook）

对外提供一个用于更新配置的端点，将该端点配置在 Git 上，Git 通过监听某些事件（例如 push 等），当发生这些事件的时候回调我们提供的端点，从而更新微服务的配置。

**不要用自动刷新，万一哪个配置不对了，就是灾难**
