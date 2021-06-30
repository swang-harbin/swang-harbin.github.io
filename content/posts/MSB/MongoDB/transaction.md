---
title: MongoDB 事务
date: '2020-07-04 00:00:00'
tags:
- MSB
- Database
- MongoDB
- Java
---
# MongoDB 事务

**综述**
在 MongoDB 中，对单个文档的操作是原子性的。因为您可以使用嵌入式文档和数组在单个文档结构中捕获数据之间的关系，而不是在多个文档和集合中进行归一化处理，所以这种单个文档的原子性在许多实际用例中避免了对多文档事务的需求。

对于需要对多个文档（在单个或多个集合中）进行原子性读写的情况，MongoDB 支持多文档事务。通过分布式事务，事务可以跨多个操作、集合、数据库、文档和 shards 使用。

**分布式事务和多文档事务**

从 MongoDB 4.2 开始，这两个术语是同义词。分布式事务指的是 sharded 集群和副本集上的多文档事务。从 MongoDB 4.2 开始，多文档事务（无论是在分片集群上还是在副本集上）也被称为分布式事务。

**多文档事务是原子的**

当一个事务提交时，在该事务中所作的所有数据更改都被保存下来，并在该事务之外可见。也就是说，一个事务不会在提交一些更改的同时回滚其他更改。

在事务提交之前，事务中所做的数据变更在事务外部是不可见的。

但是，当一个事务向多个碎片写入时，并不是所有的外部读取操作都需要等待提交的事务的结果在各个碎片中可见。例如，如果一个事务已经提交，写 1 在 A 碎片上可见，但写 2 在 B 碎片上还不可见，那么在读关注“本地”的外部读可以在不看到写 2 的情况下读取写 1 的结果。

当一个事务中止时，事务中所做的所有数据变化都会被丢弃，而不会变得可见。例如，如果事务中的任何操作失败了，事务就会中止，在事务中所做的所有数据更改都会被丢弃，而不会变得可见。

**重要提示**

在大多数情况下，多文档事务比单文档写入会产生更大的性能成本，多文档事务的可用性不应取代有效的模式设计。对于许多场景来说，去正常化的数据模型（嵌入式文档和数组）将继续是您的数据和用例的最佳选择。也就是说，对于许多场景来说，适当地对你的数据进行建模将最大限度地减少对多文档事务的需求。

**事务操作限制**

尽量在已存在的集合中操作事务，不要在事务中创建索引，创建集合等操作

## MySQL 事务复习

### 概念

**事务**：最小的不可再分的工作单元；通常一个事务对应一个完整的业务（例如银行账户转账业务，该业务就是一个最小的工作单元）

- 原子性（A）：事务是最小单位，不可再分（更多关注多行）
- 一致性（C）：事务要求所有的 DML 语句操作的时候，必须保证同时成功或者同时失败
- 隔离性（I）：事务 A 和事务 B 之间具有隔离性
- 持久性（D）：是事务的保证，事务终结的标志（内存的数据持久到硬盘文件中）

### 隔离性遇见的问题

**脏读**

此情况仅会发生在：读未提交的的隔离级别。

当数据库中一个事务 A 正在修改一个数据但是还未提交或者回滚，另一个事务 B 来读取了修改后的内容并且使用了，之后事务 A 提交了，此时就引起了脏读。

**不可重复读**

此情况仅会发生在：读未提交、读提交的隔离级别。

在一个事务 A 中多次操作数据，在事务操作过程中（未最终提交），事务 B 也才做了处理，并且该值发生了改变，这时候就会导致 A 在事务操作的时候，发现数据与第一次不一样了。就是不可重复读。

**幻读**

此情况会回发生在：读未提交、读提交、可重复读的隔离级别

一个事务按相同的查询条件重新读取以前检索过的数据，却发现其他事务插入了满足其查询条件的新数据，这种现象就称为幻读。

幻读是指当事务不是独立执行时发生的一种现象，例如第一个事务对一个表中的数据进行了修改，比如这种修改涉及到表中的“全部数据行”。同时，第二个事务也修改这个表中的数据，这种修改是向表中插入“一行新数据”。那么，以后就会发生操作第一个事务的用户发现表中还存在没有修改的数据行，就好象发生了幻觉一样。

### 隔离级别

- 读未提交（READ UNCOMMITTED）：一个事务还未提交，它所做的变更就可以被别的事务看到
- 读已提交（READ COMMITTED）：一个事务提交之后，它所做的变更才可以被别的事务看到
- 可重复读（REPEATABLE READ）：一个事务执行过程中看到的数据是一致的。未提交的更改对其他事务是不可见的
- 串行化（SERIALIAZABLE）：对应一个记录会加读写锁，出现冲突的时候，后访问的事务必须等前一个事务执行完成才能继续执行

隔离性增高，性能降低，安全性增高，MySQL 数据库默认是 READ COMMITTED 级别

