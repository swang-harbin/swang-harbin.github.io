---
title: Nacos服务注册中心
date: '2019-11-28 00:00:00'
tags:
- Nacos
- Java
---

# Nacos服务注册中心

## Nacos简介

一个更易于构建云原生应用的动态服务发现, 配置管理和服务管理平台

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222145531.png)

- 动态配置服务 : 对接入nacos的客户端进行配置的动态配置, 业内具有相同功能的有Apollo,confD
- 服务发现与管理 : 服务的注册和发现, 以及流量的管理调度等.
- 动态DNS服务 : 提供无侵入的DNS协议来支持异构系统的接入和访问.

## Nacos注册中心简介

Nacos注册中心是Nacos中负责**服务注册**, **服务发现**, **健康检查**等功能的组件

### 服务注册与发现

- 支持使用Java, Go, NodeJs等客户端进行服务的注册与发现
- 支持Dubbo服务框架, Spring Cloud Alibaba服务框架
- 支持使用DNS协议进行服务的发现

### 健康检查

- 支持服务端发送TCP, HTTP, MySQL请求进行服务健康状态的探测
- 支持客户端心跳上报1的健康状态更新

### 访问策略

- 支持基于权重的负载均衡策略
- 支持保护阈值, 解决服务雪崩问题
- 支持服务上下线
- 支持基于机房等环境信息设置访问策略

## Nacos作为注册中心的优势(对比Eureka, Zookeeper)

|                | Nacos                            | Zookeeper      | Eureka         | 优点                                                         |
| -------------- | -------------------------------- | -------------- | -------------- | ------------------------------------------------------------ |
| 一致性协议     | CP + AP                          | CP             | AP             | 可以选择使用哪种方式. 如果写入数据的成功由单条请求保证, 使用CP一致性优先保证数据的一致性, 提升服务的可用性; 如果单次请求不是很重要, 可以通过之后的数据补偿机制上报数据, 使用AP优先保证服务的可用性, 保证数据的一致性. |
| 访问协议       | HTTP/DNS                         | TCP            | HTTP           |                                                              |
| 健康检查       | TCP/HTTP/MySQL/上报心跳/用户扩展 | Keep Alive     | 上报心跳       |                                                              |
| 访问策略       | 服务端访问策略 + 客户端访问策略  | 客户端访问策略 | 客户端访问策略 | 客户端访问策略 : 将服务的所有实例下发到客户端, 在客户端或借助第三方组件进行服务的筛选; 服务端访问策略 : 在nacos控制台或使用API对服务配置特定的访问策略, 在通过接口进行服务实例查询时, 在nacos服务端进行服务实例的过滤, 不需要修改客户端并可在运行时动态调整, 更灵活. |
| 多地域数据中心 | 支持                             | 不支持         | 不支持         | nacos支持单节点/集群/同城双机房/同城多机房/扩地域多数据中心部署 |
| 读写TPS        | 万级                             | 万级           | 千级           |                                                              |
| 服务容量       | 百万级                           | 十万级         | 万级           |                                                              |

## Nacos部署

### Nacos单机部署

#### 下载Nacos安装包:

#### 解压安装包

#### 启动单机模式

```shell
sh bin/startup.sh -m standalone
```

#### 控制台访问

地址: 127.0.0.1:8848/nacos/index.html, 默认账号密码: nacos/nacos

### Nacos集群部署

#### 配置Nacos集群地址列表文件conf/**cluster.conf**

添加nacos集群中所有节点的地址

```shell
# ip:port
10.10.109.214:8848
11.16.128.34:8849
11.16.128.36:8848
```

#### 配置MySQL数据库

