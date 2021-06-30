---
title: 工厂模式（Factory）
date: '2021-02-21 12:22:00'
tags:
- MSB
- Design Pattern
- Java
---
# 工厂模式（Factory）

任何可以产生对象的方法或类，都可以称之为工厂

单例也是一种工厂

不可咬文嚼字，死扣概念

为什么有了 new 之后，还要有工厂

- 灵活控制生产过程
- 权限，修饰，日志……

## 简单工厂/静态方法模式

通过向工厂传入参数来创建对应的对象

### 代码

1. 产品对象的接口，例如可移动的 `Moveable`

   ```java
   public interface Moveable {
   
       void move();
   }
   ```

2. 具体的产品实现

   ```java
   public class Car implements Moveable{
   
       @Override
       public void move() {
           System.out.println("cat move ...");
       }
   }
   
   public class Broom implements Moveable {
    
       @Override
       public void move() {
           System.out.println("broom move ...");
       }
   
   }
   ```

3. 创建相应 `Moveable` 对象的工厂

   ```java
   public class VehicleFactory {
   
       public static Moveable create(String type) {
           Moveable move;
           // before processing...
           switch (type) {
               case "car":
                   move = new Car();
                   break;
               case "broom":
                   move = new Broom();
                   break;
               default:
                   move = null;
                   break;
           }
           // after processing...
           return move;
       }
   
   }
   ```

4. 使用

   ```java
   public class Main {
       public static void main(String[] args) {
           // 使用工厂生产 Car
           Moveable car = VehicleFactory.create("car");
           car.move();
           // 使用工厂生产 Broom
           Moveable broom = VehicleFactory.create("broom");
           broom.move();
       }
   }
   ```

### 类图&说明

![image-20210220151404026](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210220151404.png)

1. 创建产品对象的接口
2. 创建产品对象接口的具体实现
3. 工厂类，静态方法中根据传入类型参数创建相应的对象，可以在创建对象的前后进行额外处理

## 工厂方法

与简单工厂中工厂负责生产所有产品相比，工厂方法模式将生产具体产品的任务分发给了对应的产品工厂

1. 产品对象的接口，例如可移动的 `Moveable`

   ```java
   public interface Moveable {
       void move();
   }
   ```

2. 产品对象的具体实现

   ```java
   public class Car implements Moveable{
       @Override
       public void move() {
           System.out.println("car move ...");
       }
   }
   
   public class Broom implements Moveable {
       @Override
       public void move() {
           System.out.println("broom move ...");
       }
   }
   ```

3. 工厂的接口

   ```java
   public interface VehicleFactory {
       Moveable create();
   }
   ```

4. 工厂的具体实现

   ```java
   public class CarFactory implements VehicleFactory {
       @Override
       public Moveable create() {
           // before processing
           Car car = new Car();
           // after processing
           return car;
       }
   }
   
   public class BroomFactory implements VehicleFactory {
       @Override
       public Moveable create() {
           // before processing
           Broom broom = new Broom();
           // after processing
           return broom;
       }
   }
   ```

5. 使用

   ```java
   public class Main {
       public static void main(String[] args) {
           // 创建 Car 工厂，创建 Car 对象
           VehicleFactory carFactory = new CarFactory();
           Moveable car = carFactory.create();
           car.move();
   
           // 创建 Broom 工厂，创建 Broom 对象
           VehicleFactory broomFactory = new BroomFactory();
           Moveable broom = broomFactory.create();
           broom.move();
       }
   }
   ```

### 类图&说明

![image-20210220171025083](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210220171025.png)

1. 创建产品对象接口
2. 创建产品对象接口的具体实现
3. 创建工厂接口
4. 根据具体的产品对象，创建对应的工厂实现

## 抽象工厂

与工厂方法相比，抽象工厂模式提供了“产品族”的概念

### 代码

魔法族和军人族都包含食物，交通工具，武器。

1. 创建一组产品的接口

   ```java
   // 食物
   public abstract class Food {
       public abstract void scent();
   }
   // 交通工具
   public abstract class Vehicle {
       public abstract void run();
   }
   // 武器
   public abstract class Weapon {
       public abstract void attack();
   }
   ```

