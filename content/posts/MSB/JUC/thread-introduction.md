---
title: 多线程入门
date: '2020-07-04 00:00:00'
tags:
- MSB
- JUC
- Java
---
# 多线程入门

## 进程，线程，纤程

进程和线程的区别

|   区别   | 进程                                                         | 线程                                                         | 纤程/协程 |
| :------: | :----------------------------------------------------------- | :----------------------------------------------------------- | :-------- |
| 根本区别 | 资源分配的最小单位                                           | 调度和执行的最小单位                                         | -         |
|   开销   | 每个进程都有独立的代码和数据空间（进程上下文），进程间切换会有较大的开销（需要 CPU 保留和恢复线程） | 线程可以看成是轻量级进程，同一进程内的线程共享代码和数据空间（进程上下文），每个线程有自己独立的运行栈和程序计数器()，线程切换开销小 | -         |
| 所处环境 | 在操作系统中能同试运行多个程序                               | 在同一应用程序中多个顺序流同时执行                           | -         |
| 分配内存 | 系统在运行的时候会为每个进程分配不同的内存区域               | 除了 CPU 之外，不会为线程分配内存（线程使用的资源是其所属进程的资源），线程组只能共享资源 | -         |
| 包含关系 | 一个进程可以包含多个线程，没有线程的进程可以看作单线程，进程退出了线程一定会退出 | 线程是进程的一部分，线程退出进程不一定退出                   | -         |

## Java 中的多线程

- Java 中负责线程功能的是 java.lang.Thread 类
- 每个线程都通过 Thread 对象的 run()方法完成其操作，run() 方法称为线程体
- 通过调用 Thread 的 start()方法，启动线程

### 创建线程的方式

[Demo](src/main/java/我爱你/王硕/c001_thread/d01_baseapi/D01_CreateAndRun.java)

1. 继承 Thread 类，重写 run() 方法，启动的时候调用 start() 方法。
   
    ```java
    class Thread1 extends Thread {
        @Override    
        public void run() {
            for (int i = 0; i < 10; i++) {
               System.out.println(Thread.currentThread().getName());
            }
        }
    }
    public class T01_WhatIsThread {
        public static void main(String[] args){
            // 创建线程
            Thread thread = new Thread1();
            // 启动线程
            thread.start();
            for (int i = 0; i < 10; i++) {
               System.out.println(Thread.currentThread().getName());
            }
        }
    }
    ```
2. 实现 Runnable 接口，实现 run() 方法，启动的时候调用 start() 方法。**（与法 1 相比，推荐使用该方式，因为 Java 是单继承的。同时该方式使用了代理模式）**

    ```java
    class Thread2 implements Runnable {
        @Override    
        public void run() {
            for (int i = 0; i < 10; i++) {
               System.out.println(Thread.currentThread().getName() + " ---- " + i);
            }
        }
    }
    public class T01_WhatIsThread {
        public static void main(String[] args){
            // 创建线程
            Thread thread = new Thread(new Thread2());
            // 启动线程
            thread.start();
            for (int i = 0; i < 10; i++) {
               System.out.println(Thread.currentThread().getName() + " ---- " + i);
            }
        }
    }
    ```
3. 线程池的方式（底层依旧是 Thread，后续再说）

### 线程的状态

![ThreadStatus](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210405165935.png)

- 新生（New）状态
    - 用 new 关键字创建一个线程后，该线程对象就处于新生状态
    - 处于该状态的线程有自己的内存空间，通过调用 start()方法进入就绪状态
- 就绪（Runnable）状态
    - 处于就绪状态的线程具备了运行条件，但还没有分配到 CPU，处于就绪队列中，等待系统为其分配 CPU 执行
    - 当系统选定一个等待执行的线程后，它就会从就绪状态进入执行状态，该动作称为“CPU 调度”