nacos使用了5.1.34版本的MySQL连接器, 因此需要使用**5.6.5以上** 或 **5.7.***版本的MySQL, 可以查看[nacos源码](https://github.com/alibaba/nacos)的pom文件检查mysql连接器版本

- 初始化MySQL数据库

  [SQL语句源文件](https://github.com/alibaba/nacos/blob/master/distribution/conf/nacos-mysql.sql)

- application.properties配置

修改端口号, 并添加数据库的配置

```properties
# 数据库实例数量
db.num=1
# 第一个数据库实例
db.url.0=jdbc:mysql://127.0.0.1:3307/nacos_config?characterEncoding=utf8
# 数据库用户名
db.user=root
# 数据库密码
db.password=root
```

#### 启动服务, 可通过控制台查看信息

## Nacos注册中心使用场景

### 在Spring Cloud中使用Nacos作为注册中心

[官方文档](https://nacos.io/zh-cn/docs/quick-start-spring-cloud.html)

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222145621.png)

示例代码:`https://github.com/nacos-group/nacos-examples/tree/master/nacos-spring-cloud-example/nacos-spring-cloud-discovery-example`

#### 添加Maven依赖

Provider端和Consumer端均需要添加

```
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-alibaba-nacos-discovery</artifactId>
    <version>${latest.version}</version>
</dependency>
```

| Spring Cloud Version   | Spring Cloud Alibaba Version | Nacos Version |
| ---------------------- | ---------------------------- | ------------- |
| Spring Cloud Greenwich | 0.9.0RELEASE                 | 1.0.0         |
| Spring Cloud Finchley  | 0.2.2RELEASE                 | 1.0.0         |
| Spring Cloud Edgware   | 0.1.2RELEASE                 | 1.0.0         |

#### 配置Provider端

##### 在application.properties中配置NacosServer地址:

```properties
server.port=8070
spring.application.name=service-provider
spring.cloud.nacos.discovery.server-addr=127.0.0.1:8848
```

##### 通过Spring Cloud原生注解@EnableDiscoveryClient开启服务注册发现功能:

```java
@SpringBootApplication
@EnableDiscoveryClient
public class NacosProviderApplication {

    public static void main(String[] args) {
        SpringApplication.run(NacosProviderApplication.class, args);
    }

    @RestController
    class EchoController {
        @RequestMapping(value = "/echo/{string}")
        public String echo(@PathVariable String string) {
            return "Hello Nacos Discovery " + string;
        }
    }
}
```

#### 配置Consumer端

##### 在application.properties中配置NacosServer地址:

```properties
server.port=8080
spring.application.name=service-consumer
spring.cloud.nacos.discovery.server-addr=127.0.0.1:8848
```

##### 通过Spring Cloud原生注解@EnableDiscoveryClient开启服务注册发现功能:

```java
@SpringBootApplication
@EnableDiscoveryClient
public class NacosConsumerApplication {

    @LoadBalanced
    @Bean
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }

    public static void main(String[] args) {
        SpringApplication.run(NacosConsumerApplication.class, args);
    }

    @RestController
    public class TestController {

        @Autowired
        private RestTemplate restTemplate;

        @RequestMapping(value = "/echo/{str}", method = RequestMethod.GET)
        public String echo(@PathVariable String str) {
            return restTemplate.getForObject("http://service-provider/echo/" + str, String.class);
        }
    }
}
```

#### 通过客户端接口调用服务端接口

通过访问客户端接口http://127.0.0.1:8080/echo/2019

返回 Hello Nacos Discovery 2019

### 在Dubbo中使用Nacos作为注册中心

[官方文档](https://nacos.io/zh-cn/docs/use-nacos-with-dubbo.html)

#### 引入Maven依赖

```xml
<!-- Dubbo 客户端 -->
<dependency>
    <groupId>com.alibaba</groupId>
    <artifactId>dubbo</artifactId>
    <version>${latest version}</version>
</dependency>

<!--与nacos-client结合, 调用nacos-client进行服务的注册与发现-->
<dependency>
    <groupId>com.alibaba</groupId>
    <artifactId>dubbo-registry-nacos</artifactId>
    <version>${latest version}</version>
</dependency>
<!--真正与nocas服务端进行通讯的-->
<dependency>
    <groupId>com.alibaba.nacos</groupId>
    <artifactId>nacos-client</artifactId>
    <version>${latest version}</version>
</dependency>
```

#### 配置Provider端

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:dubbo="http://dubbo.apache.org/schema/dubbo"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-4.3.xsd        http://dubbo.apache.org/schema/dubbo        http://dubbo.apache.org/schema/dubbo/dubbo.xsd">

    <!-- 提供方应用信息，用于计算依赖关系 -->
    <dubbo:application name="dubbo-provider-xml-demo"/>

    <!-- 暴露的服务, 将会注册到Nacos上 -->
    <dubbo:service interface="com.alibaba.dubbo.demo.service.DemoService" ref="demoServiceLocal" version="1.0.0"/>
    
    <!-- 暴露的端口 -->
    <dubbo:protocol name="dubbo" port="20881"/>
    
    <!-- 使用Nacos注册中心 -->
    <dubbo:registry address="nacos://127.0.0.1:8848" />
</beans>
```

#### 配置Consumer端

略, 参照[官方文档](https://nacos.io/zh-cn/docs/use-nacos-with-dubbo.html)

## 在阿里云上使用Nacos注册中心

[参考视频](https://edu.aliyun.com/course/1944/learn#lesson/16997)

## Nacos基本实现原理

### Nacos注册中心数据模型

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222145712.png)

- 数据隔离模型 : nacos支持4层, 保证**不同的用户**或**相同的用户在不同的场景中**, 数据不会冲突
- 服务数据模型 : 分为3层, IP和端口存储在实例数据中, 服务和集群中存储特定配置, 进行整个的服务管理.

### Nacos注册中心逻辑模块

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222145726.png)

- 用户接口模块(User Interface) : 权限校验, 参数校验, 数据转换等
- 主存模块(Main Memory of Services) : 存储注册中心所有的数据, 所有的查询均从该处获取数据
- 推送模块(Push Service) : 管理所有的订阅端, 以及推送的触发, 聚合, 去除等工作
- 健康检查模块(Health Check Module) : 包含服务端探测和客户端上报两种方式
- 访问策略模块(Selector Module) : 根据服务配置的特定访问策略, 对下发的实例进行过滤, 支持基于标签的访问策略
- 集群管理模块(Cluster Module) : 对nacos-service集群列表进行管理, 维持一个可以联通的nocas集群
- 一致性和持久化模块(Consistency and Persistency) : 对nacos中的数据进行持久化存储, 以及SQL间的同步保证整个集群的数据置信.

### Nacos注册中心Distro协议

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222145739.png)

## 链接

一. [Nacos服务注册与发现](./nacos-service-registry-and-discovery.md)

二.[Nacos分布式配置中心](./nacos-distribut-configuration-center.md)

三.[Nacos服务注册中心](./nacos-service-registry-center.md)
