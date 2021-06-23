---
title: Spring 注解：@Resource，@Inject 自动装配
date: '2020-02-21 00:00:00'
tags:
- Spring
- Spring Annotation
- Java
---

# Spring 注解：`@Resource`，`@Inject` 自动装配

[Spring 注解系列目录](spring-anno-table.md)

Spring 也支持 Java 规范的自动装配注解

- `@Resource`：JSR250 定义
- `@Inject`：JSR330 定义

## `@Resource`

可以和 `@Autowired` 一样实现自动装配；默认是按照属性名进行装配，可以使用 name 属性指定名称

不支持 `@Primary` 功能和 `@Autowired` 的 `require=false` 功能

## `@Inject`

需要导入 `javax.inject` 的包，和 `@Autowired` 功能一样，支持 `@Primary` 功能，但是不支持 `require=false` 的功能

```xml
<!-- JSR-330 依赖注入 -->
<dependency>
	<groupId>javax.inject</groupId>
	<artifactId>javax.inject</artifactId>
	<version>1</version>
</dependency>
```
