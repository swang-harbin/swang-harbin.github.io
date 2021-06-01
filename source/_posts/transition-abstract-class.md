---
title: 接口的过渡抽象类
date: '2019-12-13 00:00:00'
updated: '2019-12-13 00:00:00'
tags:
- java
categories:
- java
---

# 接口的过渡抽象类

## 接口不当设计

![](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2020/20201129025054.png)

如果IMessage接口的1080个实现类中均需要添加一个完全相同的方法, 此时需要在每一个实现类中添加该方法, 累死. 该操作是由结构设计不当造成的

## 解决方法

使用**接口的过渡抽象类**

![](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2020/20201129025128.png)

创建一个抽象类实现Imessage接口, 具体的实现类继承该抽象类, 遇到上述问题时, 只需再改抽象类中添加方法即可.

## JDK1.8新特性

**1. 为了解决接口设计的缺陷, 所以在接口中允许开发者定义普通方法.**

范例: 观察普通方法定义

```java
interface IMessage {
    public String message();

    // 方法都具备public
    public default boolean connect() {
        System.out.println("建立消息的发送通道.");
        return true;
    }
}

class IMessageImpl implements IMessage {
    public String message() {
        return "ccue.cc";
    }
}

public class Test {

    public static void main(String[] args) {
        IMessage iMessage = new IMessageImpl();
        if (iMessage.connect()) {
            System.out.println(iMessage.message());
        }
    }
}
```

接口中的普通方法必须追加default声明, 但是该操作属于挽救功能, 所以如果不是必须的情况, 不应该作为你设计的首选.

**2. 除了可以追加普通方法之外, 接口里面也可以定义static方法, 而static方法, 可以使用接口直接调用**

范例: 观察static方法定义

```java
public class Test {

    public static void main(String[] args) {
        IMessage iMessage = IMessage.getInstance();
        if (iMessage.connect()) {
            System.out.println(iMessage.message());
        }
    }
}

interface IMessage {
    public String message();

    // 方法都具备public
    public default boolean connect() {
        System.out.println("建立消息的发送通道.");
        return true;
    }
    // 定义接口的static方法
    public static IMessage getInstance() {
        return new IMessageImpl();
    }
}

class IMessageImpl implements IMessage {
    public String message() {
        if (this.connect()) {
            return "ccue.cc";
        }
        return "没有消息发送";
    }
}
```

如果现在真的可以在接口里面定义普通方法或static方法, 那么这个功能就已经可以取代抽象类了, 但是**不应该将这两个功能作为接口的主要设计原则**. 应该奉行: **接口就是抽象方法**.