2. 创建产品的具体实现

   - 食物

     ```java
     // 面包
     public class Bread extends Food {
         @Override
         public void scent() {
             System.out.println("面包的香味……");
         }
     }
     // 蘑菇
     public class Mushroom extends Food{
         @Override
         public void scent() {
             System.out.println("蘑菇的香味……");
         }
     }
     ```

   - 交通工具

     ```java
     // 小汽车
     public class Car extends Vehicle {
         @Override
         public void run() {
             System.out.println("小汽车跑……");
         }
     }
     // 扫帚
     public class Broom extends Vehicle {
         @Override
         public void run() {
             System.out.println("魔法扫帚飞……");
         }
     }
     ```

   - 武器

     ```java
     // 枪
     public class Gun extends Weapon{
         @Override
         public void attack() {
             System.out.println("枪攻击……");
         }
     }
     // 魔法棒
     public class MagicStick extends Weapon {
         @Override
         public void attack() {
             System.out.println("魔法棒攻击……");
         }
     }
     ```

3. 创建工厂接口

   ```java
   public abstract class AbstractFactory {
   	
       public abstract Food createFood();
   
       public abstract Vehicle createVehicle();
   
       public abstract Weapon createWeapon();
   }
   ```

4. 工厂的具体实现

   ```java
   // 军人族
   public class SoldierFactory extends AbstractFactory {
       @Override
       public Food createFood() {
           // 军人族吃面包
           return new Bread();
       }
   
       @Override
       public Vehicle createVehicle() {
           // 军人族开车
           return new Car();
       }
   
       @Override
       public Weapon createWeapon() {
           // 军人族用枪
           return new Gun();
       }
   }
   // 魔法族
   public class MagicianFactory extends AbstractFactory {
   
       @Override
       public Food createFood() {
           // 魔法族吃蘑菇
           return new Mushroom();
       }
   
       @Override
       public Vehicle createVehicle() {
           // 魔法族骑扫帚飞
           return new Broom();
       }
   
       @Override
       public Weapon createWeapon() {
           // 魔法族用魔法棒
           return new MagicStick();
       }
   }
   ```

5. 使用

   ```java
   public class Main {
   
       public static void main(String[] args) {
           // 新建军人族工厂
           AbstractFactory soldierFactory = new SoldierFactory();
           // 通过军人族工厂创建军人的食物，交通工具，武器一组产品
           Food brand = soldierFactory.createFood();
           Vehicle car = soldierFactory.createVehicle();
           Weapon gun = soldierFactory.createWeapon();
           brand.scent();
           car.run();
           gun.attack();
   
           // 新建魔法族工厂
           AbstractFactory magicianFactory = new MagicianFactory();
           // 使用魔法族工厂创建魔法族的食物，交通工具，武器一组产品
           Food mushroom = magicianFactory.createFood();
           Vehicle broom = magicianFactory.createVehicle();
           Weapon magicStick = magicianFactory.createWeapon();
           mushroom.scent();
           broom.run();
           magicStick.attack();
       }
   }
   ```

### 类图&说明

![image-20210220200144714](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210220200145.png)

1. 创建 Food, Vehicle, Weapon 产品接口
2. 创建产品接口的具体实现，其中 Bread, Car, Gun 属于 Soldier 族, Mushroom, Broom, MagicStick 属于 Magician 族
3. 创建工厂接口，包含三个方法，分别是创建 Food, Vehicle, Weapon 的方法
4. 按不同族创建工厂的具体实现，不同族生产的一组产品不同

## 工厂方法 vs 抽象工厂

工厂方法方便针对单一产品进行扩展，抽象工厂方便针对产品族进行扩展，不适合对单一产品进行扩展。

### 工厂方法扩展

1. 创建新的产品具体实现，实现产品接口
2. 创建相应的产品工厂，实现工厂接口
3. 使用新的产品工厂生产新的产品

### 抽象工厂扩展

1. 创建一族新的产品具体实现，实现产品接口
2. 创建新的族工厂，实现工厂接口
3. 新的族工厂生产这一族的一系列产品

## Spring IOC 中工厂模式的使用

Spring 通过控制反转（IOC）和依赖注入（DI）从配置文件中动态加载 Bean 到 BeanFactory 中，然后通过 BeanFactory 来获取相应的 Bean 实例

1. application.xml

   ```xml
   <!-- IOC -->
   <bean id="driver" class="com.example.factory.springfactory.Driver"/>
   
   <bean id="tank" class="com.example.factory.springfactory.Tank">
       <!-- DI -->
       <property name="driver" ref="driver"/>
   </bean>
   ```

2. 测试类

   ```java
   public class Main {
       public static void main(String[] args) {
           ApplicationContext context = new ClassPathXmlApplicationContext("application.xml");
           Tank tank = (Tank) context.getBean("tank");
           System.out.println(tank);
       }
   }
   ```
