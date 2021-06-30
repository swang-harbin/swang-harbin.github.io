---
title: 装饰者模式（Decorator）
date: '2021-02-25 22:26:00'
tags:
- MSB
- Design Pattern
- Java
---
# 装饰者模式（Decorator）

在不改变已存在类的情况下，给该类添加新功能。

## Java 中装饰者模式的使用

- IO 流。`OutputStream`，`InputStream`

## 代码

1. 创建被装饰者和装饰者的顶层接口

   ```java
   public interface Person {
       void dressUp();
}
   ```

2. 创建被装饰者的具体实现

   ```java
   public class Programer implements Person {
       @Override
       public void dressUp() {
           System.out.println("程序员穿格子衬衫");
       }
   }
   ```

3. 创建装饰者抽象类

   ```java
   public abstract class PersonDecorator implements Person {
       /**
        * 被装饰对象的引用
        */
       protected Person person;
       /**
        * 通过构造方法将被装饰对象传入进来
        */
       public PersonDecorator(Person person) {
           this.person = person;
       }
   }
   ```

4. 创建具体的装饰者类

   - 给被装饰对象加个帽子的装饰者

     ```java
     public class HatDecorator extends PersonDecorator{
         /*
          * 通过构造方法传入被装饰对象
          */
         public HatDecorator(Person person) {
             super(person);
         }
         @Override
         public void dressUp() {
             // 先调用被装饰对象的方法
             person.dressUp();
             // 执行我们的扩展逻辑
             System.out.println("给 Person 戴个帽子");
         }
     }
     ```

   - 给被装饰者加个眼镜的装饰者

     ```java
     public class GlassesDecorator extends PersonDecorator {
         public GlassesDecorator(Person person) {
             super(person);
         }
         @Override
         public void dressUp() {
             person.dressUp();
             System.out.println("给 Person 戴个眼镜");
         }
     }
     ```

5. 测试类

   ```java
   public class Main {
       public static void main(String[] args) {
        // 不进行任何装饰
           Person person = new Programer();
           person.dressUp();
           System.out.println("--------------------------");
           // 给 person 加帽子
           Person hatPerson = new HatDecorator(new Programer());
           hatPerson.dressUp();
           System.out.println("--------------------------");
           // 给 person 加帽子和眼镜
           Person glassesPerson = new GlassesDecorator(new HatDecorator(new Programer()));
           glassesPerson.dressUp();
       }
   }
   ```

## 类图和说明

![image-20210225221148145](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210225221149.png)

1. 创建被装饰者和装饰者的顶层接口
2. 创建被装饰者的具体实现
3. 创建装饰者抽象类，包含被装饰者的引用，并通过构造方法将被装饰者传入进来
4. 创建具体的装饰者实现
5. 如需扩展，只需添加具体的装饰者实现即可
