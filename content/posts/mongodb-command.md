---
title: MongoDB常用命令
date: '2019-11-20 00:00:00'
updated: '2019-11-20 00:00:00'
tags:
- MongoDB
categories:
- Database
---

# MongoDB常用命令

连接MongoDB `mongodb://[username:password@]host1[:port1][,host2[:port2],...[,hostN[:portN]]][/[database][?options]]`

查看所有数据库列表 `show dbs`

查看当前使用的数据库 `db`

切换数据库 `use 数据库名`

创建数据库 `use 数据库名`

删除数据库 `db.dropDatabase()`

创建集合 `db.createCollection(name[, options])`

查看所有集合 `show collections`或`show tables`

删除集合 `db.集合名.drop()`

## 操作集合中的文档

### 插入文档

- 基本命令:`db.集合名.insert(BSON文档)`,如果集合不存在会自动创建

  ```mongodb
  db.col.insert({title: 'MongoDB 教程', 
      description: 'MongoDB 是一个 Nosql 数据库',
      by: '菜鸟教程',
      url: 'http://www.runoob.com',
      tags: ['mongodb', 'database', 'NoSQL'],
      likes: 100
  })
  ```

- 定义为变量后插入

  ```mongodb
  >document=({title: 'MongoDB 教程', 
      description: 'MongoDB 是一个 Nosql 数据库',
      by: '菜鸟教程',
      url: 'http://www.runoob.com',
      tags: ['mongodb', 'database', 'NoSQL'],
      likes: 100
  })
  
  >db.col.insert(document)
  ```

- 使用`db.集合名.save(document)`方式插入,如果不指定_id字段,save()和insert()类似,如果指定_id字段,save()方法会更新该_id的数据

### 更新文档

使用update()方法和save()方法来更新集合中的文档.

#### update()方法

update()方法用于更新已存在的文档.语法格式:

```mongodb
db.collection.update(
   <query>,
   <update>,
   {
     upsert: <boolean>,
     multi: <boolean>,
     writeConcern: <document>
   }
)
```

**参数说明**

- query : update的查询条件,类似sql update查询内where后面的
- update : update的对象和一些更新的操作符(如$,$inc...等),可以理解为sql update内set后面的
- upsert : 可选,如果不存在update的记录,是否插入objNew,默认false,不插入
- multi : 可选,只更新找到的第一条记录,如果为true,则把按条件查出来的多条记录全部更新,默认为false
- writeConcern : 可选,抛出异常的级别

**实例**

将col集合中title为MongoDB 教程的文档的title修改为MongoDB

```mongodb
db.col.update({"title":"MongoDB 教程"},{$set:{"title":"MongoDB"})
```

查看修改结果

```mongodb
db.col.find().pretty()
```

以上方式只会更新第一条发现的文档,如要修改多条相同的文档,需要设置multi为true

```mongodb
db.col.update({"title":"MongoDB 教程"},{$set:{"title":"MongoDB"}},{multi:true})
```

#### save()方法

save()方法通过传入的文档来替换已有文档,语法格式:

```mongodb
db.collection.save(
   <document>,
   {
     writeConcern: <document>
   }
)
```

**参数说明**

- document : 文档数据
- writeConcern : 可选,抛出的异常的级别

**实例**

替换_id为5dd50fc604e9adcbffb78e38的文档数据:

```mongodb
db.col.save({
    "_id" : ObjectId("5dd50fc604e9adcbffb78e38"),
    "title" : "MongoDB",
    "description" : "MongoDB 是一个 Nosql 数据库",
    "by" : "Runoob",
    "url" : "http://www.runoob.com",
    "tags" : [
            "mongodb",
            "NoSQL"
    ],
    "likes" : 110
})
```

查看结果

```mongodb
db.col.pretty()
```

### 删除文档

语法:

```mongodb
db.collection.remove(
   <query>,
   <justOne>
)
```

2.6版本后

```mongodb
db.collection.remove(
   <query>,
   {
     justOne: <boolean>,
     writeConcern: <document>
   }
)
```

**参数说明**

- query : 可选,删除的文档的条件。
- justOne : 可选,如果设为true或1，则只删除一个文档，如果不设置该参数，或使用默认值false，则删除所有匹配条件的文档。
- writeConcern : 可选,抛出异常的级别。

**实例**

删除所有title为MongoDB 教程的文档

```mongodb
db.col.remove({"title" : "MongoDB 教程"})
```

只删除第一条找到的title为MongoDB 教程的文档

```mongodb
db.col.remove({"title" : "MongoDB 教程"}, true)
```

删除所有文档,(类似于sql的truncate)

