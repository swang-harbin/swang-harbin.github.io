---
layout: post
title: SpringBoot JPA日志打印SQL语句和参数
subheading:
author: swang-harbin
categories: java
banner:
tags: spring-boot-jpa java
---

# SpringBoot JPA日志打印SQL语句和参数

Springboot JPA日志打印SQL语句和传入的参数

在application.properties中添加

```properties
logging.level.org.hibernate.SQL=debug
logging.level.org.hibernate.engine.QueryParameters=debug
logging.level.org.hibernate.engine.query.HQLQueryPlan=debug
logging.level.org.hibernate.type.descriptor.sql.BasicBinder=trace
```

**参考文档**

[Springboot JPA日志打印SQL语句和传入的参数 初阶篇](https://blog.csdn.net/qq_35387940/article/details/102561244)

