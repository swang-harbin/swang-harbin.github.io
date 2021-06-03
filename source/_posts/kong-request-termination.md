---
title: Kong熔断(Request Termination)
date: '2020-04-04 00:00:00'
updated: '2020-04-04 00:00:00'
tags:
- Kong
categories:
- Kong
---
# Kong熔断(Request Termination)

[官方文档](https://docs.konghq.com/hub/kong-inc/request-termination/)

![kong-inc_request-termination.png](https://note.youdao.com/yws/res/65801/WEBRESOURCE123656dee0bb5c7cf44409c1e095075a)

该插件使用指定的状态码和信息终止传入的请求. 这允许(临时)停止在服务或路由撒谎那个的流量, 甚至阻止使用者.

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

该插件兼容DB-less模式

## 在一个Service上启用该插件

**使用数据库**

通过发出以下请求在服务上配置此插件：
```bash
$ curl -X POST http://kong:8001/services/{service}/plugins \
    --data "name=request-termination"  \
    --data "config.status_code=403" \
    --data "config.message=So long and thanks for all the fish!"
```

**没有使用数据库**

通过将此部分添加到声明性配置文件中，在Service上配置此插件 :
```yaml
plugins:
- name: request-termination
  service: {service}
  config: 
    status_code: 403
    message: So long and thanks for all the fish!
```

`service`是此插件配置将针对的服务的`id`或`name`

## 在Route上启用该插件

**使用了数据库**

使用以下命令在Route上配置此插件

```bash
$ curl -X POST http://kong:8001/routes/{route}/plugins \
    --data "name=request-termination"  \
    --data "config.status_code=403" \
    --data "config.message=So long and thanks for all the fish!"
```

**没使用数据库**

通过将此部分添加到声明性配置文件中，在Route上配置此插件:
```yaml
plugins:
- name: request-termination
  route: {route}
  config: 
    status_code: 403
    message: So long and thanks for all the fish!
```
`route`是此插件配置将针对的Route的`id`或`name`

## 在Consumer上启用该插件

**使用数据库**

你可以使用`http://localhost:8001/plugins`端点, 在指定的Consumers上启用该插件:

```bash
$ curl -X POST http://kong:8001/consumers/{consumer}/plugins \
    --data "name=request-termination" \
    --data "config.status_code=403" \
    --data "config.message=So long and thanks for all the fish!"
```

**没用数据库**

通过将此部分添加到声明性配置文件中，在Consumer上配置此插件:
```yaml
plugins:
- name: request-termination
  consumer: {consumer}
  config: 
    status_code: 403
    message: So long and thanks for all the fish!
```

`route`是此插件配置将针对的使用者的`id`或`username`

你可以在同一个请求上组合使用`consumer.id`和`service.id`, 以进一步缩小插件的范围

## 全局插件

- **使用数据库**, 所有的插件都可以使用`http://kong:8001/plugins`端点进行配置
- **没用数据库**, 所有插件都可以在声明式配置文件中通过`plugins:`部分进行配置

与任何Service, Route或Consumer(或API, 如果您使用的是Kong的较旧版本)无关的插件均被视为"全局"插件, 并将在每个请求上运行. 阅读[插件参考](https://docs.konghq.com/latest/admin-api/#add-plugin)和[插件优先级](https://docs.konghq.com/latest/admin-api/#precedence)部分以获取更多信息.

## 参数

配置该插件时可以使用的所有参数如下表

表单参数 | 描述
--- | ---
`name` | 当前使用插件的名字, 该插件为`request-termination`
`service.id` | 该插件针对的Service ID
`route.id` | 该插件针对的Route ID
`consumer.id` | 该插件针对的Consumer ID
`enabled` 默认值:`true` | 是否应用该插件
`config.status_code` 可选项, 默认值:`503` | 响应的状态码
`config.message` 可选项 | 返回的消息, 如果使用了默认的相应生成器
`config.body` 可选项 | 返回的原始Response Body, 这与`config.message`字段互斥
`config.content_type` 可选项, 默认值:`application/json; charset=utf-8` | 使用`config.body`配置的原始响应内容类型

一旦应用, 每个请求(在Service, Route, Consumer或Global的已配置插件范围内)将通过发送已配置的响应立即终止.

## 用例范例

- 暂时停用Service(例如, 正在维护中)
- 暂时停用Route(例如, 该服务的其余部分已启动并正在运行, 但是必须禁用特定的端点)
- 暂时禁用Consumer(例如, 过度消费)
- 在logical `OR` setup中使用multiple auth plugins阻止匿名用户访问

