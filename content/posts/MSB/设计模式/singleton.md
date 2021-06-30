---
title: 单例模式（Singleton）
date: '2021-02-19 17:35:00'
tags:
- MSB
- Design Pattern
- Java
---
# 单例模式（Singleton）

## 应用场景

只需要一个实例

- 各种 Manager
- 各种 Factory

## 代码

### 饿汉式

```java
/**
 * 饿汉模式
 * <p>
 * 类加载到内存后，就实例化一个单例，JVM 保证线程安全
 * 简单实用，推荐使用
 * 唯一缺点：不管用到与否，类装载时就完成实例化
 * （话说你不用的，你装载它干啥）
 */
public class Mgr01 {

    private static final Mgr01 INSTANCE = new Mgr01();

    private Mgr01() {
    }

    public static Mgr01 getInstance() {
        return INSTANCE;
    }
}
```

或者

```java
package com.example.singleton;

/**
 * 与 Mgr01 是一个意思
 */
public class Mgr02 {

    private static final Mgr02 INSTANCE;

    static {
        INSTANCE = new Mgr02();
    }

    private Mgr02() {
    }

    public static Mgr02 getInstance() {
        return INSTANCE;
    }
}
```

### 懒汉式

```java
/**
 * 懒汉式 lazy loading
 * 虽然达到了按需初始化的目的，但是多线程访问的时候会出问题
 */
public class Mgr03 {

    private static Mgr03 INSTANCE;

    private Mgr03() {
    }

    public static Mgr03 getInstance() {
        // 当 1 号线程执行完该 if 判断后，2 号线程获得执行权，此时 INSTANCE 仍然是空，此时 1 号线程和 2 号线程会对 INSTANCE 初始化两遍
        if (INSTANCE == null) {
            INSTANCE = new Mgr03();
        }
        return INSTANCE;
    }
}
```

验证多线程访问问题

```java
import java.util.HashSet;
import java.util.Set;

public class Mgr03 {

    private static Mgr03 INSTANCE;

    private Mgr03() {
    }

    public static Mgr03 getInstance() {
        if (INSTANCE == null) {
            // 线程执行速度太快了，手动让其切换下线程
            try {
                Thread.sleep(1);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            INSTANCE = new Mgr03();
        }
        return INSTANCE;
    }

    public static void main(String[] args) {
        Set<Integer> set = new HashSet<>();
        for (int i = 0; i < 100; i++) {
            new Thread(() -> set.add(Mgr03.getInstance().hashCode())).start();
        }
        if(set.size() > 1){
            System.out.println(set);
        }
    }
}
```

#### 加 synchronized 方法

```java
/**
 * 懒汉式
 * 通过 synchronized 解决多线程下的访问问题，但是会带来性能的下降
 *
 * @author wangshuo
 * @date 2021/02/18
 */
public class Mgr04 {

    private static Mgr04 INSTANCE;

    private Mgr04() {
    }

    public synchronized static Mgr04 getInstance() {
        if (INSTANCE == null) {
            INSTANCE = new Mgr04();
        }
        return INSTANCE;
    }

}
```

#### 加 synchronized 代码块

```java
/**
 * 懒汉式
 * <p>
 * 妄图通过 synchronized 同步代码块提高效率并解决多线程访问的问题，然而不可行
 */
public class Mgr05 {

    private static Mgr05 INSTANCE;

    private Mgr05() {
    }

    public static Mgr05 getInstance() {
        // 当 1 号线程执行完该 if 判断后，2 号线程获得执行权，此时 INSTANCE 仍然是空，此时 1 号线程和 2 号线程依旧会对 INSTANCE 初始化两遍
        if (INSTANCE == null) {
            synchronized (Mgr05.class) {
                INSTANCE = new Mgr05();
            }
        }
        return INSTANCE;
    }
}
```

#### 双重检查锁

```java
/**
 * 懒汉式
 * <p>
 * 双重检查锁
 */
public class Mgr06 {

    private static volatile Mgr06 INSTANCE;

    private Mgr06() {
    }

    public static Mgr06 getInstance() {
        // 该判断用来提高效率，如果实例已经初始化过了，该处判断可以直接将实例返回
        if (INSTANCE == null) {
            // 在实例还未初始化成功的时候，如果 1 号线程和 2 号线程都执行到了这里
            synchronized (Mgr06.class) {
                // 如果两个线程都通过了第一重判断，在该代码块中再进行一次判断，可以保证对象只初始化一次
                if (INSTANCE == null) {
                    INSTANCE = new Mgr06();
                }
            }
        }
        return INSTANCE;
    }
}
```

**双重检查锁是否需要添加 `volatile`?**

