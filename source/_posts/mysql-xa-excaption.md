---
title: 'MySQL: XA错误'
date: '2020-04-29 00:00:00'
updated: '2020-04-29 00:00:00'
tags:
- Exception
- MySQL
categories:
- Database
---

# MySQL XA错误

## 异常信息

```
Caused by: com.atomikos.datasource.ResourceException: XA resource 'XA1DBMS1': resume for XID '3132372E302E302E312E746D30303037303030303032:3132372E302E302E312E746D3730' raised -7: the XA resource has become unavailable
```

## 解决方式

在数据库连接url中添加如下内容

```properties
pinGlobalTxToPhysicalConnection=true
```

## 参考文档

[已知问题说明文件](https://www.atomikos.com/Documentation/KnownProblems#MySQL_XA_bug)
