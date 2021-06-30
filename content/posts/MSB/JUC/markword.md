---
title: MarkWord
date: '2020-07-04 00:00:00'
tags:
- MSB
- JUC
- Java
---
# MarkWord

对象在 64 位 HotSpot 虚拟机中的存储方式如下，分为三块区域：**对象头**，**实例数据**，**对齐填充**。

- 对象头：对象头占用 12 个字节，包含**Mark Word**和**Class Pointer**
    - Mark Word：占用 8 个字节，记录了对象的 HashCode，GC 信息，锁信息
    - Class Pointer：占用 4 个字节，用于存储对象指向它的类元数据的首地址。
- 实例数据：存储本类对象的实例成员变量和其所有可见的父类成员变量。
实例成员变量占用空间计算：基本数据类型占用空间与其类型相关，引用数据类型只计算其引用变量的空间（均为 4 个字节），
静态变量在类加载时即分配内存，所以与实例对象容积无关，方法代码也不占用实例对象的任何空间。
- 对齐填充：存储空间分配必须是 8 字节的倍数，如果达不到，使用对齐填充补齐。

![HotSpotObject](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210405170112.png)

[Demo](/src/main/java/我爱你/王硕/c008_markword/D01_HotSpotObject.java)

##  JDK8 64 位 HotSpot 的 MarkWord 实现

使用 MarkWord 最低 3 位来标识锁

![JDK8 Mark Word](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210405170120.png)

## JOL（Java Object Layout）

添加依赖

```groovy
compile group: 'org.openjdk.jol', name: 'jol-core', version: '0.13'
```

查看对象信息

[Demo](/src/main/java/我爱你/王硕/c008_markword/D02_HelloJol.java)
