---
title: Kong限流(Rate Limiting)
date: '2020-04-07 00:00:00'
tags:
- Kong
categories:
- Kong
---
# Kong限流(Rate Limiting)

[官方地址](https://docs.konghq.com/hub/kong-inc/rate-limiting/)

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142952.png)

速率限制在给定的几秒钟, 几分钟, 几小时, 几天, 几月或几年内, 开发人员可以发出多少个HTTP请求. 如果基础服务/路由(或不建议使用的API实体)没有身份验证层, 则将使用客户端IP地址, 否则, 如果已配置身份验证插件, 则将使用使用者. 

> 注意：此插件与0.13.1之前的Kong版本和0.32之前的Kong Enterprise版本捆绑在一起的功能与此处记录的功能不同。 有关详细信息，请参阅[CHANGELOG](https://github.com/Kong/kong/blob/master/CHANGELOG.md).

## 术语

- `plugin`: 在将请求代理到上游API之前或之后, 在Kong的内部运行该插件
- `Servic`: 代表外部上游API或微服务的Kong实体
- `Route`: 代表一种将下游请求映射到上游服务的方式的Kong实体
- `Consumer`: Kong对其发出的请求进行代理; 它可能代表用户或者外部非服务.
- `Credential`: 与使用者(Consumer)相关联的唯一字符串, 也称为API密钥
- `Upstream service`: 指在Kong后面你自己的API/服务, 客户请求将被转发到这里

## 配置

该插件兼容以下协议的请求:
- http
- https

此插件部分兼容DB-less模式.

此插件可以与本地策略(不使用数据库)或redis策略(使用独立的redis, 因此与无数据库兼容)一起正常运行.

该插件不适用于需要写入数据库的集群策略.

## 在Service上启动该插件

**使用数据库**

通过下面的请求在服务上配置该插件
```bash
$ curl -X POST http://kong:8001/services/{service}/plugins \
    --data "name=rate-limiting"  \
    --data "config.second=5" \
    --data "config.hour=10000" \
    --data "config.policy=local"
```

**不用数据库**

通过在声明式配置文件中添加如下部分在服务上配置该插件
```yaml
plugins:
- name: rate-limiting
  service: {service}
  config: 
    second: 5
    hour: 10000
    policy: local
```

`{service}`是此插件将针对的服务的`id`或`name`.

## 在Route上启用该插件

**使用数据库**

通过下方请求将该插件配置到Route:
```bash
$ curl -X POST http://kong:8001/routes/{route}/plugins \
    --data "name=rate-limiting"  \
    --data "config.second=5" \
    --data "config.hour=10000" \
    --data "config.policy=local"
```

**不用数据库**

在声明式配置文件中添加如下部分配置此插件到Route
```yaml
plugins:
- name: rate-limiting
  route: {route}
  config: 
    second: 5
    hour: 10000
    policy: local
```

`{route}`是此插件将针对的Route的`id`或`name`.

# 在Consumer上配置此插件

**使用数据库**

你可以使用`http://localhost:8001/plugins`端点在指定的Consumers上启用该插件:

```bash
$ curl -X POST http://kong:8001/consumers/{consumer}/plugins \
    --data "name=rate-limiting" \
    --data "config.second=5" \
    --data "config.hour=10000" \
    --data "config.policy=local"
```

**不用数据库**

在声明式配置文件中添加如下部分配置此插件到Consumer
```yaml
plugins:
- name: rate-limiting
  consumer: {consumer}
  config: 
    second: 5
    hour: 10000
    policy: local
```

`{consumer}`是此插件配置针对的Consumer的`id`或`username`.

你可以在同一个请求中联合使用`consumer.id`和`service.id`, 进一步缩小该插件的作用域.

## 全局插件

- **使用数据库**, 所有的插件都可以使用`http://kong:8001/plugins`端点进行配置
- **没用数据库**, 所有插件都可以在声明式配置文件中通过`plugins:`部分进行配置

与任何Service, Route或Consumer(或API, 如果您使用的是Kong的较旧版本)无关的插件均被视为"全局"插件, 并将在每个请求上运行. 阅读[插件参考](https://docs.konghq.com/latest/admin-api/#add-plugin)和[插件优先级](https://docs.konghq.com/latest/admin-api/#precedence)部分以获取更多信息.

## 参数

配置该插件时可以使用的所有参数如下表

表单参数 | 描述
--- | --- 
