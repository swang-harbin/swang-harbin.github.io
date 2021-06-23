---
title: Spring 注解：BeanPostProcessor 原理
date: '2020-02-19 00:00:00'
tags:
- Spring
- Spring Annotation
- Java
---
# Spring 注解：BeanPostProcessor 原理

[Spring 注解系列目录](spring-anno-table.md)

遍历得到容器中所有的 BeanPostProcessor，挨个执行 beforeInitialization，一旦返回 null，就跳出 for 循环，不会执行后面的 BeanPostProcessor

```java
populateBean(beanName, mbd, instanceWrapper); 给 bean 进行属性赋值

initializeBean() {
wrappedBean = applyBeanPostProcessorsBeforeInitialization(wrappedBean, beanName);

// 执行自定义初始化方法
invokeInitMethods(beanName, wrappedBean, mbd);

wrappedBean = applyBeanPostProcessorsAfterInitialization(wrappedBean, beanName);
}
```