- 执行（Running）状态
    - 在运行状态的线程执行自己 run() 方法中的代码，直到等待某资源或调用 wait() 方法而进入阻塞状态或执行结束进入死亡状态
    - 如果在给定的时间片内没有执行结束或者调用了 yield() 方法，就会被系统给换下来回到等待队列，进入就绪状态
- 阻塞（Blocked）状态
    - 处于运行状态的线程在某些情况下（如执行了 sleep()/wait() 方法，或等待 I/O 设备等），将让出 CPU 并暂时停止自己运行，进行阻塞状态
    - 在阻塞状态的线程不能进入就绪队列，只有当引起阻塞的原因消除时（如 sleep/wait 时间已到，或 wait 状态被 notify()/notifyAll()，或等待的 I/O 设备空闲），线程便转入就绪状态，重新回到就绪队列，等待被系统选中后从之前停止的位置继续执行。
- 死亡（Terminated）状态
    - 线程死亡的原因有三种：1 是征程运行的线程完成了它的全部工作，2 是线程被强制性终止（如 stop() 方法，不推荐使用），3 是线程抛出未捕获的异常

注：在多线程的时候，可以实现唤醒和等待的过程，但是唤醒（notify/notifyAll）和等待（wait）的操作对应不是 thread 对象，而是我们设置的共享对象或者共享变量。
notify() 和 wait() 方法是 Object 类的方法。

### 线程的生命周期

![ThreadLifeCycle](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210405165820.png)

### Thread 类基本 API

[Demo01](src/main/java/我爱你/王硕/c001_thread/d01_baseapi/D02_ThreadAPI.java), 
[Demo02](src/main/java/我爱你/王硕/c001_thread/d01_baseapi/D03_ThreadJoin.java), 
[Demo03](src/main/java/我爱你/王硕/c001_thread/d01_baseapi/D04_ThreadSleep.java), 
[Demo04](src/main/java/我爱你/王硕/c001_thread/d01_baseapi/D05_ThreadYield.java)

| 序号 | 方法名称                                            | 描述                                                         |
| ---- | --------------------------------------------------- | ------------------------------------------------------------ |
| 1    | public static native Thread currentThread()         | 返回当前正在执行的线程                                       |
| 2    | public final String getName()                       | 返回线程的名称                                               |
| 3    | public final int getPriority()                      | 返回线程的优先级                                             |
| 4    | public final synchronized void setName(String name) | 设置线程名称                                                 |
| 5    | public final void setPriority(int newPriority)      | 设置线程优先级                                               |
| 6    | public final native boolean isAlive()               | 判断线程是否在活动                                           |
| 7    | public final void join()                            | 调用该方法的线程强制执行，其他线程变为阻塞状态，该线程执行完毕后，其他线程再执行 |
| 8    | public static native void sleep(long millis)        | 使当前线程休眠 millis 秒，期间处于阻塞状态                     |
| 9    | public static native void yield()                   | 将当前正在执行的线程暂停一次，允许其他线程执行，不阻塞，线程进入就绪状态，当前线程就会马上恢复执行 |

[Test01](src/main/java/我爱你/王硕/c001_thread/t01_ticket/T01_TicketThread.java), 
[Test02](src/main/java/我爱你/王硕/c001_thread/t01_ticket/T01_TicketThread.java),
[Test03](src/main/java/我爱你/王硕/c001_thread/t02_homework/T01_Sleep.java)

### 线程安全问题

#### 线程同步

多个线程执行时，会出现共享数据不一致问题，需要使用线程同步来解决。

**同步的前提**
- 必须有两个或两个以上的线程
- 必须是多线程使用同一资源
- 必须保证同步中只能有一个线程在运行

**同步监视器**
- `synchronized(obj){}` 中的 obj 称为同步监视器
- 同步代码块中同步监视器可以是任何对象，但是推荐使用共享资源作为同步监视器
- 同步方法中无需指定同步监视器，因为同步方法的监视器是 this，静态同步方法的监视器是当前类的 Class 对象（在同一个 ClassLoader 中是唯一的）