```mongodb
db.col.remove({})
```

### 查询文档

语法

```mongodb
db.collection.find(query, projection)
```

**参数说明**

- query : 可选,使用查询操作符指定查询条件
- projection : 可选,使用投影操作符指定返回的键.

使用易读的方式来查询数据,可以使用pretty()方法,以格式化的方式显示所有文档

```mongodb
db.collection.find().pretty()
```

只返回一个文档

```mongodb
db.collection.findOne()
```

只返回title字段

```mongodb
db.collection.find({}, {"title":1, "_id":0})
```

注:默认会显示_id字段,1代表显示,0代表不显示

### 条件操作符

#### MongoDB与RDBMS WHERE语句比较

| 操作     | 格式                       | 范例                                 | RDBMS中的类似语句 |
| -------- | -------------------------- | ------------------------------------ | ----------------- |
| 等于     | `{<key> : <value>}`         | `db.col.find({"by" : "菜鸟"})`       | `where by = "菜鸟"` |
| 小于     | `{<key> : {$lt : <value>}}` | `db.col.find({"likes" : {$lt : 50}})` | `where likes < 50` |
| 小于等于 | `{<key> : {$lte : <value>}}` | `db.col.find({"likes" : {$lq : 50}})` | `where likes <= 50` |
| 大于     | `{<key> : {$gt : <value>}}` | `db.col.find({"likes" : {$gt : 50}})` | `where likes > 50` |
| 大于等于 | `{<key> : {$gte : 50}`     | `db.col.find({"likes" : {$gte : 50}})` | `where likes >= 50` |
| 不等于   | `{key : {$ne : <value>}}`  | `db.col.find({"likes" : {$ne : 50}})` | `where likes <> 50` |

#### MongoDB AND 条件

find()方法可以传入多个键,每个键以逗号隔开,常规AND语法

```mongodb
db.col.find({key1 : value1, key2 : value2})
```

**实例**

通过 by和title查询

```mongodb
db.col.find({"by" : "菜鸟教程", "title" : "MongoDB 教程"})
```

#### MongoDB OR 条件

使用$or关键字,语法格式

```mongodb
db.col.find(
    {
        $or:[
            {key1 : value1}, {key2 : value2}
        ]
    }
)
```

#### MongoDB AND和OR联合使用

```mongodb
db.col.find({key1:value1, key2:value2}, $or:[{key3:value3}, {key4:value4}])
```

#### MongoDB 使用>和<查询

```mongodb
db.col.find({"likes": {$gt:50, $lt:100}})
```

#### MongoDB中的$type操作符

$type操作符是基于BSON类型来检索集合中匹配的数据类型,并返回结果.
MongoDB中可以使用的类型如下

| 类型                   | 数字 | 备注          |
| ---------------------- | ---- | ------------- |
| Double                 | 1    |               |
| String                 | 2    |               |
| Object                 | 3    |               |
| Array                  | 4    |               |
| Binary data            | 5    |               |
| Undefined              | 6    | 已废弃        |
| Object id              | 7    |               |
| Boolean                | 8    |               |
| Date                   | 9    |               |
| Null                   | 10   |               |
| Regular Expression     | 11   |               |
| JavaScript             | 13   |               |
| Symbol                 | 14   |               |
| JavaScript(with scope) | 15   |               |
| 32-bit integer         | 16   |               |
| Timestamp              | 17   |               |
| 64-bit integer         | 18   |               |
| Min key                | 255  | Query with -1 |
| Max key                | 127  |               |

**实例**

获取col集合中title为String类型的文档

```mongodb
db.col.find({"title" : {$type : 2}})
或
db.col.find({"title" : {$type : "string"})
```

### 分页操作

#### Limit()方法

使用limit()方法读取指定数量的数据

语法:

```mongodb
db.COLLECTION_NAME.find().limit(NUMBER)
```

注:如果没有指定limit()方法的参数,则显示所有数据

#### Skip()方法

使用skip()方法跳过指定数量的数据

语法:

```mongodb
db.COLLECTION_NAME.find().limit(NUMBER).skip(NUMBER)
```

注:skip()方法默认参数为0

### 排序操作

使用sort()方法进行排序,1为升序排列,-1为降序排列,语法:

```mongodb
db.COLLECTION_NAME.find().sort({key:1})
```

#### 同时包含limit(),skip(),sort()时,执行顺序是sort() -> skip() -> limit()

## [TODO](https://www.runoob.com/mongodb/mongodb-indexing.html)

## 参考文档

[MongoDB教程](https://www.runoob.com/mongodb/mongodb-tutorial.html)
