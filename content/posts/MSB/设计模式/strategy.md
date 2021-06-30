---
title: 策略模式（Strategy）
date: '2021-02-19 20:13:00'
tags:
- MSB
- Design Pattern
- Java
---

# 策略模式（Strategy）

## Java 中策略模式的使用

- `Comparator`

## 应用场景

对同一个事有不同的处理策略

## 代码

例如：要对 `Dog` 对象进行比较，可以根据重量进行比较，也可以根据体重进行比较。

1. `Dog` 类

   ```java
   public class Dog {
   
       private int weight;
   
       private int height;
   
       public Dog(int weight, int height) {
           this.weight = weight;
           this.height = height;
       }
   
       public int getWeight() {
           return weight;
       }
   
       public void setWeight(int weight) {
           this.weight = weight;
       }
   
       public int getHeight() {
           return height;
       }
   
       public void setHeight(int height) {
           this.height = height;
       }
   
       @Override
       public String toString() {
           return "Dog{" +
               "weight=" + weight +
               ", height=" + height +
               '}';
       }
   }
   ```

2. 策略接口

   ```java
   public interface Comparator<T> {
   
       int compare(T o1, T o2);
   
   }
   ```

3. 不同的策略实现

   1. 根据体重进行比较的策略

      ```java
      public class DogWeightComparator implements Comparator<Dog> {
      
          @Override
          public int compare(Dog o1, Dog o2) {
              return o1.getWeight() - o2.getWeight();
          }
      
      }
      ```

   2. 根据身高进行比较的策略

      ```java
      public class DogHeightComparator implements Comparator<Dog> {
      
          @Override
          public int compare(Dog o1, Dog o2) {
              return o1.getHeight() - o2.getHeight();
          }
      
      }
      ```

4. 排序类

   ```java
   public class Sort<T> {
   
       public void sort(T[] arr, Comparator<T> comparator) {
   
           for (int i = 0; i < arr.length; i++) {
               int minIndex = i;
               for (int j = i + 1; j < arr.length; j++) {
                   minIndex = comparator.compare(arr[i], arr[j]) > 0 ? j : i;
               }
               swap(arr, i, minIndex);
           }
   
       }
   
       private void swap(T[] arr, int i, int j) {
           T t = arr[i];
           arr[i] = arr[j];
           arr[j] = t;
       }
   }
   ```

5. 测试类

   ```java
   import java.util.Arrays;
   
   public class Main {
   
       public static void main(String[] args) {
           Dog[] dogs = {new Dog(1, 5), new Dog(3, 3), new Dog(5, 1)};
           Sort<Dog> sort = new Sort<>();
           // 根据体重策略进行排序
           sort.sort(dogs, new DogWeightComparator());
           System.out.println(Arrays.toString(dogs));
           // 根据高度策略进行排序
           sort.sort(dogs, new DogHeightComparator());
           System.out.println(Arrays.toString(dogs));
   
       }
   }
   ```

## 类图及说明

![strategy](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210219201006.png)

1. 创建一个策略接口，该接口中包含某些抽象方法
2. 不同的策略实现该策略接口，并根据相应策略重写接口中的方法
3. 在其它类中根据不同业务场景，使用不同的策略对象
4. 当需要扩展的时候，只需实现策略接口，并重写方法即可