**同步监视器的执行过程**
1. 第一个线程访问，锁定同步监视器，执行其中代码
2. 第二线程访问，发现同步监视器被锁定，无法访问
3. 第一个线程访问完毕，解锁同步监视器
4. 第二个线程访问，发现同步监视器未锁，锁定并访问

[Demo01](src/main/java/我爱你/王硕/c001_thread/d02_synchronized/D01_TicketSyncBlock.java), 
[Demo02](src/main/java/我爱你/王硕/c001_thread/d02_synchronized/D02_TicketSyncMethod.java),
[Test01](src/main/java/我爱你/王硕/c001_thread/t03_sync/T01_SaleSyncMethod.java),
[Test02](src/main/java/我爱你/王硕/c001_thread/t03_sync/T02_SaleSyncBlock.java)

#### 线程死锁

- 同步可以保证资源共享操作的正确性，但是过多同步也会产生死锁。
- 死锁一般情况下表示互相等待，是程序运行时出现的一种问题

[Demo](src/main/java/我爱你/王硕/c001_thread/t04_deadlock/T01_DeadLock.java)

#### 线程的生产者与消费者

- 生产者不断生产，消费者不断取走生产者生产的产品
- 生产者生产产品放到一个区域（共享资源）中，之后消费者从此区域里取出产品

多线程访问的时候出现了数据安全的问题
1. 生产者没有生产商品，消费者就可以获取
2. 商品的品牌和名称对应不上

[Test01](src/main/java/我爱你/王硕/c001_thread/t05_pc/v1/TestMain.java), 
[Test02](src/main/java/我爱你/王硕/c001_thread/t05_pc/v2/TestMain.java), 
[Test03](src/main/java/我爱你/王硕/c001_thread/t05_pc/v3/TestMain.java), 
[Test04](src/main/java/我爱你/王硕/c001_thread/t05_pc/v4/TestMain.java)

### 线程池

#### 为什么使用线程池？

在实际使用中，线程是很占用系统资源的，如果对线程管理不善，很容易导致系统问题。
因此，在大多数并发框架中，都会使用线程池来管理线程，使用线程池管理线程主要有如下好处
1. 使用线程池可以重复利用已有的线程继续执行任务，避免线程在创建和销毁时造成的消耗
2. 由于没有线程创建和销毁的消耗，可以提高系统响应速度
3. 通过线程可以对线程进行合理的管理，根据系统的承受能力调整可运行线程数量等

#### 线程池执行过程

![ThreadPoolExecProcess](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210405165853.png)

**概念**
1. 核心线程池：线程池中最少线程数，线程池启动及运行时，至少包含该数量的线程  
2. 阻塞队列：存放暂时无法执行的线程的队列（BlockingQueue）
3. 线程池：线程池中最大线程数。

**执行过程**
1. 先判断核心线程池所有的线程是否都在执行任务。如果不是则新创建一个线程执行刚提交的任务；否则，进入第 2 步
2. 判断当前阻塞队列是否已满，如果未满，则将提交的任务放置在阻塞队列中；否则，进入第 3 步
3. 判断线程池中所有的线程是否都在执行任务，如果没有，则创建一个新的线程来执行任务；否则，交给饱和策略进行处理

##### 饱和策略（拒绝策略）

- ThreadPoolExecutor.AbortPolicy：丢弃任务并抛出 RejectedExecutionException 异常。
- ThreadPoolExecutor.DiscardPolicy：也是丢弃任务，但是不抛出异常。
- ThreadPoolExecutor.DiscardOldestPolicy：丢弃队列最前面的任务，然后重新尝试执行任务（重复此过程）。
- ThreadPoolExecutor.CallerRunsPolicy：由调用线程处理该任务。

#### 线程池的分类

![ThreadPoolType](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210405165904.png)

