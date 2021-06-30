---
title: MongoDB 的索引
date: '2020-07-04 00:00:00'
tags:
- MSB
- Database
- MongoDB
- Java
---
# MongoDB 的索引

索引是一种特殊的数据结构，它以一种易于遍历的形式存储 collection 的一部分数据集

索引存储特定字段或字段集的值，按字段的值排序。索引项的排序支持高效的等值匹配和基于范围的查询操作。

MongoDB 定义了 collection 级别的索引，并且支持对 collection 中文档的任何字段或子字段进行索引。

## 术语

### 索引覆盖

指一个查询所需要的字段都在索引中，就不再需要从数据页中加载数据了。

### 索引扫描（IXSCAN）

只扫描建立了索引的数据

### 集合扫描（COLLSCAN）

对集合中的所有数据都进行扫描。对应 MySQL 的全表扫描

### 查询形状（Query Shape）

就是查询条件。

例如

```mongodb
db.user.find({"gender":"女", "age":25})
```

`{"gender":"女", "age":25}` 就是该语句的 query shape

### 索引前缀（Index Prefix）

例如创建如下索引

```mongodb
db.user.createIndex({a:1,b:1,c:1})
```

使用下方三种查询形状进行查询的时候，都可以匹配索引，不需要单独创建额外的索引

```mongodb
{a:1}
{a:1,b:1}
{a:1,b:1,c:1}
```

### 过滤性（Selectivity）

过滤性是指通过使用索引缩小查询结果范围的能力。

**示例**

1. 数据准备：假设数据库中包含如下数据

   ```mongodb
   { _id: ObjectId(), a: 1, b: "ab" }
   { _id: ObjectId(), a: 1, b: "cd" }
   { _id: ObjectId(), a: 1, b: "ef" }
   { _id: ObjectId(), a: 2, b: "jk" }
   { _id: ObjectId(), a: 2, b: "lm" }
   { _id: ObjectId(), a: 2, b: "no" }
   { _id: ObjectId(), a: 3, b: "pq" }
   { _id: ObjectId(), a: 3, b: "rs" }
   { _id: ObjectId(), a: 3, b: "tv" }
   ```

2. 查询条件

   如果要查询 `a=2` 并且 `b="no"` 的数据

3. 方式一：根据 a 字段创建索引

   因为 a 字段具备索引，所以 MongoDB 会优先根据 `a=2` 的条件进行查询，此时会查询出 3 条记录

   然后在从这 3 条记录中查询出 `b="no"` 的这条数据

4. 方式二：根据 b 字段创建索引

   因为 b 字段具备索引，所以 MongoDB 会有限根据`b="no"`的条件进行查询，此时可以直接就查询出所要的数据

**说明**

过滤性简而言之，就是说要对数据差异性较大的字段建立索引，这样根据该索引就可以查询出较少的初步结果，其他条件就可以从较少的初步结果中进行过滤

## 索引原理

官网写的是 B tree，其实是 B+tree

## 查询计划

查询计划（Query Plans）就是说，MongoDB 在执行一个查询的时候，它的执行流程是什么样的。

### 查询优化器介绍

MongoDB 中有一个查询优化器（Query Optimizer），当一个查询到达 MongoDB 后，会按照查询优化器规定的流程来进行处理。

查询优化器会根据已经建立，且对其可见的索引对 QueryShape 选择最有效的查询计划

### 查询优化器的执行流程

![image-20210422112912846](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210422112914.png)

查询优化器首先会从缓存中查询是否有符合该 QueryShape 的查询计划，如果存在，会对其进行评估，评估通过后，就会使用该查询计划生成文档结果。如果评估不通过，会清除缓存中的该查询计划，然后生成新的查询计划。

如果缓存中不存在符合该 QueryShape 的查询计划，查询优化器会对其生成一些候选的查询计划，然后对这些候选的查询计划进行评估，选择出一个最优的查询计划，然后将其缓存后再生成文档结果。

**候选查询计划的评估**

1. 先判断是否有索引
2. 根据索引数量，分别启动一个线程，使用不同的索引进行查询，分别取出 1000 条数据，看使用哪个索引查询的块

### 缓存的查询计划失效

对于 MongoDB 已经缓存的缓存计划，在某些情况下，是会是小的

- 对集合执行了 100 次写操作

  > 因为如果对某个集合进行了大量的数据写入，可能改变其索引字段对应数据的数据分布，从而导致之前的查询计划不再是最优的

