---
title: SpringAnnotation-18-属性赋值总结
date: '2020-02-20 00:00:00'
updated: '2020-02-20 00:00:00'
tags:
- spring-annotation
- spring
- java
categories:
- java
---

# SpringAnnotation-18-属性赋值总结

@Value注解汇总可以使用3中表达式

1. 基本类型数值
2. SpEL: #{}
3. ${}: 取出配置文件中的值(在运行环境变量里面的值)

使用@PropertySource或@PropertySources引入外部配置文件