- ThreadPoolExecutor
    - [newCacheThreadPool](src/main/java/我爱你/王硕/c002_threadpool/d01_threadpoolexecutor/D01_CacheTheadPool.java)
      创建一个可根据需要创建新线程的线程池，并可在已构造的线程可用时重用他们。
      这些线程池通常可以提高许多执行时间短的异步任务的效率。
      调用 execute 方法将会重用之前已构造的并且可用的线程。如果没有可用的线程，将创建一个新的线程并添加到线程池中。
      如果线程在 60 秒都没有被用到，将会把它终止并从缓存中移除。
      因此，该线程池空闲时间很长将不会消耗任何资源。
      请注意可以使用 ThreadPoolExecutor 构造函数创建具有相似属性但细节不同（例如，超时参数）的池。
      并在需要时使用提供的 ThreadFactory 创建新线程。
        - 特征:
            1. 线程池中线程数量没有固定，可达到最大值（Integer.MAX_VALUE）
            2. 线程池中的线程可进行缓存重复利用和回收（回收默认时间为 1 分钟）
            3. 当线程池中没有可用线程，会重新创建一个线程
    - [newFixedThreadPool](src/main/java/我爱你/王硕/c002_threadpool/d01_threadpoolexecutor/D02_FixedThreadPool.java)
      创建一个可重用固定线程数的线程池，以共享的无界队列来运行这些线程。
      在任何时候，至多有 nThreads 个被激活的线程处理任务。
      当在所有线程都被激活时提交了新的任务，将会把它放到队列中等待，直到有一个线程变为可用状态。
      如果任意一个线程在终止之前，由于执行过程中发生错误而被强行关闭，将会创建一个新的线程代替它执行随后的任务。
      线程池中的线程将一直存在，直到它被明确的关闭。
        - 特征
            1. 线程池中线程数是固定的，可达很好的控制线程的并发量
            2. 线程可以被重复使用，在显式关闭之前，都将一直存在
            3. 超出一定量的线程被提交时需要在队列中等待
    - [newSingleThreadExecutor](src/main/java/我爱你/王硕/c002_threadpool/d01_threadpoolexecutor/D03_SingleThreadPoolExecutor.java)
      创建一个只使用单个 worker 线程操作无界队列的 Executor。
      （注意，无论怎样，只要该线程在正常终止之前，因为执行过程中发生错误而关闭，就会创建一个新的线程代替它执行随后的任务。） 
      保证任务按照顺序执行，并且在同一时刻仅会有执行一个任务。
      与其他等效的 newFixedThreadPool(1) 不同，可保证无需重新配置此方法所返回的 Executor 即可使用其他的线程。
        - 特征:
            1. 线程池中至多执行 1 个线程，之后提交的线程将会排在队列中依次执行
- ScheduledThreadPoolExecutor
    - [newScheduledThreadPool](src/main/java/我爱你/王硕/c002_threadpool/d02_scheduledthreadpoolexecutor/D01_ScheduledThreadPool.java)
      创建一个线程池，可以延迟或定期执行。
        - 特征
            1. 线程池中具有指定数量的线程，即便是空线程也将保留
            2. 可延迟或定期执行
    - [newSingleThreadScheduledExecutor](src/main/java/我爱你/王硕/c002_threadpool/d02_scheduledthreadpoolexecutor/D02_SingleThreadScheduledExecutor.java)
      创建一个单线程的 Executor，可以在指定延迟或定期执行命令。
      （注意，无论怎样，只要该线程在正常终止之前，因为执行过程中发生错误而关闭，就会创建一个新的线程代替它执行随后的任务。） 
      保证任务按照顺序执行，并且在同一时刻仅会有执行一个任务。
      与其他等效的 newScheduledThreadPool(1) 不同，可保证无需重新配置此方法所返回的 Executor 即可使用其他的线程。
        - 特征
            1. 线程池中至多执行 1 个线程，之后提交的线程将会排在队列中依次执行
            2. 可延迟或定期执行
