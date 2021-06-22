---
title: swagger使用GET请求接收query参数
date: '2020-09-11 00:00:00'
tags:
- Swagger
- Java
categories:
- Java
---
# swagger使用GET请求接收query参数

GET请求使用对象接收query的参数, paramType使用query, 参数上不用加任何注解.
```java
@ApiImplicitParam(name = "user", value = "查询条件", dataType = "SysUser", paramType = "query")
public AjaxResult getList(SysUser user) {
```
