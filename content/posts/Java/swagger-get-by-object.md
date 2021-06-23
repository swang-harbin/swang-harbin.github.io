---
title: swagger 使用 GET 请求接收 query 参数
date: '2020-09-11 00:00:00'
tags:
- Swagger
- Java
---
# swagger 使用 GET 请求接收 query 参数

GET 请求使用对象接收 query 的参数，paramType 使用 query，参数上不用加任何注解。
```java
@ApiImplicitParam(name = "user", value = "查询条件", dataType = "SysUser", paramType = "query")
public AjaxResult getList(SysUser user) {
```
