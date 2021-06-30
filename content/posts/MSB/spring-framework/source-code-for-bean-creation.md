---
title: Bean 创建源码
date: '2020-07-04 00:00:00'
tags:
- MSB
- 源码
- Spring
- Java
---
# Bean 创建源码

## 参考下方的流程 debug 代码

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2020/20201218170257.png)

**源码中常见的几个 BeanFactory**

- DefaultListableBeanFactory

- ListableBeanFactory

- HierarchicalBeanFactory

- ConfigurableBeanFactory

  ![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2020/20201218222606.png)

**GenericBeanDefinition 和 RootBeanDefinition**

解析 xml 得到的 BeanDefinition 是 GenericBeanDefinition 类型，在执行完 BeanFactoryPostProcessor 后其依旧是 GenericBeanDefinition 类型，在进行对象创建时，将其与父类和父容器进行了合并，此时的 BeanDefinition 变为了 RootBeanDefinition 类型，用于实例化和初始化 Bean 对象。

**反射的优缺点？**

反射效率比 new 慢，但是是大量使用反射的时候才会明显感觉到慢。反射比 new 更灵活。

参考：[Java 反射到底慢在哪？](https://www.jianshu.com/p/4e2b49fa8ba1)

