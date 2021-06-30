---
title: Synchronized 细节
date: '2020-07-04 00:00:00'
tags:
- MSB
- JUC
- Java
---
# Synchronized 细节

## 锁升级细节

![Lock Upgrade](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210405170134.png)

###  锁升级过程主线

**New** -> **偏向锁** -> **轻量级锁（自旋锁）** -> **重量级锁**

- **偏向锁**：被 synchronized 修饰的代码段，大部分时间并不会被多线程访问，所以没必要设计竞争机制。
当第一个线程获取到该锁后，就将自己的线程 ID 标记在对象的 MarkWord 上，并将 MarkWord 的最低 3 为设置为 101，即对对象添加了偏向锁。
JDK8 默认没有开启偏向锁，可添加 JVM 参数 `-XX:BiasedLockingStartupDelay=0` 开启，并设置偏向锁启动的时延
（JDK11 默认开启并有 4 秒的时延，因为 JVM 内部包含一些 synchronized 代码块，确认在启动时会有线程竞争，防止在添加偏向锁后因竞争出现锁撤销/锁升级的情况，造成效率降低）
- **轻量级锁**：也叫**自旋锁**，当有多个线程轻微竞争同一把锁时，先把偏向锁撤销，每个线程在自己的线程栈中生成一个 LockRecord，然后通过自旋机制争抢锁，抢到锁的线程就将自己的 LockRecord 添加到
MarkWord 中，并将 MarkWord 的最低两位设置为 00。在 JDK1.6 之后添加了**自适应自旋**机制，由 JVM 来判断竞争的强度和控制自旋次数。
- **重量级锁**：多线程情况下对锁的竞争激烈时，自旋锁会升级为重量级锁，重量级锁会通过内核获取 Object Monitor，将需要获取该锁的线程放到 Object Monitor 的 WaitSet 中，
当某个线程获取到锁后，会撤销偏向锁/自旋锁，然后将 Object Monitor 放到 MarkWord 中，并将 MarkWord 的最低两位设置为 10


- **匿名偏向**：如果在启动时开启了偏向锁，此时新 NEW 的对象默认是带偏向锁的，但是 MarkWord 中并没有线程 ID，称此状态为匿名偏向。

###  使用 JOL 工具输出对象信息

**执行 [HelloJol](/src/main/java/我爱你/王硕/c008_markword/D02_HelloJol.java)，查看结果**

**使用 JDK8 编译运行的输出结果**：JDK8 默认是没有开启偏向锁的，对象 NEW 出来后默认是无锁的，使用 synchronized 加锁后，首先添加了轻量级锁

```
java.lang.Object object internals:
 OFFSET  SIZE   TYPE DESCRIPTION                               VALUE
                                                                              // 001: 无锁
      0     4        (object header)                           01 00 00 00 (00000001 00000000 00000000 00000000) (1)
      4     4        (object header)                           00 00 00 00 (00000000 00000000 00000000 00000000) (0)
      8     4        (object header)                           e5 01 00 f8 (11100101 00000001 00000000 11111000) (-134217243)
     12     4        (loss due to the next object alignment)
Instance size: 16 bytes
Space losses: 0 bytes internal + 4 bytes external = 4 bytes total

java.lang.Object object internals:
 OFFSET  SIZE   TYPE DESCRIPTION                               VALUE
                                                                              // 000: 轻量级锁
      0     4        (object header)                           70 99 3c cf (01110000 10011001 00111100 11001111) (-818112144)
      4     4        (object header)                           3c 7f 00 00 (00111100 01111111 00000000 00000000) (32572)
      8     4        (object header)                           e5 01 00 f8 (11100101 00000001 00000000 11111000) (-134217243)
     12     4        (loss due to the next object alignment)
Instance size: 16 bytes
Space losses: 0 bytes internal + 4 bytes external = 4 bytes total
```

**使用 JDK11 编译运行的输出结果**：JDK11 默认是开启偏向锁的，对象 NEW 出来后就是匿名偏向，只有一个线程访问时添加 synchronized，依旧是偏向锁

