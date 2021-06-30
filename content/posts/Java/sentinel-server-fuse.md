---
title: Sentinel 服务熔断
date: '2019-11-28 00:00:00'
tags:
- Sentinel
- Java
---

# Sentinel 服务熔断

Sentinel：阿里巴巴开源的面向分布式服务架构的轻量级流量控制组件

GitHub：https://github.com/alibaba/Sentinel

## Sentinel 介绍

### 背景

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222150016.png)

微服务中，其中一个服务不可用，拖垮其他服务，进而拖垮更多服务，造成服务雪崩。

### 核心特性

- 限流：限定 QPS 的阈值，保护服务不对突然而来的流量打垮
- 流量整型：流量是随机的，不均匀的，不可预测的，需要将流量调整成匀速的，或缓慢增加的
- 熔断降级：保证调用方自己不被远程不稳定的服务拖垮，及时熔断不稳定的连接，避免级联失败造成雪崩
- 系统自适应保护：结合系统的总 CPU 使用率、load、实时 QPS 等保护整个系统的不被打垮，并充分利用系统资源

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222150028.png)

#### 多样化的流量控制场景

从衡量标准，调用关系等多维度进行限流，也支持热点参数级别，集群纬度（v1.4.0 版本后）级别的限流

基于 TCP、BBR 算法的系统自适应能力，保证系统吞吐量最大化并保持系统的稳定性

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222150042.png)

### 开源生态

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222150057.png)

### 流控降级组件对比

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222150109.png)

## 使用场景

### 启动控制台

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222150128.png)

### Spring Cloud Web 应用接入

### Spring Cloud Gateway 网关接入

### Dubbo 服务接入

### 手动埋点

## 阿里云应用高可用服务 AHAS

## 视频地址

https://edu.aliyun.com/lesson_1943_16990?spm=5176.8764728.0.0.7d3679bfnaWU7Y#_16990