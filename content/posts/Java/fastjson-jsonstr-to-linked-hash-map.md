---
title: 使用 fastjson 将 JSON 字符串有序转为 LinkHashMap
date: '2020-04-02 00:00:00'
tags:
- Fastjson
- Java
---

# 使用 fastjson 将 JSON 字符串有序转为 LinkHashMap

```java
JSON.parseObject(jsonStr,LinkedHashMap.class, Feature.OrderedField);
```