| 隔离级别         | 脏读可能性 | 不可重复读可能性 | 幻读可能性 |
| ---------------- | ---------- | ---------------- | ---------- |
| READ UNCOMMITTED | 是         | 是               | 是         |
| READ COMMITTED   | 否         | 是               | 是         |
| REPEATABLE READ  | 否         | 否               | 是         |
| SERIALIAZABLE    | 否         | 否               | 否         |

### 隔离级别验证

**数据库准备**

```mysql
create database transaction_test;
use transaction_test;
create table tx_test(`id` int, `name` varchar(20));
insert into tx_test values(1,'张三');
```

#### READ UNCOMMITTED

| 序号 | session 1                                                   | session 2                                                   | 事务外                   |
| ---- | ----------------------------------------------------------- | ----------------------------------------------------------- | ------------------------ |
| 1    | `set autocommit = 0;`                                       | `set autocommit = 0;`                                       |                          |
| 2    | `set session TRANSACTION ISOLATION level READ UNCOMMITTED;` | `set session TRANSACTION ISOLATION level READ UNCOMMITTED;` |                          |
| 3    | `BEGIN;`                                                    | `BEGIN;`                                                    |                          |
| 4    | `update tx_test set name='李四' where id = 1;`              |                                                             |                          |
| 5    | `select * from tx_test;`                                    | `select * from tx_test;`                                    | `select * from tx_test;` |
| 6    | `ROLLBACK;`                                                 |                                                             |                          |
| 7    |                                                             | `select * from tx_test;`                                    | `select * from tx_test;` |
|      |                                                             | `COMMIT`                                                    |                          |

第 4 步，session1 将数据进行更改后还未提交，session2 就读取到了；之后在第 6 步时，session1 对该数据进行了回滚，此时 session2 再次读取到的就是旧的数据，出现两次读取数据不一致的情况，就是脏读

第 5 步事务外进行读取的时候，读取到的还是原来的数据，因为事务外和事务内是隔离的

#### READ COMMITTED

| 序号 | session 1                                                 | session 2                                                 | 事务外                   |
| ---- | --------------------------------------------------------- | --------------------------------------------------------- | ------------------------ |
| 1    | `set autocommit = 0;`                                     | `set autocommit = 0;`                                     |                          |
| 2    | `set session TRANSACTION ISOLATION level READ COMMITTED;` | `set session TRANSACTION ISOLATION level READ COMMITTED;` |                          |
| 3    | `BEGIN;`                                                  | `BEGIN;`                                                  |                          |
| 4    | `update tx_test set name="李四" where id = 1;`            |                                                           |                          |
| 5    | `select * from tx_test;`                                  | `select * from tx_test;`                                  | `select * from tx_test;` |
| 6    | `COMMIT;`                                                 |                                                           |                          |
| 7    |                                                           | `select * from tx_test;`                                  | `select * from tx_test;` |
| 8    |                                                           | `COMMIT`                                                  |                          |

第 4 步中，session1 修改了数据，第 5 步 session2 读不到修改后的数据，在第 6 步 session1 提交事务后，session2 再次进行读取，就读取到了新的数据，出现 session2 前后两次读取的数据不一致的情况，就是不可重复读。

#### REPEATABLE READ

| 序号 | session 1                                                  | session 2                                                  | 事务外 |
| ---- | ---------------------------------------------------------- | ---------------------------------------------------------- | ------ |
| 1    | `set autocommit = 0;`                                      | `set autocommit = 0;`                                      |        |
| 2    | `set session TRANSACTION ISOLATION level REPEATABLE READ;` | `set session TRANSACTION ISOLATION level REPEATABLE READ;` |        |
| 3    | `BEGIN;`                                                   | `BEGIN;`                                                   |        |
| 4    |                                                            | `select * from tx_test;`                                   |        |
| 5    | `insert into tx_test values(2, '王五');`                   |                                                            |        |
| 6    | `COMMIT;`                                                  |                                                            |        |
| 7    |                                                            | `select * from tx_test;`                                   |        |
| 8    |                                                            | `update tx_test set name='赵六';`                          |        |
| 9    |                                                            | `COMMIT`                                                   |        |

session2 在第 4 步和第 7 步中读取到的都是一样的，所以解决了不可重复读的问题，但是当第 8 步中，session2 对数据进行更新的时候，会出现更新的数量比查询的数量多，所以就出现了幻读的情况

#### SERIALIAZABLE

串行化可以解决脏读，不可重复读，幻读，但是效率很差

## MongoDB 的写事务