- ForkJoinPool:[Demo01](src/main/java/我爱你/王硕/c002_threadpool/d03_forkjoinpool/D01_PrintTask.java), 
  [Demo02](src/main/java/我爱你/王硕/c002_threadpool/d03_forkjoinpool/D02_SumTask.java)
    - [newWorkStealingPool](src/main/java/我爱你/王硕/c002_threadpool/d03_forkjoinpool/D03_WorkStealingPool.java)
      创建一个带并行级别的线程池，并行级别决定了同一时刻最多有多少个线程在执行，如不传入并行级别参数，将默认为当前系统 CPU 核数

#### 线程池的生命周期

![ThreadPoolLifeCycle](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210405165917.png)

- RUNNING：能接受新提交的任务，并且也能处理阻塞队列中的任务。
- SHUTDOWN：关闭状态，不再接受新提交的任务，但却可以继续处理阻塞队列中已保存的任务。
- STOP：不能接受新任务，也不处理队列中的任务，会中断正在处理任务的线程。
- TIDYING：如果所有的任务都已终止了，workerCount（有效线程数）为 0，线程池进入该状态后会调用 terminated() 方法进入 TERMINATED 状态。
- TERMINATED：在 terminated() 方法执行完后进入该状态，默认 terminated() 方法中什么也没有做。

#### 线程池参数说明

##### ThreadPoolExecutor

`newCacheThreadPool`，`newFixedThreadPool`，`newSingleThreadExecutor`，`ScheduledThreadPool`，`SingleThreadScheduledExecutor`
其实都是通过创建 `ThreadPoolExecutor` 类的对象实现的
的。

`ThreadPoolExecutor` 的全参构造方法如下

```
public ThreadPoolExecutor(int corePoolSize,
                          int maximumPoolSize,
                          long keepAliveTime,
                          TimeUnit unit,
                          BlockingQueue<Runnable> workQueue,
                          ThreadFactory threadFactory,
                          RejectedExecutionHandler handler)
```

参数 | 含义
--- | ---
int corePoolSize | 核心线程池的大小
int maximumPoolSize | 线程池能创建线程的最大个数
long keepAliveTime | 空闲线程存活时间
TimeUnit unit | keepAliveTime 的时间单位
BlockingQueue\<Runnable\> workQueue | 用于保存任务的阻塞队列
ThreadFactory threadFactory | 创建线程的工厂类
RejectedExecutionHandler handler | 拒绝（饱和）策略

##### ForkJoinPool

`WorkStealingPool` 和 `ForkJoinPool` 是通过创建 `ForkJoinPool` 类的对象实现的。

`ForkJoinPool`的全参构造方法如下
```
public ForkJoinPool(int parallelism,
                    ForkJoinWorkerThreadFactory factory,
                    UncaughtExceptionHandler handler,
                    boolean asyncMode,
                    int corePoolSize,
                    int maximumPoolSize,
                    int minimumRunnable,
                    Predicate<? super ForkJoinPool> saturate,
                    long keepAliveTime,
                    TimeUnit unit)
```

参数 | 含义
--- | ---
int parallelism | 并行级别，默认是 CPU 核数
ForkJoinWorkerThreadFactory factory | 创建线程的工厂
UncaughtExceptionHandler handler | 任务在执行过程发生不可恢复错误后的处理器，默认值为 null
boolean asyncMode | 异步模式，默认 false
int corePoolSize | 核心线程池的大小
int maximumPoolSize | 线程池能创建线程的最大个数
int minimumRunnable | 核心线程池中最小活跃线程数。当阻塞队列中线程较少时，直接在核心线程池中创建线程来执行新任务。
Predicate\<? super ForkJoinPool\> saturate | 拒绝（饱和）策略
long keepAliveTime | 空闲线程存活时间
TimeUnit unit | keepAliveTime 的时间单位


#### 阻塞队列

