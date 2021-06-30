---
title: MongoDB 的基本使用
date: '2020-07-04 00:00:00'
tags:
- MSB
- Database
- MongoDB
- Java
---
# MongoDB 的基本使用

## Mongo 安装

### 本地安装

1. 官网下载安装包

   https://www.mongodb.com/try/download/community

   4.x.y，x 为偶数是稳定版本，x 为奇数是测试版本

   ![image-20210415203243039](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210415203245.png)

2. 创建数据，配置，日志文件夹

   ```shell
   mkdir -p /path/to/mongodb/data /path/to/mongodb/conf /path/to/mongodb/logs
   ```

3. 解压安装包

   ```shell
   tar -zxvf mongodb-linux-x86_64-ubuntu2004-4.4.5.tgz -C /path/to/mongodb
   ```

4. 添加环境变量

   ```shell
   echo 'export PATH=${PATH}:/path/to/mongodb/mongodb-linux-x86_64-ubuntu2004-4.4.5/bin' >> ~/.profile && source ~/.profile
   ```

5. 启动 mongodb 服务 mongod

   1. 使用命令方式直接启动

      ```shell
      mongod --dbpath /path/to/mongodb/data --logpath /path/to/mongodb/logs/mongod.log --port 27017 --fork
      ```

   2. 使用配置文件方式启动

      mongod.yml

      ```yaml
      systemLog:
        # MongoDB 发送所有日志输出的目标指定为文件
        destination: file
        # mongod 或 mongos 应向其发送所有诊断日志记录信息的日志文件路径
        path: "/path/to/mongodb/logs/mongo.log"
        # 当 mongos 或 mongod 实例重新启动时，mongos 或 mongod 是否将新条目附加到现有日志文件的末尾
        logAppend: true
      storage:
        dbPath: "/path/to/mongodb/data"
        journal:
          # 启用或禁用持久性日志以确保数据文件保持有效和可恢复
          enabled: true
      processManagement:
        # 启用在后台运行 mongos 或 mongod 进程的守护进程模式
        fork: true
        pidFilePath: "/path/to/mongodb/logs/mongod.pid"
      net:
        # 服务实例绑定的 IP，0.0.0.0 表示任何 ip 都可以访问
        bindIp: 0.0.0.0
        # 绑定的端口
        port: 27017
      ```

      启动命令

      ```shell
      mongod -f /path/to/mongodb/conf/mongod.yml
      ```

6. 连接 mongodb

   ```shell
   mongo --host 127.0.0.1 --port 27017
   ```

7. 相关命令

   ```shell
   # 查看所有数据库
   show dbs
   # 创建一个数据库
   use test
   # 创建一个表 shop，并插入一条数据
   db.shop.insert({"name":"数据"})
   # 查询数据
   db.shop.find()
   ```

8. 关闭

   ```shell
   
   ```

### 免费云安装

mongodb 为个人用户提供了免费的服务器搭建测试用的 mongodb 集群环境

1. https://www.mongodb.com/try
2. 注册账号
3. https://cloud.mongodb.com/

## 相关工具

MongoDB 4.2 版本以下的会将相关工具直接打包在安装文件中，MongoDB4.2 版本以上将相关工具与安装文件进行了分离，所以需要手动安装下所需的工具

下载地址: https://www.mongodb.com/try/download/tools

### MongoDB Shell



### MongoDB Database Tools

1. 下载

   https://www.mongodb.com/try/download/database-tools

   ![image-20210415213344001](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210415213345.png)

2. 解压

   ```shell
   tar -zxvf mongodb-database-tools-ubuntu2004-x86_64-100.3.1.tgz
   ```

3. 将 bin 中的文件移动到 mongodb 安装目录的 bin 目录下

   ```shell
   mv mongodb-database-tools-ubuntu2004-x86_64-100.3.1/bin/* /path/to/mongodb/mongodb-linux-x86_64-ubuntu2004-4.4.5/bin/
   ```

### 连接工具