```
java.lang.Object object internals:
 OFFSET  SIZE   TYPE DESCRIPTION                               VALUE
                                                                              // 101: 偏向锁
      0     4        (object header)                           05 00 00 00 (00000101 00000000 00000000 00000000) (5)
      4     4        (object header)                           00 00 00 00 (00000000 00000000 00000000 00000000) (0)
      8     4        (object header)                           00 10 00 00 (00000000 00010000 00000000 00000000) (4096)
     12     4        (loss due to the next object alignment)
Instance size: 16 bytes
Space losses: 0 bytes internal + 4 bytes external = 4 bytes total

java.lang.Object object internals:
 OFFSET  SIZE   TYPE DESCRIPTION                               VALUE
                                                                              // 101: 偏向锁
      0     4        (object header)                           05 20 01 78 (00000101 00100000 00000001 01111000) (2013339653)
      4     4        (object header)                           8b 7f 00 00 (10001011 01111111 00000000 00000000) (32651)
      8     4        (object header)                           00 10 00 00 (00000000 00010000 00000000 00000000) (4096)
     12     4        (loss due to the next object alignment)
Instance size: 16 bytes
Space losses: 0 bytes internal + 4 bytes external = 4 bytes total
```

## 可重入锁

synchronized 是可重入锁，重入的次数必须记录，因为要解锁相应的次数。

- 偏向锁/自旋锁是把重入次数记录在线程的线程栈中，每加一次锁就创建一个 LockRecord，每解锁一次，弹出一个 LockRecord
- 重量级锁是将该信息记录在 Object Monitor 的字段中

## 问题

1. 为什么有了自旋锁还需要重量级锁?
> 自旋锁消耗 CPU 资源，当线程数多，执行时间长时，性能很低
> 重量级锁将线程放在了等待队列中，不消耗 CPU 资源。

2. 偏向锁是否一定比自旋锁效率高?
> 不一定。当明确知道系统中存在大量锁代码会被并发访问时，如果启用偏向锁，就会有大量的偏向锁撤销和升级操作，影响性能。
> JVM 启动过程，会有很多线程竞争，所以 JVM 启动时不打开偏向锁，默认过 4 秒之后才打开偏向锁，可使用`-XX:BiasedLockingStartupDelay=4`进行调整。

## 扩展

**如果计算过对象的 hashCode，则对象无法进入偏向状态！**

> 轻量级锁重量级锁的 hashCode 存在与什么地方？
>
> 答案：线程栈中，轻量级锁的 LR 中，或是代表重量级锁的 ObjectMonitor 的成员中

关于 epoch（不重要）

> **批量重偏向与批量撤销**渊源：从偏向锁的加锁解锁过程中可看出，当只有一个线程反复进入同步块时，偏向锁带来的性能开销基本可以忽略，但是当有其他线程尝试获得锁时，就需要等到 safe point 时，再将偏向锁撤销为无锁状态或升级为轻量级，会消耗一定的性能，所以在多线程竞争频繁的情况下，偏向锁不仅不能提高性能，还会导致性能下降。于是，就有了批量重偏向与批量撤销的机制。
>
> **批量重偏向**（bulk rebias）机制是为了解决：当一个线程创建了大量对象并执行了初始的同步操作，后来另一个线程也来将这些对象作为锁对象进行操作，这样会导致大量的偏向锁撤销操作。
>
> **批量撤销**（bulk revoke）机制是为了解决：在多线程竞争剧烈的情况下，使用偏向锁将会降低效率，于是乎产生了批量撤销机制。
>
> 一个偏向锁撤销计数器，每一次该 class 的对象发生偏向撤销操作时，该计数器+1，当这个值达到重偏向阈值（默认 20）时，JVM 就认为该 class 的偏向锁有问题，因此会进行批量重偏向。每个 class 对象会有一个对应的 epoch 字段，每个处于偏向锁状态对象的 Mark Word 中也有该字段，其初始值为创建该对象时 class 中的 epoch 的值。每次发生批量重偏向时，就将该值+1，同时遍历 JVM 中所有线程的栈，找到该 class 所有正处于加锁状态的偏向锁，将其 epoch 字段改为新值。下次获得锁时，发现当前对象的 epoch 值和 class 的 epoch 不相等，那就算当前已经偏向了其他线程，也不会执行撤销操作，而是直接通过 CAS 操作将其 Mark Word 的 Thread Id 改成当前线程 Id。当达到重偏向阈值后，假设该 class 计数器继续增长，当其达到批量撤销的阈值后（默认 40），JVM 就认为该 class 的使用场景存在多线程竞争，会标记该 class 为不可偏向，之后，对于该 class 的锁，直接走轻量级锁的逻辑。
>
> **总结**
> - 批量重偏向和批量撤销是针对类的优化，和对象无关。
> - 偏向锁重偏向一次之后不可再次重偏向
> - 当某个类已经触发批量撤销机制后，JVM 会默认当前类产生了严重的问题，剥夺了该类的新实例对象使用偏向锁的权利

[盘一盘 synchronized（二）—— 偏向锁批量重偏向与批量撤销](https://www.cnblogs.com/LemonFive/p/11248248.html)
