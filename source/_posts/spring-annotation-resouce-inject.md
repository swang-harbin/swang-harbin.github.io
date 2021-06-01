---
title: SpringAnnotation-20-@Resource,@Inject自动装配
date: '2020-02-21 00:00:00'
updated: '2020-02-21 00:00:00'
tags:
- spring-annotation
- spring
- java
categories:
- java
---

# SpringAnnotation-20-@Resource,@Inject自动装配

Spring也支持Java规范的自动装配注解

- @Resource: JSR250定义
- @Inject: JSR330定义

## 一. @Resource

可以和@Autowired一样实现自动装配; 默认是按照属性名进行装配, 可以使用name属性指定名称

不支持@Primary功能和@Autowired的require=false功能

## 二. @Inject

需要导入javax.inject的包, 和Autowired功能一样, 支持@Primary功能, 但是不支持require=false的功能

依赖导入

```xml
<!-- JSR-330依赖注入 -->
<dependency>
	<groupId>javax.inject</groupId>
	<artifactId>javax.inject</artifactId>
	<version>1</version>
</dependency>
```