[MongoDB Compass](https://www.mongodb.com/try/download/compass)

## 测试

导出数据命令

```
mongodump -h localhost:27017 -d dbname -o ./test
```

导入命令

```
mongorestore -h localhost:27017 -d dbname --dir ./test/
```

## 常用命令

### 数据库相关

1. 查看数据库

   ```mongodb
   show databases
   show dbs
   ```

2. 查看当前正在使用的数据库

   ```mongodb
   db
   ```

3. 选择/创建要使用的数据库

   ```mongodb
   use dbname
   ```

4. 删除数据库

   ```mongodb
   # 先选择要删除的数据库
   use dbname
   # 然后 删除该数据库
   db.dropDatabase()
   ```

5. 修复数据库的数据（本地测试可能用，生产环境一般不会用到，慎用）

   ```mongodb
   mongod --repair --dbpath=/path/to/mongodb/data
   ```

### 集合相关

1. 创建集合

   ```mongodb
   # 显式创建
   db.createCollection(collectionName)
   # 隐式创建
   db.collectionName.insert({"key":"val"})
   ```

2. 查看集合

   ```mongodb
   show collections
   ```

3. 删除集合

   ```mongodb
   db.collectionName.drop()
   ```

### 文档相关

#### 插入

- 单个文档

  ```mongodb
  db.collectionName.insert(JSON 对象)
  db.collectionName.insertOne(JSON 对象)
  db.collectionName.save(JSON 对象)
  ```

- 多个文档

  ```mongodb
  db.collectionName.insertMany[JSON 对象 1,JSON 对象 2,JSON 对象 3,...]
  ```

`insert` 也可以插入多个文档，但是 `inserMany` 会返回主键 id，`insert` 没有返回

#### 查询

1. 查询文档

   ```mongodb
   db.collectionName.find(query, projection)
   ```

   - query：可选，查询筛选器，JSON 对象，类似于 MySQL 中的 `where`
   - projection：可选，结果字段，JSON 对象，类似于 MySQL 中的 `select name, age` 中的 `name, age`

   **示例**

   ```mongodb
   # 查询所有
   db.shop.find()
   # 查询所有
   db.shop.find({})
   # 查询 name 是手机的
   db.shop.find({"name":"手机"})
   # and 查询，查询 name 是手机，同时 price 是 3000 的
   db.shop.find({"name":"手机","price":3000})
   db.shop.find({"name":"手机"},{"price":3000})
   # or 查询，查询 name 是手机，或者 price 是 3000 的
   db.shop.find($or:[{"name":"手机"},{"price":3000}])
   # 正则查找
   db.shop.find({"name":/^手/})
   ```

   **查询条件对照表**

   | SQL             | MongoDB                           | 说明                                |
   | --------------- | --------------------------------- | ----------------------------------- |
   | `a=1`           | `{a:1}`                           | 单属性字段完全匹配                  |
   | `a<>1`          | `{a:{$ne:1}}`                     | `$ne`:不存在或者存在但不等于        |
   | `a>1`           | `{a:{$gt:1}}`                     | `$gt`:存在并大于                    |
   | `a>=1`          | `{a:{$gte:1}}`                    | `$gte`:存在并大于等于               |
   | `a<1`           | `{a:{$lt:1}}`                     | `$lt`:存在并小于                    |
   | `a<=1`          | `{a:{$lte:1}}`                    | `$lte`:存在并小于等于               |
   | `a=1 AND b=1`   | `{a:1,b:1}` 或者 `{$and:[{a:1},{b:1}]}` | `$and`:匹配全部条件                 |
   | `a=1 OR b=1`    | `{$or:[{a:1},{b:1}]}`             | `$or`:匹配两个或多个条件中的一个    |
   | `a is NULL`     | `{a:{$exists:false}}`             | `$exists:false`/`$exists:true`:是否为空 |
   | `a in(1,2,3)`   | `{a:{$in:[1,2,3]}}`               | `$in`:存在并在指定数组中            |
   | `a not in(1,2,3)` | `{a:{$nin:[1,2,3]}}`              | `$nin`:不存在或不在指定数组中       |
   | `a like '%中%'` | `{a:/中/}`                        | mongodb 通过正则实现模式匹配         |

2. find 搜索子文档

   MongoDB 鼓励内嵌文档，实现关联查询

   **示例**

   ```mongodb
   # 插入测试数据
   db.shop.insert({"name":"电脑",category:{"name":"联想","cpu":"i7"}})
   # 查询 category 的 name 属性是"联想"的
   db.shop.find({"category.name":"联想"})
   # 这种方式要注意，是查询 category 是{"name":"联想"}的而不是 category 的 name 是联想
   db.shop.find({"category":{"name":"联想"}})
   ```

3. find 搜索数组

   find 支持对数组中的元素进行搜索

   **示例**

   ```mongodb
   # 插入测试数据
   db.shop.insert([{"name":"联想","cpu":["i5","i7"]},{"name":"戴尔","cpu":["i7","i9"]}])
   # 查找 cpu 中包含 i7 的
   db.shop.find({"cpu":"i7"})
   # 查找 cpu 中包含 i5 或 i9 的
   db.shop.find({$or:[{"cpu":"i5"},{"cpu":"i9"}]})
   ```

4. find 搜索数组中的对象

   **示例**

   ```mongodb
   # 插入测试数据
   db.shop.insert({"name":"手机","brand":[{"name":"小米","price":2000},{"name":"华为","price":5000},{"name":"苹果","price":8000}]})
   # 查询 brand 中包含 name 是华为的
   db.shop.find("brand.name":"华为")
   ```

5. find 加 projection 查询

   **示例**

   ```mongodb
   # 插入测试数据
   db.shop.insert({"name":"手机","price":3000},{"name":"电脑","price":5000},{"name":"日用百货","price":100})
   # 查找 name 是手机的，然后只显示 price, 0 代表不显示, 1 代表显示
   db.shop.find({"name":"手机"},{"_id":0,"price":1})
   ```

#### 更新

```mongodb
# update 和 updateOne 相同，无论输入条件匹配多少条，只更新一条
db.collectionName.update(query, updateFiled)
db.collectionName.updateOne(query, updateFiled)
# 输入条件匹配多少条，就更新多少条
db.collectionName.updateMany(query, updateFiled)
```

- query：查询条件, JSON 对象
- updateFiled：更新字段, JSON 对象

update/updateOne/updateMany，要求 updateFiled 部分，必须有如下条件之一，否则会报错

| 条件        | 说明                       |
| ----------- | -------------------------- |
| `$push`     | 增加一个对象到数组底部     |
| `$pushAll`  | 增加多个对象到数组底部     |
| `$pop`      | 从数组底部删除一个对象     |
| `$pull`     | 从数组中删除相应的对象     |
| `$pullAll`  | 从数组中删除相应的对象     |
| `$addToSet` | 如果不存在则增加一个到数组 |
| `$set`      | 修改对象属性值             |

**示例**

```mongodb
# 插入测试数据
db.shop.insert([{"name":"iphone12","price":8000},{"name":"p40","price":5000,"color":[1,2,3]},{"name":"p30"}])
# 更新数据
db.shop.update({"name":"iphone12"},{$set:{"price":9000}})
db.shop.updateOne({"name":"p30"},{$set:{"price":3500}})
db.shop.update({"name":"p40"},{$push:{"color":5}})
```

#### 删除

```mongodb
db.collectionName.remove(query,justOne,writeConcern)
```

- query：必须，查询条件，JSON 对象
- justOne：可选，设置为 true/1 就只删除 1 个文档，否则删除所有匹配的文档
- writeConcern：可选，抛出异常的级别

**示例**

```
# 插入测试数据
db.shop.insert([{"name":"zhangsan", "age":12},{"name":"lisi", "age":12},{"name":"wangwu", "age":15}])
# 删除所有文档
db.shop.remove({})
# 删除所有 age 是 12 的
db.shop.remove({"age":12})
# 只删除一个 age 是 12 的
db.shop.remove({"age":12},true)
```

### 聚合

聚合操作处理数据记录并返回计算结果。聚合操作将多个文档中的值分组在一起，并可以对分组后的数据进行各种操作，以返回一个结果。相当于 SQL 中的 COUNT，SUM，GROUP BY，LEFT JOIN 等操作

MongoDB 提供了三种执行聚合的方法

- 聚合管道(Aggregation Pipeline)
- map-reduce 函数
- 单一目的聚合方法

#### 单一目的的聚合方法

```mongodb
db.collectionName.count(query)
```

```monogodb
db.collectionName.distinct(key)
```

#### Map-Reduce 函数

先收集，再处理，官方不推荐使用

#### 聚合管道

MongoDB 的聚合管道是以数据处理流水线的概念为基础的。稳当进入一个多阶段的流水线，将文档转化为一个聚合的结果，步骤如下

![image-20210416134717320](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210416134718.png)

**示例**

```mongodb
# 插入测试数据
db.shop.insertMany([{"cust_id":"A123","amount":500,"status":"A"},{"cust_id":"A123","amount":250,"status":"A"},{"cust_id":"B212","amount":200,"status":"A"},{"cust_id":"A123","amount":300,"status":"B"}])
# 聚合
db.shop.aggregate([{$match:{"status":"A"}},{$group:{"_id":"$cust_id","total":{$sum:"$amount"}}}])
```

**流程说明**

```mongodb
# 开始一个聚合操作
db.shop.aggregate([
# 第一步, $match stage：查找出 status 为 A 的数据
{$match:{"status":"A"}},
# 第二步, $group stage：在第一步的结果基础上，将数据按照 cust_id 进行分组后，计算每个 cust_id 的金额之和(sum)
{$group:{"_id":"$cust_id","total":{$sum:"$amount"}}}
])
```

**常见步骤**

| 功能     | MQL                   | SQL            |
| -------- | --------------------- | -------------- |
| 过滤     | `$match`              | `WHERE/HAVING` |
| 投影     | `$project`            | `AS`           |
| 排序     | `$sort`               | `ORDER BY`     |
| 分组     | `$group`              | `GROUP BY`     |
| 结果大小 | `$skip`/`$limit`      | `LIMIT`        |
| 左外连接 | `$lookup`             | `LEFT JOIN`    |
| 求和     | `$sum`                | `SUM()`        |
| 总数     | `$sum`/`$sortByCount` | `COUONT()`     |
| 展开数组 | `$unwind`             | 无             |
| 图搜索   | `$graphLookup`        | 无             |
| 分面搜索 | `$facet`/`$bucket`    | 无             |

官方详细说明文档：https://docs.mongodb.com/manual/reference/sql-aggregation-comparison/

**练习**

测试数据格式：

```json
{
    "_id" : ObjectId("5fcb52a90f78ae33b1a20f95"),
    "province" : "河南",
    "shopName" : "小米自营",
    "phone" : "15001164481",
    "orderDate" : ISODate("2020-07-10T01:47:17.189Z"),
    "status" : "已完成未评价",
    "waybillNo" : "JD46107385",
    "shippingFee" : 10,
    "total" : 7063,
    "orderDetailList" : [
        {
            "_id" : NumberLong(1),
            "productName" : "HUAWEI P40 Pro",
            "sku" : "SKU40637128",
            "qty" : 3,
            "price" : 6488,
            "cost" : 5190
        },
        {
            "_id" : NumberLong(2),
            "productName" : "Apple iPhone12 Pro Max",
            "sku" : "SKU13926807",
            "qty" : 2,
            "price" : 10099,
            "cost" : 8079
        }
    ],
    "_class" : "com.mashibing.mongodb.entity.Order"
}
```

1. 查询总销售额

   ```mongodb
   db.orders.aggregate({$group:{_id:null,total:{$sum:"$total"}}})
   ```

   ```mongodb
   {
     $group:
       {
         _id: <expression>, // Group By Expression
         <field1>: { <accumulator1> : <expression1> },
         ...
       }
    }
   ```

   `_id:null` 表示将所有数据都分到一组，`total:{$sum:"$total"}` 中 `total` 表示输出的 key 是 `total`，`$sum:$total` 表示对数据中的 `total` 字段进行求和操作，`$total` 代表数据中的 `total` 字段

2. 查询 2020 年 11 月 1 日 - 2020 年 11 月 2 日已完成订单总金额和订单数

   ```mongodb
   db.orders.aggregate([
       $match:{
         status:"已完成已评价",
         orderDate:{
           $gte:ISODate('2020-11-01'),
           $lte:ISODate('2020-11-02')
         }
       },
       $group: {
         _id: null,
         sum_total: {
           $sum: "$total"
         },
         sum_shippingFee:{
           $sum: "$shippingFee"
         }
       },
       $project: {
         # 不显示_id
         "_id":0,
         result: {
           # 将 sum_tota 和 sum_shippingFee 结果相加，得到 result
           $add:["$sum_total", "$sum_shippingFee"]
         },
         # 将 sum_total 重命名为了 sum_total_x
         sum_total_x:"$sum_total",
         "sum_shippingFee":1
       }
   ])
   ```

### 其他命令

1. pretty: 将输出结果格式化

   ```mongodb
   db.orders.find().pretty()
   ```