[官方文档](https://docs.mongodb.com/manual/reference/write-concern/)

Write Concern 用于描述向独立 mongod 进程/副本集/分片集群进行写请求的确认级别。当客户端向 mongodb 发起写入请求后，每个 mongodb 写入成功都会给主节点返回 acknowledgment，来告知主节点其是否写入成功，主节点依据下方的不同配置，会将整体是否成功返回给客户端

表达式：`{ w: <value>, j: <boolean>, wtimeout: <number> }`

**w**：决定一个写操作落到多少个节点上才算成功，值包括：

- 0：发起写操作，不关心是否成功。
- 1：发起写操作，只要有一个实例写成功，即返回成功。是 MongoDB 的**默认值**
- (1, 副本集节点总数]：写操作需要全部复制到指定数目的节点上才算成功
- majority：写操作需要被复制到大多数节点上才算成功
- all：所有节点都写成功才算成功

**j**：是否要求数据必须写入到磁盘上的日志中

- true：数据只有刷写到磁盘的日志中后，才是成功
- false：数据只要写到内存，就算成功

**w**选项和**j**选项定义了 mongod 实例什么时候发送 ack

|              | j 未设置  | j：true   | j：false |
| ------------ | -------- | -------- | ------- |
| w：1        | 内存     | 磁盘日志 | 内存    |
| w：majority | 磁盘日志 | 磁盘日志 | 内存    |

**wtimeout**：指定一个时间限制，以防止写操作无限期地阻塞

### 实验

**使用之前搭建的一主两从的副本集进行操作**

1. 副本集中测试 writeConcern 参数

   ```mongodb
   db.test.insert({x:1},{writeConcern:{w:1}})
   db.test.insert({x:1},{writeConcern:{w:2}})
   db.test.insert({x:1},{writeConcern:{w:3}})
   db.test.insert({x:1},{writeConcern:{w:4}})
   db.test.insert({x:1},{writeConcern:{w:"majority"}})
   ```

   因为一共只有 3 个节点，所以当 w 是 4 的时候会写入失败

2. 模拟网络延迟

   ```mongodb
   conf=rs.conf()
   # 设置一个从节点延迟 10 秒再同步数据
   conf.members[1].slaveDelay=10
   # 不让这个从节点参与选举
   conf.members[1].priority=0
   # 刷新配置
   rs.reconfig(conf)
   ```

   再次执行 1 中的命令，当 w 是 3 的时候，会等待大约 10s 才会成功，因为需要 3 个节点都写入成功才会成功，但是其中一个节点有 10s 中的延迟同步

3. writeConcern 的其他参数

   ```mongodb
   db.test.insert({x:1},{writeConcern:{w:3}})
   # 设置 5s 返回
   db.test.insert({x:1},{writeConcern:{w:3,wtimeout:5000}})
   ```

   第二步中设置了从节点延迟 10 秒同步，然后在插入数据的时候设置超时时间是 5 秒，所以在第 5 秒的时候，主节点会返回超时提示，但是此时数据已经插入成功，并且 10 秒后，从节点会进行同步

**重要提示**

1. w:majority，要求过半数节点写入即代表成功，生产上重要数据可以这么设置，但不要设置等于有数据节点数。综合性能，majority 写延迟是最优的
2. wtimeout 默认值是 0，如果不设置，当不满足写入节点数条件下的时候，会无限期阻塞
3. wtimeout 设置时间后，在到达时间的时候会报警告，单数据已经写入，最好生产上监控起来
4. writeConcern 增加了写操作的延迟时间，但不会影响系统吞吐量，也不会显著增加服务器压力，因为写操作最终都会同步到所有节点上，只是影响了写操作的响应时间

## MongoDB 的读事务

有别与传统的关系型数据库，MongoDB 天生就是分布式数据库，所以在读数据的时候更关注如下两点:

1. 从哪里读？关注数据节点的位置
2. 什么样的数据可以读？关注数据的隔离性

第 1 点由 ReadPreference 解决，第 2 点由 ReadConcern 解决

### 读偏好（ReadPreference）

[ReadPreference](https://docs.mongodb.com/manual/core/read-preference/): 决定读取的数据来自哪个数据节点，可选值:

- primary：只读取主节点.**默认值**
- primaryPreferred：优先读取主节点，如果不可用则选择从节点
- secondary：只选择从节点
- secondaryPreferred：优先读取从节点，如果从节点不可用则选择主节点
- nearest：选择距离最近的节点

#### 使用场景

相当于 MySQL 的读写分离

- 时效性要求高，要求延迟很低或基本无延迟场景用 primary/primaryPreferred。例如用户下订单后马上跳转到订单详情页。
- 不太要求时效性场景用 secondary/secondaryPreferred，例如查询历史订单
- 时效性不高，但是资源需求大，避免影响线上资源用 secondary。例如业务监控、报表统计
- 国际化业务，数据中心同步的数据，读取最近节点用 nearest。例如用户头像数据分发

以上配置，只能控制读取一类节点，比如读取 secondary 节点。但是 secondary 中可能有 n 个节点，上述方法不能达到精准读取某一个节点，如果实现控制精准读取，可以为副本集设置 Tag
设置方法：

```mongodb
members[n].tags={ "<tag1>": "<string1>", "<tag2>": "<string2>",... }
```

示例: `members[n].tags={ "region": "south", "datacenter": "A"}`

如上，可以给某个节点打多个标签

#### 实验

**场景**

例如 5 个 MongoDB 集群的场景，其中有 3 台机器配置较高，2 台机器配置较差，此时就可以将线上业务的查询分发给 3 台性能较高的服务器，后台的统计和监控等的查询分发给性能较差的 2 台服务器。

1. 给 3 个较好的节点上打 `tags={"item":"online"}`

2. 给 2 个较差的节点上打 `tags={"item":"analyse"}`

3. 查询的时候可以指定从哪个节点查询

   ```mongodb
   db.collectionName.find({}).readPref("secondary",[{"item":"analyse"}])
   ```

#### 使用方式

##### Mongo Shell

```mongodb
db.collectionName.find({}).readPref("secondary",[{"item":"analyse"}])
```

##### MongoDB 的 JDBC 驱动 API

```java
MongoClient client = MongoClients.create(
    MongoClientSettings.builder()
    // 可以通过该方法设置读取策略，以及标签，超时时间等
    .readPreference(ReadPreference.secondaryPreferred())
    .build()
);
```

##### 通过 MongoDB 连接字符串

```shell
mongodb://192.168.254.211:28017,192.168.254.211:28018,192.168.254.211:28019/test?connect=replicaSet&slaveOk=true&replicaSet=rs0&readPreference=secondary
```

#### 相关命令

```mongodb
# 在从节点执行以下语句，关闭当前节点的数据同步
db.fsyncLock()
# 在从节点执行以下语句，打开当前节点的数据同步
db.fsyncUnlock()
```

#### 注意事项

1. 如果设置了 ReadPreference 时，应该注意高可用问题。如设置了 primary，主节点发生故障期间，业务系统将不可读取，如果业务允许，可以考虑 primaryPreferred

   > 如果设置了 primaryPreferred，然后主节点故障，此时只能保证系统可读，但是写数据会失败，因为 mongodb 集群只有主节点可写

2. 使用 Tag 也存在这样的问题，如果一个 Tag 只属于单一节点，发生故障的时候，将无节点可读，所以建议至少两个节点配置成同一个 Tag

3. tag 使用时，遵循的原则是考虑优先级，选举权因素。例如做监控或者报表的节点，不希望成为主节点，可以将优先级设置成 0

### ReadConcern

ReadPreference 决定从哪个节点读取后，[ReadConcern](https://docs.mongodb.com/manual/reference/read-concern/)决定这个节点上哪些数据可读。类似于关系型数据库的隔离级别。可选值有：

- local：读取所有可用且属于当前分片的数据。**默认值**
- available：读取所有分片上可用的数据
- majority：读取在大多数节点上提交完成的数据
- linearizable：与 majority 类似，读取大多数节点上提交完成的数据。和 majority 最大的区别是其线性化读取文档
- snapshot：读取最近快照中心的数据

**local 和 available 的区别**

在副本集上二者是没有缺别的，主要的区别是在分片集群的环境下

1. 一个 chunk x 正在从 shard1 向 shard2 迁移

   在迁移过程中，部分数据会在两个分片中同时存在，但是分片 shard1 仍是 chunk x 的负责方

   config 中记录的信息 chunk x 仍数据 shard1

#### local 和 majority 的对比

准备一主两从的 MongoDB 集群



![image-20210420194455206](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210420194456.png)

P：Primary

S1：Secondary1

S2：Secondary2

| 时间 | 事件                                                         | 普通读                         | 大多数读                       |
| ---- | ------------------------------------------------------------ | ------------------------------ | ------------------------------ |
| t0   | 在 P 写入 x=1<br/>此时 S1 和 S2 还未同步，所以只可以从 P 中读到数据<br/>同时此时 P 不知道 S1，S2 是否写完，所以大多数读都是 x=0 | P：x=1<br/>S1：x=0<br/>S2：x=0 | P：x=0<br/>S1：x=0<br/>S2：x=0 |
| t1   | S1 复制了 P 中的 x=1<br/>此时 S1 同步了 P 中的数据，所以可以从 S1 中读到 x=1<br/>但是此时只有 S1 知道自己有数据，其他节点不知道，所以大多数读都是 x=0 | P：x=1<br/>S1：x=1<br/>S2：x=0 | P：x=0<br/>S1：x=0<br/>S2：x=0 |
| t2   | S2 复制了 P 中的 x=1<br/>此时 S2 同步了 P 中的数据，所以可以从 S2 中读到 x=1<br/>但是此时只有 S2 知道自己有数据，其他节点不知道，所以大多数读都是 x=0 | P：x=1<br/>S1：x=1<br/>S2：x=1 | P：x=0<br/>S1：x=0<br/>S2：x=0 |
| t3   | S1 通知 P 写成功，P 向客户端返回写成功，然后 P 向 S1 发送确认通知<br/>此时 P 知道自己和 S1 写成功了，所以通过 P 大多数读可以读到 x=1<br/>但是 S1 只知道自己成功了，不知道其他节点是否成功，所以通过 S1 大多数读会读到 x=0 | P：x=1<br/>S1：x=1<br/>S2：x=1 | P：x=1<br/>S1：x=0<br/>S2：x=0 |
| t4   | S2 通知 P 已经写成功，然后 P 向 S2 发送确认通知<br/>此时 P 知道自己和 S1，S2 都写成功了，所以通过 P 大多数读可以读到 x=1<br/>但是 S2 只知道自己成功了，不知道其他节点是否成功，所以通过 S2 大多数读会读到 x=0 | P：x=1<br/>S1：x=1<br/>S2：x=1 | P：x=1<br/>S1：x=0<br/>S2：x=0 |
| t5   | S1 收到 P 的确认通知<br/>S1 知道自己和 P 都成功了，所以通过 S1 大多数读会读到 x=1 | P：x=1<br/>S1：x=1<br/>S2：x=1 | P：x=1<br/>S1：x=1<br/>S2：x=0 |
| t6   | S2 收到 P 的确认通知<br/>S2 知道自己和 P 都成功了，所以通过 S2 大多数读会读到 x=1 | P：x=1<br/>S1：x=1<br/>S2：x=1 | P：x=1<br/>S1：x=1<br/>S2：x=1 |

##### majority 实现原理

节点上维护了多个 x 版本，MVCC 的机制

MongoDB 的 ReadConcern 支持 majority 级别，需要如下两个支持：

1. 配置支持：MongoDb 默认配置了 `replication.enableMojorityReanConcer=true`
2. 存储引擎支持：wiredtiger 存储引擎作为 mongoDB 的默认存储引擎，支持 ReadCommited 的 majority 级别

当某个 MongoDB 节点有数据更新时，该节点就会起一个单独的 snapshot 线程，会周期性的对当前数据集进行 snapshot，并记录快照的最新 oplog 时间戳。只有确保 oplog 已经同步到大多数节点时，对应的 snapshot 才会标记为 commmited，用户读取时，根据 readPreference 选出一个节点，从其最新的 commited 状态的 snapshot 读取数据，就能保证读到的数据一定已经同步到的大多数节点。

| 最新 oplog 时间戳 | P            | S1            | S2            | 状态        | 描述                                                         |
| --------------- | ------------ | ------------- | ------------- | ----------- | ------------------------------------------------------------ |
| t0              | P-snapshot-0 |               |               | uncommitted | 向 P 中写入数据，P 的数据改变，所以 P 生成快照                    |
| t1              |              | S1-snapshot-0 |               | uncommitted | S1 复制 P 中的数据，S1 的数据改变，所以 S1 生成快照                |
| t2              |              |               | S2-snapshot-0 | uncommitted | S2 复制 P 中的数据，S2 的数据改变，所以 S2 生成快照                |
| t3              | P-snapshot-1 |               |               | committed   | S1 通知了 P 写入成功，P 中的数据改变，所以 P 生成快照<br/>P 知道数据已经同步到大多数节点，所以快照状态为 committed |
| t4              | P-snapshot-2 |               |               | committed   | S2 通知了 P 写入成功，P 中的数据改变，所以 P 生成快照<br/>P 知道数据已经同步到大多数节点，所以快照状态为 committed |
| t5              |              | S1-snapshot-1 |               | committed   | P 通知 S1 大多数写入成功，S1 中数据改变，所以 S1 生成快照<br/>S1 知道数据已经同步到大多数节点，所以快照状态为 committed |
| t6              |              |               | S2-snapshot-1 | committed   | P 通知 S2 大多数写入成功，S2 中数据改变，所以 S2 生成快照<br/>S2 知道数据已经同步到大多数节点，所以快照状态为 committed |

P 中的 P-snapshot-2，S1 中的 S1-snapshot-1，S2 中的 S2-snapshot-1 都是同步到大多数节点的快照数据，所以从这三个中读取到的数据是一致的。

**Primary 节点**

Secondary 节点在自身 oplog 发生变化时，会通过 `replSetUpdatePosition` 命令来将 oplog 进度立即通知给 Primary，另外心跳的消息里也会包含最新的 oplog 的信息；通过上述方式，primary 节点就能很快知道 oplog 同步的情况，知道**最新一条已经同步到大多数节点的 oplog**，并更新 snapshot 的状态。比如当 t3 已经写入到大多数节点时，P-snapshot-1 会被更新为 commited 状态。（不必要的 snapshot 也会被定期清理掉）

**Secondary 节点**

Secondary 节点拉取 oplog 时，primary 节点会将**最新一条已经同步到大多数节点的 oplog**的信息返回给 Secondary 节点，Secondary 节点通过这个 oplog 时间戳来更新自身的 snapshot 状态

##### 实验

对比"majority"和"local"

1. 使用之前的一主两从的 MongoDB 副本集

2. 对两个从节点执行如下语句，禁止从节点从主节点复制数据

   ```mongodb
   db.fsyncLock()
   ```

3. 在主节点中插入数据

   ```mongodb
   db.test.insert({x:1})
   ```

4. 在主节点中执行查询

   ```mongodb
   db.test.find().readConcern("local")
   ```

   使用 local 级别可以查询到数据

5. 在主节点执行查询

   ```mongodb
   # 因为查不到数据，所以会一直阻塞
   db.test.find().readConcern("majority")
   # 可以使用 maxTimeMS 设置超时时间，5 秒后查不到数据就直接失败
   db.test.find().readConcern("majority").maxTimeMS(5000)
   ```

   使用 majority 级别不能查询到数据，因为一共有 3 个节点，2 个节点没有进行同步，所以大多数节点没有写成功，所以读大多数节点是读不到的

##### 解决脏读

ReadConcern 的设计初衷就是为了解决数据的脏读问题

**ReadConcern:majority 相当于关系数据库的 READ COMMITTED**

写操作在到达大多数节点之前都是不安全的，一旦主节点崩溃，从节点还没有复制到该数据，刚才写的数据就相当于丢失了。

> 例如：向主节点写入 x=1，从节点都还没有将该数据进行同步，然后主节点就崩溃了，此时我们通过 ReadConcern 的 majority 进行读取，是读取不到该数据的，所以相当于该数据丢失了。
>
> // TODO
>
> t3 时刻，P 和 S1 中都写成功了，然后 P 给客户端返回的是写成功，然后 P 崩溃，此时因为 S1 没有收到 P 的确认通知，所以 S1 上新数据的快照没有变为 committed 的，重新选举节点后，是查询不到这条数据的，但是 P 之前给客户端返回写入成功了

把一次写入看成是一次事务，如果向主节点写入的数据被大多数节点同步了，此时可以看成事务被提交了，通过 ReadConcern 的 majority 可以获取到该数据；如果向主节点写入的数据没有被大多数节点同步，此时可以看成事务被回滚了，通过 ReadConcern 的 majority 不能读取到该数据

使用 ReadConcern:majority 可以有效避免脏读问题

##### ReadPreference+WriteConcern+ReadConcern 实现安全的读写分离

场景：一般主从架构，在主节点写入，从从节点读取

```mongodb
# 在主节点插入数据
db.orders.insert({"id":1,"sku":"a",price:50})
# 从从节点查询数据
db.orders.find({"id":1}).readPref("secondary")
```

上方语句是不安全的，向主节点写入之后，多个从节点有可能有的复制成功了，有的没复制成功，那就会出现不同的线程读取到的数据是不一样的，有的能读取到，有的读取不到。

要保证安全的读写，需要使用如下语句

```mongodb
# 在主节点插入数据，保证大多数写成功
db.orders.indert({"id":1,"sku":"a",price:50},{writeConcern:{w:"majority"}})
# 在从节点读取数据，大多数节点写成功，读大多数才能成功，否则就查不到数据
db.orders.find({"id":1}).readPref("secondary").readConcern("majority")
```

保证只有大多数写成功后，大多数读才能读到数据，如果大多数写还没成功，大多数读是读不到数据的

#### linearizable

和 majority 相同，只读取大多数节点确认过的数，但是和 majority 最大差别是绝对保证操作的线性顺序：在写操作自然时间后面发生的读，一定可以读到之前的写

**分析 majority 的问题**

![image-20210421160136791](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210421160138.png)

| 时间 | 状态描述                                                     |
| ---- | ------------------------------------------------------------ |
| t0   | 初始状态：1 主 2 从，x=1                                        |
| t1   | 某些客户端连接在了 P 上，但是由于网络原因，P 节点与 S 节点失联    |
| t2   | 选举出了新的主节点 P1（某些客户端依旧与 P 连接）                  |
| t3   | 有新的客户端连接到了 P1，并将 x 修改为 2（某些客户端依旧与 P 连接）  |
| t4   | 之前连接在 P 上的客户端，查询 x 的值，读到 x=1; 新的客户端从 P1 读取数据，读到 x=2 |

linearizable 的实现原理是在 read 操作之前添加了一个空的写操作，如果当前 Primary 节点是离线的，进程尚在，仍然可能有连接的查询，空的写操作就会失败，从而被检查出来。

linearizable 只对读单个文档有效，并且可能会导致非常慢的读，所以可以配合 maxTimeMS 设置超时时间一起使用

#### snapshot

相当于关系数据库的 SERIALIAZABLE

- 只在多文档事务中生效
- 不出现脏读
- 不出现不可重复读
- 不出现幻读

因为所有的读都使用同一个快照，直到事务提交为止该快照才被释放

#### 生产事故分析

一般产生事故的原因：

- 代码明显错误，未经过代码 cr

- 不和操作规范的数据运维故障

  > 例如使用了错误的 sql 语句，对大面积数据进行了更新操作

- 代码深度 bug，长久未发现，可能是单一 bug，也可能实时组合 bug 负负得正，修正某一处，导致其他 bug

  > 例如两个 bug，当它们都存在的时候，系统可以运行，但是修正其中一个之后，另一个 bug 才暴露出来

- 设计不合理，上线复杂，后台易用性，可用性差

  > 例如配置方式复杂，操作页面操作复杂，造成误操作等

- 机器容量评估不充分，流量打爆服务器

- 相关技术使用不规范，偶现生产事故。

  > 例如主从读取设置不合理，从节点读取不到。或者某一时刻从节点读取飙高，造成从节点 CPU 使用率飙高，从而造成从节点复制数据延迟

#### 性能影响

WriteConcern 只是稍微影响了写操作的响应时间，但是不会影响系统的吞吐量。

ReadPreference 可以实现读写分离，也不会影响集群的性能。

ReadConcern 由于每次在写操作的时候，都会创建 snapshot 快照，这些快照都存储在 cache 中，会对性能有一定的损耗，性能大约降低 30%，如下图：

![image-20210420224628461](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210420224631.png)

## MongoDB 的多文档事务

MongoDB 虽然从 4.2 开始全面支持多文档事务，但不代表可以毫无节制的使用。通过合理的设计文档模型，可以规避大部分使用事务的必要性。

事务，就代表着锁，节点协调，网络沟通，性能降低。

能不用就不用

### ACID 多文档事务支持

| 事务属性            | 支持程度                                                     |
| ------------------- | ------------------------------------------------------------ |
| 原子性（Atomocity）   | 单表：1.x 支持<br/>副本集多表多行：4.0<br/>分片集群多表多行：4.2 |
| 一致性（Consistency） | writeConcern, readConcern（3.2）                               |
| 隔离性（Isolation）   | ReadConcern(3.2)                                             |
| 持久性（Durability）  | journal and replication                                      |

### 事务的隔离性

事务完成前，事务外的操作对该事务所做的修改，不可访问

1. 先插入两条测试数据

   ```mongodb
   db.test.insertMany([{x:1},{x:2}]);
   ```

2. 在第一个窗口使用事务进行操作

   ```mongodb
   # 开启一个事务
   var session=db.getMongo().startSession();
   session.startTransaction();
   var coll = session.getDatabase("test").getCollection("test");
   # 更新数据
   coll.updateOne({x:1},{$set:{y:2}});
   # 在事务内读取，可以读取到事务修改的数据
   coll.find();
   # 在事务外读取，不能读取到事务修改的数据
   db.test.find();
   # 事务回滚
   session.abortTransaction();
   # 事务提交
   session.commitTransaction()
   ```

MongoDB 的 session 事务如果超过 1 分钟没有提交/回滚，会自动回滚

### 实验：可重复读

```mongodb
# 开启一个事务
var session=db.getMongo().startSession();
# 对该事务设置 snapshot 级别的读和 majority 级别的写，保证数据的一致性
session.startTransaction({readConcern:{level:"snapshot"},writeConcern:{w:"majority"}});
var coll = session.getDatabase("test").getCollection("test");
coll.find();
 
db.test.updateOne({x:1},{$set:{y:1}});
db.test.find();
session.abortTrancsaction();
```

### 实验：写冲突

| session 1                                                    | session 2                                                    | 事务外                                   | 描述                                                         |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ---------------------------------------- | ------------------------------------------------------------ |
| `var session = db.getMongo().startSession();`<br/>`session.startTransaction({readConcern:{level:"snapshot"},writeConcern:{w:"majority"}});`<br/>`var coll = session.getDatabase("test").getCollection("test");` | `var session = db.getMongo().startSession();`<br/>`session.startTransaction({readConcern:{level:"snapshot"},writeConcern:{w:"majority"}});`<br/>`var coll = session.getDatabase("test").getCollection("test");` |                                          | 两个会话都开启事务                                           |
| `coll.updateOne({x:1},{$set:{y:1}});`                        |                                                              |                                          | session1 更新数据                                             |
|                                                              | `coll.updateOne({x:1},{$set:{y:2}});`                        | `db.test.update({x:1},{$set:{y:4}})`阻塞 | session2 也更新数据，此时 session2 会报错。如果在事务外也对该数据进行更新，就会阻塞 |
| `session.commitTransaction();`                               |                                                              | 成功                                     | session1 提交后，事务外的更改才会成功                         |
|                                                              | `var session = db.getMongo().startSession();`<br/>`session.startTransaction({readConcern:{level:"snapshot"},writeConcern:{w:"majority"}});`<br/>`var coll = session.getDatabase("test").getCollection("test");` |                                          | session2 需要重新开启事务进行操作                             |
|                                                              | `coll.updateOne({x:1},{$set:{y:2}});`                        |                                          | session2 等到 session1 事务结束后才能更新成功数据               |

## Java 中 MongoDB 事务的使用

1. 引入依赖

   ```xml
   <dependency>
       <groupId>org.mongodb</groupId>
       <artifactId>mongodb-driver-sync</artifactId>
       <version>4.0.4</version>
   </dependency>
   ```

2. 测试类

   ```java
   package com.example.mongodbtransactionjava;
   
   import com.mongodb.ReadConcern;
   import com.mongodb.ReadPreference;
   import com.mongodb.TransactionOptions;
   import com.mongodb.WriteConcern;
   import com.mongodb.client.*;
   import org.bson.Document;
   
   public class TestMain {
   
   
       static String URI = "mongodb://192.168.56.101:28017,192.168.56.102:28018,192.168.56.103:28019/test?connect=replicaSet&slaveOk=true&replicaSet=rs0";
   
       public static void main(String[] args) {
           // 1. 获取客户端
           MongoClient client = MongoClients.create(URI);
   
           // 2. 创建一个 session
           ClientSession session = client.startSession();
           // 3. 定义 session 的选项
           TransactionOptions txOptions = TransactionOptions.builder()
                   .readPreference(ReadPreference.primary())
                   .readConcern(ReadConcern.LOCAL)
                   .writeConcern(WriteConcern.MAJORITY)
                   .build();
           // 4. 创建 session 内操作
           TransactionBody<String> txBody = () -> {
               MongoCollection<Document> coll1 = client.getDatabase("mydb1").getCollection("foo");
               MongoCollection<Document> coll2 = client.getDatabase("mydb2").getCollection("bar");
   
               coll1.insertOne(session, new Document("abc", 2));
               coll2.insertOne(session, new Document("xyz", 9990));
   
               System.out.println(1 / 0);
               return "Insert into collections in different databases";
           };
   
           try {
               // 5. 执行事务
               session.withTransaction(txBody, txOptions);
               // 6. 提交事务
               session.commitTransaction();
           } catch (Exception e) {
               // 7. 发生异常，回滚事务
               session.abortTransaction();
           } finally {
               // 8. 关闭事务
               session.close();
           }
       }
   }
   ```

## SpringBoot 操作 MongoDB 事务

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
         uri: mongodb://mongodb://192.168.56.101:28017,192.168.56.102:28018,192.168.56.103:28019/test?connect=replicaSet&slaveOk=true&replicaSet=rs0
   ```

3. 配置 MongoDB 的事务管理器

   ```java
   package com.example.mongodbspring.config;
   
   import org.springframework.context.annotation.Bean;
   import org.springframework.context.annotation.Configuration;
   import org.springframework.data.mongodb.MongoDatabaseFactory;
   import org.springframework.data.mongodb.MongoTransactionManager;
   
   @Configuration
   public class TransactionConfig {
       @Bean
       public MongoTransactionManager mongoTransactionManager(MongoDatabaseFactory factory) {
           return new MongoTransactionManager(factory);
       }
   }
   ```

4. 创建两个不同的文档类

   ```java
   package com.example.mongodbspringreplic.entity;
   
   import org.springframework.data.mongodb.core.mapping.Document;
   
   @Document(collection = "apple")
   public class Apple {
   
       private String color;
   
       private Integer price;
   
       public Apple(String color, Integer price) {
           this.color = color;
           this.price = price;
       }
   }
   ```

   ```java
   package com.example.mongodbspringreplic.entity;
   
   import org.springframework.data.mongodb.core.mapping.Document;
   
   @Document(collection = "banana")
   public class Banana {
   
       private String color;
   
       private Integer price;
   
       public Banana(String color, Integer price) {
           this.color = color;
           this.price = price;
       }
   }
   ```

5. 在服务层调用

   ```java
   package com.example.mongodbspringreplic.service;
   
   import com.example.mongodbspringreplic.entity.Apple;
   import com.example.mongodbspringreplic.entity.Banana;
   import org.springframework.beans.factory.annotation.Autowired;
   import org.springframework.data.mongodb.core.MongoTemplate;
   import org.springframework.stereotype.Service;
   import org.springframework.transaction.annotation.Transactional;
   
   @Service
   public class TransactionTestService {
   
       @Autowired
       private MongoTemplate mongoTemplate;
   
       /**
        * 跟使用 MySQL 等的事务一样，添加 Transactional 注解即可
        */
       @Transactional(rollbackFor = Exception.class)
       public void test() {
           Apple apple = new Apple("红色", 10);
           Banana banana = new Banana("黄色", 20);
           mongoTemplate.insert(apple);
           mongoTemplate.insert(banana);
           // 出现异常会自动回滚
           System.out.println(1 / 0);
       }
   }
   ```
