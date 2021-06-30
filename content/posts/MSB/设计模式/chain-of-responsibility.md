---
title: 责任链模式（Chain of Responsibility）
date: '2021-02-23 20:54:00'
tags:
- MSB
- Design Pattern
- Java
---
# 责任链模式（Chain of Responsibility）

将多个处理流程连接到一起形成链式结构，依次对请求进行处理。

可根据需要，选择处理方式：

1. 只要有一个流程处理成功/失败，就不执行后续其他流程。例如 Filter
2. 执行所有流程

## 代码

1. 创建需要被处理的对象类

   ```java
   /**
    * 需要被责任链处理的对象类
    */
   public class Request {
   
       /**
        * 请求类型
        */
       private String type;
   
       /**
        * 请求消息
        */
       private String message;
   
       public Request(String type, String message) {
           this.type = type;
           this.message = message;
       }
   
       public String getType() {
           return type;
       }
   
       public void setType(String type) {
           this.type = type;
       }
   
       public String getMessage() {
           return message;
       }
   
       public void setMessage(String message) {
           this.message = message;
       }
   }
   ```

2. 创建责任链中流程的抽象类

   ```java
   /**
    * 责任链中流程的抽象类
    */
   public abstract class Filter {
   
       /**
        * 下一个流程
        */
       private Filter nextFilter;
   
       /**
        * 处理请求的方法
        *
        * @param request 需要被处理的对象
        */
       public abstract void doFilter(Request request);
   
       public Filter getNextFilter() {
           return nextFilter;
       }
   
       public Filter setNextFilter(Filter nextFilter) {
           this.nextFilter = nextFilter;
           return this;
       }
   }
   ```

3. 责任链中流程的具体实现

   ```java
   /*
    * 只处理 A 类型的 Request，其他类型的请求交给后续处理
    */
   public class AFilter extends Filter {
       @Override
       public void doFilter(Request request) {
           System.out.println("AFilter doFilter...");
           // 只处理 A 类型的 Request，其他类型的请求交给后续处理
           if ("A".equals(request.getType())) {
               System.out.println("AFilter 处理了请求，请求的 message 是：" + request.getMessage());
           } else {
               Filter nextFilter = this.getNextFilter();
               if (nextFilter != null) {
                   nextFilter.doFilter(request);
               }
           }
       }
   }
   /*
    * 只处理 B 类型的 Request，其他类型的请求交给后续处理
    */
   public class BFilter extends Filter {
       @Override
       public void doFilter(Request request) {
           System.out.println("BFilter doFilter...");
           if ("B".equals(request.getType())) {
               System.out.println("BFilter 处理了请求，请求的 message 是：" + request.getMessage());
           } else {
               Filter nextFilter = this.getNextFilter();
               if (nextFilter != null) {
                   nextFilter.doFilter(request);
               }
           }
       }
   }
   /*
    * 只处理 A 类型的 Request，其他类型的请求交给后续处理
    */
   public class CFilter extends Filter {
       @Override
       public void doFilter(Request request) {
           System.out.println("CFilter doFilter...");
           if ("C".equals(request.getType())) {
               System.out.println("CFilter 处理了请求，请求的 message 是：" + request.getMessage());
           } else {
               Filter nextFilter = this.getNextFilter();
               if (nextFilter != null) {
                   nextFilter.doFilter(request);
               }
           }
       }
   }
   ```

4. 测试

   ```java
   public class Main {
       public static void main(String[] args) {
           Filter aFilter = new AFilter();
           Filter bFilter = new BFilter();
           Filter cFilter = new CFilter();
           // 按照 AFilter，BFilter，CFilter 的顺序将他们组成一条责任链
           Filter filterChain = aFilter.setNextFilter(bFilter.setNextFilter(cFilter));
   
           // A 类型的请求在 AFitler 处处理成功，就不会继续向后执行了
           filterChain.doFilter(new Request("A", "我是 A 类型的请求"));
           System.out.println("-------------------------------");
           // B 类型的请求会先经过 AFilter，AFilter 处理不了，交给 BFilter 处理
           filterChain.doFilter(new Request("B", "我是 B 类型的请求"));
           System.out.println("-------------------------------");
           filterChain.doFilter(new Request("C", "我是 C 类型的请求"));
           System.out.println("-------------------------------");
       }
   }
   ```

## 类图和说明

![image-20210223203215883](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210223203216.png)

1. 创建需要被责任链处理的对象类
2. 创建责任链中每个流程的抽象类，该类包含它的下一个流程的引用和处理请求的方法
3. 创建各个流程的具体实现
4. 可根据需要设置流程何时返回或执行下一流程
5. 如需扩展，只需实现责任链接口，并将其添加到相应链条中即可
