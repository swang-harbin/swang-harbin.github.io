---
title: 分布式事务
date: '2021-03-13 20:54:00'
tags:
- MSB
- Project
- 网约车三期
- Java
---
# 分布式事务

**数据库的本地事务如何保证?**

锁, redo, undo

**ACID**

AD: 依靠日志文件

CI: 依靠锁

刚性事务(acid), 柔性事务(base).

XA 协议：事务管理器(TM), 资源管理器(RM)

## 模型

![image-20210311111701726](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210311111702.png)



第三方支付回调支付系统，支付系统调用订单系统，支付系统和订单系统需要事务一致。

其中支付系统和订单系统，需要保持事务一致的系统称为**资源管理器**

为了保证 RM 的事务，就需要一个第三方来进行管理，所以引入了**事务管理器**

**事务管理器**与**资源管理器**间进行协作，保证**资源管理器**间的事务。

## 2PC 模型

### 1 阶段

![1pc](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210311145224.png)

1. TM 向所有参与事务的 RM 发送事务内容，询问是否可以提交事务，等待 RM 回应
2. RM 收到 TM 的询问，开始执行 sql 语句，将 undo 和 redo 信息写入日志，但是不提交本地事务
3. 如果 RM 执行成功，会给 TM 返回 yes, 表示可以进行事务提交；否则返回 no, 表示不可提交事务。

如果 TM 在任一阶段收到了 RM 返回的 no 或者超时没有收到响应，就通知所有 RM 执行回滚, RM 通过之前写入的 undo 信息执行回滚，并释放在整个事务期间占用的资源，并反馈回滚结果, TM 中断事务

### 2 阶段

![2pc](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210311145238.png)

4. 如果在 1PC 阶段, TM 收到的都是 yes, 则向 RM 发送提交消息；否则只要有 1 个 no, 或者超时就向所有参与的 RM 发送回滚消息

5. RM 收到提交/回滚消息，开始提交/回滚本地事务
6. RM 提交事务提交成功后，会给 TM 返回 yes/no

在 2 阶段中，如果 RM 执行提交后就故障了，这样就没办法回滚了。

在 2PC 模型中，如果在第 2 阶段, TM 通知提交后, A 系统提交本地事务后, B 系统还未提交本地事务, B 系统和 TM 就都宕机了，这时，就成了 A 系统和 B 系统的数据不一致，即使可以通过其他手段解决这个问题，但是此时已经出现了数据不一致的情况, **2PC 解决不了这个问题**

## 3PC 模型

### 3PC 和 2PC 的区别

1. 引入超时机制。同时在 TM(超时，中断事务)和 RM(超时，在 pre 中断，在 do 提交)中都引入超时机制。

   > 2PC 中只有 TM 有超时机制

2. 在第一阶段和第二阶段中插入一个准备阶段。保证了在最后提交阶段之前各参与 RM 的状态是一致的。降低锁资源的概率和时长

### 1 阶段

在 2PC 中，只要一开始，就会锁定资源，所以 3PC 在 2PC 之前添加了一个新的阶段

![image-20210311161147561](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210311161148.png)

1. TM 向参与事务的 RM 先发送一个请求，询问他们是否能 commit
2. RM 尝试获取锁，此时不执行 sql, 所以不锁定资源。如果能获取锁就返回 yes
3. TM 收到所有 yes 后，才开始执行下一阶段

## 柔性事务

### CAP 理论

CAP 是一个已经被证实的理论：一个分布式系统最多只能满足一致性(Consistency), 可用性(Availability)和分区容错性(Partition tolerance)这三项中的两项。它可以作为我们架构设计，技术选型的考量标准。对于多数大型互联网应用的场景，节点众多，部署分散，而且现在的集群规模越来越大，所以节点故障，网络故障是常态，而且要保证服务可用性达到 N 个 9(99.99%), 并要达到良好的响应性能来提高用户体验, **因此一般都会做出如下选择：保证 P 和 A, 舍弃 C 强一致性，保证最终一致性**

### BASE 理论

BASE 是 Basically Availbale(基本可用), Soft state(软状态)和 Eventually consistent(最终一致性)三个短语的缩写. BASE 理论是对 CAP 中 AP 的一个扩展，通过牺牲强一致性来获得可用性，当出现故障允许部分不可用但是要保证核心功能可用，允许数据在一段时间内是不一致的，但最终达到一致状态。满足 BASE 理论的事务，我们称之为"柔性事务".

- 基本可用：分布式系统在出现故障时，允许损失部分可用功能，保证核心功能可用。如电商网址交易付款出现问题了，商品依然可以正常浏览。

- 软状态：由于不要求强一致性，所以 BASE 允许系统中存在中间状态(也叫软状态), 这个状态不影响系统可用性，如订单中的"支付中", "数据同步中"等状态，待数据最终一致后改为"成功"状态

- 最终一致性：最终一致性是指经过一段时间后都将会达到一致。如订单中的"支付中"状态，最终会变为"支付成功"或者"支付失败", 使订单状态与实际交易结果达成一致，但需要一定时间的延迟，等待。

## 消息队列+事件表

不适用：数据量特别大的情况

幂等：通过消息中事件的 id, 主键约束，来保证消息重复消费的问题

![消息队列+事件表](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210313185226.png)

1. 支付系统自己的业务更新支付表，然后创建一个支付事件，插入到事件表
2. 支付系统的定时任务从事件表中查询出 new 状态的事件，将其更新为 published, 发送给消息队列
3. 订单系统监听到消息队列中的消息，将事件状态更新为 received
4. 订单系统的定时任务从事件表中查询出 received 状态的事件，将其更新为 processed, 并执行订单系统自己的业务，更新订单表

### 实现

#### 环境准备

1. 准备消息队列 activemq, 修改 activemq.xml 添加如下代码，开启死信队列

   ```xml
   <destinationPolicy>
       <policyMap>
           <policyEntries>
               <!-- 死信队列 -->
               <policyEntry queue=">">
                   <deadLetterStrategy>
                       <individualDeadLetterStrategy queuePrefix="DLQ." useQueueForQueueMessages="true" processNonPersistent="true"/>
                   </deadLetterStrategy>
               </policyEntry>
               </policyMap>
           </policyEntries>
   </destinationPolicy>
   ```

2. 创建事件表

   > 两个系统可以使用同一张事件表，也可以使用两张事件表，结构相同

   ```java
   create table `online-taxi-three`.tbl_pay_event
   (
   	id int auto_increment,
   	pay_type varchar(32) null comment '事件类型(支付表支付完成，订单表修改状态)',
   	process varchar(32) null comment '事件环节(new, published, received, processed)',
   	content varchar(255) null comment '事件内容，保存事件发生时需要传递的数据',
   	create_time datetime null,
   	update_time datetime null,
   	constraint tbl_order_event_id_uindex
   		unique (id)
   );
   
   alter table `online-taxi-three`.tbl_pay_event
   	add primary key (id);
   ```

#### 支付系统

1. 引入依赖

   ```xml
   <!-- mybatis -->
   <dependency>
       <groupId>org.mybatis.spring.boot</groupId>
       <artifactId>mybatis-spring-boot-starter</artifactId>
       <version>2.1.4</version>
   </dependency>
   <!-- mysql -->
   <dependency>
       <groupId>mysql</groupId>
       <artifactId>mysql-connector-java</artifactId>
   </dependency>
   <!-- activemq -->
   <dependency>
       <groupId>org.springframework.boot</groupId>
       <artifactId>spring-boot-starter-activemq</artifactId>
   </dependency>
   <dependency>
       <groupId>org.apache.activemq</groupId>
       <artifactId>activemq-pool</artifactId>
   </dependency>
   <!-- web -->
   <dependency>
       <groupId>org.springframework.boot</groupId>
       <artifactId>spring-boot-starter-web</artifactId>
   </dependency>
   <!-- lombok -->
   <dependency>
       <groupId>org.projectlombok</groupId>
       <artifactId>lombok</artifactId>
       <optional>true</optional>
   </dependency>
   ```

2. 配置文件

   ```yaml
   server:
     port: 8080
   spring:
     application:
       name: service-pay
     activemq:
       broker-url: tcp://127.0.0.1:61616
       user: admin
       password: admin
       pool:
         enabled: true
         max-connections: 100
     datasource:
       driver-class-name: com.mysql.cj.jdbc.Driver
       url: jdbc:mysql://localhost:3306/online-taxi-three?characterEncoding=utf-8&serverTimezone=Asia/Shanghai
       username: root
       password: root
       dbcp2:
         initial-size: 5
         min-idle: 5
         max-total: 5
         max-wait-millis: 200
         validation-query: SELECT 1
         test-while-idle: true
         test-on-borrow: false
         test-on-return: false
   mybatis:
     mapper-locations:
       - classpath:mapper/*.xml
   ```

3. ActiveMQ 配置类

   ```java
   package com.example.servicepay.config;
   
   import org.apache.activemq.ActiveMQConnectionFactory;
   import org.apache.activemq.command.ActiveMQQueue;
   import org.springframework.beans.factory.annotation.Value;
   import org.springframework.context.annotation.Bean;
   import org.springframework.context.annotation.Configuration;
   
   import javax.jms.Queue;
   
   /**
    * @author wangshuo
    * @date 2021/03/13
    */
   @Configuration
   public class ActiveMqConfig {
   
       @Value("${spring.activemq.broker-url}")
       private String brokerUrl;
   
       @Bean
       public Queue payOrderQueue() {
           return new ActiveMQQueue("PayOrderQueue");
       }
   
       @Bean
       public ActiveMQConnectionFactory connectionFactory() {
           return new ActiveMQConnectionFactory(brokerUrl);
       }
   }
   ```

4. 使用 mybatis-generator 生成 entity, dao, mapper

5. 创建 Controller, 模拟支付业务

   ```java
   package com.example.servicepay.controller;
   
   import com.example.servicepay.dao.TblPayEventDAO;
   import com.example.servicepay.entity.TblPayEvent;
   import lombok.extern.slf4j.Slf4j;
   import org.springframework.beans.factory.annotation.Autowired;
   import org.springframework.transaction.annotation.Transactional;
   import org.springframework.web.bind.annotation.GetMapping;
   import org.springframework.web.bind.annotation.RequestMapping;
   import org.springframework.web.bind.annotation.RestController;
   
   import java.util.Date;
   
   /**
    * @author wangshuo
    * @date 2021/03/13
    */
   @RestController
   @RequestMapping("/pay")
   @Slf4j
   public class PayController {
   
       @Autowired
       private TblPayEventDAO tblPayEventDAO;
   
       @GetMapping("/pay-success")
       @Transactional(rollbackFor = Exception.class)
       public String paySuccess() {
           // 支付成功，将支付信息插入到支付表
           // 向事件表中插入一条新数据
           TblPayEvent event = new TblPayEvent();
           event.setProcess("new");
           event.setPayType("支付成功，订单表修改状态");
           event.setContent("相关支付信息");
           event.setCreateTime(new Date());
           event.setUpdateTime(new Date());
           int insert = tblPayEventDAO.insert(event);
           return insert > 0 ? "success" : "fail";
       }
   }
   ```

