---
title: Kong使用DB-less模式
date: '2019-12-08 00:00:00'
tags:
- Kong
---
# Kong使用DB-less模式
## 介绍
通常, Kong必须使用一个数据库(Postgres或Cassandra)去保存它对各种实体的配置, 例如路由, 服务和插件. Kong使用```kong.conf```文件设置数据库.

Kong1.1版本添加了不使用数据库的能力, 将各种实体信息保存在内存中, 称为DB-less mode. 当使用DB-less模式时, 这些实体的配置会保存在第二个YMAL或JSON配置文件中, 使用声明式配置.

### 使用DB-less的好处
- 减少依赖 : 不需要去安装和管理一个数据库
- 适合CI/CD脚本的自动化 : 实体的配置单独保存在一个文件中, 可以通过Git仓库等进行管理.
- 使得kong有更多的部署方式 : 例如, 不使用数据库的Kong非常适合在网络服务方案中做轻量的支持

### 设置Kong使用DB-less模式

### 使用DB-less模式启动kong

DB-less模式启动kong, 包含两种方式 : 

#### 在**kong.conf**中指定

创建**kong.conf**, 在**kong.conf**中添加
```properties
# 设置不使用数据库
database = off
```

使用创建的**kong.conf**, 启动kong
```bash
# 启动kong
$ kong start -c kong.conf
```

#### 通过设置环境变量指定

```bash
# 设置环境变量
$ export KONG_DATABASE=off
# 创建kong.conf
$ touch kong.conf
# 启动kong
$ kong start -c kong.conf
```

### 测试查看kong的配置

在Kong启动后, 访问管理页面, 验证**database**被设置成了**off**

```bash
$ http :8081/

# 返回
HTTP/1.1 200 OK
Access-Control-Allow-Origin: *
Connection: keep-alive
Content-Length: 6342
Content-Type: application/json; charset=utf-8
Date: Wed, 27 Mar 2019 15:24:58 GMT
Server: kong/1.1.0
{
    "configuration:" {
       ...
       "database": "off",
       ...
    },
    ...
    "version": "1.1.0"
}
```
Kong运行起来了, 但是没有加载声明式配置文件. 这意味着, 这个节点的配置是空的. 这没有任何的路由, 服务或者实体:

```bash
$ http :8001/routes

# 返回
HTTP/1.1 200 OK
Access-Control-Allow-Origin: *
Connection: keep-alive
Content-Length: 23
Content-Type: application/json; charset=utf-8
Date: Wed, 27 Mar 2019 15:30:02 GMT
Server: kong/1.1.0

{
    "data": [], 
    "next": null
}
```

### 创建声明配置文件

通过如下命令, 在当前目录创建一个具备结构的声明配置文件**kong.yml**
```bash
$ kong config -c kong.conf init
```

### 声明配置文件格式

#### 介绍和创建

kong的声明配置文件包含实体和他们的值, 以下是一个小的, 但是完整的例子, 说明了多个特征 : 
```bash
_format_version: "1.1"

services:
- name: my-service
  url: https://example.com
  plugins:
  - name: key-auth
  routes:
  - name: my-route
    paths:
    - /

consumers:
- username: my-user
  keyauth_credentials:
  - key: my-key
```
**_format_version: "1.1"** 是唯一一个必须存在的元数据, 指明该配置文件的语法格式版本号. 

在最上面, 可以定义任意的Kong实体, 可以是**核心实体**(在上例中的**services**和**consumers**), 也可以是**自定义实体**(例如:**keyauth_credentials**), 自定义实体可以对声明配置文件的固有格式进行扩展, 这也是```kong config```命令必须要有一个```kong.conf```的原因, 以便用户来管理**plugins**.

