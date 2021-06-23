---
title: Disable SerializationFeature.FAIL_ON_EMPTY_BEANS
date: '2019-12-18 00:00:00'
tags:
- Exception
- Java
---

# Disable SerializationFeature.FAIL_ON_EMPTY_BEANS

## 错误提示

> com.fasterxml.jackson.databind.exc.InvalidDefinitionException: No serializer found for class org.hibernate.proxy.pojo.bytebuddy.ByteBuddyInterceptor and no properties discovered to create BeanSerializer (to avoid exception, disable SerializationFeature.FAIL_ON_EMPTY_BEANS) (through reference chain: icu.intelli.springboot.entity.User\$HibernateProxy\$sPsvljjm["hibernateLazyInitializer"])

## 出错原因

使用 SpringBoot 2.2.2 整合 JPA 时，调用 `userRepository.getOne(id)` 方法时，出的错

## 解决办法

### 方法一

在实体类上添加如下注解

```java
@JsonIgnoreProperties(value = {"handler","hibernateLazyInitializer","fieldHandler"})
```

### 方法二

注册一个 objectMapper 覆盖掉默认的，这样就不用在每个类上面使用 `@JsonIgnoreProperties`

```java
@Bean
public ObjectMapper objectMapper() {
     return new ObjectMapper().disable(SerializationFeature.FAIL_ON_EMPTY_BEANS);
}

// ObjectMapper 为 com.fasterxml.jackson.databind.ObjectMapper;
```

### 方法三

不使用 SpringBoot 默认的 jackson 进行对象 json 化，手动使用其他 json 框架如 fastJson 进行 json 化然后返回

```xml
<dependency>
    <groupId>com.alibaba</groupId>
    <artifactId>fastjson</artifactId>
    <version>1.2.47</version>
</dependency>
```

## 参考文档

[Disable SerializationFeature.FAIL_ON_EMPTY_BEANS](https://blog.csdn.net/J080624/article/details/82529082)
