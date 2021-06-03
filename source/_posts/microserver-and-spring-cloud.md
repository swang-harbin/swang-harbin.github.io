---
title: 接口的过渡抽象类
date: '2019-11-29 00:00:00'
updated: '2019-11-29 00:00:00'
tags:
- 'Spring Cloud'
- Microserver
- Java
categories:
- Java
---

# 微服务概述与Spring Cloud

## 微服务是什么

### [微服务提出者 : Martin Fowler](http://martinfowler.com/articles/microservices.html)

- 就目前而言, 对于微服务业界并没有一个统一的, 标准的定义(While there is no precise definition of this architectural style)

### 软件架构的发展:

1. 单机版 : ALL IN ONE

   icu.intelli.service.商品/交易/积分/订单/库存...

   所有模块/服务都在一个war包中

2. 分布式 : 专业的事情交给专业的人做

   各个模块/服务独立出来, 各自形成微小的进程, 尽量降低耦合度, 拥有自己独立的数据库.

   独立部署

3. 微服务架构 :

### 从技术纬度理解 :

微服务化的核心就是将传统的一站式应用, 根据业务拆分成一个一个的微服务, 彻底地去耦合, 每一个微服务提供单个业务功能的服务, 一个服务做一件事, 从技术角度看就是一种小而独立的处理过程, 类似进程概念, 能够自行单独启动或销毁, 拥有自己独立的数据库.

## 微服务与微服务架构

### 微服务 :

> 强调的是服务的大小, 它关注的是某一个点, 是具体解决某一问题/提供落地对应服务的一个服务应用, 强调的是一个个的个体, 每个个体完成一个具体的任务或功能.

### 微服务架构 :

> 强调的是整体, 使用哪种方式将一个个的微服务组装起来, 对外构成一个整体.

> 通常而言, 微服务架构是一种架构模式或者说是一种架构风格, 它提倡将单一应用程序划分成一组小的服务, 每个服务运行在其独立的进程中, 服务之间互相协调, 互相配合,为用户提供最终价值. 服务之间采用轻量级的通信机制互相沟通(dubbo通过RPC调用, SpringCloud通过RESTful API调用). 每个服务都围绕具体的业务进行构建, 并且能够被独立地部署到生产环境, 类生产环境等. 另外, 应尽量避免统一的, 集中式的服务管理机制, 对具体的一个服务而言, 应根据业务上下文, 选择合适的语言, 工具对其进行构建, 可以有一个非常轻量级的集中式管理来协调这些服务, 可以使用不同的语言来编写服务, 也可以使用不同的数据存储.

## 微服务优缺点

### 优点

- 每个服务足够内聚, 足够小, 代码容易理解, 这样能聚集一个指定的业务功能或业务需求
- 开发简单, 开发效率提高, 一个服务可能就是专一的只干一件事.
- 微服务能够被小团队单独开发, 2-5人即可
- 微服务是松耦合的, 有功能意义的服务, 无论在开发阶段和部署阶段都是独立的
- 微服务能够使用不同的语言开发
- 易于和第三方集成, 允许容易且灵活的方式集成自动部署, 通过持续集成工具(如Jenkins, Hudson, bamboo)
- 易于被一个开发人员理解, 修改和维护, 小团队能更关注自己的工作成果. 无需通过合作才能体现价值.
- 允许利用融合最新技术
- 微服务只是业务逻辑代码, 不会和HTML, CSS或其他页面组件混合
- 每个微服务都有自己的存储能力, 可以拥有自己的数据库, 也可以使用公共的数据库

#### 2种开发模式

##### 前后端分离

后端给前端H5工程师按照约定提供 **Rest地址 + 输入参数格式和报文约定 + 输出参数**

$.post(rest, jsonParameter, callBack)

##### 2. 全栈工程师

**H5 + javaEE + ...**

### 缺点

- 开发人员要处理分布式系统的复杂性
- 多服务运维难度, 随着服务的增加运维压力也增大
- 系统部署依赖
- 服务间通信成本
- 数据一致性
- 系统集成测试
- 性能监控
- ...

## 微服务技术栈有哪些

微服务技术栈 : 多种落地技术的集合体

| 微服务条目                             | 落地技术                                                     |
| -------------------------------------- | ------------------------------------------------------------ |
| 服务开发                               | SpringBoot, Spring, SpringMVC                                |
| 服务配置与管理                         | Archaius, Diamond                                            |
| 服务注册与发现                         | Eureka, Consul, Zookeeper等                                  |
| 服务调用                               | Rest, RPC, gRPC                                              |
| 服务熔断器                             | Hystrix, Envoy, Sentinel等                                   |
| 负载均衡                               | Ribbon, Nginx等                                              |
| 服务接口调用(客户端调用服务的简化工具) | Feign                                                        |
| 消息队列                               | Kafka, RabbitMQ, ActiveMQ等                                  |
| 服务配置中心管理                       | SpringCloudConfig, Chef等                                    |
| 服务路由(API网关)                      | Zuul等                                                       |
| 服务监控                               | Zabbix, Nagios, Metrics, Spectator等                         |
| 全链路追踪                             | Zipkin, Brave, Dapper等                                      |
| 服务部署                               | Docker, OpenStack, Kubernetes等                              |
| 数据流操作开发包                       | SpringCloud Stream(封装与Redis, Rabbit, Kafka等发送接收消息) |
| 事件消息总线                           | Spring Cloud Bus                                             |
| ...                                    | ...                                                          |

## 为什么选择SpringCloud作为微服务架构

### 选择依据

- 整体解决方案和框架成熟度
- 社区热度
- 可维护性
- 学习曲线

### 当前各大IT公司的微服务架构有哪些

