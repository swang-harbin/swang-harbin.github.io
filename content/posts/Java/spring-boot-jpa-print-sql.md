---
title: SpringBoot JPA 日志打印 SQL 语句和参数
date: '2019-12-24 00:00:00'
tags:
- Spring Boot
- Spring Data JPA
- Java
---

# SpringBoot JPA 日志打印 SQL 语句和参数

Springboot JPA 日志打印 SQL 语句和传入的参数

在 application.properties 中添加

```properties
logging.level.org.hibernate.SQL=debug
logging.level.org.hibernate.engine.QueryParameters=debug
logging.level.org.hibernate.engine.query.HQLQueryPlan=debug
logging.level.org.hibernate.type.descriptor.sql.BasicBinder=trace
```

## 参考文档

[Springboot JPA 日志打印 SQL 语句和传入的参数 初阶篇](https://blog.csdn.net/qq_35387940/article/details/102561244)

