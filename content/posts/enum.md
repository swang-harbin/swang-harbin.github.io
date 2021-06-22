---
title: 枚举
date: '2019-12-13 00:00:00'
tags:
- Enum
- Java
categories:
- Java
---
#  枚举

枚举的主要作用是定义有限个数对象的一种结构(多例设计), 枚举就属于多例设计, 并且其结构比多例设计更简单

**多例模式**

```java
class Color {
    private static final Color RED = new Color("红色");
    private static final Color GREEN = new Color("绿色");
    private static final Color BLUE = new Color("蓝色");

    private String title;

    private Color(String title) {
        this.title = title;
    }

    public static Color getInstance(String color) {
        switch (color) {
            case "red":
                return RED;
            case "green":
                return GREEN;
            case "blue":
                return BLUE;
            default:
                return null;
        }
    }

    public String toString() {
        return this.title;
    }
}
```

## 枚举的基本定义

从JDK1.5之后, 在程序之中提供了`enum`的关键字, 利用此关键字可以实现枚举的定义

**定义一个枚举**

```java
enum Color { // 枚举类
    RED, GREEN, BLUE; //实例化对象
}

// 调用方式:
Color c = Color.RED;
```

采用多例设计模式需要编写很多程序代码, 牵扯到了构造方法的私有化以及静态方法. 使用枚举更简便, 并且在编译时即可判断所使用的的实例化对象是否存在.

**在进行枚举处理的时候还可以利用values()方法获取所有的枚举对象, 而多例需要使用到对象数组**

```java
for(Color c: Color.values()){
    sout(c);
}
```

**在JDK1.5追加了枚举结构之后, 可以在switch之中进行枚举项的判断**

```java
public class Test {

    public static void main(String[] args) {
        Color c = Color.RED;
        switch (c) {
            case RED:
                System.out.println("红色");
                break;
            case GREEN:
                System.out.println("绿色");
                break;
            case BLUE:
                System.out.println("蓝色");
                break;
        }
    }
}

// 枚举类
enum Color { 
    //实例化对象
    RED, GREEN, BLUE
}
```

多例是无法实现这种与switch直接连接de, 多例想要实现它, 需要编写大量的if判断

## Enum类

严格意义上讲, 枚举并不属于一种新的结构, 他的本质相当于是一个类, 这个类默认会继承Enum类

```java
public abstract class Enum<E extends Enum<E>>
        implements Comparable<E>, Serializable {}
```

现在定义的枚举类的类型就是Enum中所使用的E类型

Enum类中的方法

| No.  | 方法名称                                 | 类型 | 说明           |
| ---- | ---------------------------------------- | ---- | -------------- |
| 01   | protected Enum(String name, int ordinal) | 构造 | 传入名字和序号 |
| 02   | public final String name()               | 普通 | 获得对象名字   |
| 03   | public final int ordinal()               | 普通 | 获得对象序号   |

```java
public class Test {

    public static void main(String[] args) {
        for (Color c : Color.values()) {
            System.out.println(c.ordinal() + " - " + c.name());
        }
    }
}
// 枚举类
enum Color {
    //实例化对象
    RED, GREEN, BLUE
}
```

在枚举之中, 每一个对象的序号都是根据对象的定义顺序来决定的

面试题: 请解释enum与Enum的区别?

- enum: 是从JDK1.5之后提供的一个关键字, 用于定义枚举类;
- Enum: 是一个抽象类, 所以使用enum关键字定义的类就默认继承了此类

## 定义枚举结构

一直强调枚举本身就属于一种多例设计模式, 那么既然是多例设计模式, 那么在一个类中可以定义的内容是非常多的. 例如: 构造方法, 普通方法, 属性等, 这些内容在枚举类中依旧可以直接定义, 但是需要注意的是: 枚举中定义的构造方法不能采用非私有化定义(public无法使用).

**在枚举中定义其他结构**

```java
public class Test {

    public static void main(String[] args) {
        for (Color c : Color.values()) {
            System.out.println(c.ordinal() + " - " + c.name() + " - " + c);
        }
    }
}
// 枚举类
enum Color { 
    //枚举对象要写在首行
    RED("红色"), GREEN("绿色"), BLUE("蓝色"); 
    // 定义属性
    private String title;

    private Color(String title) {
        this.title = title;
    }

    public String toString() {
        return title;
    }
}
```

本程序在简化程度上要远远高于多例设计模式, 除了这种基本的结构之外, 在枚举结构中也可以实现接口的继承

**枚举实现接口**

```java
public class Test {

    public static void main(String[] args) {
        IMessage msg = Color.RED;
        System.out.println(msg.getMessage());
    }
}
// 枚举类
enum Color implements IMessage { 
    //枚举对象要写在首行
    RED("红色"), GREEN("绿色"), BLUE("蓝色"); 
    // 定义属性
    private String title; 

    private Color(String title) {
        this.title = title;
    }

    public String toString() {
        return title;
    }

    @Override
    public String getMessage() {
        return this.title;
    }
}

interface IMessage {
    public String getMessage();
}
```

在枚举类中可以直接定义抽象方法, 并且要求每一个枚举对象都要独立实现覆写此抽象方法

**枚举中定义抽象方法**

```java
public class Test {

    public static void main(String[] args) {
        Color c = Color.RED;
        System.out.println(c.getMessage());
    }
}
// 枚举类
enum Color { 
    //枚举对象要写在首行
    RED("红色") {
        public String getMessage() {
            return this.toString();
        }
    }, GREEN("绿色") {
        public String getMessage() {
            return this.toString();
        }
    }, BLUE("蓝色") {
        public String getMessage() {
            return this.toString();
        }
    }; 
    // 定义属性
    private String title; 

    private Color(String title) {
        this.title = title;
    }

    public String toString() {
        return title;
    }

    // 定义抽象方法
    public abstract String getMessage();
}
```

这个程序实际上不使用枚举也可以正常实现, 追加几个判断即可, 所以对于枚举, 用与不用随意, 能看懂就可以了.