- mongod 重启

  > 因为查询计划是在缓存中的，所以重启服务后会被清空

- 索引重建/修改/删除

  > 索引都改变了，查询计划肯定要重新评估

### 手动设置查询计划

生产环境，由于业务原因，可能出现按照 MongoDB 生成的查询计划查询的速度变慢了，此时通过 hint 命令强制指定使用哪些索引

```mongodb
db.collectionName.find().hint()
```

官方还提供了一种监听器的方式

## 索引管理

### 创建索引

**语法**

```mongodb
db.collectionName.createIndex(keys,options)
```

| 参数    | 类型      | 描述                                                         |
| ------- | --------- | ------------------------------------------------------------ |
| keys    | documents | 指定要对哪些字段创建什么类型的索引。`{col:val}` 形式。其中 `col` 表示要对哪个字段建立索引；`val` 表示要对该字段建立升序索引还是降序索引。升序索引是 1，降序索引是 -1。比如 `{"name":1}` 表示对 `name` 字段建立升序索引。|
| options | documents | 可选。包含一组控制索引创建选项的文档。<br>可选参数：`background`，`unique`<br>- `background`：Boolean 类型，默认值 false。是否在后台建立索引。如果为 false，建立索引的时候会阻塞对数据库其他的操作。<br>- `unique`：Boolean 类型，默认为 false。建立的索引是否唯一。如果为 true 则创建唯一索引。|

**使用技巧**

1. 尽量将 background 设置为 true，通常 MongoDB 存储的数据量都很大（百万/千万/上亿），创建索引很耗费时间。如果为 false，会导致业务中断。
2. 创建索引时，会先在 primary 节点上建立，此时可以将主节点与从节点断开连接，在主节点上创建索引时让从节点继续提供查询服务，等主节点创建完索引后，在让从节点创建索引

所有用于存储的组件，无论是 mysql 还是 mongodb 还是 es 或者 redis，如果你想干一些数据迁移，重新分片，重新分表等，都可能会影响线上业务。

### 查看索引

```mongodb
db.collectionName.getIndexes()
```

### 删除索引

```mongodb
# 删除指定索引
db.collectionName.dropIndex(index)
# 删除所有索引
db.collectionName.dropIndexes()
```

| 参数  | 类型            | 描述                                                         |
| ----- | --------------- | ------------------------------------------------------------ |
| index | string/document | 指定要删除的索引。可以通过索引名（string）或索引规范文档（document）来删除。若要删除文本索引，请指定索引名称。|

**示例**

```mongodb
# 测试数据
db.test.insertMany([{"x":5,"y":"a"},{"x":6,"y":"b"}])
# 对 x 字段创建索引
db.test.createIndex({x:1})
# 查询所有索引
db.test.getIndexes()
# 通过索引名称删除索引
db.test.dropIndex("x_1")
# 通过索引规范文档删除索引
db.test.dropIndex({x:1})
```

## 查询分析

```mongodb
db.collectionName.find().explain(verbose)
```

- verbose：可选参数。默认值是 `queryPlanner`，用于指定 explain 输出信息的详细程度
  - `queryPlanner`：MongoDB 运行查询优化器对当前的查询进行评估并选择一个最佳的查询计划
  - `executionStats`：MongoDB 运行查询优化器对当前的查询进行评估并选择一个最佳的查询计划进行执行。在执行完毕后返回这个最佳执行计划执行完成时的相关统计信息。对于写操作 `db.collection.explain()` 返回关于更新和删除操作的信息，但是并不将修改应用到数据库。
  - `allPlansExecution`：包括上述两种模式的所有信息。同时如果有多个查询计划会列出候选的查询计划。

**测试**

1. 插入测试数据

   ```mongodb
   for(var i=0;i<100000;i++){db.test.insert({name:i,age:i,date:new Date()})}
   ```

2. 查看执行计划

   ```mongodb
   db.test.find({name:1}).explain("executionStats")
   ```

