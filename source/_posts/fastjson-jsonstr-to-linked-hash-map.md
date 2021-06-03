---
title: 使用fastjson将JSON字符串有序转为LinkHashMap
date: '2020-04-02 00:00:00'
updated: '2020-04-02 00:00:00'
tags:
- Fastjson
- Java
categories:
- Java
---

# 使用fastjson将JSON字符串有序转为LinkHashMap

```java
JSON.parseObject(jsonStr,LinkedHashMap.class, Feature.OrderedField);
```
