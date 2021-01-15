---
layout: post
title: SpringAnnotation-18-属性赋值总结
subheading:
author: swang-harbin
categories: java
banner:
tags: spring-annotation spring java
---

# SpringAnnotation-18-属性赋值总结

@Value注解汇总可以使用3中表达式

1. 基本类型数值
2. SpEL: #{}
3. ${}: 取出配置文件中的值(在运行环境变量里面的值)

使用@PropertySource或@PropertySources引入外部配置文件