3. 结果说明

   ```json
   
   {
       "queryPlanner" : {
           "plannerVersion" : 1,
           "namespace" : "test.test",
           "indexFilterSet" : false,
           "parsedQuery" : {
               "name" : {
                   "$eq" : 1
               }
           },
           // 获胜的执行计划
           "winningPlan" : {
               // 全表扫描
               "stage" : "COLLSCAN",
               "filter" : {
                   "name" : {
                       "$eq" : 1
                   }
               },
               "direction" : "forward"
           },
           "rejectedPlans" : [ ]
       },
       "executionStats" : {
           "executionSuccess" : true,
           // 返回的结果集数量
           "nReturned" : 1,
           // 执行所需时间
           "executionTimeMillis" : 37,
           // 检查了几个索引
           "totalKeysExamined" : 0,
           // 检查的文档总数
           "totalDocsExamined" : 100000,
           "executionStages" : {
               // 扫描方式：全表扫描
               "stage" : "COLLSCAN",
               "filter" : {
                   "name" : {
                       "$eq" : 1
                   }
               },
               "nReturned" : 1,
               "executionTimeMillisEstimate" : 3,
               "works" : 100002,
               "advanced" : 1,
               "needTime" : 100000,
               "needYield" : 0,
               "saveState" : 100,
               "restoreState" : 100,
               "isEOF" : 1,
               "direction" : "forward",
               "docsExamined" : 100000
           }
       },
       "serverInfo" : {
           "host" : "ubuntu-01",
           "port" : 27017,
           "version" : "4.4.5",
           "gitVersion" : "ff5cb77101b052fa02da43b8538093486cf9b3f7"
       },
       "ok" : 1,
       "$clusterTime" : {
           "clusterTime" : Timestamp(1619077624, 1),
           "signature" : {
               "hash" : BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
               "keyId" : NumberLong(0)
           }
       },
       "operationTime" : Timestamp(1619077624, 1)
   }
   ```

4. 对 `name` 字段创建索引

   ```mongodb
   db.test.createIndex({"name":1})
   ```

5. 再次执行 `db.test.find({name:1}).explain("executionStats")` 查看执行计划

   ```json
   
   {
       "queryPlanner" : {
           "plannerVersion" : 1,
           "namespace" : "test.test",
           "indexFilterSet" : false,
           "parsedQuery" : {
               "name" : {
                   "$eq" : 1
               }
           },
           // 获胜的执行计划
           "winningPlan" : {
               "stage" : "FETCH",
               "inputStage" : {
                   // 索引扫描
                   "stage" : "IXSCAN",
                   "keyPattern" : {
                       "name" : 1
                   },
                   "indexName" : "name_1",
                   "isMultiKey" : false,
                   "multiKeyPaths" : {
                       "name" : [ ]
                   },
                   "isUnique" : false,
                   "isSparse" : false,
                   "isPartial" : false,
                   "indexVersion" : 2,
                   "direction" : "forward",
                   "indexBounds" : {
                       "name" : [
                           "[1.0, 1.0]"
                       ]
                   }
               }
           },
           "rejectedPlans" : [ ]
       },
       "executionStats" : {
           "executionSuccess" : true,
           // 返回 1 条数据
           "nReturned" : 1,
           // 只耗费了 2 毫秒
           "executionTimeMillis" : 2,
           // 只检查了 1 个索引
           "totalKeysExamined" : 1,
           // 只查看了一个文档
           "totalDocsExamined" : 1,
           "executionStages" : {
               "stage" : "FETCH",
               "nReturned" : 1,
               "executionTimeMillisEstimate" : 0,
               "works" : 2,
               "advanced" : 1,
               "needTime" : 0,
               "needYield" : 0,
               "saveState" : 0,
               "restoreState" : 0,
               "isEOF" : 1,
               "docsExamined" : 1,
               "alreadyHasObj" : 0,
               "inputStage" : {
                   "stage" : "IXSCAN",
                   "nReturned" : 1,
                   "executionTimeMillisEstimate" : 0,
                   "works" : 2,
                   "advanced" : 1,
                   "needTime" : 0,
                   "needYield" : 0,
                   "saveState" : 0,
                   "restoreState" : 0,
                   "isEOF" : 1,
                   "keyPattern" : {
                       "name" : 1
                   },
                   "indexName" : "name_1",
                   "isMultiKey" : false,
                   "multiKeyPaths" : {
                       "name" : [ ]
                   },
                   "isUnique" : false,
                   "isSparse" : false,
                   "isPartial" : false,
                   "indexVersion" : 2,
                   "direction" : "forward",
                   "indexBounds" : {
                       "name" : [
                           "[1.0, 1.0]"
                       ]
                   },
                   "keysExamined" : 1,
                   "seeks" : 1,
                   "dupsTested" : 0,
                   "dupsDropped" : 0
               }
           }
       },
       "serverInfo" : {
           "host" : "ubuntu-01",
           "port" : 27017,
           "version" : "4.4.5",
           "gitVersion" : "ff5cb77101b052fa02da43b8538093486cf9b3f7"
       },
       "ok" : 1,
       "$clusterTime" : {
           "clusterTime" : Timestamp(1619077834, 1),
           "signature" : {
               "hash" : BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
               "keyId" : NumberLong(0)
           }
       },
       "operationTime" : Timestamp(1619077834, 1)
   }
   ```

