---
title: Kong负载均衡&蓝绿部署&金丝雀发布
date: '2019-12-10 00:00:00'
updated: '2019-12-10 00:00:00'
tags:
- Kong
categories:
- Kong
---
# Kong负载均衡&蓝绿部署&金丝雀发布

## 介绍
Kong为提交到后端的请求提供多种负载均衡方式: 一个简单的DNS-based方法和一个更动态的ring-balancer方法(允许服务不通过DNS服务器注册)

## DNS-based 负载均衡

### A记录(A records)
一个A记录包含一个或多个IP地址. 因此, 当一个主机名解析为一个A记录, 每一个后端服务必须有他自己的IP地址.

因为没有权重(weight)信息, 所以, 所有的入口在负载均衡时都具有相同的权重, 并且这个均衡器会进行一个简单的轮询.

### SRV记录(SRV records)
SRV记录包含它所有IP地址的权重和端口信息, 后端服务可以通过IP和端口号来唯一的标识. 因此, 一个IP地址能够承载多个在不同端口上的服务实例.

因为权重(weight)是可用的, 每个入口在负载均衡时会有自己的权重, 将会进行带权重的轮询.

同样的, 任何一个给定的端口信息将会覆盖DNS服务器中的端口信息. 如果一个服务有host=myhost.com和port=123两个属性, 并且myhost.com解析为具有127.0.0.1:456的SRV记录, 则该请求会被代理为http://127.0.0.1:456/somepath, 123端口被重写为456.

### DNS优先权(DNS priorities)
DNS解析器会按以下的顺序解析记录类型: 
1. 以前最后解决成功的类型
2. SRV记录
3. A记录
4. CNAME记录

