---
title: Spring 注解：属性赋值总结
date: '2020-02-20 00:00:00'
tags:
- Spring
- Spring Annotation
- Java
---

# Spring 注解：属性赋值总结

[Spring 注解系列目录](spring-anno-table.md)

`@Value` 注解汇总可以使用 3 种表达式

1. 基本类型数值
2. SpEL：`#{}`
3. `${}`：取出配置文件中的值（在运行环境变量里面的值）

使用 `@PropertySource` 或 `@PropertySources` 引入外部配置文件