6. 添加定时任务，定时将数据库中 new 状态的事务

   ```java
   package com.example.servicepay.task;
   
   import com.example.servicepay.dao.TblPayEventDAO;
   import com.example.servicepay.entity.TblPayEvent;
   import com.fasterxml.jackson.core.JsonProcessingException;
   import com.fasterxml.jackson.databind.ObjectMapper;
   import lombok.extern.slf4j.Slf4j;
   import org.springframework.beans.factory.annotation.Autowired;
   import org.springframework.jms.core.JmsMessagingTemplate;
   import org.springframework.scheduling.annotation.Scheduled;
   import org.springframework.stereotype.Component;
   import org.springframework.transaction.annotation.Transactional;
   
   import javax.jms.Queue;
   import java.util.List;
   
   /**
    * @author wangshuo
    * @date 2021/03/13
    */
   @Component
   @Slf4j
   public class ProducerTask {
   
       @Autowired
       private TblPayEventDAO tblPayEventDAO;
   
       @Autowired
       private Queue payOrderQueue;
   
       @Autowired
       private JmsMessagingTemplate jmsMessagingTemplate;
   
       @Autowired
       private ObjectMapper objectMapper;
   
       /**
        * 定时将事件表中为 new 状态的事件发送到消息队列
        * Transactional: 在发生异常时回滚数据库中的数据
        */
       @Scheduled(cron = "0/5 * * * * ?")
       @Transactional(rollbackFor = Exception.class)
       public void task() throws JsonProcessingException {
           log.info("定时任务，将 new 状态的事件发送到消息队列");
   
           List<TblPayEvent> events = tblPayEventDAO.selectByProcess("new");
           for (TblPayEvent event : events) {
               // 更新事件表状态
               event.setProcess("published");
               tblPayEventDAO.updateByPrimaryKey(event);
               log.info("修改 pay 事件表状态为 已发布到消息队列");
               // 把该事件发送到消息队列
               jmsMessagingTemplate.convertAndSend(payOrderQueue, objectMapper.writeValueAsString(event));
           }
   
       }
   }
   ```

7. 在启动类上添加 `@EnableScheduling` 和 `@EnableJms` 注解

#### 订单系统

1. 引入依赖

   > 与支付系统相同

2. 添加配置文件

   > 与支付系统相同，只需要修改端口和服务名即可
   >
   > 如果支付系统和订单系统使用了不同的两个库，还需要修改数据库连接

   ```java
   server:
     port: 8081
   spring:
     application:
       name: service-order
   ```

3. ActiveMQ 配置

   ```java
   package com.example.serviceorder.config;
   
   import org.apache.activemq.ActiveMQConnectionFactory;
   import org.apache.activemq.RedeliveryPolicy;
   import org.springframework.beans.factory.annotation.Value;
   import org.springframework.context.annotation.Bean;
   import org.springframework.context.annotation.Configuration;
   import org.springframework.jms.config.DefaultJmsListenerContainerFactory;
   import org.springframework.jms.config.JmsListenerContainerFactory;
   
   /**
    * @author wangshuo
    * @date 2021/03/13
    */
   @Configuration
   public class ActiveMqConfig {
   
       @Value("${spring.activemq.user}")
       private String username;
       @Value("${spring.activemq.password}")
       private String password;
       @Value("${spring.activemq.broker-url}")
       private String brokerURL;
   
       /**
        * 连接工厂
        *
        * @param redeliveryPolicy
        * @return
        */
       @Bean
       public ActiveMQConnectionFactory activeMQConnectionFactory(RedeliveryPolicy redeliveryPolicy) {
           ActiveMQConnectionFactory activeMQConnectionFactory = new ActiveMQConnectionFactory(username, password, brokerURL);
           activeMQConnectionFactory.setRedeliveryPolicy(redeliveryPolicy);
           return activeMQConnectionFactory;
       }
   
       /**
        * 重发策略
        *
        * @return
        */
       @Bean
       public RedeliveryPolicy redeliveryPolicy() {
           return new RedeliveryPolicy();
       }
   
       /**
        * 设置消息队列 确认机制
        *
        * @param activeMQConnectionFactory
        * @return
        */
       @Bean
       public JmsListenerContainerFactory jmsListenerContainerFactory(ActiveMQConnectionFactory activeMQConnectionFactory) {
           DefaultJmsListenerContainerFactory defaultJmsListenerContainerFactory = new DefaultJmsListenerContainerFactory();
           defaultJmsListenerContainerFactory.setConnectionFactory(activeMQConnectionFactory);
           // 1: 自动确认, 2: 客户端手动确认, 3: 自动批量确认, 4: 事务提交并确认
           defaultJmsListenerContainerFactory.setSessionAcknowledgeMode(2);
           return defaultJmsListenerContainerFactory;
   
       }
   }
   ```

4. 使用 mybatis-generater 生成 entity, dao, mapper

5. 添加 ActiveMQ 的监听器

   ```java
   package com.example.serviceorder.listener;
   
   import com.example.serviceorder.dao.TblPayEventDAO;
   import com.example.serviceorder.entity.TblPayEvent;
   import com.fasterxml.jackson.databind.ObjectMapper;
   import lombok.extern.slf4j.Slf4j;
   import org.springframework.beans.factory.annotation.Autowired;
   import org.springframework.jms.annotation.JmsListener;
   import org.springframework.stereotype.Component;
   
   import javax.jms.JMSException;
   import javax.jms.Session;
   import javax.jms.TextMessage;
   
   /**
    * @author wangshuo
    * @date 2021/03/13
    */
   @Component
   @Slf4j
   public class PayOrderQueueListener {
   
       @Autowired
       private ObjectMapper objectMapper;
   
       @Autowired
       private TblPayEventDAO tblPayEventDAO;
   
       /**
        * 监听 PayOrderQueue 中的消息
        *
        * @param textMessage
        * @param session
        * @throws JMSException
        */
       @JmsListener(destination = "PayOrderQueue", containerFactory = "jmsListenerContainerFactory")
       public void receive(TextMessage textMessage, Session session) throws JMSException {
           log.info("收到消息: " + textMessage.getText());
           try {
               TblPayEvent event = objectMapper.readValue(textMessage.getText(), TblPayEvent.class);
               event.setProcess("received");
               tblPayEventDAO.updateByPrimaryKey(event);
               // 告诉消息队列，消息已被消费
               textMessage.acknowledge();
           } catch (Exception e) {
               e.printStackTrace();
               // 如果出现异常，要把该消息放回消息队列
               session.rollback();
           }
       }
   }
   ```

6. 添加定时任务

   ```java
   package com.example.serviceorder.task;
   
   import com.example.serviceorder.dao.TblPayEventDAO;
   import com.example.serviceorder.entity.TblPayEvent;
   import lombok.extern.slf4j.Slf4j;
   import org.springframework.beans.factory.annotation.Autowired;
   import org.springframework.scheduling.annotation.Scheduled;
   import org.springframework.stereotype.Component;
   import org.springframework.transaction.annotation.Transactional;
   
   import java.util.List;
   
   /**
    * @author wangshuo
    * @date 2021/03/13
    */
   @Component
   @Slf4j
   public class ConsumerTask {
   
       @Autowired
       private TblPayEventDAO tblPayEventDAO;
   
       /**
        * 获取事件表中已接收的事件，调用订单服务
        */
       @Scheduled(cron = "0/5 * * * * ?")
       @Transactional(rollbackFor = Exception.class)
       public void task() {
           log.info("定时任务获取已接收事件，更新订单信息");
           // 查询出所有状态是 received 的事件
           List<TblPayEvent> events = tblPayEventDAO.selectByProcess("received");
           log.info("获取到{}个已接收事件", events.size());
           for (TblPayEvent event : events) {
               // 修改事件状态
               event.setProcess("processed");
               tblPayEventDAO.updateByPrimaryKey(event);
               // 调用订单服务，更新订单
           }
   
       }
   }
   ```

7. 在启动类上添加 `@EnableScheduling` 和 `@EnableJms` 注解

### 相关扩展说明

1. 事件表可以是同一张表，也可以是两个数据库中的两张表
2. 定时任务可以使用分布式定时任务，来提高系统稳定性

## tx-lcn 框架