- ArrayBlockingQueue：基于数组的阻塞队列，在其内部维护了一个定长数组，用来缓存队列中的数据对象。

  这是一个常用的阻塞队列，除了一个定长数组外，其内部还保存着两个整型变量，分别标识着队列队列的头部和尾部。

  在生产者放入数据和消费者获取数据时共用同一个锁对象，由此意味着两者无法实现真正的并行，这点尤其不同于 LinkedBlockingQueue；

  按照实现原理来分析，其完全可以采用分离锁，从而实现生产者和消费者操作的完全并行。Doug Lea 之所以没有这样去做，也许是因为该队列对于数据的写入和获取操作已经足够轻巧，以至于引入独立的锁机制，除了给代码带来额外的复杂性外，其在性能上完全占不到任何便宜。ArrayBlockingQueue 与 LinkedBlockingQueue 还有一个明显的不同之处在于，前者在插入或删除元素时不会产生或销毁任何额外的对象实例，而后者则会生成额外的 Node 对象，这在长时间需要高效并发地处理大批量数据的系统中，其对于 GC 的影响还是存在一定的区别。同时，在创建 ArrayBlockingQueue 时，我们还可以控制对象内部锁是否采用公平锁，默认使用非公平锁。

- LinkedBlockingQueue：基于链表的阻塞队列，在其内部维护了一个链表，用来缓存队列中的数据对象。

  可以选择是否和自定队列的大小，如不指定，默认是 Integer.MAX_VALUE。

  当生产者往队列中放入一个数据时，队列会从生产者手中获取数据，并缓存到队列内部，而生产者立即返回；只有当队列缓冲区达到最大缓冲容量时（可通过构造函数指定该值，默认值为 Integer.MAX_VALUE），才会阻塞生产者队列，直到消费者从队列中消费掉一份数据，生产者线程会被唤醒，反之对于消费者这端的处理也基于同样地原理。而其之所以能够高效的处理并发数据，还因为其对于生产者端和消费者端分别采用了独立的锁来控制数据同步，这也意味着在高并发情况下，生产者和消费者可以并行的操作队列中的数据，以此来提高整个队列的并发性能。

- DelayQueue：延迟队列中的元素只有当其指定的延迟时间到了，才能从队列中获取该元素。DelayQueue 是一个没有大小限制的队列，因此往队列中插入数据的操作（生产者）永远不会被阻塞，而只有获取数据的操作（消费者）才会被阻塞。

  使用场景较少，但都相当巧妙，常见的例子比如使用一个 DelayQueue 来管理一个超时未响应的连接队列。

- PriorityBlockingQueue：基于优先级的阻塞队列（优先级的判断基于构造函数传入的 Comparator 对象来决定）。需要注意的是，该队列并不会阻塞生产者，而只会在没有可消费数据时阻塞消费者。因此使用的时候要特别注意，生产者生产数据的速度绝对不能比消费者消费数据的速度快，否则时间一长，会最终耗尽所有的可用堆内存空间。在实现该队列时，内部控制线程同步的锁采用的是公平锁。

- SynchronousQueue：一种无缓冲的等待队列，类似于无中介的直接交易，有点像原始社会中的生产者和消费者，生产者拿着商品去集市销售给产品的最终消费者，而消费者必须亲自去集市找到所要商品的直接生产者，如果一方没有找到合适的目标，那么大家都在集市等待。相对于有缓冲的 BlockingQueue 来说，少了一个中间经销商环节（缓冲区），如果有经销商，生产者直接把产品批发给经销商，而无需在意经销商最终会将这些产品卖给哪些消费者，由于经销商可以库存一部分商品，因此相对于直接交易模式，总体来说采用经销商的模式吞吐量会高一些（可以批量售卖）；但另一方面，有因为经销商的引入，使得产品从生产者到消费者中间增加了额外的交易环节，单个产品的及时相应性能可能会降低。
  
  声明一个 SynchronousQueue 有两种不同的方式，它们之间有着不太一样的行为。公平模式和非公平模式（默认使用）的区别：
    - 如果采用公平模式，会使用公平锁，并配合一个 FIFO 队列来阻塞所欲的生产者和消费者，从而实现整体的公平策略
    - 如果是非公平模式，会使用非公平锁，同时配合一个 LIFO 队列来管理多余的生产者和消费者，而后一种模式，如果生产者和消费者的处理速度有差距，则很容易
      出现饥渴的情况，即可能有某些生产者或者是消费者的数据永远得不到处理。