- 阿里 : Dubbo(2012年起不再维护, 2017年8月启动维护)/HSF
- 京东 : JSF
- 新浪微博 : Motan
- 当当网 : DubboX(公司被买了)
- ... : ...

Dubbo和SpringCloud生态较好

### 各个微服务框架对比

| 功能点/服务框架 | Netglix/Spring Cloud                                         | Motan                                                        | gRPC(Google)              | Thrift(Facebook) | Dubbo(Alibaba)/DubboX(dangdang) |
| --------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------- | ---------------- | ------------------------------- |
| 功能定位        | 完整的微服务架构                                             | RPC框架, 但整合了ZK或Consul, 实现集群环境的基本服务注册/发现 | RPC框架                   | RPC框架          | 服务框架                        |
| 支持Rest        | 是, Ribbon支持多种可插拔序列化选择                           | 否                                                           | 否                        | 否               | 否                              |
| 支持RPC         | 否                                                           | 是(Hession2)                                                 | 是                        | 是               | 是                              |
| 支持多语言      | 是(Rest形式)                                                 | 否                                                           | 是                        | 是               | 是                              |
| 服务注册/发现   | 是(Eureka), Eureka服务注册表, Karyon服务端框架支持服务自注册和健康检查 | 是(zookeeper/consul)                                         | 否                        | 否               | 是                              |
| 负载均衡        | 是(服务端Zuul+客户端Ribbon) Zuul服务:动态路由器,云端负载均衡. Eureka:针对中间层服务器 | 是(客户端)                                                   | 否                        | 否               | 是(客户端)                      |
| 配置服务        | Archaius, Spring cloud Config Server集中配置                 | 是(zookeeper提供)                                            | 否                        | 否               | 否                              |
| 服务调用链监控  | 是(Zuul) Zuul提供边缘服务, API网关                           | 否                                                           | 否                        | 否               | 否                              |
| 高可用/容器     | 是(服务端Hystrix + 客户端Ribbon)                             | 是(客户端)                                                   | 否                        | 否               | 是(客户端)                      |
| 典型应用案例    | Netflix                                                      | Sina                                                         | Google                    | Facebook         | -                               |
| 社区活跃程度    | 高                                                           | 一般                                                         | 高                        | 一般             | 2017年8月开始维护               |
| 学习难度        | 中等                                                         | 低                                                           | 高                        | 高               | 低                              |
| 文档丰富        | 高                                                           | 一般                                                         | 一般                      | 一般             | 高                              |
| 其他            | Spring Cloud Bus为我们应用程序带来了更多管理端点             | 支持降级                                                     | Netflix内部在开发继承gRPC | IDL定义          | 实践的公司比较多                |

### SpringCloud是什么

#### 是什么

分布式微服务架构下的一站式解决方案, 是各个微服务架构落地技术的集合体, 俗称微服务全家桶 

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222143543.png)

SpringCloud, 基于SpringBoot提供了一套微服务解决方案, 包括注册与发现, 配置中心, 全链路监控, 服务网关, 负载均衡, 熔断器等组件, 除了基于NetFlix的开源组件做高度抽象封装之外, 还有一些选型中立的开源组件.

SpringCloud利用Spring Boot的开发便利性巧妙地简化了分布式系统基础设施的开发, SpringCloud为开发人员提供了快速构建分布式系统的一些工具, 如服务发现注册、配置中心、消息总线、负载均衡、断路器、数据监控等，都可以用Spring Boot的开发风格做到一键启动和部署。

Spring Cloud并没有重复制造轮子，它只是将目前各家公司开发的比较成熟、经得起实际考验的服务框架组合起来，通过Spring Boot风格进行再封装屏蔽掉了复杂的配置和实现原理，最终给开发者留出了一套简单易懂、易部署和易维护的分布式系统开发工具包。

##### SpringCloud和SpringBoot关系

- SpringBoot关注微观, 就是一个一个的微服务; SpringCloud关注宏观, 是微服务的全家桶.
- SpringBoot可以单独使用, SpringCloud依赖于SpringBoot

SpringBoot专注于快速方便的开发单个微服务个体, SpringCloud关注全局的服务治理框架.

#### Dubbo与SpringCloud的对比

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222143611.png)

- 最大区别 : SpringCloud抛弃了Dubbo的RPC通信, 采用基于HTTP的REST方式.

> REST方式牺牲了服务调用性能, 但也避免了原生RPC带来的问题. REST比RPC更灵活, 服务提供方和调用方的依赖只靠一纸契约, 不存在代码级别的强依赖, 这在强调快速演化的微服务环境下显得更为合适.

- 品牌机与组装机的区别 

  ![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222143634.png)

- 社区支持与更新力度

  Dubbo : http://github.com/dubbo

  SpringCloud : https://github.com/spring-cloud

  ![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222143650.png)

**总结** :

- Dubbo的定位始终是一款RPC框架, 而SpringCloud是微服务框架的一站式解决方案.
- 由于RPC协议, 注册中心元数据不匹配等问题, 在面临微服务框架选型时Dubbo与SpringCloud只能二选一
- Dubbo之后会积极寻求适配到SpringCloud生态

#### 能干嘛

参照技术纬度

#### 去哪下

[SpringCloud官网](https://spring.io/projects/spring-cloud)

参考文档 :

- [Spring Cloud Netflix 中文文档 参考手册 中文版](https://www.springcloud.cc/spring-cloud-netflix.html)
- [Spring Cloud Dalston 中文文档 参考手册 中文版](https://www.springcloud.cc/spring-cloud-dalston.html)
- [springcloud中国社区](https://www.springcloud.cn/)
- [springcloud中文网](https://www.springcloud.cc/)

#### 怎么玩

参照技术纬度

#### 国内使用情况

阿里云等