实体间**one-to-one**的关系可以通过嵌套来表示, 而涉及到两个以上的实体关系, 必须使用其顶级实体, 通过定义的主键或名字指定. 例如一个插件即需要一个服务方也需要一个消费方 : 
```bash
plugins:
# 该插件的名称
- name: syslog
    # 引用了上面的my-user
    consumer: my-user
    # 引用了上面的my-service
    service: my-service
```

#### 格式检查
```bash
$ kong config -c kong.conf parse kong.yml

parse successful
```

#### 加载配置文件

加载声明配置文件包含3种方式 : 

##### 在kong.conf中指定

在**kong.conf**中添加 : 
```bash
declarative_config = /ymlpath/kong.yml

# 启动kong
$ kong start -c kong.conf
```

##### 设置环境变量指定

```bash
# 设置DB-less模式
$ export KONG_DATABASE=off
# 设置kong.yml位置
$ export KONG_DECLARATIVE_CONFIG=kong.yml
# 启动kong
$ kong start -c kong.conf
```

##### 在运行时修改配置
可以在一个运行中的kong节点通过http请求**/config**端点进行配置 : 
```bash
$ http :8001/config config=@kong.yml
```
该方式替换了之前加载进内存中的配置.

## 相关配置说明

### 内存缓存需求

实体的配置都在kong的缓存中. 请确保内存缓存的配置正确 : 可以查看**kong.conf**中的**mem_cache_size**设置

### 没有中心数据库协调

这种方式没有中心数据库, 多个kong节点没有中央协调点以及数据的集群传输 : 每个节点都是完全相互独立的.

这意味着每个独立的节点都有自己的声明配置文件. 使用**/config**方式不会影响其他的节点, 因为各个节点之间是没有关联的.

### 只读的管理接口

当使用DB-less模式运行Kong时, 只能通过声明配置的方式配置实体,  通过端点对实体的CURD操作只有读是有效的, 通常使用**GET**方式来检查实体的工作状态, 如果使用**POST**, **PATCH**, **PUT**或**DELETE**方式请求端点(例如**/service**或**/plugins**), 将会返回**HTTP 405 Not Allowed**.

这种限制仅限于对数据库的操作. 例如, 允许使用**POST**方式去设置目标的健康状态, 因为这是一个节点特定的内存操作.

### 插件兼容性

DB-less模式不支持所有的Kong插件, 因为有一些插件需要中心数据库的支持来动态的创建实体, 或需要动态创建实体.

#### 完全兼容的插件

以下的插件只从数据库中读取数据(大部分只是读取它们的初始化配置), 所以DB-less模式是完全支持的.

- aws-lambda
- azure-functions
- bot-detection
- correlation-id
- cors
- datadog
- file-log
- http-log
- tcp-log
- udp-log
- syslog
- ip-restriction
- prometheus
- zipkin
- request-transformer
- response-transformer
- request-termination
- kubernetes-sidecar-injector

#### 部分兼容的插件

认证插件是能够使用的, 只要使用静态证书, 并且设置为声明配置的一部分. 所有的认证插件 : 
- acl
- basic-auth
- hmac-auth
- jwt
- key-auth

kong捆绑的限流插件为计数器提供不同的存储和协调策略: **local**策略存储节点内存的计数器, 按每个节点的方式应用限制; **redis**策略使用外部Redis的key-value存储, 来协调不同节点的计数器; **cluster**策略使用Kong数据库作为集群范围限制的中央协调点. DB-less模式可以使用**local**策略和**redis**策略, 不能使用**cluster**策略. 所有的限流插件 : 

- rate-limiting
- response-ratelimiting

**pre-function**和**post-function**插件可以在DB-less模式下使用他们的无服务模式, 但是如果有配置尝试写数据库将会失败.

#### 完全不兼容的插件

- oauth2 : 在日常工作中, 该插件需要创建和删除令牌, 并且提交到数据库, 这在DB-less模式下是不可用的.

## 参考文档
[DB-less and Declarative Configuration](https://docs.konghq.com/1.4.x/db-less-and-declarative-config/)
