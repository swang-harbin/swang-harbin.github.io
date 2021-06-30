---
title: JUC 中新的锁
date: '2020-07-04 00:00:00'
tags:
- MSB
- JUC
- Java
---
# JUC 中新的锁

## ReentranLock

ReentranLock：可重入锁，是用来替代 synchronized 的。

### ReentranLock 和 synchronized 的区别

1. synchronized 有锁升级的过程，ReentranLock 底层是 CAS，不会锁升级。它们两个都是可重入的。
2. synchronized 加锁之后，当程序执行结束或抛异常后，会自动释放锁；ReentranLock 必须在 finally 中手动释放锁，否则会造成死锁
3. ReentranLock 有 tryLock 方法，可以进行尝试加锁
4. ReentranLock 有 lockInterruptibly 方法，可以使用 interrupt 方法来中断获取锁
5. ReentranLock 可以指定公平锁/非公平锁，synchronized 只有非公平锁

- [D01_ReentrantLock](/src/main/java/我爱你/王硕/c010_reentrantlock/D01_ReentrantLock.java)
- [D02_TryLock](/src/main/java/我爱你/王硕/c010_reentrantlock/D02_TryLock.java)
- [D03_LockInterruptibly](/src/main/java/我爱你/王硕/c010_reentrantlock/D03_LockInterruptibly.java)
- [D04_FairLock](/src/main/java/我爱你/王硕/c010_reentrantlock/D04_FairLock.java)

## CountDownLatch

CountDownLatch 代表倒数的门闩，在创建的时候设置一个数值，每当调用一次它的 countDown 方法，就会将该数值减一，直到减到 0 后，await 方法才会向下执行，否则一直阻塞

- [CountDownLatch](/src/main/java/我爱你/王硕/c011_countdownlatch/D01_CountDownLatch.java)

## CyclicBarrier

CyclicBarrier 是循环栅栏。是设置一个阈值，然后通过 await 方法拦截到来的线程，当拦截的线程数到达阈值之后，将这些线程一起放行，然后将栅栏再立起来。

- [CyclicBarrier](/src/main/java/我爱你/王硕/c012_cyclicbarrier/D01_CyclicBarrier.java)

应用场景：比如说某个复杂操作，需要查询数据库，还需要访问文件，访问网络，然后才能向下执行，此时就可以使用 CyclicBarrier 并行执行，当这三个步骤都执行完之后，才能向下执行，注意这里的三个步骤是独立的没有依赖关系的，
因为 CyclicBarrier 并不能保证线程的执行顺序

## Phaser

Phaser 是阶段锁。所有线程都执行完第一个流程，然后才能开始第二个流程。

- [Phaser](/src/main/java/我爱你/王硕/c013_phaser/D01_Phaser.java)

## ReadWriteLock

ReadWriteLock 是读写锁，分为读锁和写锁。读锁是共享锁，写锁是排他锁。

- [ReadWriteLock](/src/main/java/我爱你/王硕/c014_readwritelock/D01_ReadWriteLock.java)

多线程情况下，当一个线程进行写的时候，我们要阻止其他线程进行写和读，防止出现写错误和读到不正确的数据。当一个线程进行读的时候，我们要阻止其他线程进行写，但是不需要阻止其他线程进行读。所以引入了读锁和写锁的概念。
读锁允许其他线程也进行读操作，但是不允许其他线程进行写操作。写锁不允许其他线程进行读和写操作。**使用读锁可以提高读的效率**

## Semaphore

Semaphore 是信号量。用来设置允许多少个线程同时执行，可理解为“限流”。

- [Semaphore](/src/main/java/我爱你/王硕/c015_semaphore/D01_Semaphore.java)

## Exchanger

Exchanger 是交换器。用于两个线程间交换数据的时候使用的。

- [Exchanger](/src/main/java/我爱你/王硕/c016_exchanger/D01_Exchanger.java)
