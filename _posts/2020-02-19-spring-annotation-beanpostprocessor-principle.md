---
layout: post
title: SpringAnnotation-13-BeanPostProcessor原理
subheading: 
author: swang-harbin
categories: java
banner: 
tags: spring-annotation spring java
---
# SpringAnnotation-13-BeanPostProcessor原理

遍历得到容器中所有的BeanPostProcessor, 挨个执行beforeInitialization, 一旦返回null, 就跳出for循环, 不会执行后面的BeanPostProcessor

```java
populateBean(beanName, mbd, instanceWrapper); 给bean进行属性赋值

initializeBean() {
wrappedBean = applyBeanPostProcessorsBeforeInitialization(wrappedBean, beanName);

// 执行自定义初始化方法
invokeInitMethods(beanName, wrappedBean, mbd);

wrappedBean = applyBeanPostProcessorsAfterInitialization(wrappedBean, beanName);
}
```