**ArrayBlockingQueue 和 LinkedBlockingQueue 区别**
1. 队列中锁的实现不同

    - ArrayBlockingQueue 中的锁是没有分离的，即生产者和消费者共用同一个锁

    - LinkedBlockingQueue 中锁是分离的，即生产者用的是 putLock，消费者是 takeLock

2. 队列大小初始化方式不通
    - ArrayBlockingQueue 必须指定队列大小
    - LinkedBlockingQueue 可以不指定队列的大小，默认是 Integer.MAX_VALUE

#### 线程池的 execute 方法

```java
public class ThreadPoolExecutor extends AbstractExecutorService {
    public void execute(Runnable command) {
        if (command == null)
            throw new NullPointerException();
        /*
         * Proceed in 3 steps:
         *
         * 1. If fewer than corePoolSize threads are running, try to
         * start a new thread with the given command as its first
         * task.  The call to addWorker atomically checks runState and
         * workerCount, and so prevents false alarms that would add
         * threads when it shouldn't, by returning false.
         *
         * 2. If a task can be successfully queued, then we still need
         * to double-check whether we should have added a thread
         * (because existing ones died since last checking) or that
         * the pool shut down since entry into this method. So we
         * recheck state and if necessary roll back the enqueuing if
         * stopped, or start a new thread if there are none.
         *
         * 3. If we cannot queue task, then we try to add a new
         * thread.  If it fails, we know we are shut down or saturated
         * and so reject the task.
         */
        int c = ctl.get();
        if (workerCountOf(c) < corePoolSize) {
            if (addWorker(command, true))
                return;
            c = ctl.get();
        }
        if (isRunning(c) && workQueue.offer(command)) {
            int recheck = ctl.get();
            if (! isRunning(recheck) && remove(command))
                reject(command);
            else if (workerCountOf(recheck) == 0)
                addWorker(null, false);
        }
        else if (!addWorker(command, false))
            reject(command);
    }
}
```

![ExecuteMethod](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210405165926.png)

1. 如果当前运行的线程少于 corePoolSize，则会创建新线程来执行新任务，否则下一步
2. 如果阻塞队列未满，则将提交的任务存放到阻塞队列 workQueue 中，否则下一步
3. 如果线程个数未超过 maximumPoolSize，则会创建新线程来执行任务，否则下一步
4. 根据拒绝（饱和）策略 RejectedExecutionHandler 进行处理

#### 线程池的 execute 和 submit 对比

submit 是基方法 Executor.execute(Runnable) 的延伸，通过创建并返回一个 Future 类对象，可用于取消执行和/或等待完成。

- execute 只能执行 Runnable 接口的实现类，submit 可以执行 Runnable 或 Callable 接口的实现类
- execute 没有返回值，submit 返回 Future，通过 Future 的 get() 方法可以获取 call() 方法的返回值

[Demo](src/main/java/我爱你/王硕/c004_callableandsubmit/D01_Callable.java)

#### 线程池的关闭

关闭线程池，可以通过 shutdown 或 shutdownNow 方法。

原理：遍历线程池中的所有线程，然后依次中断。

1. shutdownNow 首先将线程池状态设置为 STOP，然后尝试停止所有正在执行和未执行的线程，并返回等待执行任务的列表
2. shutdown 只是将线程池的状态设置为 SHUTDOWN 状态，然后中断所有没有正在执行任务的线程
