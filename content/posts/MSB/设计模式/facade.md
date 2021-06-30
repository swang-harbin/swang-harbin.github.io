---
title: 外观/门面模式（Facade）
date: '2021-02-21 16:05:00'
tags:
- MSB
- Design Pattern
- Java
---
# 外观/门面模式（Facade）

当某些业务需要多个模块进行协作时，创建一个门面，在门面中处理各个子系统间的关系，客户端只需要与门面进行沟通即可，不需要挨个调用各个模块。

假如 Client 为了完成某个业务，需要调用 SubSystem01、SubSystem02、SubSystem03、SubSystem04，如果不使用门面模式，所有处理代码都在 Client 中进行，如果后期业务变化了，就需要修改 Client 中的代码，不方便维护。
![image-20210221160801541](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210221160801.png) 

使用门面模式后，将 SubSystem 间的关系封装在 Facade 中，客户端仅于 Facade 交互，后期如果业务逻辑变更，只需修改 Facade 即可
![image-20210221160949768](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210221160950.png)


## 代码

1. 创建子系统

   ```java
   /**
    * 注册系统
    */
   public class RegistrySystem {
       public void registry() {
           System.out.println("注册房产信息……");
       }
   }
   
   /**
    * 估值系统
    */
   public class ValuationSystem {
       public void valuation() {
           System.out.println("房价估值……");
       }
   }
   
   /**
    * 交易系统
    */
   public class TradingSystem {
       public void trading() {
           System.out.println("交易成功……");
       }
   }
   ```

2. 创建门面

   ```java
   /**
    * 房产局门面
    */
   public class RealEstateBureauFacade {
       private RegistrySystem registrySystem = new RegistrySystem();
       private ValuationSystem valuationSystem = new ValuationSystem();
       private TradingSystem tradingSystem = new TradingSystem();
   
       public void buyHouse() {
           System.out.println("购买房屋……");
           registrySystem.registry();
           valuationSystem.valuation();
           tradingSystem.trading();
       }
   }
   ```

3. 调用

   ```java
   public class Main {
       public static void main(String[] args) {
           // 使用门面前
           new RegistrySystem().registry();
           new ValuationSystem().valuation();
           new TradingSystem().trading();
           // 使用门面后
           new RealEstateBureauFacade().buyHouse();
       }
   }
   ```

## 类图和说明

![image-20210221155902558](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210221155903.png)

1. 创建子系统：ReigstrySystem，ValustionSystem，TradingSystem
2. 创建门面，包含子系统的引用
3. 在门面添加方法，按需调用多个子系统
4. 客户端只需调用门面即可完成工作，不需依次调用所需的子系统
5. 如需扩展只需要修改门面类即可
