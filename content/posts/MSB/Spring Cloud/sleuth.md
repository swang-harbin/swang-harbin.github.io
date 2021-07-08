---
title: Sleuth
date: '2021-01-15 23:07:00'
tags:
- MSB
- Spring Cloud
- Sleuth
- Java
---
# Sleuth

## 概念

### 分布式计算八大误区

1. 网络可靠。

2. 延迟为零。

3. 带宽无限。

4. 网络绝对安全。

5. 网络拓扑不会改变。

6. 必须有一名管理员。

7. 传输成本为零。

8. 网络同质化。（操作系统，协议）

### 链路追踪的必要性

如果能跟踪每个请求，中间请求经过哪些微服务，请求耗时，网络延迟，业务逻辑耗时等。我们就能更好地分析系统瓶颈、解决系统问题。因此链路跟踪很重要。

**链路追踪的目的**：解决错综复杂的服务调用中链路的查看。排查慢服务

**市面上链路追踪产品，大部分都是基于 google 的 Dapper 论文**

- zipkin：twitter 开源，严格按照 google 的 Dapper 论文
- pinpoint：韩国的 Naver 公司
- Cat：美团点评
- EagleEye：淘宝

### 链路追踪要考虑的几个问题

1. 探针的性能消耗。尽量不影响服务本尊
2. 易用性。开发可以很快介入，别浪费太多精力
3. 数据分析。要实时分析。维度足够

## Sleuth 简介

Sleuth 是 Spring Cloud 的分布式跟踪解决方案

1. span（跨度）：基本工作单元。一次链路调用，创建一个 span。span 用一个 64 位 id 唯一标识。包括：id，描述，时间戳事件，spanId，span 父 Id

   span 被启动和停止时，记录了时间信息，初始化 span 叫 root span，它的 spanId 和 traceId 相同

2. trace（跟踪）：一组共享“root span”的 span 组成的树状结构，trace 也有一个 64 位 ID，trace 中所有 span 共享一个 traceId。类似于一棵 span 树

3. annotation（标签）：用于记录事件的存在。其中，核心 annotation 用来定义请求的开始和结束

   - CS（Client Send 客户端发起请求）。客户端发起请求描述了 span 开始
   - SR（Server Received 服务端接收请求）。服务端获得请求并准备处理它。SR-CS=网络延迟
   - SS（Server Send 服务端处理完成，并将结果发送给客户端）。标识服务器完成请求处理，响应客户端。SS-SR=服务器处理请求的时间
   - CR（Client Received 客户端接收服务端信息）。span 结束的标识。客户端接收到服务器的响应。CR-CS=客户端发出请求到服务器响应的总时间

其实数据结构是一棵树，从 root span 开始

## Sleuth 的使用

### Sleuth 单独使用

1. 引入依赖，注意：每个需要监控的系统都需要引入

   ```xml
   <!-- 引入 sleuth 依赖 -->
   <dependency>
       <groupId>org.springframework.cloud</groupId>
       <artifactId>spring-cloud-starter-sleuth</artifactId>
   </dependency>
   ```

2. 修改 sleuth 日志记录级别为 debug

   ```yaml
   logging:
     level:
       org.springframework.cloud.sleuth: debug
   ```

3. 任意访问一个接口，日志包含如下输出

- consumer 日志：`[eureka-consumer,1a409c98e7a3cdbf,1a409c98e7a3cdbf,false]`

- provider 日志：`[eureka-provider,1a409c98e7a3cdbf,b3d93470b5cf8434,false`

**格式说明** 

`[服务名称,traceID（一次请求调用链中唯一 ID）,spanID（基本的工作单元，获取数据等）,是否让 zipkin 收集和显示此信息]`

可以看到 consumer 和 provider 的 traceID 是相同的

### 使用 Zipkin

单独使用 Sleuth 看日志很麻烦，zipkin 是 twitter 开源的分布式跟踪系统。原理是手机系统的时序数据，从而追踪微服务架构中系统延时等问题，并提供一个友好的图形页面。

**zipkin 包含 4 个部分**

- Controller：采集器
- Storage：存储器
- RESTful API：接口
- Web UI：UI 界面

**原理**

sleuth 收集跟踪信息通过 http 请求发送给 zipkin server，zipkin 将跟踪信息存储，并提供 RESTful API 接口，zipkin UI 页面通过调用该 API 进行数据展示。默认使用内存存储，可以修改为使用 MySQL，ES 等存储。

zipkin 最好和 rabbitmq，mysql 等配合使用

**操作步骤**

1. 添加依赖，每个需要监控的系统都要添加

   ```xml
   <!-- zipkin -->
   <dependency>
       <groupId>org.springframework.cloud</groupId>
       <artifactId>spring-cloud-starter-zipkin</artifactId>
   </dependency>
   ```

2. 修改配置，每个需要监听的系统都要添加

   ```yaml
   spring:
     #zipkin
     zipkin:
       # zipkin 服务的地址
       base-url: http://localhost:9411/
     sleuth:
       sampler:
         # 采样比例默认是 0.1，设置为 1 表示全部上报
         rate: 1  
   ```

3. 启动 zipkin

   - 方法 1，通过 jar 启动

     > 去 [Zipkin 官网](https://zipkin.io/) 下载 jar 包，通过 `java -jar zipkin.jar` 启动

   - 方法 2，通过 docker 启动

     > `docker run -d --name=zipkin -p 9411:9411 openzipkin/zipkin`

4. 访问 `http://localhost:9411/zipkin` 查看图形页面

5. 任意发送请求，查看页面的变化

