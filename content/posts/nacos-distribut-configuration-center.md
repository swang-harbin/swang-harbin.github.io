---
title: Nacos分布式配置中心
date: '2019-11-28 00:00:00'
tags:
- Nacos
- Java
categories:
- Java
---

# 分布式配置中心

配置中心 : 把关于应用的配置, 集中的放在一个地点.

nacos可以做配置中心

## 使用配置中心的好处

- 分离的多环境配置 : 简化应用的配置过程, 比如, 同一个应用部署到不同的环境(test, dev, prod)使用不同的配置.
- 可以更灵活的管理权限
- 安全性高 : 将密码等信息部署在相对安全的地方

## 使用nacos做配置中心

### 添加配置文件

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222144940.png)

### bootstrap.properties

```properties
# 指定使用哪个配置文件
# 此处指定的是名称为 nacos-config-example 的配置文件, 对应上图中的Data ID
# Group默认是DEFAULT_GROUP
spring.application.name=nacos-config-example
# 当前服务的端口
server.port=18083
# nacos服务的地址和端口
spring.cloud.nacos.config.server-addr=127.0.0.1:8848
```

### POM

```xml
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-starter-alibaba-nacos-config</artifactId>
        <version>0.9.0.RELEASE</version>
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

### NacosConfigExampleApplication

```java
@SpringBootApplication
public class NacosConfigExampleApplication {
    public static void main(String[] args) {
        SpringApplication.run(NacosConfigExampleApplication.class, args);
    }
}

@RestController
@RefreshScope
class EchoController {
    @Value("${user.name:unknown}")
    private String userName;
    @RequestMapping(value = "/")
    public String echo() {
        return userName;
    }
}
```

## 使用nacos作为配置中心的其他技巧

### 使用yaml格式文件作为配置文件

修改bootstrap.properties, 添加**spring.cloud.nacos.config.file-extension=yaml**

```properties
# 指定使用哪个配置文件
# 此处指定的是名称为 nacos-config-example 的配置文件, 对应上图中的Data ID
# Group默认是DEFAULT_GROUP
spring.application.name=nacos-config-example
# 当前服务的端口
server.port=18083
# nacos服务的地址和端口
spring.cloud.nacos.config.server-addr=127.0.0.1:8848

# 指定读取的配置文件格式
spring.cloud.nacos.config.file-extension=yaml
```

在nacos控制台修改配置文件, 不需要重启应用即可实现配置的动态更新.

### profile的使用

#### 在nacos中创建配置文件

nacos-config-example-{profile}

> 例如:
> nacos-config-example-develop.yaml
> application-product.properties

#### 修改bootstrap.properties

添加**spring.profiles.active=粒度**, 并修改**[spring.application.name](http://spring.application.name/)**和**spring.cloud.nacos.config.file-extension**的值

```properties
spring.application.name=nacos-config-example
spring.cloud.nacos.config.file-extension=yaml
spring.profiles.active=develop
```

### namespace的使用

#### 在nacos中创建新的namespace

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222145102.png)

#### 在新的namespace中创建配置文件

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222145117.png)

#### 修改bootstrapt.properties

添加**spring.cloud.nacos.config.namespace=Namespace ID**

```properties
# 例:
spring.cloud.nacos.config.namespace=74ce8dac-3b1f-43e1-82ad-645f9c7ff741
```

## 链接

一. [Nacos服务注册与发现](./nacos-service-registry-and-discovery.md)

二.[Nacos分布式配置中心](./nacos-distribut-configuration-center.md)

三.[Nacos服务注册中心](./nacos-service-registry-center.md)
