---
title: Nacos 服务注册与发现
date: '2019-11-28 00:00:00'
tags:
- Nacos
- Java
---

# Nacos 服务注册与发现

[Nacos 系列目录](./nacos-alibaba-table.md)

## 服务注册

服务实例将自身服务注册到注册中心，包括服务所在 IP 和 Port，服务版本以及访问协议等。

类比为增强版的 DNS

## 服务发现

应用实例通过注册中心，获取到注册到其中的服务实例的信息，通过这些信息去请求它们提供的服务。

## 为什么需要服务注册和发现

在微服务中，由于自动扩缩，故障与升级，整组服务实例会动态变更

## 安装启动 nacos

nacos：一个更易于构建云原生应用的动态服务发现、配置管理和服务管理平台。

nocas 包含一个监听的 API，以及一个控制台

控制台访问地址：http://localhost:8848/nacos/
username：nacos
password：nacos

## nacos 注册与发现示例代码

github 地址：https://github.com/szihai/Nacos-discovery-demo

### 服务端

#### ProviderApplication.java

```java
@SpringBootApplication
@EnableDiscoveryClient
public class ProviderApplication {
    public static void main(String[] args) {
        SpringApplication.run(ProviderApplication.class, args);
    }
}


@RestController
class EchoController {
    @RequestMapping(value = "/echo/{string}", method = RequestMethod.GET)
    public String echo(@PathVariable String string) {
        return string;
    }
}
```

**`@EnableDiscoveryClient`**：让服务中心（nacos）来扫描，并将其加入到注册中心中，是 Spring Cloud 的 Annotation

#### application.properties

```properties
# 服务的名字
spring.application.name=service-provider
# 服务发布端口
server.port=8081
# 把 nocas 的服务地址和端口号告诉该应用程序
spring.cloud.nacos.discovery.server-addr=127.0.0.1:8848
# 暴露这些 endpoint
management.endpoints.web.exposure.include=*
```

启动 provider 后，在 nacos 上即可发现该服务

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222144612.png)

#### POM

```xml
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-actuator</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-starter-alibaba-nacos-discovery</artifactId>
    </dependency>
</dependencies>

<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-dependencies</artifactId>
            <version>Greenwich.SR1</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-alibaba-dependencies</artifactId>
            <version>0.9.0.RELEASE</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>
```

#### Actuator 端点

- 监控和管理服务
- /info，/health
- http://localhost:8081/actuator/nacos-discovery

application.properties

```properties
# 暴露这些 endpoint
management.endpoints.web.exposure.include=*
```

以及 POM 中引入的一些依赖，需要了解 Spring Cloud

详情需要了解 Spring Boot 的端点相关

### 消费端

#### POM 文件

```xml
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-starter-alibaba-nacos-discovery</artifactId>
        <version>0.9.0.RELEASE</version>
    </dependency>
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-starter-openfeign</artifactId>
        <version>2.1.0.RELEASE</version>
    </dependency>
</dependencies>

<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-dependencies</artifactId>
            <version>Greenwich.SR1</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>
```

比服务端多了个 **spring-cloud-starter-openfeign**，需要手动引入

#### application.properties

```properties
# 服务名称
spring.application.name=service-consumer
# 服务端口
server.port=18082
# nacos 地址和端口
spring.cloud.nacos.discovery.server-addr=127.0.0.1:8848
```

#### ConsumerApplication

nacos 支持 **REST Template** 和 **Feign client**

```java
@SpringBootApplication
@EnableDiscoveryClient
@EnableFeignClients
public class ConsumerApplication {

    @LoadBalanced
    @Bean
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }

    public static void main(String[] args) {
        SpringApplication.run(ConsumerApplication.class, args);
    }
}

@FeignClient(name = "service-provider")
interface EchoService {
    @RequestMapping(value = "/echo/{str}", method = RequestMethod.GET)
    String echo(@PathVariable("str") String str);
}

@RestController
class TestController {
    @Autowired
    private RestTemplate restTemplate;
    @Autowired
    private EchoService echoService;

    @RequestMapping(value = "/echo-rest/{str}", method = RequestMethod.GET)
    public String rest(@PathVariable String str) {
        return restTemplate.getForObject("http://service-provider/echo/" + str,
                                         String.class);
    }

    @RequestMapping(value = "/echo-feign/{str}", method = RequestMethod.GET)
    public String feign(@PathVariable String str) {
        return echoService.echo(str);
    }
}
```
