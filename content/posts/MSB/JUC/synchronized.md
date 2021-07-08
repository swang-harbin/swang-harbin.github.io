---
title: synchronized
date: '2021-04-05 16:52:00'
tags:
- MSB
- JUC
- Java
---
# synchronized

## 底层实现

jdk 早期的时候，synchronized 使用的是**重量级锁**，每个线程都要去操作系统那来申请锁，造成高并发时效率很低

**改进**：HotSpot 中对 synchronized 使用**锁升级**的机制。

**锁升级**：第一个访问锁的线程，会在该锁对象的 markword 记录该线程（**偏向锁**），
当有其他线程来竞争这把锁的时候，就升级为**自旋锁**，即将这些线程放到一个队列中，然后使用 while 循环进行对锁的获取，此时是在用户空间的，
在自旋锁转了十次以后还没有获取到锁，就会将锁升级为**重量级锁**，由内核来分配锁。

参考文档：[深入并发-Synchronized](https://blog.csdn.net/baidu_38083619/article/details/82527461)


需要注意，并不是自旋锁就一定比重量级锁效率高，要分情况
- **加锁代码执行时间短，线程数少，使用自旋锁**
- **加锁代码执行时间长，线程数多，用重量级锁**

原因
- 自旋锁：while 循环占用 cpu，但是不存在用户态内核态切换
- 重量级锁：将线程放入内核的等待队列，由内核进行调度，不占用 cpu，但是有一次状态的切换


## 内容回顾

[Demo](/src/main/java/我爱你/王硕/c005_synchronized)

- 线程的概念，启动方式，常用方法
- synchronized(Object) 不能使用 String 类型常量，以及基本数据类型
- 线程同步 synchronized
    - 锁的是对象，不是代码，是在对象的 markword 中做了标记
    - 普通方法上 synchronized 锁的是 this，静态方法上 synchronized 锁的是当前类的 XXX.class
    - 同步方法和普通方法可以同时被调用
    - synchronized 是可重入的
    - 如果在同步方法中抛出异常会释放锁，其他线程就可以来了，所以要注意对异常的处理
    - synchronized 锁升级的过程：偏向锁 -> 自旋锁（执行时间短，线程数少） -> 重量级锁（执行时间长，线程数多）