解析顺序可通过[```dns_order```属性配置](https://docs.konghq.com/1.4.x/configuration/#dns_order)

### DNS注意事项

- 每当DNS被刷新, 都会生成一个列表以正确处理权重. 并尝试将权重保持为彼此的倍数来保证算法的高效性. 例如, 权重为17和31的两个权重值, 将会导致具有527条记录的列表, 而16和32(或他们的最小相对值1和2)两个权重将导致仅有3条记录的列表, 特别是有一个非常小(甚至是0)的TTL值
- 一些域名服务器不返回所有的记录(由于UDP包的大小造成的), 这时, 一个给定的Kong节点只能使用域名服务器提供的少数上游服务实例. 在这种情况下, 上游实例池的加载可能不一致, 因为域名服务器提供的信息有限, 所以Kong节点实际上并没有发现某些实例. 为了减轻这种情况, 请使用其他域名服务器, 或使用IP地址替换名称, 或使用足够的Kong节点保证使用了所有的上游服务.
- 当域名返回了**3 name error**, 这是kong的有效响应. 如果这是意外情况, 请首先验证是否正在查询正确的名称, 然后检查您的名称服务器配置. 
- 从DNS记录(A或SRV)中初始选择IP地址不是随机的. 因此使用TTL为0的记录时, 名称服务器应将记录列表随机化.

## 环平衡器(Ring-balancer)

当使用ring-balancer, 后端服务的添加和删除会被Kong管理, 这时更新DNS不是必须的. Kong会作为服务注册表. 可以使用一个HTTP请求添加/删除节点, 并立即启动/停止接收流量.

通过**upstream**和**target**条目来配置ring-balancer

- target : 后端服务的地址, 使用IP地址(或域名)和端口号指定. 例如: "192.168.100.12.80". 每个target都可以通过附加的**weight**去设置它的权重.

- upstream : 能被用在路由(Route)的host字段中的一个虚拟主机名(virtual hostname), 例如: 一个上游服务的被命名为**weather.v2.service**, 那么带有**host=weather.v2.service**的请求均可以请求它.

### 上游(Upstream)

每个upstream有它自己的ring-balancer. 每个**upstream**有许多的**target**连接到它, 并且代理到虚拟主机名(可以使用**upstream**的**post_header**属性对其覆盖)的请求将会在targets之间进行负载均衡.ring-balancer会预先定义一定数量的slots, 并根据目标权重将slots分配给upstream中的targets.

可以使用HTTP请求Admin API添加或移除targets. 
这种操作成本较低. 更改upstream本身的成本较高, 例如当slots的数量变了, 需要重建负载均衡器.

只有当target历史被清理时, 均衡器会被完全重建. 其他情况只会根据更改重建.

ring-balancer中的位置(positions, from 1 to slots)是随机分配的. 必要的随机性使得在运行时调用ring-balancer的成本较低. 在wheel(the positions, ring-balancer中的位置)上进行轮询会提供在targets分布均匀的加权轮询, 同时对targets的插入/删除成本较低.

每个target应该有大约100个slots, 确保slots是合理分配的. 例如: 如果预计有8个targets, 这个**upstream**需要定义**slots=800**, 哪怕起初只有2个targets.

这里通过更多的slots获取更好的随机分布, 如果通过之后去修改(添加/移除 targets), 付出的代价更大.

有关添加和操作upstreams的信息, 可以查看[Admin API reference](https://docs.konghq.com/1.4.x/admin-api#upstream-object)

### 目标(Target)
由于**upstream**维护了一个改变历史, targets只能被添加, 不能被修改或删除. 想要去改变一个target, 只需要为这个target添加一个新的记录, 并改变他的**weight**值. 会使用最后一条记录. 设置target的**weight=0**, 可以有效的从均衡器中删除它. 有关添加和操作targets的信息, 可以查看[Admin API reference](https://docs.konghq.com/1.4.x/admin-api#target-object)

当targets中的不活动条目比活动条目高10倍时会被自动清理. 清理会重建均衡器, 因此它比只添加target记录更耗费资源.

**target**可以使用主机名替代IP地址. 这种情况下, 主机名会被解析, 解析出来的所有条目都会添加到ring-balancer. 例如: 添加**api.host.com:123**和**weight=100**. 'api.host.com'被解析为一个A记录包含2个IP地址. 这两个IP地址会作为target被添加, 每个都具有**weight=100**属性和123端口. 

当它被解析为SRV记录, 将会提取DNS记录中的端口和权重, 并且会覆盖给定的端口123和权重100. 

均衡器会遵循DNS记录中设置的TTL值, 并在它过期时重新查询和更新均衡器.

例外: 当DNS记录的TTL被设置为0时, 会将这个主机名作为单独的target和指定的权重一起添加进来. 当这个target的每个代理请求后会再次查询该名称服务器.

### 负载均衡算法(Balancing Algorithms)
默认情况下ring-balancer使用weighted-round-robin(加权轮询). 另一种方法是基于hash的算法. 对于hash的输入可以是**none**, **consumer**, **ip**, **header**, **cookie**. 当设置为**none**时, 将会使用weighted-round-robin算法, 并禁用hash算法.

有两个选项, 主选项(primary)和副选项(fallback), 以防止主选项失败.(例如, 如果主选项设置为consumer, 但是没有consumer认证)

**不同的hash选项介绍** : 

- none: 不使用hash, 使用weight-round-robin替代
- consumer: 使用消费者ID(consumer id)作为hash的输入值. 如果没有消费者ID, 该选项会把认证ID(credential id)作为副选项
- ip: 把远程的IP地址作为hash的输入值. 使用该选项, 请查看[real_ip_header](https://docs.konghq.com/1.4.x/configuration/#real_ip_header)
- header: 使用提供的header(在hash_on_header或hash_fallback_header字段配置)作为hash的数据值. 
- cookie: 提供一个cookie名称(hash_on_cookie字段)和路径(hash_on_cookie_path字段, 默认"/")作为hash的输入值. 如果请求中不包含cookie, 它将由相应配置. 因此如果设置cookie作为主选项, **hash_fallback**是无效的.

hash算法遵循'consistent--hashing(或ketama principle), 确保因为改变targets而对均衡器进行修改时的损失最小. 这会最大化upstream缓存的命中.

更多信息查看[Admin API reference](https://docs.konghq.com/1.4.x/admin-api#upstream-object)中关于upstream的设置.

### 平衡的注意事项

ring-balancer被设计为单节点使用或集群使用. 对于加权轮询算法那没有太大的区别, 但是当使用基于hash的算法时, 所有的节点都应该建立完全相同的ring-balancer, 以确保它们做相同的工作. 为了做到这一点, 必须使用确定的方法来创建均衡器.

- 不要在均衡器中使用主机名, 因为平衡器可能会缓慢的分开, 因为DNS ttl仅是第二匹配选项, 请求取决于实际的主机名称. 另外, 一些命名服务器不会返回所有的记录, 会加剧这种问题. 所以, Kong在集群时使用hash算法, 通过IP地址添加target.

- 当选用hash算法时, 请确保输入的值具备足够的差异, 可以获取一个分布均匀的散列表. Hash使用CRC-32来计算. 例如, 你的系统有上万个用户, 但每个平台仅定义了几个消费者(例如Web, IOS和Android), 则使用远程IP地址设置作为Hash的输入是无法满足需求的. Hash需要输入ip可以提供更大的差异, 使得Hash的输出分布更均匀. 但是如果许多客户端位于同一个NET网关(例如:呼叫中心), 则cookie比ip能提供更好的分布.

## 蓝绿部署(Blue-Green Deployments)
使用ring-balancer可以很轻松的为服务进行[蓝绿部署](http://blog.christianposta.com/deploy/blue-green-deployments-a-b-testing-and-canary-releases/).

切换target的基础架构仅需要向服务发送一个**PATCH**请求, 去改变他的**host**值. 

设置"Blue"环境, 运行version1的地址服务:
```bash
# 创建一个upstream
curl -X POST http://kong:8001/upstreams \
    --data "name=upstreams-name"

# 添加两个target(服务)到upstream
curl -X POST http://kong:8001/upstreams/upstreams-name/targets \
    --data "target=192.168.34.15:80"
    --data "weight=100"

curl -X POST http://kong:8001/upstreams/upstreams-name/targets \
    --data "target=192.168.34.16:80"
    --data "weight=50"

# 创建一个服务指向Blue upstream
curl -X POST http://kong:8001/services/ \
    --data "name=service-name" \
    --data "host=upstreams-name" \
    --data "path=/address"
    
# 添加一个路由作为服务的入口点
curl -X POST http://kong:8001/services/service-name/routes/ \
    --data "hosts[]=address.mydomain.com"
```

将请求头中的host设置为**address.mydomain.com**, 该请求会被Kong反向代理到两个已经定义的targets中: 2/3的请求会发送到**http://192.168.34.15:80/address (weight=100)**, 1/3的请求会发送到**http://192.168.34.16:80/address (weight=50)**.


在部署version2之前, 先设置"Green"环境
```bash
# 创建一个新的upstream
curl -X POST http://kong:8001/upstreams \
    --data "name=upstream-name-2"

# 往upstream中添加这些targets
curl -X POST http://kong:8001/upstreams/upstream-name-2/targets \
    --data "target=192.168.34.17:80"
    --data "weight=100"
curl -X POST http://kong:8001/upstreams/upstream-name-2/targets \
    --data "target=192.168.34.18:80"
    --data "weight=100"
```

激活Blue/Green, 只需要更新服务即可: 
```bash
# 从Blue upstream切换到Green upstream, v1 -> v2
$ curl -X PATCH http://kong:8001/services/service-name \
    --data "host=upstream-name-2"
```

将请求头中的host设置为**address.mydomain.com**, 现在它会被Kong代理到新的targets; 1/2的请求会发送到 http://192.168.34.17:80/address (weight=100), 另1/2的请求会发送到http://192.168.34.18:80/address (weight=100)

像往常一样, 通过Kong的Admin API做的改变是动态的, 并会立即生效. 不需要重新加载或重新启动, 没有处理的请求会被删除.


## 金丝雀发布(Canary Releases)

使用ring-balancer, target的权重能够被精细地调整, 从而实现平滑的[金丝雀发布](http://blog.christianposta.com/deploy/blue-green-deployments-a-b-testing-and-canary-releases/)

使用2个非常简单的targets示例: 
```bash
# 第一个target权重为1000
curl -X POST http://kong:8001/upstreams/upstreams-name/targets \
    --data "target=192.168.34.17:80"
    --data "weight=1000"

# 第二个target权重为0
curl -X POST http://kong:8001/upstreams/upstreams-name/targets \
    --data "target=192.168.34.18:80"
    --data "weight=0"
```
通过多次请求, 每次仅修改target的权重, 流量将会缓慢的路由到其他target. 例如: 将它设置为10%
```bash
# 修改第一个targets的权重为900
$ curl -X POST http://kong:8001/upstreams/upstreams-name/targets \
    --data "target=192.168.34.17:80"
    --data "weight=900"

# 修改第二个targets的权重为100
$ curl -X POST http://kong:8001/upstreams/upstreams-name/targets \
    --data "target=192.168.34.18:80"
    --data "weight=100"
```
通过Kong的Admin API做的改变是动态的, 并会立即生效. 不需要重新加载或重新启动, 没有处理的请求会被删除.

## 参考文档
[Loadbalancing reference](https://docs.konghq.com/1.4.x/loadbalancing/#table-of-contents)
