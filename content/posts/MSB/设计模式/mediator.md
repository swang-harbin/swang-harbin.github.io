---
title: 中介/调停者模式（Mediator）
date: '2021-02-23 16:11:00'
tags:
- MSB
- Design Pattern
- Java
---
# 中介/调停者模式（Mediator）

多个对象/类间进行通讯，会很复杂

![image-20210221193205302](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210221193205.png)

使用 Mediator 后，所有对象/类只与 Mediator 进行通讯，彼此之间不直接进行通讯。降低了复杂度，并减少耦合

![image-20210221193211764](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210221193212.png)



## 代码

1. 创建 Colleague 接口

   ```java
   public interface Customer {
   }
   ```

2. 创建 Mediator 接口

   ```java
   public interface AbstractMediator {
       String transaction(Customer customer);
   }
   ```

3. 创建 Colleague 的具体实现，各个实现间是需要相互通讯的，各个实现间通过 Mediator 进行通讯

   - 买家

     ```java
     public class Buyer implements Customer {
     
         private int houses;
         /**
          * 客户持有中介的引用
          */
         private AbstractMediator mediator;
     
         public Buyer(int houses, AbstractMediator mediator) {
             this.houses = houses;
             this.mediator = mediator;
         }
     
         public void buyHouse() {
             System.out.println("买家通过中介买房子");
             // 通过中介来与其他客户交互
             String msg = mediator.transaction(this);
             System.out.println(msg);
         }
     
         public int getHouses() {
             return houses;
         }
         public void setHouses(int houses) {
             this.houses = houses;
         }
     }
     ```

   - 卖家

     ```java
     public class Seller implements Customer {
     
         private int houses;
     
         /**
          * 客户持有中介的引用
          */
         private AbstractMediator mediator;
     
         public Seller(int houses, AbstractMediator mediator) {
             this.houses = houses;
             this.mediator = mediator;
         }
     
         public void sell() {
             System.out.println("卖家通过中介卖房子");
             // 通过中介来与其他客户交互
             String msg = mediator.transaction(this);
             System.out.println(msg);
         }
     
         public int getHouses() {
             return houses;
         }
     
         public void setHouses(int houses) {
             this.houses = houses;
         }
     
     }
     ```

4. 创建 Mediator 的具体实现

   ```java
   import java.util.LinkedList;
   import java.util.List;
   
   /**
    * 房产中介
    */
   public class RealEstateMediator implements AbstractMediator {
       /**
        * 中介里持有客户的引用
        */
       private List<Customer> buyers = new LinkedList<>();
       private List<Customer> sellers = new LinkedList<>();
   
       @Override
       public String transaction(Customer customer) {
           Buyer buyer = null;
           Seller seller = null;
           if (customer instanceof Buyer) {
               buyer = (Buyer) customer;
               buyers.add(buyer);
               if (sellers.isEmpty()) {
                   return "没有卖家";
               }
               seller = (Seller) sellers.get((int) (Math.random() * sellers.size()));
           }
           if (customer instanceof Seller) {
               seller = (Seller) customer;
               sellers.add(seller);
               if (buyers.isEmpty()) {
                   return "没有买家";
               }
               buyer = (Buyer) buyers.get((int) (Math.random() * buyers.size()));
           }
   
           if (seller.getHouses() == 0) {
               return "卖家没有房子";
           }
           seller.setHouses(seller.getHouses() - 1);
           buyer.setHouses(buyer.getHouses() + 1);
           sellers.remove(seller);
           buyers.remove(buyer);
           return "交易成功";
       }
   }
   ```

5. 测试

   ```java
   public class Main {
       public static void main(String[] args) {
           // 中介者
           RealEstateMediator mediator = new RealEstateMediator();
           // 卖家内部通过 mediator 对象与买家交互
           Seller seller = new Seller(10, mediator);
           seller.sell();
           // 买家内部通过 mediator 对象与卖家交互
           Buyer buyer = new Buyer(0, mediator);
           buyer.buyHouse();
   
       }
   }
   ```

## 类图和说明

![image-20210223154257972](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210223154258.png)



1. 创建 Mediator 接口，其中规定 Mediator 需要实现的方法
2. 创建 Mediator 的具体实现，在该实现中，持有需要交互对象的引用
3. 创建 Colleague 接口，Colleague 的具体实现是需要交互的对象
4. 创建 Colleague 的具体实现，在具体实现中包含 Mediator 的引用
5. 需要交互的 Colleague 间没有关联关系，都是通过 Mediator 来进行通讯
6. 如需扩展，只需要实现 Colleague 接口即可

**关键点是每个 Colleague 中包含 Mediator 的引用，在 Colleague 中通过 Mediator 与其他 Colleague 进行交互**

## 和门面模式区别

门面模式是在具体服务前添加了一层门面，客户通过门面访问具体服务，是单向访问

![image-20210223160612054](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210223160612.png)

中介者模式是让所有同事通过中介进行通讯，是双向访问

![image-20210223160619336](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210223160619.png)
