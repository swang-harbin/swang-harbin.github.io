---
title: Kong 集群参考
date: '2019-12-11 00:00:00'
tags:
- Kong
---
# 集群参考

## 介绍

Kong 集群允许你通过添加更多的机器来水平扩展系统，并处理更多传入请求。因为它们都使用同一个数据库，所以它们会使用相同的配置。指向同一个数据库的 Kong 节点将属于同一个集群。

需要在 Kong 集群前添加一个负载均衡器，来在可用节点之间分配流量。

## Kong 集群能够/不能够做的
拥有一个 Kong 集群并不意味着客户端的流量就会在这些 Kong 节点之间实现负载均衡。仍然需要在所有的 Kong 集群节点前添加一个负载均衡器去分配流量。否则，一个 Kong 集群中的所有节点都使用相同的配置。

处于性能考虑, Kong 在代理请求时避免数据库的连接，并在内存中缓存数据库内容。该缓存实体包含服务，路由，消费方，插件，证书等等……因为这些值已经存储在内存中，所以需要将任意一个节点使用 Admin API 做的改变传播给其他的节点。

本文介绍了如何使那些缓存的实体失效以及如何为您的用例配置 Kong 节点，这些配置考虑了性能和一致性。

## 单节点 Kong 集群

一个单独的 Kong 节点连接到数据库（cassandra 或 PostgreSQL）创建一个单节点的 Kong 集群。任何通过该节点的 Admin API 做的改变会即时生效。例

想象有一个 Kong 节点 A，如果我们删除以前注册的服务
```bash
curl -X DELETE http://127.0.0.1:8001/services/test-service
```
这时，任何访问 A 节点的请求都会返回 **404 Not Found**，因为该节点从内部缓存中清除了它
```bash
curl -i http://127.0.0.1:8000/test-service
```

## 多节点的 Kong 集群

在多个 Kong 节点的集群中，连接相同数据库的其他节点不会立即接收到 A 节点删除该服务的通知，虽然服务不在数据库了（它被 A 节点删除了），但是它还存在在 B 节点的内存中。

所有的节点进行周期性的后台工作去同步其他节点执行的改变。这项工作的频率可以通过如下配置设置

```bash
db_update_frequency (default: 5 seconds)
```

每隔 `db_update_frequency` 秒，所有正在运行的 Kong 节点会轮询数据库中的更新，并在需要时清除它们缓存中的实体。

如果我们通过 A 节点删除了一个服务，这个改变在节点 B 轮询数据库之前对于 B 节点来说是无效的，要过 `db_update_frequency` 秒才生效。（小于等于）

这个配置使得 Kong 集群最终一致。

## 正在缓存什么

所有核心的实体，例如服务，路由，插件，消费者，证书都会被 Kong 缓存到内存，并根据轮询机制将它们更新为失效。

另外, Kong 还缓存未命中的数据。例如你配置的一个服务没有 plugin，Kong 将会缓存这个信息。例

在 A 节点，我们添加一个 Service 和一个 Route
```bash
# node A
$ curl -X POST http://127.0.0.1:8001/services \
    --data "name=example-service" \
    --data "url=http://example.com"

$ curl -X POST http://127.0.0.1:8001/services/example-service/routes \
    --data "paths[]=/example"
```

（注意，我们使用 /services/example-service/routes 作为快捷方式：也可以使用 /routes 端点代替，但是这时我们需要使用 service_id 作为参数，这个新的服务 ID 是 UUID）

对 A 节点和 B 节点的代理端口发送请求，将会缓存该服务，并缓存没有在该服务上配置 plugin 的事实: 
```bash
# node A
curl http://127.0.0.1:8000/example

HTTP 200 OK
...
```

```bash
# node B
curl http://127.0.0.2:8000/example

HTTP 200 OK
...
```

现在我们通过 A 节点的 Admin API 添加一个插件
```bash
# node A
curl -X POST http://127.0.0.1:8001/services/example-service/plugins \
    --data "name=example-plugin"
```
// TODO [官方文档](https://docs.konghq.com/1.4.x/clustering/#what-is-being-cached)
