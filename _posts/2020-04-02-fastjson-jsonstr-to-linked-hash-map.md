---
layout: post
title: 使用fastjson将JSON字符串有序转为LinkHashMap
subheading:
author: swang-harbin
categories: java
banner:
tags: fastjson java
---

# 使用fastjson将JSON字符串有序转为LinkHashMap

```java
JSON.parseObject(jsonStr,LinkedHashMap.class, Feature.OrderedField);
```