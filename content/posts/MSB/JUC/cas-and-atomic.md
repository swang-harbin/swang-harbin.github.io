---
title: CAS（Compare And Set），无锁优化/自旋锁
date: '2021-04-05 16:52:00'
tags:
- MSB
- JUC
- Java
---
# CAS（Compare And Set），无锁优化/自旋锁

cas(V, Expected, NewValue)
```
if(V == E)  // 判断原始的值 V 和期望的原始值 E 是否相同
  V = N // 如果相等才将结果值 N 赋值给原始值 V
  otherwise try again or fail   // 否则，重新尝试或失败
```

![CAS](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210405170047.png)

CAS 是由 CPU 原语（lock cmpxchg）支持的，所以在执行 CAS 的过程时不会被打断。

java 中 AtomicInteger.incrementAndGet 调用 Unsafe.getAndAddInt() 方法，其实现如下

```
@HotSpotIntrinsicCandidate
public final int getAndAddInt(Object o, long offset, int delta) {
    int v;
    do {
        // 先获取值
        v = getIntVolatile(o, offset);
            // 调用系统的 CAS 操作
    } while (!weakCompareAndSetInt(o, offset, v, v + delta));
    return v;
}
```
[Demo](/src/main/java/我爱你/王硕/c007_casandatomic/D01_AtomicInteger.java)

## CAS 中的 ABA 问题

CAS 操作时，程序需要先从内存中取出数据（由程序完成，不能保证原子性），然后再进行 CAS 操作（由 CPU 支持，保证原子性），
在这两个步骤之间，假设按照如下顺序进行执行，即会发生 ABA 问题。

1. 线程 1 从内存位置 V 中取出 A
2. 线程 2 从内存位置 V 中取出 A
3. 线程 2 进行了写操作，将 B 写入内存位置 V
4. 线程 2 将 A 再次写入内存位置 V
5. 线程 1 进行 CAS 操作，发现 V 中仍然是 A，交换成功

尽管线程 1 的 CAS 操作成功，但是其并不知道内存位置 V 的数据发生过改变。

[Demo](/src/main/java/我爱你/王硕/c007_casandatomic/D02_ABA.java)

**解决办法**

加 version，在 Java 中可以使用 `AtomicStampedReference`

[Demo](/src/main/java/我爱你/王硕/c007_casandatomic/D03_AtomicStampedReference.java)

## AtomicLong，Synchronized，LongAdder 的比较

[Demo](/src/main/java/我爱你/王硕/c007_casandatomic/D04_AtomicLongVsSynchronizedVsLongAdder.java)

