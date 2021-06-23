---
title: Kong 限流(Rate Limiting)
date: '2020-04-07 00:00:00'
tags:
- Kong
---
# Kong 限流（Rate Limiting）

[官方地址](https://docs.konghq.com/hub/kong-inc/rate-limiting/)

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142952.png)

速率限制在给定的几秒钟，几分钟，几小时，几天，几月或几年内，开发人员可以发出多少个 HTTP 请求。如果基础服务/路由（或不建议使用的 API 实体）没有身份验证层，则将使用客户端 IP 地址，否则，如果已配置身份验证插件，则将使用使用者。

> 注意：此插件与 0.13.1 之前的 Kong 版本和 0.32 之前的 Kong Enterprise 版本捆绑在一起的功能与此处记录的功能不同。有关详细信息，请参阅 [CHANGELOG](https://github.com/Kong/kong/blob/master/CHANGELOG.md)。

## 术语

- `plugin`：在将请求代理到上游 API 之前或之后，在 Kong 的内部运行该插件
- `Servic`：代表外部上游 API 或微服务的 Kong 实体
- `Route`：代表一种将下游请求映射到上游服务的方式的 Kong 实体
- `Consumer`：Kong 对其发出的请求进行代理；它可能代表用户或者外部非服务。
- `Credential`：与使用者（Consumer）相关联的唯一字符串，也称为 API 密钥
- `Upstream service`：指在 Kong 后面你自己的 API/服务，客户请求将被转发到这里

## 配置

该插件兼容以下协议的请求：
- http
- https

此插件部分兼容 DB-less 模式。

此插件可以与本地策略（不使用数据库）或 redis 策略（使用独立的 redis，因此与无数据库兼容）一起正常运行。

该插件不适用于需要写入数据库的集群策略。

## 在 Service 上启动该插件

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

`{service} `是此插件将针对的服务的 `id` 或 `name`。

## 在 Route 上启用该插件

**使用数据库**

通过下方请求将该插件配置到 Route：
```bash
$ curl -X POST http://kong:8001/routes/{route}/plugins \
    --data "name=rate-limiting"  \
    --data "config.second=5" \
    --data "config.hour=10000" \
    --data "config.policy=local"
```

**不用数据库**

在声明式配置文件中添加如下部分配置此插件到 Route
```yaml
plugins:
- name: rate-limiting
  route: {route}
  config: 
    second: 5
    hour: 10000
    policy: local
```

`{route} `是此插件将针对的 Route 的 `id `或 `name`。

# 在 Consumer 上配置此插件

**使用数据库**

你可以使用 `http://localhost:8001/plugins` 端点在指定的 Consumers 上启用该插件：

```bash
$ curl -X POST http://kong:8001/consumers/{consumer}/plugins \
    --data "name=rate-limiting" \
    --data "config.second=5" \
    --data "config.hour=10000" \
    --data "config.policy=local"
```

**不用数据库**

在声明式配置文件中添加如下部分配置此插件到 Consumer
```yaml
plugins:
- name: rate-limiting
  consumer: {consumer}
  config: 
    second: 5
    hour: 10000
    policy: local
```

`{consumer}` 是此插件配置针对的 Consumer 的 `id` 或 `username`。

你可以在同一个请求中联合使用 `consumer.id` 和 `service.id`，进一步缩小该插件的作用域。

## 全局插件

- **使用数据库**，所有的插件都可以使用 `http://kong:8001/plugins` 端点进行配置
- **没用数据库**，所有插件都可以在声明式配置文件中通过 `plugins:` 部分进行配置

与任何 Service，Route 或 Consumer（或 API，如果您使用的是 Kong 的较旧版本）无关的插件均被视为“全局”插件，并将在每个请求上运行。阅读 [插件参考](https://docs.konghq.com/latest/admin-api/#add-plugin) 和 [插件优先级](https://docs.konghq.com/latest/admin-api/#precedence) 部分以获取更多信息。

## 参数

配置该插件时可以使用的所有参数如下表

表单参数 | 描述
--- | --- 
`name` | 使用的插件的名字，这里是 `rate-limiting` 
`service.id` | 该插件针对的 Service 的 id 
`route.id` | 该插件针对的 Route 的 id 
`consumer.id` | 该插件针对的 Consumer 的 id 
`enabled`<br>默认值：`true` | 是否应用该插件
`config.seond`<br>*半可选* | 开发者没秒可以发送的 HTTP 请求量。必须至少存在一个限制条件。
`config.minute`<br>*半可选* | 开发者每分钟可以发送的 HTTP 请求量。必须至少存在一个限制条件。
`config.hour`<br>*半可选* | 开发者每小时可以发送的 HTTP 请求量。必须至少存在一个限制条件。
`config.day`<br>*半可选* | 开发者每天可以发送的 HTTP 请求量。必须至少存在一个限制条件。
`config.month`<br>*半可选* | 开发者每月可以发送的 HTTP 请求量。必须至少存在一个限制条件。
`config.year`<br>*半可选* | 开发者每年可以发送的 HTTP 请求量。必须至少存在一个限制条件。
`config.limit_by`<br>*可选* <br> 默认值：`consumer` | 汇总限制时使用的实体：`consumer`，`credential`，`ip`，`service`。如果无法确定 `consumer`，`credential `或 `service`，系统将总是回退到 `ip`。
`config.policy`<br>*可选*<br>默认值：`cluster` | 用于检索和增加限制的限流策略。可用值是 `local`（计数器将存储在节点上的本地内存中），`cluster`（计数器存储在数据存储区中并在节点之间共享）和 `redis`（计数器存储在Redis服务器上并在节点之间共享）。在 DB-less 模式下，必须至少指定 `local` 或 `redis` 之一。请参阅 [实施注意事项](https://docs.konghq.com/hub/kong-inc/rate-limiting/#implementation-considerations)，以了解有关应使用哪种策略的详细信息。
`config.fault_tolerant`<br>*可选*<br>默认值：`true` | 一个布尔值，它确定即使 Kong 在连接第三方数据库时遇到问题，是否也应代理该请求。如果 `true`，无论如何，请求都会被代理，从而有效禁用限流功能，直到该数据存储再次工作。如果是 `false`，客户端将会收到 `500` 错误 
`config.hide_client_headers`<br>*可选*<br>默认值：`false` | 可选隐藏信息丰富的响应头
`config.redis_host`<br>*半可选* | 当使用 `redis` 策略，该属性指定 Redis 服务的地址 
`config.redis_port`<br>*可选*<br>默认值：6379 | 当时用 `redis` 策略，该属性指定 Redis 服务的端口 
`config.redis_password`<br>*可选* | 当使用 `redis` 策略，该属性指定连接到的 Redis 服务的密码 
`config.redis_timeout`<br>*可选*<br>默认值：`2000` | 当使用 `redis` 策略，该属性指定任意命令提交到 Redis 服务的超时时间毫秒数 
`config.redis_database`<br>*可选*<br>默认值：`0` | 当时用 `redis` 策略，该属性指定使用的 Redis 数据库 

## 发送给客户端的头信息

当启用了该插件，Kong 会将一些其他的头信息发送回客户端，以告知允许的限制，有多少请求可用以及恢复配额之前需要花费多长时间，例如：
```yaml
RateLimit-Limit: 6
RateLimit-Remaining: 4
RateLimit-Reset: 47
```

此插件还将发送头信息，告诉标明时间范围内的限制以及剩余的请求数量：
```yaml
X-RateLimit-Limit-Minute: 10
X-RateLimit-Remaining-Minute: 9
```

或者，如果设置了多个时间限制，它将返回多个时间限制的组合：
```yaml
X-RateLimit-Limit-Second: 5
X-RateLimit-Remaining-Second: 4
X-RateLimit-Limit-Minute: 10
X-RateLimit-Remaining-Minute: 9
```

如果达到配置的任何限制，则插件将使用以下 JSON 正文向客户端返回 `HTTP / 1.1 429` 状态码。

```json
{ "message": "API rate limit exceeded" }
```

**注意事项**

> 头信息中的 `RateLimit-Limit`，`RateLimit-Remaining `和 `RateLimit-Reset` 是基于HTTP的Internet-Draft（Internet 草案）中 [RateLimit标头字段](https://tools.ietf.org/html/draft-polli-ratelimit-headers-01)，并且将来可能会更改，以确保规范更新。

## 实施注意事项

此插件支持 3 种策略，每种都有各自的优点和缺点

策略 | 优点 | 缺点
--- | --- | ---
`cluster` | 准确，无需额外的组件来支持 | 具有相对最大的性能影响，每个请求都强制对基础数据存储区进行读取和写入。
`redis` | 准确，对性能的影响小于 `cluster` 策略 | 必须安装外部的 redis，具有比 `local` 策略较大的性能影响 
`local` | 对性能的影响最小 | 不准确，除非在 Kong 前面使用了一个 Hash 一致的负载均衡器，否则在扩展节点数时，它会发散 

这有 2 个常见的使用示例
1. *每笔交易都很重要*。例如，这些是具有财务后果的交易。这里要求最高的准确性。
2. *后端保护*。在这里精度不那么重要，而只是用来保护后端服务免于过载。即可以由特定用户使用，也可以从总体上防御攻击。

**注意事项**

*仅限企业版* Kong 社区版不提供该限流插件对 [Redis Sentinel](https://redis.io/topics/sentinel) 支持。Kong 企业版订阅用户可以选择将 Redis Sentinel 与 Kong 限流插件一起使用以交付高可用性的主从部署

### 每笔交易都很总要

在此场景下，`local `策略是不可选的。这里的决定是在`redis`策略的额外性能与其额外的支持工作之间进行的。基于此平衡，选择应该使用 `cluster` 还是 `redis`。

建议从 `cluster` 策略开始，如果性能急速下降，则可以选择迁移到 `redis`。请记住，现有使用情况指标无法从数据存储库移植到 Redis。通常，对于寿命很短的指标（每秒或每分钟）来说这不是问题，而对于寿命较长（数月）的指标则可能产生较大影响，因此你可能需要更仔细地设计交换机。

### 后端保护

由于准确性不太重要，因此可以使用 `local` 策略。可能需要进行一些实验才能获取正确的配置。例如，如果用户每秒绑定100个请求，并且您拥有一个相对平衡的 5 节点 Kong 集群，则将本地限制设置为每秒 30 个请求即可。如果你担心有太多的 false-negatives，增加该值的大小。

请记住，随着集群扩展到更多节点，用户将获取更多的请求，同样，当集群缩减时，false-negatives 的可能性也会增加。因此，通常在扩展时更新你的限制。

可以通过在 Kong 前面使用 Hash 负载均衡器来减轻上述不准确性，以确保始终将同一用户定向到同—— Kong 节点。这样即可以减少误差，又可以防止缩放问题。

使用 `local` 策略时，很可能会向用户授予比协议更多的权限，但是它可以有效的阻止任何攻击，同时保持最佳性能。
