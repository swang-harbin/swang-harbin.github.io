---
title: Nacos 分布式配置中心
date: '2019-11-28 00:00:00'
tags:
- Nacos
- Java
---

# 分布式配置中心

[Nacos 系列目录](./nacos-al)

配置中心：把关于应用的配置，集中的放在一个地点。

nacos 可以做配置中心

## 使用配置中心的好处

- 分离的多环境配置：简化应用的配置过程，比如，同一个应用部署到不同的环境（test，dev，prod）使用不同的配置。
- 可以更灵活的管理权限
- 安全性高：将密码等信息部署在相对安全的地方

## 使用 nacos 做配置中心

### 添加配置文件

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222144940.png)

### bootstrap.properties

```properties
# 指定使用哪个配置文件
# 此处指定的是名称为 nacos-config-example 的配置文件，对应上图中的 Data ID
# Group 默认是 DEFAULT_GROUP
spring.application.name=nacos-config-example
# 当前服务的端口
server.port=18083
# nacos 服务的地址和端口
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

## 使用 nacos 作为配置中心的其他技巧

### 使用 yaml 格式文件作为配置文件

修改 bootstrap.properties，添加 **spring.cloud.nacos.config.file-extension=yaml**

```properties
# 指定使用哪个配置文件
# 此处指定的是名称为 nacos-config-example 的配置文件，对应上图中的 Data ID
# Group 默认是 DEFAULT_GROUP
spring.application.name=nacos-config-example
# 当前服务的端口
server.port=18083
# nacos 服务的地址和端口
spring.cloud.nacos.config.server-addr=127.0.0.1:8848

# 指定读取的配置文件格式
spring.cloud.nacos.config.file-extension=yaml
```

在 nacos 控制台修改配置文件，不需要重启应用即可实现配置的动态更新。

### profile 的使用

#### 在 nacos 中创建配置文件

nacos-config-example-{profile}

> 例如
> nacos-config-example-develop.yaml
> application-product.properties

#### 修改 bootstrap.properties

添加 **spring.profiles.active=粒度**，并修改 **[spring.application.name](http://spring.application.name/)** 和 **spring.cloud.nacos.config.file-extension** 的值

```properties
spring.application.name=nacos-config-example
spring.cloud.nacos.config.file-extension=yaml
spring.profiles.active=develop
```

### namespace 的使用

#### 在 nacos 中创建新的 namespace

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222145102.png)

#### 在新的 namespace 中创建配置文件

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222145117.png)

#### 修改 bootstrapt.properties

添加 **spring.cloud.nacos.config.namespace=Namespace ID**

```properties
# 例
spring.cloud.nacos.config.namespace=74ce8dac-3b1f-43e1-82ad-645f9c7ff741
```