[tx-lcn github 官网](https://github.com/codingapi/tx-lcn)

### LCN 模式

Lock, Confirm, Notify

XA 协议, Oracle 提出的, 2PC 的

- **L**ock: 锁定事务单元

- **C**onfirm: 确认事务

- **N**otify: 通知事务

#### 流程图

假设调用放调用服务 A, 服务 A 调用服务 B, 服务 B 调用服务......调用服务 N.

![image-20210313214837868](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210313214838.png)

LCN 的调用流程

![lcn](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210317114121.png)

黑色线是假如没有添加事务管理时的执行流程。

红色线+黑色线是添加了事务管理时的执行流程

通过灰色虚线可以将该过程分为两个阶段，类似于上方的 [2PC 模型](#2PC 模型)

#### 协调机制

创建事务组和把服务添加到事务组都很容易，但是事务通知模块怎么能通知服务去提交/回滚事务，是重点。因为服务是依次调用，然后从后向前通知提交/回滚的，所以前面的服务已经提交事务了，才会去调用后面的事务。

所以解决办法就是让前面的服务不真正的提交事务，而是把它与数据库的连接保存起来，等最后一个服务被调用结束后，在从保存的数据库连接中依次取出连接，进行提交/回滚。

sql 操作完了，提交了, connection 释放了, close(connection.close())

假释放 close, 存储到一个 Map<请求 Id, connection>

目的：对应调用和连接

协调机制本质: **代理了 DataSource, 保持了请求和 DB 连接的对应.**

#### 补偿机制

第二阶段如果由于网络原因会造成提交/回滚的通知提交失败，此时 lcn 会将通知的具体事项和需要执行的 sql 操作记录下来，用来做后续的补偿

#### 架构图

![lcn](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210315230222.png)

#### 代码

##### TX-Manager

1. 引入依赖

   ```xml
   <!--tm manager-->
   <dependency>
       <groupId>com.codingapi.txlcn</groupId>
       <artifactId>txlcn-tm</artifactId>
       <version>${txlcn.version}</version>
   </dependency>
   
   <dependency>
       <groupId>com.codingapi.txlcn</groupId>
       <artifactId>txlcn-tc</artifactId>
       <version>${txlcn.version}</version>
   </dependency>
   
   <dependency>
       <groupId>com.codingapi.txlcn</groupId>
       <artifactId>txlcn-txmsg-netty</artifactId>
       <version>${txlcn.version}</version>
   </dependency>
   ```

2. 生成数据库表，在 txlcn-tm 的包中有一个 tx-manager.sql 文件，包含了建表语句

   ![image-20210315191321893](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210315191322.png)

   ```sql
   /*
    Navicat Premium Data Transfer
   
    Source Server         : local
    Source Server Type    : MySQL
    Source Server Version : 100309
    Source Host           : localhost:3306
    Source Schema         : tx-manager
   
    Target Server Type    : MySQL
    Target Server Version : 100309
    File Encoding         : 65001
   
    Date: 29/12/2018 18:35:59
   */
   CREATE DATABASE IF NOT EXISTS  `tx-manager` DEFAULT CHARSET utf8 COLLATE utf8_general_ci;
   USE `tx-manager`;
   
   SET NAMES utf8mb4;
   SET FOREIGN_KEY_CHECKS = 0;
   
   -- ----------------------------
   -- Table structure for t_tx_exception
   -- ----------------------------
   DROP TABLE IF EXISTS `t_tx_exception`;
   CREATE TABLE `t_tx_exception`  (
       `id` bigint(20) NOT NULL AUTO_INCREMENT,
       `group_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
       `unit_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
       `mod_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
       `transaction_state` tinyint(4) NULL DEFAULT NULL,
       `registrar` tinyint(4) NULL DEFAULT NULL,
       `ex_state` tinyint(4) NULL DEFAULT NULL COMMENT '0 待处理 1 已处理',
       `remark` varchar(10240) NULL DEFAULT NULL COMMENT '备注',
       `create_time` datetime(0) NULL DEFAULT NULL,
       PRIMARY KEY (`id`) USING BTREE
   ) ENGINE = InnoDB AUTO_INCREMENT = 967 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;
   
   SET FOREIGN_KEY_CHECKS = 1;
   ```

3. 配置文件

   ```yaml
   # TM 事务管理器的服务端 WEB 访问端口。提供一个可视化的界面，端口自定义
   server:
     port: 7970
   spring:
     application:
       name: tx-lcn-transaction-manager
     # TM 事务管理器，需要访问数据库，实现分布式事务状态记录
     datasource:
       driver-class-name: com.mysql.cj.jdbc.Driver
       url: jdbc:mysql://localhost:3306/tx-manager?characterEncoding=UTF-8&setTimeZone=Asia/Shanghai
       username: root
       password: root
     # TM 事务管理器，是依赖 redis 使用分布式事务协调的。尤其是 TCC 和 TXC 两种事务模型
     redis:
       host: 127.0.0.1
       port: 6379
       database: 0
   tx-lcn:
     manager:
       # TM 事务管理器，提供的 WEB 管理平台的登录密码。无用户名。默认是 codingapi
       admin-key: codingapi
     # 日志。
     logger:
       # 如果需要 TM 记录日志，则开启，赋值为 true, 并提供后续的配置。
       enabled: true
       # 为日志功能提供数据库连接。和之前配置的分布式事务管理器管理依赖使用的数据源不同
       driver-class-name: com.mysql.cj.jdbc.Driver
       jdbc-url: jdbc:mysql://localhost:3306/tx-manager?characterEncoding=UTF-8&setTimeZone=Asia/Shanghai
       username: root
       password: root
   ```

4. 在启动类上添加 `@EnableTransactionManagerServer` 注解

##### ResourceManager

1. 引入依赖

   ```xml
   <!-- lcn, TX-Client -->
   <dependency>
       <groupId>com.codingapi.txlcn</groupId>
       <artifactId>txlcn-tc</artifactId>
       <version>${txlcn.version}</version>
   </dependency>
   
   <dependency>
       <groupId>com.codingapi.txlcn</groupId>
       <artifactId>txlcn-txmsg-netty</artifactId>
       <version>${txlcn.version}</version>
   </dependency>
   ```

2. 配置类

   ```yaml
   tx-lcn:
     client:
       # TM 的 IP 地址和端口
       manager-address: 127.0.0.1:7970
   ```

3. 在启动类上添加 `@EnableDistributedTransaction` 注解

4. 创建业务数据库

   ```sql
   create table lcn_order.tbl_order
   (
       id int not null,
       order_name varchar(32) null,
       constraint tbl_order_id_uindex
       unique (id)
   );
   
   alter table lcn_order.tbl_order
   	add primary key (id);
   ```

5. 生成 entity, dao, mapper

6. 需要使用分布式事务的地方添加 `@LcnTransaction` 注解

   - ServiceA 远程调用 ServiceB

     ```java
     @Service
     public class ServiceA {
         
         @Autowired
         private ValueDao valueDao;
         
         //远程 B 模块业务
         @Autowired
         private ServiceB serviceB;
         
         //分布式事务注解
         @LcnTransaction 
         //本地事务注解
         @Transactional(rollbackFor = Exception.class)
         public String execute(String value) throws BusinessException {
             // step1. 调用远程服务
             String result = serviceB.rpc(value);
             // step2. 本地事务操作。
             valueDao.save(value);
             valueDao.saveBackup(value);
             return result + " > " + "ok-A";
         }
     }
     
     ```

   - ServiceB

     ```java
     @Service
     public class ServiceB {
     
         @Autowired
         private ValueDao valueDao;
         
         //分布式事务注解
         @LcnTransaction
         //本地事务注解
         @Transactional
         public String rpc(String value) throws BusinessException {
             valueDao.save(value);
             valueDao.saveBackup(value);
             return "ok-B";
         }
     }
     ```

#### TX-Manager 集群

##### TX-Manager 集群配置

其他配置都可以不变，只需要把端口修改即可

```yaml
spring:
  application:
    name: tx-lcn-transaction-manager
  # TM 事务管理器，需要访问数据库，实现分布式事务状态记录
  datasource:
    driver-class-name: com.mysql.cj.jdbc.Driver
    url: jdbc:mysql://localhost:3306/tx-manager?characterEncoding=UTF-8&setTimeZone=Asia/Shanghai
    username: root
    password: root
  # TM 事务管理器，是依赖 redis 使用分布式事务协调的。尤其是 TCC 和 TXC 两种事务模型
  redis:
    host: 127.0.0.1
    port: 6379
    database: 0
tx-lcn:
  manager:
    # TM 事务管理器，提供的 WEB 管理平台的登录密码。无用户名。默认是 codingapi
    admin-key: msb
  # 日志。
  logger:
    # 如果需要 TM 记录日志，则开启，赋值为 true, 并提供后续的配置。
    enabled: true
    # 为日志功能提供数据库连接。和之前配置的分布式事务管理器管理依赖使用的数据源不同
    driver-class-name: com.mysql.cj.jdbc.Driver
    jdbc-url: jdbc:mysql://localhost:3306/tx-manager?characterEncoding=UTF-8&setTimeZone=Asia/Shanghai
    username: root
    password: root
---
spring:
  profiles: TM_01
# TM 事务管理器的服务端 WEB 访问端口。提供一个可视化的界面，端口自定义
server:
  port: 7971
---
spring:
  profiles: TM_02
# TM 事务管理器的服务端 WEB 访问端口。提供一个可视化的界面，端口自定义
server:
  port: 7972
```

##### TX-Client 配置

需要去 [TX-Manager 的管理页面](http://127.0.0.1:7971) 查看，与管理页面的端口不一样

```yaml
tx-lcn:
  client:
    manager-address: 127.0.0.1:8071,127.0.0.1:8072
```

#### 源码

##### 代理 Connection

1. 通过 Spring 的 AOP 方式，拦截 `javax.sql.DataSource.getConnection()` 方法，返回 LCN 的代理连接对象

   ```java
   package com.codingapi.txlcn.tc.aspect;
   
   import com.codingapi.txlcn.tc.aspect.weave.DTXResourceWeaver;
   import com.codingapi.txlcn.tc.config.TxClientConfig;
   import lombok.extern.slf4j.Slf4j;
   import org.aspectj.lang.ProceedingJoinPoint;
   import org.aspectj.lang.annotation.Around;
   import org.aspectj.lang.annotation.Aspect;
   import org.springframework.core.Ordered;
   import org.springframework.stereotype.Component;
   
   import java.sql.Connection;
   
   /**
    * create by lorne on 2018/1/5
    */
   @Aspect
   @Component
   @Slf4j
   public class DataSourceAspect implements Ordered {
   
       private final TxClientConfig txClientConfig;
   
       private final DTXResourceWeaver dtxResourceWeaver;
   
       public DataSourceAspect(TxClientConfig txClientConfig, DTXResourceWeaver dtxResourceWeaver) {
           this.txClientConfig = txClientConfig;
           this.dtxResourceWeaver = dtxResourceWeaver;
       }
   
   
       @Around("execution(* javax.sql.DataSource.getConnection(..))")
       public Object around(ProceedingJoinPoint point) throws Throwable {
           // 获取连接对象，返回的是被 tx-lcn 框架接管的 Connection
           return dtxResourceWeaver.getConnection(() -> (Connection) point.proceed());
       }
   
   }
   ```

2. LcnConnectionProxy 对象

   ```java
   package com.codingapi.txlcn.tc.core.transaction.lcn.resource;
   
   import com.codingapi.txlcn.txmsg.dto.RpcResponseState;
   import lombok.extern.slf4j.Slf4j;
   
   import java.sql.*;
   import java.util.Map;
   import java.util.Properties;
   import java.util.concurrent.Executor;
   
   
   @Slf4j
   // 代理模式，实现了 java.sql.Connection 接口
   public class LcnConnectionProxy implements Connection {
   
       private Connection connection;
   
       public LcnConnectionProxy(Connection connection) {
           this.connection = connection;
       }
   
       /**
        * notify connection
        *
        * @param state transactionState
        * @return RpcResponseState RpcResponseState
        */
       public RpcResponseState notify(int state) {
           try {
               if (state == 1) {
                   log.debug("commit transaction type[lcn] proxy connection:{}.", this);
                   // 手动提交
                   connection.commit();
               } else {
                   log.debug("rollback transaction type[lcn] proxy connection:{}.", this);
                   // 手动回滚
                   connection.rollback();
               }
               connection.close();
               log.debug("transaction type[lcn] proxy connection:{} closed.", this);
               return RpcResponseState.success;
           } catch (Exception e) {
               log.error(e.getLocalizedMessage(), e);
               return RpcResponseState.fail;
           }
       }
   
       // 关闭自动提交
       @Override
       public void setAutoCommit(boolean autoCommit) throws SQLException {
           connection.setAutoCommit(false);
       }
   
       // commit 方法是空方法，通过 notify 手动提交
       @Override
       public void commit() throws SQLException {
           //connection.commit();
       }
   	// rollback 方法是空方法，通过 notify 手动回滚
       @Override
       public void rollback() throws SQLException {
           //connection.rollback();
       }
   	// close 方法是空方法，假关闭连接
       @Override
       public void close() throws SQLException {
           //connection.close();
       }
   }
   ```

##### `@LcnTransaction` 生效

 1. 事务拦截器

    ```java
    package com.codingapi.txlcn.tc.aspect;
    /**
     * LCN 事务拦截器
     * create by lorne on 2018/1/5
     */
    @Aspect
    @Component
    @Slf4j
    public class TransactionAspect implements Ordered {
    
        private final TxClientConfig txClientConfig;
    
        private final DTXLogicWeaver dtxLogicWeaver;
    
        public TransactionAspect(TxClientConfig txClientConfig, DTXLogicWeaver dtxLogicWeaver) {
            this.txClientConfig = txClientConfig;
            this.dtxLogicWeaver = dtxLogicWeaver;
        }
    
        /**
         * DTC Aspect (Type of LCN)
         */
        @Pointcut("@annotation(com.codingapi.txlcn.tc.annotation.LcnTransaction)")
        public void lcnTransactionPointcut() {
        }
    
        @Around("txTransactionPointcut()")
        public Object transactionRunning(ProceedingJoinPoint point) throws Throwable {
            DTXInfo dtxInfo = DTXInfo.getFromCache(point);
            TxTransaction txTransaction = dtxInfo.getBusinessMethod().getAnnotation(TxTransaction.class);
            dtxInfo.setTransactionType(txTransaction.type());
            dtxInfo.setTransactionPropagation(txTransaction.propagation());
            return dtxLogicWeaver.runTransaction(dtxInfo, point::proceed);
        }
    
        @Around("lcnTransactionPointcut() && !txcTransactionPointcut()" +
                "&& !tccTransactionPointcut() && !txTransactionPointcut()")
        public Object runWithLcnTransaction(ProceedingJoinPoint point) throws Throwable {
            // 创建分布式事务信息对象，内部包含 groupId 等信息
            DTXInfo dtxInfo = DTXInfo.getFromCache(point);
            LcnTransaction lcnTransaction = dtxInfo.getBusinessMethod().getAnnotation(LcnTransaction.class);
            // 标记事务单元的事务类型
            dtxInfo.setTransactionType(Transactions.LCN);
            dtxInfo.setTransactionPropagation(lcnTransaction.propagation());
            // 重点: 
            return dtxLogicWeaver.runTransaction(dtxInfo, point::proceed);
        }
    }
    ```

2. 分布式事务信息

   ```java
   package com.codingapi.txlcn.tc.aspect;
   
   /**
    * Description:
    * Date: 19-1-11 下午 1:21
    *
    * @author ujued
    */
   @AllArgsConstructor
   @Data
   public class DTXInfo {
       private static final Map<String, DTXInfo> dtxInfoCache = new ConcurrentReferenceHashMap<>();
   
       private String transactionType;
   
       private DTXPropagation transactionPropagation;
   
       private TransactionInfo transactionInfo;
   
       /**
        * 用户实例对象的业务方法（包含注解信息）
        */
       private Method businessMethod;
   
       private String unitId;
   
   
       public static DTXInfo getFromCache(ProceedingJoinPoint proceedingJoinPoint) throws Throwable {
           String signature = proceedingJoinPoint.getSignature().toString();
           // 获取事务 id
           String unitId = Transactions.unitId(signature);
           // 获取该事务 id 的信息，放置在该事务调用中有多个事务单元的信息
           DTXInfo dtxInfo = dtxInfoCache.get(unitId);
           if (Objects.isNull(dtxInfo)) {
               MethodSignature methodSignature = (MethodSignature) proceedingJoinPoint.getSignature();
               Method method = methodSignature.getMethod();
               Class<?> targetClass = proceedingJoinPoint.getTarget().getClass();
               Method thisMethod = targetClass.getMethod(method.getName(), method.getParameterTypes());
               dtxInfo = new DTXInfo(thisMethod, proceedingJoinPoint.getArgs(), targetClass);
               // 事务单元 ID 和事务信息放在缓存中
               dtxInfoCache.put(unitId, dtxInfo);
           }
           dtxInfo.reanalyseMethodArgs(proceedingJoinPoint.getArgs());
           return dtxInfo;
       }
   }
   ```

3. runTransaction

   ```java
   package com.codingapi.txlcn.tc.aspect.weave;
   
   /**
    * Description:
    * Company: CodingApi
    * Date: 2018/11/29
    *
    * @author ujued
    */
   @Component
   @Slf4j
   public class DTXLogicWeaver {
   
       private final DTXServiceExecutor transactionServiceExecutor;
   
       private final TCGlobalContext globalContext;
   
       @Autowired
       public DTXLogicWeaver(DTXServiceExecutor transactionServiceExecutor, TCGlobalContext globalContext) {
           this.transactionServiceExecutor = transactionServiceExecutor;
           this.globalContext = globalContext;
       }
   
       public Object runTransaction(DTXInfo dtxInfo, BusinessCallback business) throws Throwable {
   
           if (Objects.isNull(DTXLocalContext.cur())) {
               DTXLocalContext.getOrNew();
           } else {
               return business.call();
           }
   
           log.debug("<---- TxLcn start ---->");
           DTXLocalContext dtxLocalContext = DTXLocalContext.getOrNew();
           TxContext txContext;
           // ---------- 保证每个模块在一个 DTX 下只会有一个 TxContext ---------- //
           if (globalContext.hasTxContext()) {
               // 有事务上下文的获取父上下文
               txContext = globalContext.txContext();
               dtxLocalContext.setInGroup(true);
               log.debug("Unit[{}] used parent's TxContext[{}].", dtxInfo.getUnitId(), txContext.getGroupId());
           } else {
               // 没有的开启本地事务上下文
               txContext = globalContext.startTx();
           }
   
           // 本地事务调用
           if (Objects.nonNull(dtxLocalContext.getGroupId())) {
               dtxLocalContext.setDestroy(false);
           }
   
           dtxLocalContext.setUnitId(dtxInfo.getUnitId());
           dtxLocalContext.setGroupId(txContext.getGroupId());
           dtxLocalContext.setTransactionType(dtxInfo.getTransactionType());
   
           // 事务参数
           TxTransactionInfo info = new TxTransactionInfo();
           info.setBusinessCallback(business);
           info.setGroupId(txContext.getGroupId());
           info.setUnitId(dtxInfo.getUnitId());
           info.setPointMethod(dtxInfo.getBusinessMethod());
           info.setPropagation(dtxInfo.getTransactionPropagation());
           info.setTransactionInfo(dtxInfo.getTransactionInfo());
           info.setTransactionType(dtxInfo.getTransactionType());
           info.setTransactionStart(txContext.isDtxStart());
   
           //LCN 事务处理器
           try {
               // 重点: 
               return transactionServiceExecutor.transactionRunning(info);
           } finally {
               // 线程执行业务完毕清理本地数据
               if (dtxLocalContext.isDestroy()) {
                   // 通知事务执行完毕
                   synchronized (txContext.getLock()) {
                       txContext.getLock().notifyAll();
                   }
   
                   // TxContext 生命周期是？ 和事务组一样（不与具体模块相关的）
                   if (!dtxLocalContext.isInGroup()) {
                       globalContext.destroyTx();
                   }
   
                   DTXLocalContext.makeNeverAppeared();
                   TracingContext.tracing().destroy();
               }
               log.debug("<---- TxLcn end ---->");
           }
       }
   }
   
   ```

3. startTx()和 destroyTx()

   ```java
   package com.codingapi.txlcn.tc.core.context;
   
   /**
    * Description:
    * Date: 19-1-22 下午 6:17
    *
    * @author ujued
    * @see AttachmentCache
    * @see PrimaryKeysProvider
    */
   @Component
   @Slf4j
   public class DefaultGlobalContext implements TCGlobalContext {
   
       private final AttachmentCache attachmentCache;
   
       private final List<PrimaryKeysProvider> primaryKeysProviders;
   
       private final TxClientConfig clientConfig;
   
       @Override
       public TxContext startTx() {
           TxContext txContext = new TxContext();
           // 事务发起方判断
           txContext.setDtxStart(!TracingContext.tracing().hasGroup());
           if (txContext.isDtxStart()) {
               TracingContext.tracing().beginTransactionGroup();
           }
           txContext.setGroupId(TracingContext.tracing().groupId());
           String txContextKey = txContext.getGroupId() + ".dtx";
           attachmentCache.attach(txContextKey, txContext);
           log.debug("Start TxContext[{}]", txContext.getGroupId());
           return txContext;
       }
   
       /**
        * 在用户业务前生成，业务后销毁
        *
        * @param groupId groupId
        */
       @Override
       public void destroyTx(String groupId) {
           attachmentCache.remove(groupId + ".dtx");
           log.debug("Destroy TxContext[{}]", groupId);
       }
   }
   
   ```

4. transactionRunning()

   ```java
   /*
    * Copyright 2017-2019 CodingApi .
    *
    * Licensed under the Apache License, Version 2.0 (the "License");
    * you may not use this file except in compliance with the License.
    * You may obtain a copy of the License at
    *
    *      http://www.apache.org/licenses/LICENSE-2.0
    *
    * Unless required by applicable law or agreed to in writing, software
    * distributed under the License is distributed on an "AS IS" BASIS,
    * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    * See the License for the specific language governing permissions and
    * limitations under the License.
    */
   package com.codingapi.txlcn.tc.core;
   
   
   import com.codingapi.txlcn.common.exception.TransactionException;
   import com.codingapi.txlcn.common.util.Transactions;
   import com.codingapi.txlcn.logger.TxLogger;
   import com.codingapi.txlcn.tc.core.propagation.DTXPropagationResolver;
   import com.codingapi.txlcn.tc.support.TxLcnBeanHelper;
   import com.codingapi.txlcn.tc.core.context.TCGlobalContext;
   import lombok.extern.slf4j.Slf4j;
   import org.springframework.beans.factory.annotation.Autowired;
   import org.springframework.stereotype.Component;
   
   import java.util.Set;
   
   /**
    * LCN 分布式事务业务执行器
    * Created by lorne on 2017/6/8.
    */
   @Component
   @Slf4j
   public class DTXServiceExecutor {
   
       private static final TxLogger txLogger = TxLogger.newLogger(DTXServiceExecutor.class);
   
       private final TCGlobalContext globalContext;
   
       private final TxLcnBeanHelper txLcnBeanHelper;
   
       private final DTXPropagationResolver propagationResolver;
   
       @Autowired
       public DTXServiceExecutor(TxLcnBeanHelper txLcnBeanHelper, TCGlobalContext globalContext,
                                 DTXPropagationResolver propagationResolver) {
           this.txLcnBeanHelper = txLcnBeanHelper;
           this.globalContext = globalContext;
           this.propagationResolver = propagationResolver;
       }
   
       /**
        * 事务业务执行
        *
        * @param info info
        * @return Object
        * @throws Throwable Throwable
        */
       public Object transactionRunning(TxTransactionInfo info) throws Throwable {
   
           // 1. 获取事务类型
           String transactionType = info.getTransactionType();
   
           // 2. 获取事务传播状态
           DTXPropagationState propagationState = propagationResolver.resolvePropagationState(info);
   
           // 2.1 如果不参与分布式事务立即终止
           if (propagationState.isIgnored()) {
               return info.getBusinessCallback().call();
           }
   
           // 3. 获取本地分布式事务控制器
           DTXLocalControl dtxLocalControl = txLcnBeanHelper.loadDTXLocalControl(transactionType, propagationState);
   
           // 4. 织入事务操作
           try {
               // 4.1 记录事务类型到事务上下文
               Set<String> transactionTypeSet = globalContext.txContext(info.getGroupId()).getTransactionTypes();
               transactionTypeSet.add(transactionType);
   
               dtxLocalControl.preBusinessCode(info);
   
               // 4.2 业务执行前
               txLogger.txTrace(
                   info.getGroupId(), info.getUnitId(), "pre business code, unit type: {}", transactionType);
   
               // 4.3 执行业务
               // 事务发起者会走 XXStartingTransaction, 事务参与者会走 XXRunningTransaction
               Object result = dtxLocalControl.doBusinessCode(info);
   
               // 4.4 业务执行成功
               txLogger.txTrace(info.getGroupId(), info.getUnitId(), "business success");
               dtxLocalControl.onBusinessCodeSuccess(info, result);
               return result;
           } catch (TransactionException e) {
               txLogger.error(info.getGroupId(), info.getUnitId(), "before business code error");
               throw e;
           } catch (Throwable e) {
               // 4.5 业务执行失败
               txLogger.error(info.getGroupId(), info.getUnitId(), Transactions.TAG_TRANSACTION,
                              "business code error");
               dtxLocalControl.onBusinessCodeError(info, e);
               throw e;
           } finally {
               // 4.6 业务执行完毕
               dtxLocalControl.postBusinessCode(info);
           }
       }
   
   
   }
   
   ```

### TCC 模式

- **T**ry: 尝试执行业务

- **C**onfirm: 确认执行业务

- **C**ancel: 取消执行业务

#### 流程图

![image-20210317163425031](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210317163425.png)

在支付系统中调用订单系统，保证支付系统和订单系统的分布式事务。

两个系统都执行成功才会提交提交完整事务，执行 confirmXX 方法。

只要有一方执行失败，参与者都会执行 cancelXX 方法

#### 代码

##### TX-Manager

[单点配置](#TX-Manager) 和 [集群配置](#TX-Manager 集群配置) 都与 LCN 模式中 TX-Manager 的配置方式相同

##### ResourceManager

[单点配置](#ResourceManager) 和 [集群配置](#TX-Manager 集群配置) 都与 LCN 模式中 ResourceManager 的配置方式相同

只有第 6 步中业务代码需要修改

1. 首先把 `LcnTransaction` 注解修改为 `@TccTransaction` 注解
2. 然后添加 confirmXX 方法和 cancelXX 方法

- ServiceA

  ```java
  @Service
  public class ServiceA {
      
      @Autowired
      private ValueDao valueDao;
      
      //远程 B 模块业务
      @Autowired
      private ServiceB serviceB;
      
      //分布式事务注解
      @TccTransaction 
      //本地事务注解
      @Transactional(rollbackFor = Exception.class)
      public String execute(String value) throws BusinessException {
          // step1. 调用远程服务
          String result = serviceB.rpc(value);
          // step2. 本地事务操作。
          valueDao.save(value);
          valueDao.saveBackup(value);
          return result + " > " + "ok-A";
      }
      /**
       * 在需要保证分布式事务的方法名上添加 confirm 前缀。
       * 如果 execute 方法正常执行结束，则执行该方法
       */
      public String confirmExecute(String value){
          System.out.println("执行成功");
          return "执行成功";
      }
      /**
       * 在需要保证分布式事务的方法名上添加 cancel 前缀。
       * 如果 execute 方法执行过程中发生异常，则执行该方法
       * 需要手动编写 execute 中执行的 sql 的反 sql 来进行回滚
       */
      public String cancelExecute(String value){
          // 要根据 execute()方法中执行的本地 sql 编写反 sql,来手动进行更新
          valueDao.delete(value);
          return "执行失败";
      }
  }
  ```

- ServiceB

  ```java
  @Service
  public class ServiceB {
  
      @Autowired
      private ValueDao valueDao;
  
      //分布式事务注解
      @TccTransaction
      //本地事务注解
      @Transactional
      public String rpc(String value) throws BusinessException {
          valueDao.save(value);
          valueDao.saveBackup(value);
          return "ok-B";
      }
  
      public String confirmRpc(String value){
          System.out.println("执行成功");
          return "执行成功";
      }
  
      public String cancelRpc(String value){
          // 要根据 execute()方法中执行的本地 sql 编写反 sql,来手动进行更新
          valueDao.delete(value);
          return "执行失败";
      }
  
  }
  ```

#### 补充说明

1. TCC 模式适合分布式业务简单的场景，因为对每个分布式业务的方法，都要添加相应的 confirm 和 cancel 方法，会写更多的代码。
2. 该种方式(TCC+MySQL)通常不在生产环境中使用。
   - 通常带事务的中间件用 lcn, 比如 MySQL.
   - 其他没有事务的中间件用 tcc, 例如 redis.

3. 在业务代码中可以 insert/update/delete 之后，将该对象存储到 Map 中，然后在 cancel 中获取该对象来执行反 sql

   ```java
   @Service
   public class ServiceB {
   
       @Autowired
       private ValueDao valueDao;
   	// 创建一个 Map 来存储对象, key 使用机器名+方法名+输入参数等
       private static Map<String, Object> objs = new HashMap<>();
       
       //分布式事务注解
       @TccTransaction
       //本地事务注解
       @Transactional
       public String rpc(String value) throws BusinessException {
           Value v = valueDao.save(value);
           objs.put(hostname + "_rpc_" + value, v);
           valueDao.saveBackup(value);
           return "ok-B";
       }
   
       public String confirmRpc(String value){
           objs.remove(hostname + "_rpc_" + value);
           System.out.println("执行成功");
           return "执行成功";
       }
   
       public String cancelRpc(String value){
           Value v = (Value)objs.get(hostname + "_rpc_" + value);
           // 要根据 execute()方法中执行的本地 sql 编写反 sql,来手动进行更新
           valueDao.delete(v.getId);
           objs.remove(hostname + "_rpc_" + value);
           return "执行失败";
       }
   }
   ```

### TCC+MySQL+Redis 模式

LCN 模式只能应用于本地存在连接对象且可通过连接对象控制事务的模块，例如 MySQL 等，对于 Redis 等没有本地事务控制的中间件是无效的。所以如果需要保证 MySQL 和 Redis 的双写一致性，可以用这种方式

如果需要保证 redis 和 MySQL 的双写一致性，只需要在 try 方法中编写代码即可，然后在 cancel 方法中编写 redis 和 MySQL 的反操作/sql

#### 源码

```java
package com.codingapi.txlcn.tc.core.transaction.tcc.control;

/**
 * Description:
 * Date: 2018/12/13
 *
 * @author 侯存路
 */
@Component
@Slf4j
public class TccTransactionCleanService implements TransactionCleanService {

    private final ApplicationContext applicationContext;

    private final TMReporter tmReporter;

    private final TCGlobalContext globalContext;

    @Autowired
    public TccTransactionCleanService(ApplicationContext applicationContext,
                                      TMReporter tmReporter, TCGlobalContext globalContext) {
        this.applicationContext = applicationContext;
        this.tmReporter = tmReporter;
        this.globalContext = globalContext;
    }

    @Override
    public void clear(String groupId, int state, String unitId, String unitType) throws TransactionClearException {
        Method exeMethod;
        boolean shouldDestroy = !TracingContext.tracing().hasGroup();
        try {
            TccTransactionInfo tccInfo = globalContext.tccTransactionInfo(unitId, null);
            Object object = applicationContext.getBean(tccInfo.getExecuteClass());
            // 将要移除。
            if (Objects.isNull(DTXLocalContext.cur())) {
                DTXLocalContext.getOrNew().setJustNow(true);
            }
            if (shouldDestroy) {
                TracingContext.init(Maps.of(TracingConstants.GROUP_ID, groupId, TracingConstants.APP_MAP, "{}"));
            }
            DTXLocalContext.getOrNew().setGroupId(groupId);
            DTXLocalContext.cur().setUnitId(unitId);
            exeMethod = tccInfo.getExecuteClass().getMethod(
                state == 1 ? tccInfo.getConfirmMethod() : tccInfo.getCancelMethod(),
                tccInfo.getMethodTypeParameter());
            try {
                exeMethod.invoke(object, tccInfo.getMethodParameter());
                log.debug("User confirm/cancel logic over.");
            } catch (Throwable e) {
                log.error("Tcc clean error.", e);
                tmReporter.reportTccCleanException(groupId, unitId, state);
            }
        } catch (Throwable e) {
            throw new TransactionClearException(e.getMessage());
        } finally {
            if (DTXLocalContext.cur().isJustNow()) {
                DTXLocalContext.makeNeverAppeared();
            }
            if (shouldDestroy) {
                TracingContext.tracing().destroy();
            }
        }
    }
}
```

### LCN+TCC 混合使用

LCN 和 TCC 两种模式也可以混合使用，例如在 A 服务中使用 LCN 模式，在 B 服务中使用 TCC 模式。只需要在 A 服务中使用 `@LcnTransaction` 注解，在 B 服务中使用 `@TccTransaction` 注解即可

### LCN 模式和 TCC 模式对比

#### LCN

**原理介绍**: LCN 模式是通过代理 Connection 的方式实现对本地事务的操作，然后在由 TxManager 统一协调控制事务。当本地事务提交回滚或者关闭连接时将会执行假操作，该代理的连接将由 LCN 连接池管理。

**模式特点**

- 该模式对代码的嵌入性为低。
- 该模式仅限于本地存在连接对象且可通过连接对象控制事务的模块。
- 该模式下的事务提交与回滚是由本地事务方控制，对于数据一致性上有较高的保障。
- 该模式缺陷在于代理的连接需要随事务发起方一共释放连接，增加了连接占用的时间。

#### TCC

**原理介绍**: TCC 事务机制相对于传统事务机制（X/Open XA Two-Phase-Commit），其特征在于它不依赖资源管理器(RM)对 XA 的支持，而是通过对（由业务系统提供的）业务逻辑的调度来实现分布式事务。主要由三步操作，Try: 尝试执行业务、Confirm:确认执行业务、Cancel: 取消执行业务。

**模式特点**

- 该模式对代码的嵌入性高，要求每个业务需要写三种步骤的操作。
- 该模式对有无本地事务控制都可以支持使用面广。
- 数据一致性控制几乎完全由开发者控制，对业务开发难度要求高。

## Seata

[Seata 官网](http://seata.io/zh-cn/)

注意这里的 TC 和 TM 的概念与 tx-lcn 中的概念有区别

- TC: Transaction Coordinator, 事务协调者

- TM: Transaction Manager, 事务管理者，也叫事务发起者。

  > 注意：在 seata 中 TM 和 lcn 中 TM 的功能不同。在 seata 中的 TM 也是 RM 的一种, TC 类似于 lcn 中的 TM

- RM: Resource Manager, 资源管理者

### AT 模式

**只适用于基于本地 ACID 事务的关系型数据库.**

#### 整体机制

两阶段提交协议的演变：

- 一阶段：业务数据和回滚日志记录在同一个本地事务中提交，释放本地锁和连接资源。
- 二阶段：
  - 提交异步化，非常快速地完成。
  - 回滚通过一阶段的回滚日志进行反向补偿。

#### 写隔离

引入了**全局锁**, 只有持有**全局锁**, 才能进行提交，提交后释放**全局锁**. 如果超时没获取到**全局锁**就会回滚

**正常流程(二阶段是全局提交)**

![at 写](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210318155522.png)

1. 首先事务 1 先执行，获取本地锁，执行 SQL, 然后获取**全局锁**, 执行本地提交，最后释放本地锁。
2. 然后事务 2 开始执行，获取本地锁，执行 SQL
3. 在事务 1 全局提交前，事务 2 一直尝试获取**全局锁**
4. 事务 1 在二阶段全局提交后释放**全局锁**, 事务 2 拿到**全局锁**, 开始进行本地提交，释放本地锁

**回滚流程(二阶段是全局回滚)**

如果在事务 2 尝试获取全局锁期间，事务 1 的二阶段不是全局提交而是全局回滚，则会出现下方回滚流程

![image-20210318160650856](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210318162556.png)

1. 首先事务 1 先执行，获取本地锁，执行 SQL, 然后获取全局锁，执行本地提交，最后释放本地锁
2. 然后事务 2 开始执行，获取本地锁，执行 SQL
3. 在事务 2 尝试获取**全局锁**的时候，事务 1 收到有服务返回 no, 所以需要执行全局回滚，此时事务 1 需要获取本地锁，但是此时本地锁被事务 2 持有，全局锁被事务 1 持有，所以会出现死锁状态。
4. 等事务 2 获取**全局锁**超时后，执行本地回滚并释放本地锁
5. 事务 1 获取到本地锁，开始执行本地回滚。至此全局回滚结束

因为在事务 1 执行结束前，事务 1 一直持有**全局锁**, 所以事务 2 不能进行本地提交，所以不会出现**脏读**的问题

#### 读隔离

在数据库本地事务隔离级别 **读已提交（Read Committed）** 或以上的基础上，Seata（AT 模式）的默认全局隔离级别是 **读未提交（Read Uncommitted）**。

如果应用在特定场景下，必需要求全局的 **读已提交**，目前 Seata 的方式是通过 SELECT FOR UPDATE 语句的代理。

![Read Isolation: SELECT FOR UPDATE](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210318173034.png)

SELECT FOR UPDATE 语句的执行会申请 **全局锁**，如果 **全局锁** 被其他事务持有，则释放本地锁（回滚 SELECT FOR UPDATE 语句的本地执行）并重试。这个过程中，查询是被 block 住的，直到 **全局锁** 拿到，即读取的相关数据是 **已提交** 的，才返回。

出于总体性能上的考虑，Seata 目前的方案并没有对所有 SELECT 语句都进行代理，仅针对 FOR UPDATE 的 SELECT 语句。

#### 项目搭建

相关的配置脚本，github 位置 https://github.com/seata/seata/tree/develop/script

##### 搭建 TC

1. 下载 seata-server

   http://seata.io/zh-cn/blog/download.html

2. 修改 registry.conf 配置

   ```json
   # 注册中心配置
   registry {
     # file、nacos、eureka、redis、zk、consul、etcd3、sofa
     # 要让 seata 注册到 eureka 上，所以修改成 eureka
     type = "eureka"
   
     # 上方 type 设置为了 eureka，所以修改 eureka 的配置，设置成 eureka-server 的地址
     eureka {
       serviceUrl = "http://localhost:7900/eureka"
       application = "eureka-server"
       weight = "1"
     }
   }
   # 配置中心的配置
   config {
     # file、nacos、apollo、zk、consul、etcd3
     # 如果 type 类型是 file，则从本地 file.conf 中获取配置参数
     type = "file"
     # 因为 config.type=file，所以此处指定配置文件名称
     file {
       name = "file.conf"
     }
   }
   ```

3. 修改 file.conf 文件

   ```json
   service {
     # transaction server group mapping
     # 事务组的名称，相当于 spring.application.name
     vgroup_mapping.my_tx_group = "seata-server"
     
     disableGlobalTransaction = true
   }
   
   ## transaction log store, only used in seata-server
   store {
     ## store mode: file、db、redis
     # 存储类型
     mode = "db"
   
     ## database store property
     # 因为 store.mode 设置为了 db，所以修改 db 的配置
     db {
       ## the implement of javax.sql.DataSource, such as DruidDataSource(druid)/BasicDataSource(dbcp)/HikariDataSource(hikari) etc.
       datasource = "druid"
       ## mysql/oracle/postgresql/h2/oceanbase etc.
       dbType = "mysql"
       driverClassName = "com.mysql.cj.jdbc.Driver"
       url = "jdbc:mysql://127.0.0.1:3306/seata-server?useUnicode=true&useSSL=false&characterEncoding=utf8&serverTimezone=Asia/Shanghai"
       user = "root"
       password = "root"
       minConn = 5
       maxConn = 100
       globalTable = "global_table"
       branchTable = "branch_table"
       lockTable = "lock_table"
       queryLimit = 100
       maxWait = 5000
     }
   }
   ```

4. 创建数据表

   因为使用的是 db 模式，所以需要创建数据库表：https://github.com/seata/seata/blob/develop/script/server/db/mysql.sql

   ```sql
   -- -------------------------------- The script used when storeMode is 'db' --------------------------------
   -- the table to store GlobalSession data
   CREATE TABLE IF NOT EXISTS `global_table`
   (
       `xid`                       VARCHAR(128) NOT NULL,
       `transaction_id`            BIGINT,
       `status`                    TINYINT      NOT NULL,
       `application_id`            VARCHAR(32),
       `transaction_service_group` VARCHAR(32),
       `transaction_name`          VARCHAR(128),
       `timeout`                   INT,
       `begin_time`                BIGINT,
       `application_data`          VARCHAR(2000),
       `gmt_create`                DATETIME,
       `gmt_modified`              DATETIME,
       PRIMARY KEY (`xid`),
       KEY `idx_gmt_modified_status` (`gmt_modified`, `status`),
       KEY `idx_transaction_id` (`transaction_id`)
   ) ENGINE = InnoDB
     DEFAULT CHARSET = utf8;
   
   -- the table to store BranchSession data
   CREATE TABLE IF NOT EXISTS `branch_table`
   (
       `branch_id`         BIGINT       NOT NULL,
       `xid`               VARCHAR(128) NOT NULL,
       `transaction_id`    BIGINT,
       `resource_group_id` VARCHAR(32),
       `resource_id`       VARCHAR(256),
       `branch_type`       VARCHAR(8),
       `status`            TINYINT,
       `client_id`         VARCHAR(64),
       `application_data`  VARCHAR(2000),
       `gmt_create`        DATETIME(6),
       `gmt_modified`      DATETIME(6),
       PRIMARY KEY (`branch_id`),
       KEY `idx_xid` (`xid`)
   ) ENGINE = InnoDB
     DEFAULT CHARSET = utf8;
   
   -- the table to store lock data
   CREATE TABLE IF NOT EXISTS `lock_table`
   (
       `row_key`        VARCHAR(128) NOT NULL,
       `xid`            VARCHAR(96),
       `transaction_id` BIGINT,
       `branch_id`      BIGINT       NOT NULL,
       `resource_id`    VARCHAR(256),
       `table_name`     VARCHAR(32),
       `pk`             VARCHAR(36),
       `gmt_create`     DATETIME,
       `gmt_modified`   DATETIME,
       PRIMARY KEY (`row_key`),
       KEY `idx_branch_id` (`branch_id`)
   ) ENGINE = InnoDB
     DEFAULT CHARSET = utf8;
   ```

5. 启动 Eureka-Server

6. 启动 seata-server

   ```shell
   ./bin/seata-server.sh
   ```

##### 搭建 TM

1. 引入依赖

   ```xml
   <dependency>
       <groupId>com.alibaba.cloud</groupId>
       <artifactId>spring-cloud-alibaba-seata</artifactId>
       <version>2.2.0.RELEASE</version>
   </dependency>
   ```

2. 添加配置

   ```yaml
   spring:
     cloud:
       alibaba:
         seata:
           # 对应 TC 的配置文件 file.conf 中的 service.vgroup_mapping.my_tx_group
           tx-service-group: my_tx_group
   ```

3. 根据业务场景创建数据库和 entity，mapper，dao

   > 此处创建三个项目：seata-one，seata-two，seata-three
   >
   > 三个数据库：seata-rm-one, seata-rm-two, seata-rm-three
   >
   > 三个数据表，分别在对应的数据库里：tbl_one, tbl_two, tbl_three

   ![image-20210323102644051](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210323102644.png)

4. 在每个 TM 的数据库中都要创建 seata 用的 undo_log 数据表

   ```sql
   -- 注意此处 0.3.0+ 增加唯一索引 ux_undo_log
   CREATE TABLE `undo_log` (
       `id` bigint(20) NOT NULL AUTO_INCREMENT,
       `branch_id` bigint(20) NOT NULL,
       `xid` varchar(100) NOT NULL,
       `context` varchar(128) NOT NULL,
       `rollback_info` longblob NOT NULL,
       `log_status` int(11) NOT NULL,
       `log_created` datetime NOT NULL,
       `log_modified` datetime NOT NULL,
       `ext` varchar(100) DEFAULT NULL,
       PRIMARY KEY (`id`),
       UNIQUE KEY `ux_undo_log` (`xid`,`branch_id`)
   ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
   ```

5. 在事务发起方的方法上添加 `@GlobalTransactional` 注解，即可

   ```java
   /**
    * 在事务发起方上添加 GlobalTransactional 注解即可
    */
   @GlobalTransactional(rollbackFor = Exception.class)
   public String rm1() {
       TblOne o = new TblOne();
       o.setId(1);
       o.setVal("rm1");
       tblOneDAO.insert(o);
   	// 调用 seata-two 和 seata-three 服务
       restTemplate.postForObject("http://seata-two/rm-two", null, String.class);
       restTemplate.postForObject("http://seata-three/rm-three", null, String.class);
   	// System.out.println(1/0);
       return "rm1 success";
   }
   ```



### TCC 模式

#### 流程

![image-20210318210431069](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210318210431.png)

#### TCC 的问题

##### 幂等

RM 在执行完 confirm/cancel 的时候，会通知 TC, 如果 TC 没有收到该通知，就会再次通知 RM 执行 confirm/cancel, 就会出现**多次执行 confirm/cancel 的情况**

##### 空回滚

RM 向 TC 注册完分支事务后，该事务已经落库，但是由于网络抖动等原因，TC 检测到超时后，通知 RM 执行了 cancel 方法，出现还没有执行 try 方法，就执行了 cancel 中的回滚方法，从而发生异常

##### 资源悬挂

在空回滚的基础上，TC 检测超时后，已经通知了所有 RM 执行了 cancel 方法，之后发起方对参与方的 Try 才开始执行，由于此时分布式事务已经结束，执行 Try 方法使用的锁资源等无法在被释放，从而造成资源悬挂

**无论是幂等，空回滚，还是资源悬挂吗，都可以通过使用事务状态控制表来解决**

> 加 事务状态控制表(全局事务 Id, 分支事务 Id, 分支事务状态), 全局事务 Id 和分支事务 Id 构成表的联合主键，全局事务状态有 3 种: INIT(I), CONFIRMED(C), ROLLBACKED(R), 在执行 try 的时候将事务标记为 I, 在执行 confirm/cancel 的时候将事务标记为 C/R.

#### 项目搭建

http://seata.io/zh-cn/blog/integrate-seata-tcc-mode-with-spring-cloud.html

##### 搭建 TC

和 AT 模式的 [搭建 TC](#搭建 TC) 相同

##### 搭建 TM

1. 引入依赖

   ```xml
   <dependency>
       <groupId>com.alibaba.cloud</groupId>
       <artifactId>spring-cloud-alibaba-seata</artifactId>
       <version>2.2.0.RELEASE</version>
   </dependency>
   ```

2. 添加配置

   ```yaml
   spring:
     cloud:
       alibaba:
         seata:
           # 对应 TC 的配置文件 file.conf 中的 service.vgroup_mapping.my_tx_group
           tx-service-group: my_tx_group
   ```

3. 业务接口

   ```java
   package com.example.one.service;
   
   import com.example.one.entity.TblOne;
   import io.seata.rm.tcc.api.BusinessActionContext;
   import io.seata.rm.tcc.api.BusinessActionContextParameter;
   import io.seata.rm.tcc.api.LocalTCC;
   import io.seata.rm.tcc.api.TwoPhaseBusinessAction;
   
   /**
    * LocalTCC 一定要定义在接口上
    */
   @LocalTCC
   public interface RmOneTccService {
   
       /**
        * 定义两阶段提交
        * name = 该 tcc 的 bean 名称，全局唯一
        * commitMethod = 二阶段的确认方法
        * rollbackMethod = 二阶段的取消方法
        * BusinessActionContextParameter 注解 可以将参数传递到第二阶段中
        */
       @TwoPhaseBusinessAction(name = "rm1TccAction", commitMethod = "rm1TccConfirm", rollbackMethod = "rm1TccCancel")
       String rm1Tcc(@BusinessActionContextParameter(paramName = "param") TblOne o);
   	/**
   	 * 确认方法，方法名要与 commitMethod 方法指定的一致
   	 * context 可以传递 try 方法中使用 BusinessActionContextParameter 注解指定的方法参数
   	 */
       String rm1TccConfirm(BusinessActionContext context);
   
       String rm1TccCancel(BusinessActionContext context);
   }
   ```

4. 业务实现类

   ```java
   package com.example.one.service.impl;
   
   import com.example.one.dao.TblOneDAO;
   import com.example.one.entity.TblOne;
   import com.example.one.service.RmOneTccService;
   import io.seata.rm.tcc.api.BusinessActionContext;
   import org.springframework.beans.factory.annotation.Autowired;
   import org.springframework.stereotype.Service;
   import org.springframework.transaction.annotation.Transactional;
   import org.springframework.web.client.RestTemplate;
   
   @Service("rmOneTccService")
   public class RmOneTccServiceImpl implements RmOneTccService {
   
       @Autowired
       private TblOneDAO tblOneDAO;
   
       @Autowired
       private RestTemplate restTemplate;
   
       /**
        * 根据实际业务场景选择实际业务执行逻辑或资源预留逻辑
        * 结合 Spring 的 Transactional 注解，在二阶段的 cancel 方法中只需对非关系型数据库进行手动回滚即可
        */
       @Override
       @Transactional(rollbackFor = Exception.class)
       public String rm1Tcc(TblOne o) {
           int id = tblOneDAO.insert(o);
           o.setId(id);
           // TODO 操作中间件，非关系型数据库
           restTemplate.postForObject("http://seata-two/rm-two", null, String.class);
           restTemplate.postForObject("http://seata-three/rm-three", null, String.class);
           //        System.out.println(1/0);
           return "rm1 success";
       }
   
       /**
        * 若一阶段采用资源预留，在二阶段确认时要提交预留的资源
        */
       @Override
       public String rm1TccConfirm(BusinessActionContext context) {
   
           return null;
       }
   
       @Override
       public String rm1TccCancel(BusinessActionContext context) {
           // 从 context 中获取 try 方法中的参数
           Object param = context.getActionContext("param");
           // TODO 操作中间件，非关系型数据库的回滚操作
           return null;
       }
   }
   ```

### 源码

SeataAutoConfiguration

## 2PC vs TCC vs 消息队列

|        | 2PC  | TCC      | 消息队列 |
| ------ | ---- | -------- | -------- |
| 一致性 | 强   | 最终一致 | 最终一致 |
| 吞吐量 | 低   | 中       | 高       |
| 复杂度 | 简单 | 复杂     | 中       |

使用 2PC 和 TCC 需要调用所有事务参与者后才返回，使用消息队列，只需要调用一次消息队列即可返回，所以使用消息队列的吞吐量更高

## 可靠消息

### 最终一致性解决方案

![image-20210323184644977](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210323184645.png)



如果 1-1 发送完待确认消息，1-2 将其入库后，长时间没有收到支付服务的消息，就会在数据库中长时间包含待确认状态的消息，所以支付服务提供一个查询接口，可靠消息服务使用定时任务定时回调该接口去查询业务状态，从而将待确认消息修改为已确认/已取消状态。这样还可以将支付服务和可靠消息服务间的分布式事务进行解耦。

如果只依靠 1-6 向消息队列发送一次消息，可能会发送失败，所以可靠消息服务可以使用定时任务，定时将已确认状态的消息发送到消息队列，并将其修改为已发送状态。

依靠 2-4 订单服务通知可靠消息服务修改消息状态为已完成，也会造成订单服务和可靠消息服务的分布式事务耦合，所以订单服务提供回调接口，可靠消息服务使用定时任务来获取订单状态，进而修改消息状态，可以将订单服务和可靠消息服务间分布式事务进行解耦

**消息列表+事件表方案与可靠消息服务的对比**

消息列表+事件表的方案，在每个微服务的数据库中都包含了一张事件表

而可靠消息服务将事务的控制抽离成了一个单独的服务，该服务中只需要有一张事件表即可，并可以对外提供对多个不同服务间的事务控制

### 最大努力通知方案

应用场景：第三方系统调用

1. 尽最大努力通知调用方
2. 提供接口给调用方调用

例如支付宝支付回调，25 小时内回调 8 次。

### 事务消息方案

![image-20210323213351509](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210323213353.png)



RocketMQ 的回查机制：RocketMQ 本身包含一个定时任务，会定时对 half 消息进行扫描，然后回调相应的服务接口，如果服务返回已经成功，则将该 half 消息提交，否则，将其删除。

### 代码

#### RocketMQ 安装

1. 下载 RocketMQ

   https://rocketmq.apache.org/

2. 启动 RocketMQ 和 RocketMQ-Externals

   ```shell
   # 启动 nameserver
   sh ./bin/mqnamesrv
   # 启动 broker
   sh bin/mqbroker -n 127.0.0.1:9876 autoCreateTopicEnable=true
   ```

   JDK11 需要修改 RocketMQ 的启动文件：https://www.zhuyc.vip/archives/2020010716144722086

3. 下载启动控制台 RocketMQ-Console-NG

   https://github.com/apache/rocketmq-externals/tree/master/rocketmq-console

   ```shell
   # 拉取镜像
   docker pull apacherocketmq/rocketmq-console:2.0.0
   # 启动容器
   docker run -e "JAVA_OPTS=-Drocketmq.namesrv.addr=172.17.0.1:9876 -Dcom.rocketmq.sendMessageWithVIPChannel=false" -p 8080:8080 --name rocketmq-console -d apacherocketmq/rocketmq-console:2.0.0
   ```

#### 事务发起方

1. 添加 RocketMQ 依赖

   ```xml
   <!-- RocketMQ -->
   <dependency>
       <groupId>org.apache.rocketmq</groupId>
       <artifactId>rocketmq-spring-boot-starter</artifactId>
       <version>2.2.0</version>
   </dependency>
   ```


2. 配置事务监听器

   ```java
   package com.example.producer.listener;
   
   import com.alibaba.fastjson.JSONObject;
   import com.example.producer.dao.TransactionLogDAO;
   import com.example.producer.entity.TblOrder;
   import com.example.producer.service.TblOrderService;
   import lombok.extern.slf4j.Slf4j;
   import org.apache.rocketmq.client.producer.LocalTransactionState;
   import org.apache.rocketmq.client.producer.TransactionListener;
   import org.apache.rocketmq.common.message.Message;
   import org.apache.rocketmq.common.message.MessageExt;
   import org.springframework.beans.factory.annotation.Autowired;
   import org.springframework.stereotype.Component;
   
   /**
    * 事务监听器
    * 发送 half msg 返回 send ok 后，执行 executeLocalTransaction 方法，即执行本地事务
    * RocketMQ 定时回查时，执行 checkLocalTransaction 方法, 对
    *
    * @author wangshuo
    * @date 2021/03/24
    */
   @Component
   @Slf4j
   public class OrderTransactionListener implements TransactionListener {
   
       /**
        * 本地业务服务
        */
       @Autowired
       private TblOrderService tblOrderService;
   
       /**
        * 事务日志表，便于回查
        */
       @Autowired
       private TransactionLogDAO transactionLogDAO;
   
       /**
        * 发送 half msg 返回 send ok 后执行该方法
        */
       @Override
       public LocalTransactionState executeLocalTransaction(Message message, Object o) {
           log.info("开始执行本地事务");
           LocalTransactionState state;
           try {
               // 本地业务
               String body = new String(message.getBody());
               TblOrder order = JSONObject.parseObject(body, TblOrder.class);
               // 在创建订单的时候，同时向事务日志表中插入一条记录，便于回查时使用
               tblOrderService.createOrder(order, message.getTransactionId());
               // 只有返回 commit 后，消息才能被消费者消费
               state = LocalTransactionState.COMMIT_MESSAGE;
               log.info("本地事务已提交. {}", message.getTransactionId());
           } catch (Exception e) {
               log.info("执行本地事务失败.", e);
               state = LocalTransactionState.ROLLBACK_MESSAGE;
           }
           return state;
       }
   
       /**
        * 回查 走的方法
        */
       @Override
       public LocalTransactionState checkLocalTransaction(MessageExt messageExt) {
           // TODO 回查多次失败 人工补偿。给管理员发邮件
           log.info("开始回查本地事务状态. {}", messageExt.getTransactionId());
           LocalTransactionState state;
           String transactionId = messageExt.getTransactionId();
           if (transactionLogDAO.selectCount(transactionId) > 0) {
               state = LocalTransactionState.COMMIT_MESSAGE;
           } else {
               // 查到 UNKNOW 后，过一会还会再来回查
               state = LocalTransactionState.UNKNOW;
           }
           log.info("结束本地事务状态查询: {}", state);
           return state;
       }
   }
   ```

3. 配置事务生产者

   ```java
   package com.example.producer.producer;
   
   import com.example.producer.listener.OrderTransactionListener;
   import lombok.extern.slf4j.Slf4j;
   import org.apache.rocketmq.client.exception.MQClientException;
   import org.apache.rocketmq.client.producer.TransactionMQProducer;
   import org.apache.rocketmq.client.producer.TransactionSendResult;
   import org.apache.rocketmq.common.message.Message;
   import org.springframework.beans.factory.annotation.Autowired;
   import org.springframework.stereotype.Component;
   
   import javax.annotation.PostConstruct;
   import javax.annotation.PreDestroy;
   import java.util.concurrent.ArrayBlockingQueue;
   import java.util.concurrent.ThreadPoolExecutor;
   import java.util.concurrent.TimeUnit;
   
   /**
    * 对外提供 sendMessage 方法，以供业务调用，向 RocketMQ 发送 half message
    *
    * @author wangshuo
    * @date 2021/03/23
    */
   @Slf4j
   @Component
   public class OrderTransactionProducer {
       /**
        * 事务消息生产者
        */
       private TransactionMQProducer producer;
       /**
        * 用于执行本地事务和事务状态回查的监听器
        */
       @Autowired
       private OrderTransactionListener orderTransactionListener;
       /**
        * 执行任务的线程池
        */
       ThreadPoolExecutor executor = new ThreadPoolExecutor(
           5, 5, 60,
           TimeUnit.SECONDS, new ArrayBlockingQueue<>(50));
   
       @PostConstruct
       public void init() {
           String producerGroup = "order_trans_group";
           String namesrvAddr = "127.0.0.1:9876";
           producer = new TransactionMQProducer(producerGroup);
           producer.setNamesrvAddr(namesrvAddr);
           producer.setSendMsgTimeout(Integer.MAX_VALUE);
           producer.setExecutorService(executor);
           producer.setTransactionListener(orderTransactionListener);
           try {
               producer.start();
           } catch (MQClientException e) {
               log.error("producer 启动失败.", e);
           }
       }
   
       @PreDestroy
       public void stop() {
           if (producer != null) {
               producer.shutdown();
           }
       }
   
       /**
        * 对外提供方法，发送 half message
        */
       public TransactionSendResult sendMessage(String topic, String data) throws MQClientException {
           log.info("发送 half message");
           Message message = new Message(topic, data.getBytes());
           TransactionSendResult result = this.producer.sendMessageInTransaction(message, null);
           log.info("half message 发送成功");
           return result;
       }
   }
   ```

4. 订单服务

   ```java
   package com.example.producer.service.impl;
   
   import com.alibaba.fastjson.JSONObject;
   import com.example.producer.dao.TblOrderDAO;
   import com.example.producer.dao.TransactionLogDAO;
   import com.example.producer.entity.TblOrder;
   import com.example.producer.entity.TransactionLog;
   import com.example.producer.producer.OrderTransactionProducer;
   import com.example.producer.service.TblOrderService;
   import lombok.extern.slf4j.Slf4j;
   import org.apache.rocketmq.client.exception.MQClientException;
   import org.springframework.beans.factory.annotation.Autowired;
   import org.springframework.stereotype.Service;
   import org.springframework.transaction.annotation.Transactional;
   
   /**
    * @author wangshuo
    * @date 2021/03/24
    */
   @Slf4j
   @Service("tblOrderService")
   public class TblOrderServiceImpl implements TblOrderService {
   
       @Autowired
       private TblOrderDAO tblOrderDAO;
   
       @Autowired
       private TransactionLogDAO transactionLogDAO;
   
       @Autowired
       private OrderTransactionProducer orderTransactionProducer;
   
       /**
        * 供 Controller 调用，给 RocketMQ 发送 half message
        *
        * @param order 订单对象
        */
       @Override
       public void createOrder(TblOrder order) {
           try {
               orderTransactionProducer.sendMessage("order", JSONObject.toJSONString(order));
           } catch (MQClientException e) {
               log.info("创建订单失败", e);
           }
       }
   
       /**
        * 在 half message 返回 send ok 后, TransactionListener 中执行该业务方法
        *
        * @param order         订单信息
        * @param transactionId RocketMQ 生成的事务 Id
        */
       @Override
       @Transactional(rollbackFor = Exception.class)
       public void createOrder(TblOrder order, String transactionId) {
           // 1. 创建订单
           tblOrderDAO.insert(order);
           // 2. 写入事务日志
           TransactionLog log = new TransactionLog();
           log.setBusiness("order");
           log.setForeignKey(String.valueOf(order.getId()));
           transactionLogDAO.insert(log);
       }
   }
   ```

#### 事务参与方

1. 添加 RocketMQ 依赖

   ```xml
   <!-- RocketMQ -->
   <dependency>
       <groupId>org.apache.rocketmq</groupId>
       <artifactId>rocketmq-spring-boot-starter</artifactId>
       <version>2.2.0</version>
   </dependency>
   ```

2. 订单监听器

   ```java
   package com.example.consumer.listener;
   
   import com.alibaba.fastjson.JSONObject;
   import com.example.consumer.entity.TblOrder;
   import com.example.consumer.service.TblPayService;
   import lombok.extern.slf4j.Slf4j;
   import org.apache.rocketmq.client.consumer.listener.ConsumeConcurrentlyContext;
   import org.apache.rocketmq.client.consumer.listener.ConsumeConcurrentlyStatus;
   import org.apache.rocketmq.client.consumer.listener.MessageListenerConcurrently;
   import org.apache.rocketmq.common.message.MessageExt;
   import org.springframework.beans.factory.annotation.Autowired;
   import org.springframework.stereotype.Component;
   
   import java.util.List;
   
   /**
    * @author wangshuo
    * @date 2021/03/24
    */
   @Slf4j
   @Component
   public class OrderMessageListener implements MessageListenerConcurrently {
   
       @Autowired
       private TblPayService tblPayService;
   
       @Override
       public ConsumeConcurrentlyStatus consumeMessage(List<MessageExt> list, ConsumeConcurrentlyContext consumeConcurrentlyContext) {
           log.info("消费者线程监听到消息。");
           try {
               for (MessageExt message : list) {
                   log.info("开始处理订单数据，准备增加积分....");
                   TblOrder order = JSONObject.parseObject(message.getBody(), TblOrder.class);
                   tblPayService.increasePoints(order);
               }
               return ConsumeConcurrentlyStatus.CONSUME_SUCCESS;
           } catch (Exception e) {
               log.error("处理消费者数据发生异常。", e);
               return ConsumeConcurrentlyStatus.RECONSUME_LATER;
           }
       }
   }
   ```

3. 订单消费者

   ```java
   package com.example.consumer.consumer;
   
   import com.example.consumer.listener.OrderMessageListener;
   import org.apache.rocketmq.client.consumer.DefaultMQPushConsumer;
   import org.apache.rocketmq.client.exception.MQClientException;
   import org.springframework.beans.factory.annotation.Autowired;
   import org.springframework.stereotype.Component;
   
   import javax.annotation.PostConstruct;
   
   /**
    * @author wangshuo
    * @date 2021/03/24
    */
   @Component
   public class OrderConsumer {
   
       private DefaultMQPushConsumer consumer;
   
       @Autowired
       private OrderMessageListener orderMessageListener;
   
       @PostConstruct
       public void init() throws MQClientException {
           String consumerGroup = "order-consumer-group";
           String namesrvAddr = "127.0.0.1:9876";
           consumer = new DefaultMQPushConsumer(consumerGroup);
           consumer.setNamesrvAddr(namesrvAddr);
           consumer.subscribe("order", "*");
           consumer.registerMessageListener(orderMessageListener);
           // 2 次失败 就进私信队列
           consumer.setMaxReconsumeTimes(2);
           consumer.start();
       }
   
   }
   ```

4. 死信队列中的订单监听器

   ```java
   package com.example.consumer.listener;
   
   import com.alibaba.fastjson.JSONObject;
   import com.example.consumer.entity.TblOrder;
   import com.example.consumer.service.TblPayService;
   import lombok.extern.slf4j.Slf4j;
   import org.apache.rocketmq.client.consumer.listener.ConsumeConcurrentlyContext;
   import org.apache.rocketmq.client.consumer.listener.ConsumeConcurrentlyStatus;
   import org.apache.rocketmq.client.consumer.listener.MessageListenerConcurrently;
   import org.apache.rocketmq.common.message.MessageExt;
   import org.springframework.beans.factory.annotation.Autowired;
   import org.springframework.stereotype.Component;
   
   import java.util.List;
   
   /**
    * 监听死信队列中的消息
    *
    * @author wangshuo
    * @date 2021/03/24
    */
   @Slf4j
   @Component
   public class OrderDldMessageListener implements MessageListenerConcurrently {
   
       @Autowired
       TblPayService tblPayService;
   
       @Override
       public ConsumeConcurrentlyStatus consumeMessage(List<MessageExt> list, ConsumeConcurrentlyContext context) {
           log.info("死信队列：消费者线程监听到消息。");
           try {
               for (MessageExt message : list) {
                   log.info("死信队列：开始处理订单数据，准备增加积分....");
                   TblOrder order = JSONObject.parseObject(message.getBody(), TblOrder.class);
                   tblPayService.increasePoints(order);
               }
               return ConsumeConcurrentlyStatus.CONSUME_SUCCESS;
           } catch (Exception e) {
               log.error("死信队列：处理消费者数据发生异常", e);
               return ConsumeConcurrentlyStatus.RECONSUME_LATER;
           }
       }
   }
   ```

5. 死信队列中订单消费者

   ```java
   package com.example.consumer.consumer;
   
   import com.example.consumer.listener.OrderDldMessageListener;
   import org.apache.rocketmq.client.consumer.DefaultMQPushConsumer;
   import org.apache.rocketmq.client.exception.MQClientException;
   import org.springframework.beans.factory.annotation.Autowired;
   import org.springframework.stereotype.Component;
   
   import javax.annotation.PostConstruct;
   
   /**
    * 对死信队列中的消息进行消费
    *
    * @author wangshuo
    * @date 2021/03/24
    */
   @Component
   public class OrderDldConsumer {
   
       DefaultMQPushConsumer consumer;
   
       @Autowired
       private OrderDldMessageListener orderDldMessageListener;
   
       @PostConstruct
       public void init() throws MQClientException {
           String consumerGroup = "consumer-order-dld-group";
           String namesrvAddr = "127.0.0.1:9876";
           consumer = new DefaultMQPushConsumer(consumerGroup);
           consumer.setNamesrvAddr(namesrvAddr);
           consumer.subscribe("%DLQ%consumer-order-group", "*");
           consumer.registerMessageListener(orderDldMessageListener);
           consumer.setMaxReconsumeTimes(2);
           consumer.start();
       }
   }
   ```

6. 业务代码

   ```java
   package com.example.consumer.service.impl;
   
   import com.example.consumer.dao.TblPayDAO;
   import com.example.consumer.entity.TblOrder;
   import com.example.consumer.entity.TblPay;
   import com.example.consumer.service.TblPayService;
   import lombok.extern.slf4j.Slf4j;
   import org.springframework.beans.factory.annotation.Autowired;
   import org.springframework.stereotype.Service;
   
   @Slf4j
   @Service("tblPayService")
   public class TblPayServiceImpl implements TblPayService {
       @Autowired
       private TblPayDAO tblPayDAO;
   
       @Override
       public void increasePoints(TblOrder order) {
           TblPay pay = new TblPay();
           pay.setVal("12345");
           tblPayDAO.insert(pay);
           log.info("增加积分成功");
       }
   }
   ```

## 分布式事务总结

|                   |                                 |                                                              |                          |
| ----------------- | ------------------------------- | ------------------------------------------------------------ | ------------------------ |
| 2PC               |                                 | 只有协调者超时，超时就回滚                                   | 一开始就占用资源         |
| 3PC               | 把 2PC 的第一阶段拆成了两个阶段   | 协调者和参与者都会超时(协调者超时回滚，参与者 pre 超时回滚, do 超时提交) | 从第二阶段开始才占用资源 |
| TCC               | 是把 2PC 的第二阶段拆成了两个阶段 |                                                              | 不占用连接，性能高       |
| LCN(LCN, TCC)     |                                 |                                                              |                          |
| seata(AT, TCC)    |                                 |                                                              |                          |
| 消息队列 + 事件表 |                                 |                                                              |                          |
| 最大努力通知      |                                 |                                                              |                          |
| 可靠消息服务      |                                 |                                                              |                          |
| 消息事务          |                                 |                                                              |                          |