需要。因为 `INSTANCE = new Mgr06();` 并不是一个原子操作，其包含四个指令，对应三个过程：
1. 分配内存；
2. 调用构造方法，执行初始化；
3. 将对象引用赋值给变量。
由于 CPU 执行指令是乱序执行的，所以可能出现先执行第 3 步，然后执行第 2 步的情况。如果 1 号线程在执行第 3 步的时候，2 号线程执行了第一重判断，此时 INSTANCE 已经不是 null 了，所以会将未初始化的对象返回，从而引发错误。

`INSTANCE = new Mgr06()` 的字节码指令

```java
// 分配内存，创建对象实例
0: new           #5
// 复制栈顶地址，并再将其压入栈顶
3: dup
// 调用构造器方法，初始化对象
4: invokespecial #6
// 存入局部方法变量表
7: astore_1
```

#### 静态内部类

```java
package com.example.singleton;

/**
 * 静态内部类方式
 * JVM 保证单例
 * 加载外部类时不会加载内部类，在调用内部类的时候才会加载内部类，这样可以实现懒加载
 *
 * @author wangshuo
 * @date 2021/02/19
 */
public class Mgr07 {

    private Mgr07() {
    }

    private static class Mgr07Holder {
        private static final Mgr07 INSTANCE = new Mgr07();
    }

    public static Mgr07 getInstance() {
        return Mgr07Holder.INSTANCE;
    }
}
```

#### 枚举

```java
package com.example.singleton;

/**
 * 枚举方式
 * 不仅可以解决线程同步，还可以防止反序列化
 */
public enum Mgr08 {

    INSTANCE;

    public static Mgr08 getInstance() {
        return INSTANCE;
    }
    
}
```

## 破坏单例模式

以上 7 种方式，除了枚举方式，都可以通过反射或反序列化进行破坏。因为枚举类没有构造方法

### 使用反射破坏

```java
public static void main(String[] args) throws NoSuchMethodException, IllegalAccessException, InvocationTargetException, InstantiationException {
    Constructor<Mgr06> constructor = Mgr06.class.getDeclaredConstructor();
    constructor.setAccessible(true);
    Mgr06 instance01 = constructor.newInstance();
    Mgr06 instance02 = Mgr06.getInstance();
    System.out.println(instance01.hashCode());
    System.out.println(instance02.hashCode());
}
```

**解决方式**

可以添加一个计数器

```java
/**
 * 懒汉式
 * <p>
 * 双重检查锁
 */
public class Mgr06 {

    private static int count;

    private static volatile Mgr06 INSTANCE;

    private Mgr06() {
        // 在创建对象的时候对计数器进行判断
        synchronized (Mgr06.class) {
            if (count > 0) {
                throw new RuntimeException("不允许破坏单例模式!!!");
            }
        }
        count++;
    }

    public static Mgr06 getInstance() {
        if (INSTANCE == null) {
            synchronized (Mgr06.class) {
                if (INSTANCE == null) {
                    INSTANCE = new Mgr06();
                }
            }
        }
        return INSTANCE;
    }

}
```

### 使用反序列化破坏

1. 首先需要单例类实现 `Serializable` 接口

   ```java
   public class Mgr06 implements Serializable{
       
   }
   ```

2. 序列化后反序列化即可创建出第二个对象

   ```java
   public static void main(String[] args) throws IOException, ClassNotFoundException {
       Mgr06 instance01 = Mgr06.getInstance();
       ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream("./obj"));
       oos.writeObject(instance01);
       ObjectInputStream ois = new ObjectInputStream(new FileInputStream("./obj"));
       Mgr06 instance02 = (Mgr06) ois.readObject();
       System.out.println(instance01.hashCode());
       System.out.println(instance02.hashCode());
   }
   ```

**解决方式**

单例类中添加 `readResolve` 方法

```java
import java.io.Serializable;

/**
 * 懒汉式
 * <p>
 * 双重检查锁
 */
public class Mgr06 implements Serializable {

    private static volatile Mgr06 INSTANCE;

    private Mgr06() {
    }

    public static Mgr06 getInstance() {
        if (INSTANCE == null) {
            synchronized (Mgr06.class) {
                if (INSTANCE == null) {
                    INSTANCE = new Mgr06();
                }
            }
        }
        return INSTANCE;
    }
	/**
	 * 添加该方法，在反序列化的时候即可返回我们指定的实例
	 */
    private Object readResolve() {
        return INSTANCE;
    }

}
```

## 推荐使用

1. [饿汉式](#饿汉式)

   最简单，除了没有懒加载，没啥其他问题。需要手动防止反射/反序列化破坏。

2. [双重检查锁](#双重检查锁)

   没任何问题。即达到了懒加载的目的，也保证了线程安全。需要手动防止反射/反序列化破坏。

3. [静态内部类](#静态内部类)

   没任何问题。即达到了懒加载的目的，也保证了线程安全。需要手动防止反射/反序列化破坏。

4. [枚举](#枚举)

   最完美的方式。即保证了懒加载的目的，也保证了线程安全，同时不会被反射/反序列化破坏。

