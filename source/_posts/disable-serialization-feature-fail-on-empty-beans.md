---
title: Disable SerializationFeature.FAIL_ON_EMPTY_BEANS
date: '2019-12-18 00:00:00'
updated: '2019-12-18 00:00:00'
tags:
- Exception
- Java
categories:
- Java
---

# Disable SerializationFeature.FAIL_ON_EMPTY_BEANS

## 错误提示

```console
com.fasterxml.jackson.databind.exc.InvalidDefinitionException: No serializer found for class org.hibernate.proxy.pojo.bytebuddy.ByteBuddyInterceptor and no properties discovered to create BeanSerializer (to avoid exception, disable SerializationFeature.FAIL_ON_EMPTY_BEANS) (through reference chain: icu.intelli.springboot.entity.User\$HibernateProxy\$sPsvljjm["hibernateLazyInitializer"])
```

## 出错原因

使用SpringBoot2.2.2整合JPA时, 调用`userRepository.getOne(id)`方法时, 出的错

## 解决办法

### 法1 :

在实体类上添加如下注解

```java
@JsonIgnoreProperties(value = {"handler","hibernateLazyInitializer","fieldHandler"})
```

### 法2 :

注册一个objectMapper覆盖掉默认的，这样就不用在每个类上面使用`@JsonIgnoreProperties`：

```java
@Bean
public ObjectMapper objectMapper() {
     return new ObjectMapper().disable(SerializationFeature.FAIL_ON_EMPTY_BEANS);
}

// ObjectMapper为com.fasterxml.jackson.databind.ObjectMapper;
```

### 法3 :

不使用SpringBoot默认的jackson进行对象json化, 手动使用其他json框架如fastJson进行json化然后返回

```xml
<dependency>
    <groupId>com.alibaba</groupId>
    <artifactId>fastjson</artifactId>
    <version>1.2.47</version>
</dependency>
```

## 参考文档

[Disable SerializationFeature.FAIL_ON_EMPTY_BEANS](https://blog.csdn.net/J080624/article/details/82529082)