## 索引类型

### 单字段索引



### 组合（复合）索引

#### 创建方法

```mongodb
db.collectionName.createIndex({col:val,col2:val2,col3:val3})
```

#### ESR 原则

创建组合索引要遵循 ESR 原则

- E（Equal）：精准匹配放在最前面
- S（Sort）：排序条件放中间
- R（Range）：范围匹配放最后

如果不能同时满足 ESR，那要满足 ES/ER（总之 E 要放前面）

#### 示例

1. 假如有如下查询语句

   ```mongodb
   db.user.find({gender:"F",age:{$gte:25}}).sort("birthday":1)
   ```

2. 此时可以对 user 表的 `gender`，`age`，`birthday` 三个字段创建联合索引

3. 有如下 6 种排列组合

   ```json
   {"gender":1,"age":1,"birthday":1}
   {"gender":1,"birthday":1,"age":1}
   {"age":1,"gender":1,"birthday":1}
   {"age":1,"birthday":1,"gender":1}
   {"birthday":1,"age":1,"gender":1}
   {"birthday":1,"gender":1,"age":1}
   ```

4. 按照 ESR 原则，应该使用如下方式创建索引

   ```mongodb
   db.user.createIndex({"gender":1,"birthday":1,"age":1})
   ```

### 多值索引

针对数组创建的索引

#### 索引数组字段

1. 示例数据

   ```json
   db.user.insert({"address": {"city": "Los Angeles","state": "California","pincode": "123"},"tags": ["music","cricket","blogs"],"name": "Tom Benzamin"})
   ```

2. 对 `tags` 字段建立索引

   ```mongodb
   db.user.createIndex({"tags":1})
   ```

3. 创建索引后可以通过如下方式查询

   ```mongodb
   db.user.find({tags:"cricket"})
   ```

4. 可以通过`explain`查看索引是否生效

   ```mongodb
   db.user.find({tags:"cricket"}).explain("executionStats")
   ```

#### 针对子文档索引

1. 针对 address 的子文档创建索引

   ```mongodb
   db.user.createIndex({"address.city":1,"address.state":1,"address.pincode":1})
   ```

2. 使用子文档的字段来进行查询

   ```mongodb
   db.user.find({"address.city":"Los Angeles"})
   ```

3. 可以通过 `explain` 查看索引是否生效

   ```mongodb
   db.user.find({"address.city":"Los Angeles"}).explain("executionStats")
   ```

### 地理位置索引

参考：https://docs.mongodb.com/manual/core/geohaystack/

### 全文索引

类似于 ES 的功能

### TTL 索引

带有失效期的索引

### 部分索引

只对部分数据添加索引，可以减少索引的数量，从而加快查询速度

1. 例如 2020 年旧的数据只有 `name` 和 `age` 字段，在 2021 年后添加了 `tel` 字段，此时可以只对 `tel` 字段添加索引。

   > 因为旧的数据没有该字段，所以如果对旧数据也添加该索引，会影响索引的性能

2. 例如只对 2021 年的数据添加索引，对 2020 年的数据不加索引，如果大部分查询都是查 2021 年的数据，此时可以加快数据的查询速度

#### 使用方式

```mongodb
db.collectionName.createIndex(keys,{partialFilterExpression:condition})
```

- keys：需要添加索引的字段，例如 `{"createTime":1}`
- conodition：过滤条件，例如 `{"createTime":{$gte:"2021-01-01"}}`

#### 示例

只对 2021 年 01 月 01 日之后的数据的 createTime 列添加索引

```mongodb
db.test.createIndex(
	{"createTime":1},
	{partialFilterExpression:{createTime:{$gte:"2020-01-01"}}}
)
```

### 哈希索引

Hash 结构的索引

## 注意事项

### 创建索引启用 `background`

参考 [创建索引](#创建索引)

### 索引失效

1. 正则表达式查询
2. 非操作符：`$nin`，​`$not`
3. 算数运算符：`$mod`
4. \$where 子句

**解决方案**

索引失效添加 `hint`
