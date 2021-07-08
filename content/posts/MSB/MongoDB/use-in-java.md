---
title: Java 操作 MongoDB
date: '2021-04-16 17:30:00'
tags:
- MSB
- Database
- MongoDB
- Java
---
# Java 操作 MongoDB

官方文档：https://docs.mongodb.com/drivers/java/

## 原生方式

1. 引入连接器依赖

   ```xml
   <dependency>
       <groupId>org.mongodb</groupId>
       <artifactId>mongodb-driver-sync</artifactId>
       <version>4.2.3</version>
   </dependency>
   ```

2. 获取数据库连接

   ```java
   public MongoClient getClient() {
       return MongoClients.create(
           MongoClientSettings.builder()
           .applyToClusterSettings(builder ->
                                   // 可以使用 List 配置多节点集群
                                   builder.hosts(Collections.singletonList(new ServerAddress("172.10.16.146", 27017))))
           .retryWrites(true)
           .build()
       );
   }
   ```

3. 插入数据

   ```java
   public void insert() {
       // 1. 获取数据库连接
       MongoClient client = getClient();
       // 2. 获取数据库
       MongoDatabase db = client.getDatabase(DATABASE);
       // 3. 获取集合
       MongoCollection<Document> collection = db.getCollection(COLLECTION);
       // 4. 创建文档
       Document document = new Document()
           .append("name", "手机")
           .append("price", 8000);
       // 5. 插入文档
       InsertOneResult insertOneResult = collection.insertOne(document);
       // result 中包含插入文档的 Id 等信息
       System.out.println(JSON.toJSONString(insertOneResult, true));
   }
   ```

4. 查询数据

   ```java
   public void find() {
       // 1. 获取数据库连接
       MongoClient client = getClient();
       // 2. 获取数据库
       MongoDatabase db = client.getDatabase(DATABASE);
       // 3. 获取集合
       MongoCollection<Document> collection = db.getCollection(COLLECTION);
       Bson condition = Filters.eq("name", "手机");
       FindIterable<Document> documents = collection.find();
       MongoCursor<Document> cursor = documents.iterator();
       try {
           while (cursor.hasNext()) {
               Document document = cursor.next();
               System.out.println(document.toJson());
           }
       } finally {
           cursor.close();
       }
   }
   ```

5. 更新数据

   ```java
   public void update() {
       // 1. 获取数据库连接
       MongoClient client = getClient();
       // 2. 获取数据库
       MongoDatabase db = client.getDatabase(DATABASE);
       // 3. 获取集合
       MongoCollection<Document> collection = db.getCollection(COLLECTION);
       // 4. 更新条件
       Bson condition = Filters.and(Filters.eq("name", "手机"));
       // 5. 更新属性
       Document document = new Document("$set", new Document("price", 7000));
       // 6. 执行更新
       UpdateResult updateResult = collection.updateMany(condition, document);
       System.out.println(JSON.toJSONString(updateResult, true));
   }
   ```

6. 删除数据

   ```java
   public void delete() {
       // 1. 获取数据库连接
       MongoClient client = getClient();
       // 2. 获取数据库
       MongoDatabase db = client.getDatabase(DATABASE);
       // 3. 获取集合
       MongoCollection<Document> collection = db.getCollection(COLLECTION);
       // 4. 删除条件
       Bson condition = Filters.and(Filters.eq("name", "手机"));
       // 6. 执行删除
       DeleteResult deleteResult = collection.deleteMany(condition);
       System.out.println(JSON.toJSONString(deleteResult, true));
   }
   ```

## MongoTemplate

1. 引入依赖

   ```xml
   <dependency>
       <groupId>org.springframework.boot</groupId>
       <artifactId>spring-boot-starter-data-mongodb</artifactId>
   </dependency>
   ```

2. 配置文件

   ```yaml
   spring:
     data:
       mongodb:
         uri: mongodb://172.10.16.146:27017/test-spring
   ```

3. 创建一个实体类，在类上要标注 `@Document` 注解，注意使用 `collection` 指定集合，而不是

   ```java
   import com.alibaba.fastjson.annotation.JSONField;
   import org.springframework.data.mongodb.core.mapping.Document;
   
   import java.util.Date;
   
   /**
    * @author wangshuo
    * @date 2021/04/16
    */
   @Data
   @Document(collection = "orders")
   public class Order {
   
       /**
        * 省
        */
       private String province;
       /**
        * 店铺名称
        */
       private String shopName;
       /**
        * 电话号码
        */
       private String phone;
       /**
        * 下单日期
        */
       @JSONField(format="yyyy-MM-dd HH:mm:ss")
       private Date orderDate;
       /**
        * 订单状态
        */
       private String status;
       /**
        * 运单号码
        */
       private String waybillNo;
       /**
        * 总运费
        */
       private Integer shippingFee;
   
       /**
        * 总费用
        */
       private Integer total;
   }
   ```

4. 测试类

   ```java
   import com.alibaba.fastjson.JSON;
   import com.example.mongodbspringreplic.entity.Orders;
   import com.mongodb.client.result.DeleteResult;
   import com.mongodb.client.result.UpdateResult;
   import org.junit.jupiter.api.Test;
   import org.springframework.beans.factory.annotation.Autowired;
   import org.springframework.boot.test.context.SpringBootTest;
   import org.springframework.data.mongodb.core.MongoTemplate;
   import org.springframework.data.mongodb.core.query.Criteria;
   import org.springframework.data.mongodb.core.query.Query;
   import org.springframework.data.mongodb.core.query.Update;
   
   import java.util.Date;
   import java.util.List;
   
   @SpringBootTest
   class MongodbSpringApplicationTests {
   
       @Autowired
       private MongoTemplate mongoTemplate;
   
       @Test
       void insert() {
           Orders orders = new Orders();
           orders.setProvince("黑龙江省");
           orders.setOrderDate(new Date());
           orders.setPhone("123456789");
           orders.setShippingFee(777);
           orders.setTotal(1000);
           orders.setStatus("已完成");
           orders.setWaybillNo("123");
           orders.setShopName("我的店铺");
           orders = mongoTemplate.insert(orders);
           System.out.println(JSON.toJSONString(orders, true));
       }
   
       @Test
       void update() {
           Query query = new Query();
           query.addCriteria(Criteria.where("province").is("黑龙江省"));
           Update update = Update.update("shippingFee", 20);
           UpdateResult result = mongoTemplate.updateMulti(query, update, Orders.class);
           System.out.println(JSON.toJSONString(result, true));
       }
   
       @Test
       void find() {
           Query query = new Query();
           query.addCriteria(Criteria.where("province").is("黑龙江省"));
           List<Orders> orders = mongoTemplate.find(query, Orders.class);
           System.out.println(JSON.toJSONString(orders, true));
       }
   
       @Test
       void delete() {
           Query query = new Query();
           query.addCriteria(Criteria.where("province").is("黑龙江省"));
           DeleteResult deleteResult = mongoTemplate.remove(query, Orders.class);
           System.out.println(JSON.toJSONString(deleteResult, true));
       }
   
   }
   ```
