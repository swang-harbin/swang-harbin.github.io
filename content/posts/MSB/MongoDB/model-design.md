---
title: MongoDB 模型设计
date: '2020-07-04 00:00:00'
tags:
- MSB
- Database
- MongoDB
- Java
---
# MongoDB 模型设计

数据模型是一组符号，文本组成的集合，用以准确表达信息，达到有效交流，沟通的目的

## 组成元素

### 实体 Entity

描述业务的主要数据集合

是，什么，合适，何地，为何，如何

### 属性 Attribute

描述实体里面的单个信息

### 关系 Relationship

描述实体与实体之间的数据规则

- 结构规则，1-N，N-1，N-N
- 引用规则：电话号码不能单独存在

## 概念-逻辑-物理

|            | 概念模型 CDM                                        | 逻辑模型 LDM                                      | 物理模型 PDM                                                  |
| ---------- | -------------------------------------------------- | ------------------------------------------------ | ------------------------------------------------------------ |
| 目的       | 描述业务系统要管理的对象                           | 基于概念模型，详细列出所有实体，实体的属性及关系 | 根据概念模型，结合数据库的物理结构，设计具体的表结构，字段列表及主外键 |
| 特点       | 用概念名词来描述现实中的实体及业务规则，如“联系人” | 基于业务的描述，和数据库无关                     | 技术实现细节，和具体的数据库类型相关                         |
| 主要使用者 | 用户--需求分析师                                   | 需求分析师-架构师及开发者                        | 开发者，DBA                                                  |

### 示例

#### 概念模型

- 客户信息
- 服务信息

#### 逻辑模型

![image-20210419222649037](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210419222653.png)

#### 物理模型

一般关系数据库涉及原则，遵循第三范式，数据在数据库里尽量不存在冗余。现在通常反三范式

![image-20210419222744256](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210419222746.png)

## 关系型数据库建模原则

### 一、基础规范

1. 必须使用 InnoDB 存储引擎

   解读：支持事务、行级锁、并发性能更好、CPU 及内存缓存页优化使得资源利用率更高

2. 必须使用 UTF8 字符集

   解读：万国码，无需转码，无乱码风险，节省空间

3. 数据表、数据字段必须加入中文注释

   解读：N 年后谁知道这个 r1，r2，r3 字段是干嘛的

4. 禁止使用存储过程、视图、触发器、Event

   解读：高并发大数据的互联网业务，架构设计思路是“解放数据库 CPU，将计算转移到服务层”，并发量大的情况下，这些功能很可能将数据库拖死，业务逻辑放到服务层具备更好的扩展性，能够轻易实现“增机器就加性能”。数据库擅长存储与索引，CPU 计算还是上移吧

5. 禁止存储大文件或者大照片

   解读：为何要让数据库做它不擅长的事情？大文件和照片存储在文件系统，数据库里存 URI 多好

### 二、命名规范

1. 只允许使用内网域名，而不是 ip 连接数据库

2. 线上环境、开发环境、测试环境数据库内网域名遵循命名规范

   业务名称：xxx

   线上环境：my10000m.mysql.jddb.com

   开发环境：yf10000m.mysql.jddb.com

   测试环境：test10000m.mysql.jddb.com

   从库在名称后加 -s 标识，备库在名称后加 -ss 标识

   线上从库：my10000sa.mysql.jddb.com

3. 库名、表名、字段名：小写，下划线风格，不超过 32 个字符，必须见名知意，禁止拼音英文混用
4. 表名 t_xxx，非唯一索引名 idx_xxx，唯一索引名 uniq_xxx

### 三、表设计规范

1. 单实例表数目必须小于 500

2. 单表列数目必须小于 30

3. 表必须有主键，例如自增主键

   解读：

   a）主键递增，数据行写入可以提高插入性能，可以避免 page 分裂，减少表碎片提升空间和内存的使用

   b）主键要选择较短的数据类型，Innodb 引擎普通索引都会保存主键的值，较短的数据类型可以有效的减少索引的磁盘空间，提高索引的缓存效率

   c）无主键的表删除，在 row 模式的主从架构，会导致备库夯住

4. 禁止使用外键，如果有外键完整性约束，需要应用程序控制

   解读：外键会导致表与表之间耦合，update 与 delete 操作都会涉及相关联的表，十分影响 sql 的性能，甚至会造成死锁。高并发情况下容易造成数据库性能，大数据高并发业务场景数据库使用以性能优先

### 四、字段设计规范

1. 必须把字段定义为 NOT NULL 并且提供默认值

   解读：

   a）null 的列使索引/索引统计/值比较都更加复杂，对 MySQL 来说更难优化

   b）null 这种类型 MySQL 内部需要进行特殊处理，增加数据库处理记录的复杂性；同等条件下，表中有较多空字段的时候，数据库的处理性能会降低很多

   c）null 值需要更多的存储空，无论是表还是索引中每行中的 null 的列都需要额外的空间来标识

   d）对 null 的处理时候，只能采用 `is null` 或 `is not null`，而不能采用 `=`、`in`、`<`、`<>`、`!=`、`not in` 这些操作符号。如：`where name!='shenjian'`，如果存在 name 为 null 值的记录，查询结果就不会包含 name 为 null 值的记录

2. 禁止使用 TEXT、BLOB 类型

   解读：会浪费更多的磁盘和内存空间，非必要的大量的大字段查询会淘汰掉热数据，导致内存命中率急剧降低，影响数据库性能

3. 禁止使用小数存储货币

   解读：使用整数吧，小数容易导致钱对不上

4. 必须使用 varchar(20) 存储手机号

   解读：

   a）涉及到区号或者国家代号，可能出现 `+-()`

   b）手机号会去做数学运算么？

   c）varchar 可以支持模糊查询，例如：`like "138%"`

5. 禁止使用 ENUM，可使用 TINYINT 代替

6. status 禁止这么用，你要写成有逻辑意义得字段，比如用户状态，userStatus，is_delete，不要存成 int 类型，而是用 TINYINT


   解读：

   a）增加新的 ENUM 值要做 DDL 操作

   b）ENUM 的内部实际存储就是整数，你以为自己定义的是字符串？

### 五、索引设计规范

1. 单表索引建议控制在 5 个以内

2. 单索引字段数不允许超过 5 个

   解读：字段超过 5 个时，实际已经起不到有效过滤数据的作用了

3. 禁止在更新十分频繁、区分度不高的属性上建立索引

   解读：

   a）更新会变更 B+树，更新频繁的字段建立索引会大大降低数据库性能

   b）“性别”这种区分度不大的属性，建立索引是没有什么意义的，不能有效过滤数据，性能与全表扫描类似

4. 建立组合索引，必须把区分度高的字段放在前面

   解读：能够更加有效的过滤数据

### 六、SQL 使用规范

1. 禁止使用 `SELECT *`，只获取必要的字段，需要显示说明列属性

   解读：

   a）读取不需要的列会增加 CPU、IO、NET 消耗

   b）不能有效的利用覆盖索引

   c）使用 `SELECT *` 容易在增加或者删除字段后出现程序 BUG

2. 禁止使用 `INSERT INTO t_xxx VALUES(xxx)`，必须显示指定插入的列属性

   解读：容易在增加或者删除字段后出现程序 BUG

3. 禁止使用属性隐式转换

   解读：`SELECT uid FROM t_user WHERE phone=13800000000` 会导致全表扫描，而不能命中 phone 索引，猜猜为什么？（这个线上问题不止出现过一次）

4. 禁止在 WHERE 条件的属性上使用函数或者表达式

   解读：`SELECT uid FROM t_user WHERE from_unixtime(day)>='2017-01-15'` 会导致全表扫描

   正确的写法是：`SELECT uid FROM t_user WHERE day>= unix_timestamp('2017-01-15 00:00:00')`

6. 禁止负向查询，以及%开头的模糊查询

   解读：

   a）负向查询条件：`NOT`、`!=`、`<>`、`!<`、`!>`、`NOT IN`、`NOT LIKE` 等，会导致全表扫描

   b）`%` 开头的模糊查询，会导致全表扫描

7. 禁止大表使用 JOIN 查询，禁止大表使用子查询

   解读：会产生临时表，消耗较多内存与 CPU，极大影响数据库性能

8. 禁止使用 OR 条件，必须改为 IN 查询

   解读：旧版本 Mysql 的 OR 查询是不能命中索引的，即使能命中索引，为何要让数据库耗费更多的 CPU 帮助实施查询优化呢？

9. 应用程序必须捕获 SQL 异常，并有相应处理

10. 同表的增删字段、索引合并一条 DDL 语句执行，提高执行效率，减少与数据库的交互。

### 总结

大数据量高并发的互联网业务，极大影响数据库性能的都不让用。

## 实践建模流程

### 基础建模

#### 确定对象

需求分析，找出系统中需要的逻辑模型

- 客户

- 企业性质（个体，工商，国企，外企。。。）

- 公司地址

- 销售人员

#### 明确关系

列出实体之间的关系

- 一个客户只有一个企业性质（1-1）
- 一个客户有多个地址（办公，注册，分公司等）（1-N）
- 一个客户，可以有多个销售人员跟进处理，一个销售人员也可以管理多个客户（N-N）

#### 根据关系建模

##### 1-1

- 基本原则：一对一关系以内嵌为主，或者直接在文档中存有字段即可
- 例外情况：内嵌后，不应是文档过大超出 16M 限制
  [官方文档](https://docs.mongodb.com/manual/reference/limits/index.html) 说明 BSON 文件的最大大小为 16 兆字节。
- 最大文档大小有助于确保单个文档不会使用过多的 RAM，或者在传输过程中不会使用过多的带宽

##### 1-N

- 基本原则：一对多同样以内嵌为主，用数组来表示一对多
- 例外情况：内前后文档大小不能超过 16M，数组长度太大（数万，其实 1000 以上，查询性能就会降低），数组长度无法确定（需求决定）

##### N-N

- 基本原则：不需要映射表，一般用内嵌数据来表示一对多，通过冗余来实现 N-N
- 例外情况：内前后文档大小不能超过 16M，数组长度太大（数万，其实 1000 以上，查询性能就会降低），数组长度无法确定（需求决定）

### 优化细节

使用引用避免性能瓶颈，使用冗余优化访问性能。能冗余就冗余，不能冗余再用引用。

### 套用设计模式

MongoDB 的文档是需要设计的，并且实践中，需要了解读写比例等因素，如同关系型数据库类似，特定问题，mongodb 也有特定的景点设计模式可以参考

[官方文档](https://www.mongodb.com/blog/search/Daniel%20Coupal)

#### 多态模式（Polymorphic）

当集合中的所有文档都具有相似但不相同的结构时，我们将其称为多态模式。如前所述，当我们希望从单个集合中访问（查询）信息时，多态模式非常有用。根据我们要运行的查询将文档分组在一起（而不是将其分散在多个表或集合中）有助于提高性能。

假设我们有一个应用程序用来跟踪所有不同运动项目的专业运动员。

我们仍然希望能够在应用程序中访问所有的运动员，但每个运动员的属性都不尽相同，这就是多态模式可以发挥作用的地方。在下面的示例中，我们将来自两个不同项目运动员的数据存储在同一个集合中。即使文档在同一集合中，存储的关于每个运动员的数据也不必须是相同的。

![image-20210420081826028](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210420081829.png)

对于职业运动员的记录既有相似之处也有不同之处。使用多态模式，我们可以很容易地适应这些差异。如果不使用多态模式，我们可能会有一个保龄球运动员的集合和一个网球运动员的集合。当我们想询问所有运动员时，我们需要进行耗时且复杂的连接操作（join）。相反，由于我们使用了多态模式，我们所有的数据都存储在一个运动员集合中，通过一个简单的语句就可以完成对所有运动员的查询。
这种设计模式也可以使用在嵌入式子文档中。在上面的例子中，Martina Navratilova 不仅仅是作为一名单独的选手参加比赛，所以我们可能希望她的记录结构如下：

![image-20210420081854087](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210420081857.png)

从应用程序开发的角度来看，当使用多态模式时，我们将查看文档或子文档中的特定字段，以便能够跟踪差异。例如，我们知道一个网球运动员可能参加不同的项目，而另一个运动员可能不参加。这通常需要应用程序基于给定文档中的信息选择不同的代码路径。或者，可能会编写不同的类或子类来处理网球、保龄球、足球和橄榄球运动员之间的差异。

**示例用例**

多态模式的一个示例用例是单一视图应用程序。假设你在一家公司工作，随着时间的推移，这家公司以其技术和数据模式收购了其它公司。假如每家公司都有许多数据库，每个都以不同的方式为“向客户提供的保险”建模。然后你购买了这些公司，并希望将所有这些系统集成到一起。而将这些不同的系统合并到一个统一的 SQL 模式中是一项既昂贵又费时的工作。
Metlife 能够在几个月内利用 MongoDB 和多态模式构建他们的单一视图应用程序。他们的单一视图应用程序将来自多个来源的数据聚合到一个中央存储库中，从而使客户服务、保险代理、计费还有其它部门能够 360°了解一个客户。这使得他们能够以较低的成本为客户提供更好的服务。此外，利用 MongoDB 的灵活数据模型和多态模式，开发团队能够快速创新，使其产品上线。
单一视图应用程序是多态模式的一个用例。它也适用于产品目录，例如自行车和鱼竿具有不同的属性。我们的运动员示例可以很容易地扩展到一个更完善的内容管理系统中，并在其中使用多态模式。

**结论：**
当文档具有更多的相似性而不是差异性时，就会使用多态模式。这种模式设计的典型用例是：

- 单一视图应用程序
- 内容管理
- 移动应用程序
- 产品目录

####  属性模式（Attribute）

假设现在有一个关于电影的集合。其中所有文档中可能都有类似的字段：标题、导演、制片人、演员等等。假如我们希望在上映日期这个字段进行搜索，这时面临的挑战是“哪个上映日期”？在不同的国家，电影通常在不同的日期上映。

![image-20210420082028215](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210420082031.png)

搜索上映日期需要同时查看多个字段。为了快速进行搜索，我们需要在电影集合中使用多个索引：

![image-20210420082036632](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210420082040.png)

使用属性模式，我们可以将此信息移至数组中并减少对索引需求。我们将这些信息转换成一个包含键值对的数组：

![image-20210420082048795](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210420082051.png)

通过在数组中的元素上创建一个这样的索引，索引变得更易于管理：{"releases.location": 1,"releases.date": 1}

使用属性模式，我们可以将组织信息添加到文档中，在获取通用特征的同时以应对罕见的/不可预测的字段，比如在一个新节日或小节日里上映的电影。此外，使用键/值约定允许非确定性命名（non-deterministic naming）并且可以很容易地添加限定符（qualifiers）。假如我们有一个关于瓶装水的数据集合，那么它们的属性可能看起来是这样：

![image-20210420082100089](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210420082103.png)

这里我们将信息分为键和值 “k” 和 “v”，并添加第三个字段 “u”，允许度量单位单独存储。

**应用场景**

属性模式非常适合具有相同值类型的字段集（如日期列表）。它在处理产品特性时也能很好地工作。有些产品，如服装，可能具有以小、中、大来表示的尺码，同一集合中的其他产品可以用体积表示，其它的可以用实际尺寸或重量来表示。
一个资产管理领域的客户最近使用属性模式部署了他们的解决方案。客户使用该模式存储给定资产的所有特征。这些特征在资产中很少常见，或者在设计时很难预见到。关系模型通常使用复杂的设计过程以用户定义字段的形式表达这样的思想。
虽然产品目录中的许多字段类似，例如名称、供应商、制造商、原产地等，但产品的规格或属性可能有所不同。如果应用程序和数据访问模式依赖于需要同时搜索这些不同字段，那么属性模式为数据提供了一个良好的结构。

**结论：**
属性模式特别适用于以下情况：

- 我们有一些大文档，它们有很多相似的字段，而这些字段的一个子集具有共同的特征，我们希望对该子集字段进行排序或查询；
- 我们需要排序的字段只能在一小部分文档中找到；
- 或上述两个条件均满足。

出于性能原因考虑，为了优化搜索我们可能需要许多索引以照顾到所有子集。创建所有这些索引可能会降低性能。属性模式为这种情况提供了一个很好的解决方案。

####  桶模式（Bucket）

随着数据在一段时间内持续流入（时间序列数据），我们可能倾向于将每个测量值存储在自己的文档中。然而，这种倾向是一种非常偏向于关系型数据处理的方式。如果我们有一个传感器每分钟测量温度并将其保存到数据库中，我们的数据流可能看起来像这样：

![image-20210420082205715](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210420082208.png)

随着我们的应用程序在数据和索引大小上的扩展，这可能会带来一些问题。例如，我们可能最终不得不对每次测量的 sensor_id 和 timestamp 进行索引，实现以内存为代价的快速访问。但利用文档数据模型，我们可以按时间将这些数据“以桶的方式”储存到特定时间片测量值的文档中。我们还可以通过编程方式向每一个“桶”中添加附加信息。
通过将桶模式应用于数据模型，我们可以在节省索引大小、简化潜在的查询以及在文档中使用预聚合数据的能力等方面获得一些收益。获取上面的数据流并对其应用桶模式，我们可以得到：

![image-20210420082217541](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210420082220.png)

使用桶模式，我们将数据“封装”到一个小时的桶中。这个特定的数据流仍然在增长，因为它目前只有 42 个测量值；这个小时还有更多的测量值要添加到“桶”中。当它们添加到 measurements 数组中时，transaction_count 将增加，并且 sum_temperature 也将更新。有预先聚合的 sum_temperature 值，就可以很容易拉出一个特定的存储桶并确定该桶的平均温度（sum_temperature / transaction_co-unt）。在处理时间序列数据时，知道 2018 年 7 月 13 日加利福尼亚州康宁市下午 2:00 至 3:00 的平均温度通常比知道下午 2:03 那一时刻的温度更有意义也更重要。通过用桶组织数据并进行预聚合，我们可以更轻松地提供这些信息。
此外，随着我们收集的信息越来越多，为了更高效我们可能决定将源数据进行归档。你想我们多久才会需要访问从 1948 年开始康宁市的温度？能够将这些数据桶移动到数据存档中是一项很大的收益。

**应用场景示例**

有一个 Bosch 的物联网实现可以成为时间序列数据在现实世界中体现价值的一个例子。他们将 MongoDB 和时间序列数据应用于一个汽车业的数据程序中。该应用程序从整个车辆的各种传感器中获取数据，从而提高车辆本身的诊断能力和部件性能。
其它一些例子还包括在银行的金融程序中使用这种模式将交易进行分组。

**结论**

处理时间序列数据时，在 MongoDB 中使用桶模式是一个很好的选择。它减少了集合中的文档总数，提高了索引性能，并且通过预聚合简化了数据访问。

#### 异常值模式（Outlier）

之前的几种设计模式，尽管文档的模式略有不同，但从应用程序和查询的角度来看，文档的结构基本上是一致的。然而，如果情况并非如此会怎么样？当有数据不属于“正常”模式时会发生什么？如果有异常值怎么办？
假设你正在搭建一个出售图书的电子商务网站，你可能会想查询“有哪些人购买了某本特定的书”。这对于一个可以向顾客展示他感兴趣书籍的推荐系统来说会很有用。你决定将顾客的 user_id 存储在每本书的一个数组中。很简单，对吧？
这可能确实适用于 99.99% 的情况，但是当 J.K.罗琳 发行了一本新的哈利波特书籍，并且销量以百万计激增时，会发生什么呢？16MB 的 BSON 文档大小限制很容易达到。针对这种异常情况重新设计整个应用程序可能会降低典型书籍的性能，但我们确实需要考虑这一点。
使用异常值模式就是在防止一些少数的查询或文档将我们推向对大多数用例来说都不佳的解决方案。并非每本书都能卖出数百万册。
一个存有 user_id 的典型 book 文档可能看起来像这样：

![image-20210420082321234](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210420082323.png)


对于绝大多数不太可能登上“畅销书”排行榜的书来说，这可以工作得很好。尽管将异常值考虑进来后导致了 customers_purchased 数组超出了我们设置的 1000 个条目的限制，但我们可以添加一个新字段将这本书“标记”为异常值。
然后，我们将多出的信息移动到与书籍的 id 相关联的单独文档中。在应用程序中，我们可以看文档是否有值为 true 的 has_extras 字段。如果是，那么应用程序将会检索额外的信息。这样处理可以使其对大多数应用程序代码来说是基本透明的。
许多设计决策都基于应用程序的工作负载，因此这个解决方案旨在展示一个异常值模式的示例。这里要理解的重要概念是，异常值在其数据中有足够大的差异，如果它们被当作“正常值”对待，那么为它们更改应用程序设计将降低其它更典型查询和文档的性能。

**应用场景示例**

异常模式是一种高级模式，但可以带来较大的性能改进。它经常在受欢迎程度可以作为一个因素的情况下使用，例如社交网络关系、图书销售、电影评论等。互联网已经大幅缩小了我们的世界，当某个东西变得受欢迎时，它改变了我们需要对数据建模的方式。
一个例子是拥有视频会议产品的客户。大多数视频会议的被授权的与会者列表可以和会议保存在同一文档中。然而，也有一些活动预计会有数千的参加者，比如一家公司的全体员工。对于那些“异常”会议，这个客户使用“overflow”文档来记录那些长长的与会者列表。

**结论**

异常值模式所要解决的问题是防止以少量文档或查询来确定应用程序的解决方案，尤其是当该解决方案对大多数用例来说不是最佳的时候。我们可以利用 MongoDB 的灵活数据模型在文档中添加一个字段来将其标记为异常值。然后在应用程序内部，我们对异常值的处理会略有不同。通过为典型的文档或查询定制模式，应用程序的性能将会针对那些正常的用例进行优化，而那些异常值仍将得到处理。
这个模式需要考虑的一点是，它通常是为特定的查询和情况而定制的。因此，一些临时产生的查询可能会导致性能不理想。此外，由于大部分工作是在应用程序代码本身内完成的，因此随着时间的推移可能需要进行额外的代码维护。

####  计算模式（Computed）

我们已经在使用模式构建系列研究了各种优化存储数据的方法。现在，我们从另一个角度来看看模式设计。通常，仅仅存储数据并使其可用还不够。当我们可以从数据中计算出值时，数据会变得有用的多。最新 Amazon Alexa 的总销售收入是多少？有多少观众看了这部最新的大片？这类问题可以从数据库中存储的数据那里得到答案，但必须进行计算。
每次在请求时运行这些计算都会是一个极其消耗资源的过程，特别是在大型数据集上。CPU 周期、磁盘访问、内存都会被牵涉进来。
假设现在有一个关于电影信息的 Web 应用程序。每次我们访问应用查找电影时，页面都会提供有关播放这部电影的影院数量、观看电影的总人数以及总收入的信息。如果应用必须不断地为每次页面访问计算这些值，那么当碰上那些很受欢迎的电影时会使用掉大量的处理资源。
然而，大多数时候我们不需要知道确切的数字。我们可以在后台进行计算，然后每隔一段时间更新一次电影信息的主文档。这些计算允许我们在显示有效数据的同时无需给 CPU 带来额外的负担。
当有在应用程序中需要重复计算的数据时，我们可以使用计算模式。当数据访问模式为读取密集型时，也会使用计算模式；例如，如果每小时有 1000000 次读取而只有 1000 次写入，则在写入时进行计算会使计算次数减少 1000 倍。

![image-20210420082416501](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210420082419.png)

在我们的电影数据库示例中，我们可以根据特定电影上的所有放映信息进行计算，并将计算结果与电影本身的信息存储在一起。在低写负载的环境中，这个计算可以与源数据的任意更新一起完成。如果有更多的常规写入，则可以按定义好的时间间隔（例如每小时）进行计算。因为不会对上映信息中的源数据做任何修改，所以我们可以继续运行现有的计算，或者在任何时间点运行新的计算，并且确定将得到正确的结果。
一些执行计算的其它策略可能会涉及例如向文档添加时间戳以指示文档上次的更新时间。之后，应用程序可以确定何时需要进行计算。另一种选择是可以生成一个需要完成的计算队列。使用何种更新策略最好留给应用开发人员去选择。

**应用场景示例**

只要有对数据进行计算的需求，就可以使用计算模式。一个很好的例子是需要求和的数据集（如收入或观影者），但时间序列数据、产品目录、单视图应用程序和事件源也同样很适合这种模式。
这是许多客户已经实现的模式。例如，一个客户对车辆数据进行了大量的聚合查询，并将结果存储在服务器上，以在接下来的几个小时显示这些信息。
一家出版公司将所有类型的数据进行编制来创建像“100 个最佳的……”这样的有序列表。这些列表一段时间只需要重新生成一次，而底层数据可能在其它时间更新。

**结论**

这一强大的设计模式可以减少 CPU 工作负载并提高应用程序性能。它可以用于对集合中的数据进行计算或操作，并将结果存储在文档中，以避免重复进行相同的计算。当你的系统在重复执行相同的计算，并且具有较高的读写比时，请考虑使用计算模式。

#### 子集模式（Subset）

在多年前，第一代 PC 拥有高达 256KB 的 RAM 和两个 5.25 英寸的软盘驱动器。没有硬盘，因为在当时它们极为昂贵。这些限制导致在处理大量（对那时来说）数据时由于内存不足，必须在物理上交换软盘。如果当时有办法只把我经常使用的数据（如同整体数据的一个子集）放入内存就好了。
现代应用程序也无法幸免于资源消耗的影响。MongoDB 将频繁访问的数据（称为工作集）保存在 RAM 中。当数据和索引的工作集超过分配的物理 RAM 时，随着磁盘访问的发生以及数据从 RAM 中转出，性能会开始下降。
我们如何解决这个问题？首先，我们可以向服务器添加更多的 RAM，不过也就只能扩展这么多。我们也可以考虑对集合进行分片，但这会带来额外的成本和复杂性，而我们的应用程序可能还没有准备好来应对这些。另一种选择是减小工作集的大小，这就是我们可以利用子集模式的地方。
此模式用来解决工作集超出 RAM，从而导致信息从内存中被删除的问题。这通常是由拥有大量数据的大型文档引起的，这些数据实际上并没有被应用程序使用。我这么说到底是什么意思呢？
假设一个电子商务网站有一个产品评论列表。当访问该产品的数据时，我们很可能只需要最近 10 个左右的评论。将整个产品数据与所有评论一起读入，很容易导致工作集的膨胀。

![image-20210420082504352](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210420082507.png)


相比于将所有的评论与产品存储在一起，我们可以将其分为两个集合。一个集合具有最常用的数据，例如当前的评论；另一个集合具有不太常用的数据，例如旧的评论、产品历史记录等。我们可以复制在一对多或多对多关系中最常用的那部分数据。

![image-20210420082535547](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210420082538.png)

在 Product 集合中，我们只保留最近十次的评论。这允许通过只引入整体数据的一部分或子集来减少工作集。附加信息（本例中的 reviews）存储在单独的 Reviews 集合中，如果用户希望查看更多的评论，则可以访问该集合。在考虑将数据拆分到何处时，文档中使用最多的部分应放入“主”集合，而使用频率较低的数据应放入另一个集合。对于我们例子中的评论，这个分割点可能是产品页面上可见的评论数。

**应用场景示例**

当我们的文档拥有大量数据而其并不常用时，子集模式就非常有用。产品评论、文章评论、电影中的演员信息都是这个模式的应用场景案例。每当文档大小对工作集的大小产生压力并导致工作集超过计算机的 RAM 容量时，子集模式便成为一个可以考虑的选项。

**结论**

通过使用包含有频繁访问数据的较小文档，我们减少了工作集的总体大小。这使得应用程序所需要的最常用信息的磁盘访问时间更短。在使用子集模式时必须做的一个权衡是，我们必须管理子集，而且如果我们需要引入更旧的评论或所有信息，则需要额外的数据库访问才能做到这一点。

#### 扩展引用模式（Extended Reference）

贯穿整个 设计模式，希望你已经了解到一件事，即模式是什么样子取决于数据的访问方式。如果我们有许多相似的字段，属性模式可能是一个很好的选择。为了适配一小部分数据的访问会极大地改变我们的应用程序吗？也许异常值模式是值得考虑的。还有一些模式，例如子集模式，会引用额外的集合，并依赖 JOIN 操作将每个数据块重新组合在一起。如果需要大量的 JOIN 操作来聚集那些需要频繁访问的数据，这时要怎么办呢？这就是我们可以使用扩展引用模式的地方。

有时将数据放置在一个单独的集合中是有道理的。如果一个实体可以被认为是一个单独的“事物”，那么使其拥有单独的集合通常是有意义的。例如在一个电子商务应用中，存在订单的概念，就像客户和库存一样，它们都是独立的逻辑实体。

![image-20210420082620453](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210420082623.png)

然而从性能的角度来看，这就成了问题，因为我们需要为特定的订单将信息拼凑起来。一个客户可以有 N 个订单，创建一个 1-N 关系。如果我们反过来从订单的角度看，它们与客户之间有一种 N-1 的关系。仅仅是为了减少 JOIN 操作而为每个订单嵌入关于客户的所有信息，会导致大量的信息重复。此外，对于订单来说，并非所有的客户信息都是必须的。

扩展引用模式提供了一种很好的方法来处理这类情况。我们只复制经常访问的字段，而不是复制全部的客户信息。我们只嵌入那些优先级最高、访问最频率的字段，例如名称和地址，而不是嵌入所有信息或包含一个引用来 JOIN 信息。

![image-20210420082628414](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210420082631.png)

使用此模式时需要考虑的一点是，数据是重复的。因此最好存储在主文档中的数据是不会经常更改的字段。像 user_id 和人名之类的东西是不错的选择，这些很少改变。
此外，要注意只引入和复制所需的数据。想象一下订单发票，如果我们在发票上输入客户的姓名，我们是否在那个时间点会需要他们的第二个电话号码和非送货地址？可能不会，因此我们可以将该数据从 invoice 集合中删除，并添加一个 custormer 集合的引用。
当信息被更新时，我们同样需要考虑如何处理。哪些扩展引用发生了更改？应该什么时候进行更新？如果该信息是账单地址，我们是否需要出于历史目的维护该地址，还是可以直接更新？有时使数据重复会更好，因为你可以保留历史值，这可能更有意义。我们发货时客户所居住的地址在订单文档中更有意义，然后可以通过客户集合来获取现在的地址。

**应用场景示例**

订单管理应用是此模式的经典用例。在考虑订单到客户的 N-1 关系时，我们希望减少信息的连接以提高性能。通过包含对需要频繁连接数据的一个简单引用，我们在处理过程中省掉了一个步骤。
我们继续使用订单管理系统的作为例子。在发票上，Acme 公司可能被列为一个铁砧的供应商。从发票的角度来看，拥有 Acme 公司的联系信息可能并不重要。例如，这些信息最好保存在单独的 supplier 集合中。在 invoice 集合中，我们会保留有关供应商的必要信息，作为对供应商信息的扩展引用。

**结论**

当应用程序中有许多重复的 JOIN 操作时，扩展引用模式是一个很好的解决方案。通过识别查找端（lookup side）的字段并将那些经常访问的字段引入主文档，可以提高性能。这是通过更快的读取和减少 JOIN 的总数来实现的。但是请注意，重复数据是这种设计模式的一个副作用。

#### 近似值模式（Approximation）

在所需要的计算非常有挑战性或消耗的资源昂贵（时间、内存、CPU 周期）时，如果精度不是首要考虑因素时，那么我们就可以使用近似值模式。再回顾一下人口问题，精确计算这个数字的成本是多少？从我开始计算起，它将会改变还是可能会改变？如果这个数字被报告为 39,000，而实际上是 39,012，这会对这个城市的规划战略产生什么影响？
从应用程序的角度看，我们可以构建一个近似因子，它允许对数据库进行更少写入的同时仍然提供统计上有效的数字。例如，假设我们的城市规划是基于每 10000 人需要一台消防车，那么用 100 人作为这个计划的“更新”周期看起来就不错。“我们正接近下一个阈值了，最好现在开始做预算吧。”
在应用程序中，我们不需要每次更改都去更新数据库中的人口数。我们可以构建一个计数器，只在每达到 100 的时候才去更新数据库，这样只用原来 1%的时间。在这个例子里，我们的写操作显著减少了 99%。还有一种做法是创建一个返回随机数的函数。比如该函数返回一个 0 到 100 之间的数字，它在大约 1%的时间会返回 0。当这个条件满足时，我们就把计数器增加 100。
我们为什么需要关心这个？当数据量很大或用户量很多时，对写操作性能的影响也会变得很明显。规模越大，影响也越大，而当数据有一定规模时，这通常是你最需要关心的。通过减少写操作以及不必要的“完美”，可以极大地提高性能。

**应用场景示例**

人口统计的方式是近似值模式的一个示例。另一个可以应用此模式的用例是网站视图。一般来说，知道访问过该网站的人数是 700,000 还是 699,983 并不重要。因此，我们可以在应用程序中构建一个计数器，并在满足阈值时再更新数据库。
这可能会极大地降低网站的性能。在关键业务数据的写入上花费时间和资源才是有意义的，而把它们全部花在一个页面计数器上似乎并不是对资源很好的利用。

![image-20210420082707345](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210420082710.png)

电影网站 – 写操作负载降低

在上图中，我们看到了如何使用近似值模式，这不仅可以减少计数操作的写入，还可以通过减少这些写入来降低架构的复杂性和开销。这可以带来更多的收益，而不仅仅是写操作时间的减少。与前面讨论过的计算模式（The Computed Pattern）类似，它通过降低计算的频率，从而在总体上节约了 CPU 的使用。

**结论**

近似值模式对于处理难以计算和/或计算成本高昂的数据，并且这些数字的精确度不太关键的应用程序是一个很好的解决方案。我们可以减少对数据库的写入，从而提高性能，并且保持数字仍然在统计上是有效的。然而，使用这种模式的代价是精确的数字无法被表示出来，并且必须在应用程序本身中实现。

#### 树形模式（Tree）

到目前为止，我们讨论的许多设计模式都强调省去 JOIN 操作的时间是有好处的。那些会被一起访问的数据也应该存储在一起，即便导致了一些数据重复也是可以的。像扩展引用（Extended Reference）这样的设计模式就是一个很好的例子。但是，如果要联接的数据是分层的呢？例如，你想找出从某个员工到 CEO 的汇报路径？MongoDB 提供了 `$graphlookup` 运算符，以图的方式去浏览数据，这可能是一种解决方案。但如果需要对这种分层数据结构进行大量查询，你可能还是需要应用相同的规则，将那些会被一起访问的数据存储在一起。这里我们就可以使用树形模式。
在以前的表格式数据库中，有许多方法可以表示一个树。最常见的是，让图中的每个节点列出其父节点，还有一种是让每个节点列出其子节点。这两种表示方式可能都需要多次访问来构建出节点链。

![image-20210420082757173](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210420082800.png)

还有一种做法，我们可以将一个节点到层级顶部的完整路径储存起来。在本例中，我们将存储每个节点的“父节点”。这在一个表格式数据库中很可能是通过对一个父节点的列表进行编码来完成的。而在 MongoDB 中，可以简单地将其表示为一个数组。

![image-20210420082806900](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210420082810.png)


如图所示，在这种表示中会有一些重复数据。如果信息是相对静态的，比如在家谱中你的父母和祖先是不变的，从而使这个数组易于管理。然而，在我们的公司架构示例中，当变化发生并且架构进行重组时，你需要根据需要更新层次结构。与不用每次计算树所带来的好处相比，这仍然是一个很小的成本。

**应用场景示例**

产品目录是另一个使用树形模式的好例子。产品通常属于某个类别，而这个类别是其它类别的一部分。例如，一个固态硬盘（Solid State Drive）可能位于硬盘驱动器（Hard Drives）下，而硬盘驱动器又属于存储（Storage）类别，存储又在计算机配件（Computer Parts）下。这些类别的组织方式可能偶尔会改变，但不会太频繁。

![image-20210420082815289](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210420082817.png)

注意在上面这个文档中的 ancestor_categories 字段跟踪了整个层次结构。我们还使用了一个字段 parent_category。在这两个字段中重复储存直接父级节点是我们与许多客户合作后发现的使用树形模式的一种最佳实践。包含“parent”字段通常很方便，特别是当你需要保留在文档上使用 `$graphLookup` 的能力时。
将祖先节点保存在数组中可以提供对这些值创建多键索引（multi-key index）的能力。这允许轻松找到给定类别的所有子代。至于直接子代，可以通过查看将给定类别作为其直接“父母”的文档来访问。我们刚刚说过有这个字段会很方便。

**结论**

在使用对于许多模式时，通常需要在易用性和性能之间进行权衡。对于树形模式来说，它通过避免多次连接操作可以获得更好的性能，但是你需要自己管理图的更新。

####  预分配模式（Preallocation）

MongoDB 最明显的优势之一就是文档数据模型。它在模式设计和开发周期中均提供了很大的灵活性。用 MongoDB 文档可以很容易地处理那些不知道之后会需要哪些字段的场景。然而，有些时候当结构是已知的，并且能够被填充或扩充时，会使设计简单得多。这就是我们可以使用预分配模式的地方。

为避免性能问题，内存通常以块的形式进行分配。在 MongoDB 的早期（MongoDB 3.2 版之前），当它使用 MMAPv1 存储引擎时，一个常见的优化是提前分配所需的内存，以满足不断增长的文档未来会达到的大小。MMAPv1 中不断增长的文档需要由服务端以相当昂贵的成本进行位置的迁移。WiredTiger 的无锁机制（lock-free）和重写（rewrite）更新算法不需要这种处理。
      随着 MMAPv1 在 MongoDB 4.0 中的弃用，预分配模式似乎失去了一些吸引力和必要性。然而，仍然会有一些用例需要 WiredTiger 的预分配模式。与我们在《使用模式构建》系列中讨论的其它模式一样，有一些涉及到应用程序的事项需要考虑。
      这个模式只要求创建一个初始的空结构，稍后再进行填充。这听起来似乎很简单，但你需要在简化预期的结果和解决方案可能会消耗的额外资源中取得平衡。大文档会产生比较大的工作集，也就需要更多的 RAM 来包含此工作集。
      如果应用程序的代码在使用未完全填充的结构时更容易编写和维护，则这种方案带来的收益很容易超过 RAM 消耗所带来的成本。假设现在有一个需求要将剧院的空间表示为一个二维数组，其中每个座位都有一个“行”和一个“数字”，例如，座位“C7”。有一些行可能会有比较少的座位，但是在二维数组中查找座位“B3”会比用复杂的公式在一个只存储实际座位的一维数组中查找更快、更简洁。这样，找出可使用的座位也更容易，因为可以为这些座位创建一个单独的数组。

![image-20210420082914793](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210420082918.png)

**应用场景示例**

如前所述，二维结构的表示（比如场地）是一个很好的用例。另一个例子是预约系统，按照每天作为粒度，其中资源会被冻结或者预订。针对每个有效天使用一个单元格可能比保存一个范围的列表可以更快地进行计算和检查。

![image-20210420082934539](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210420082936.png)

**结论**

在使用 MongoDB 的 MMAPv1 存储引擎时，此模式可能是最常用的模式之一。然而，由于这个存储引擎的弃用，它失去了一些通常的使用场景，但在某些情况下仍然有用。和其它模式一样，你需要在“简单”和“性能”之间做出权衡。

#### 文档版本控制模式（Document Versioning）

​	数据库，例如 MongoDB，非常擅长查询大量数据并进行频繁更新。然而，在大多数情况下，我们只针对数据的最新状态执行查询。那如果有些场景下我们需要查询数据的以前状态呢？如果我们需要一些文档的版本控制功能怎么办？这就是我们可以使用文档版本控制模式的地方。

​	这个模式的关键是保持文档的版本历史记录处于可用状态。我们可以构建一个专用的版本控制系统和 MongoDB 配合使用。这个系统用于处理少数文档的更改，而 MongoDB 用于处理其它文档。这可能看起来有些笨。但是通过使用文档版本控制模式，我们可以避免使用多个系统来管理当前文档及其历史，方法是将它们保存在同一个数据库中。

​	这种模式解决了这样一个问题：希望可以在不引入第二个管理系统的情况下保留 MongoDB 中某些文档的旧版本。为此，我们在每个文档中添加一个字段，以便跟踪文档版本。然后，数据库将会有两个集合：一个集合具有最新的（和查询最多的数据），另一个具有所有数据的修订版本。

文档版本控制模式对数据库以及应用程序中的数据访问模式做了一些假设。

- 每个文档不会有太多的修订版本。
- 需要做版本控制的文档不会太多。
- 大多数的查询都是基于文档的最新版本。

如果你发现这些假设不适用于你的场景，那么这个模式也许不太合适。这需要你更改对于这一模式中版本的实现，或者你的用例可能需要换一个解决方案。

**应用场景示例**

文档版本控制模式在高度规范化的行业中非常有用，这些行业会要求一组数据的特定时间点版本。金融和医疗行业就是很好的例子，保险业和法律相关的行业也同样如此。有许多场景需要跟踪数据某些部分的历史记录。
我们来看看一个保险公司可能会如何使用这种模式。每个客户都有一个“标准”保单和一个（根据客户意愿增加的）该客户特有的保单附加条款。这附加的第二部分包括保险单附加条款列表和正在投保的特定项目列表。当客户更改了受保的具体项目时，这一信息需要随之更新，而同时之前的历史记录也需要保留。这在业主或承租人这样的保单中相当常见。例如，有人想要投保的特定项目超出了所提供的典型保险范围，那么这部分会作为附加条款单独列出。保险公司的另一个用例可能是保留他们随时间邮寄给客户的“标准保单”的所有版本。
根据文档版本控制模式的需求，这看起来是一个非常好的用例。保险公司可能有几百万个客户，对“附加”列表的修改可能不会太频繁，而且对保单的大多数搜索针对的都是最新版本。

在我们的数据库中，每个客户可能在 current_policies 集合中有一个包含客户特定信息的 current_policy 文档，以及在 policy_revisions 集合中有一个 policy_revision 文档。此外，还会有一个对于大多数客户来说相同的 standard_policy 集合。当客户购买新项目并希望将其添加到其保单中时，将使用 current_policy 文档创建一个新的 policy_revision 文档。随后，文档中的版本字段将会递增以标识其为最新版本，并将客户的更改添至其中。

![image-20210420083311887](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210420083315.png)

最新版本存储在 current_policies 集合中，而旧版本将写入 policy_revisions 集合。通过在 current_policy 集合中保留最新版本，查询请求可以保持简单。根据对数据的需求，policy_revisions 集合可能也只保留几个版本。

![image-20210420083320283](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210420083324.png)

在这个例子中，中土（Middle-earth）保险公司为其客户制定了一个 standard_policy。夏尔（Shire）的所有居民都将共享这个保单文档。现在比尔博（Bilbo）还想在他正常的保险范围之外添加一些特别的保项：他的精灵宝剑（Elven Sword）以及，当然，还有至尊魔戒（the One Ring）。这些将保存在 current_policies 集合中，并且在进行更改时，policy_revisions 集合将保留更改的历史记录。
      文档版本控制模式相对容易实现。它可以在现有系统上实现，而不会对应用程序或现有文档进行太多的更改。此外，访问文档最新版本的查询仍然可以执行。
      这种模式的一个缺点是对于历史信息需要访问不同的集合。此外，这种模式对数据库的总体写入量会更高。这就是为什么使用此模式的要求之一是数据的更改不会太频繁。

**结论**

​	当你需要跟踪文档的更改时，文档版本控制模式是一个很好的选择。它相对容易实现，并且可以应用于现有的一组文档。另一个好处是，对最新版本数据的查询仍然可以很好地执行。但是，它不能取代专用的版本控制系统。

#### 模式版本控制

有人说，生活中唯一不变的就是变化。这对数据库模式也是如此。我们曾经认为不需要的信息，现在我们要捕捉。或者新的服务变得可用，需要包含在数据库记录中。无论变化背后的原因是什么，在一段时间后，我们不可避免地需要对应用程序中的底层模式设计进行更改。虽然这往往会带来挑战，或许在传统的表格数据库系统中至少会有一些头疼的问题，但在 MongoDB 中，我们可以使用 Schema Versioning 模式来让更改变得更容易。

如前所述，在表格式数据库中更新数据库模式可能是一个挑战。通常情况下，应用程序需要停止，数据库迁移以支持新的模式，然后重新启动。这种停机时间会导致客户体验不佳。此外，如果迁移没有完全成功会怎样？恢复到之前的状态往往是一个更大的挑战。

Schema Versioning 模式利用了 MongoDB 对不同形状的文档存在于同一数据库集合中的支持。MongoDB 的这种多态性非常强大。它允许具有不同字段甚至同一字段的不同字段类型的文档，可以和平并存。

这种模式的实现比较简单。我们的应用程序从一个原始模式开始，最终需要修改这个模式。当这种情况发生时，我们可以创建新的模式，并将其保存到数据库中，并带有 schema_version 字段。这个字段将允许我们的应用程序知道如何处理这个特定的文档。另外，我们也可以让我们的应用程序根据一些给定字段的存在或不存在来推断版本，但前一种方法是首选。我们可以假设没有这个字段的文档，是版本 1。那么每一个新的模式版本都会递增 schema_version 字段的值，并可以在应用程序中进行相应的处理。

随着新信息的保存，我们使用最新的模式版本。我们可以根据应用和用例，确定是否需要将所有文档更新到新的设计，是否需要在访问记录时更新，还是完全不更新。在应用程序内部，我们将为每个模式版本创建处理函数。

**应用场景示例**

​	如前所述，几乎每个数据库在其生命周期中的某个时刻都需要改变，所以这种模式在很多情况下都很有用。让我们来看一个客户资料的用例。在没有广泛的联系方法之前，我们开始保存客户信息。他们只能在家里或工作中联系。

![image-20210420083527145](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210420083529.png)

随着时间的推移，越来越多的客户记录被保存，我们注意到手机号码也需要保存。把这个字段添加进去就很直接。

更多的时间过去了，现在我们发现，拥有家庭电话的人越来越少，而其他联系方式的记录变得越来越重要。像 Twitter、Skype 和 Google Hangouts 这样的项目正变得越来越流行，也许在我们刚开始保存联系人信息的时候，甚至都没有这些功能。我们还想尝试尽可能地证明我们的应用程序的未来性，在阅读了 Building with Patterns 系列之后，我们知道了 Attribute Pattern，并将其实现为一个 contact_method 的值数组。在这样做的时候，我们创建一个新的模式版本。

![image-20210420083535475](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210420083537.png)


MongoDB 文档模型的灵活性使得所有这些都可以在不影响数据库的情况下进行。从应用的角度来看，它可以被设计成读取两个版本的模式。这种如何处理模式差异的应用变化也不应该需要停机，假设涉及的应用服务器不止一个。

**结论**
Schema Versioning 模式非常适用于以下情况：应用程序停机不是一个选项，更新文档可能需要数小时、数天或数周的时间来完成，更新文档到新的版本不是一个要求，或者是这些情况的组合。它允许轻松地添加一个新的 schema_version 字段，并让应用程序适应这些变化。此外，它为我们作为开发人员提供了一个机会来更好地决定何时以及如何进行数据迁移。所有这些事情都会减少未来的技术债务，这是该模式的另一大优势。

与本系列中提到的其他模式一样，Schema Versioning 模式也有一些需要考虑的事情。如果你在一个字段上有一个索引，而这个索引并不位于文档中的同一层次，那么你在迁移文档的时候可能需要 2 个索引。

这种模式的主要好处之一是涉及到数据模型本身的简单性。所有需要做的就是添加 schema_version 字段。然后让应用程序处理和处理不同的文档版本。

此外，正如在用例中看到的那样，我们能够将模式设计模式结合在一起以获得额外的性能。在这个案例中，将模式版本和属性模式一起使用。允许在不停机的情况下进行模式升级，这使得 Schema Versioning 模式在 MongoDB 中变得特别强大，并且很可能成为足够的理由在你的下一个应用中使用 MongoDB 的文档模式而不是传统的表格式数据库。

#### 总结

现在到了我们总结使用模式构建系列的时候，这是一个很好的机会回顾一下这个系列涵盖的模式所解决的问题，并着重复习每个模式所具有的一些好处以及做出的权衡。关于模式设计，最常见的问题是“我正在设计一个要做某某事情的应用程序，如何对数据建模？”正如我们希望你在学习本系列过程中可以体会到的那样，要回答这个问题，需要考虑很多事情。不过我们提供了一个应用场景示例图，这至少有助于为通用的数据建模提供一些初级的指导。

**应用场景示例**

下图是我们在与客户合作多年后发现的用于各种应用程序中设计模式的指导原则。对于哪种设计模式可以用于某类特定的应用程序不是“一成不变”的。你需要仔细查看用例中经常使用的那些，但是不要忽略其它的，它们可能仍然适用。如何设计应用程序的数据模式非常依赖于数据访问的方式。

![image-20210420083649957](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210420083653.png)

**注释：**
Catalog：目录
Content Management：内容管理
Internet of Things：物联网
Mobile：手机
Personalization：个人化
Real-Time Analytics：实时分析
Single View：单一视图

##### 近似值

近似值模式适用于当昂贵的计算很频繁，而这些计算的精度要求通常不是首要考虑的时候。

优点

- 对数据库更少的写入
- 保持在统计学上有效的数字

缺点

- 无法展示精确的数字
- 需要在应用层实现

##### 属性

属性模式适用于解决这样一类问题：我们有一些大文档，它们有很多相似的字段，而这些字段的一个子集具有共同的特征，我们希望对该子集字段进行排序或查询。当需要排序的字段只能在一小部分文档中找到。或者在文档中同时满足这两个条件时。

优点

- 需要更少的索引
- 查询变得更容易编写，而且通常更快

##### 分桶

当需要管理流式数据，如时间序列、实时分析或物联网（IOT）应用程序时，分桶模式是一个很好的解决方案。

优点

- 减少了集合中的文档总数
- 提高了索引性能
- 可以通过预聚合简化数据的访问

##### 计算

当数据访问模式为读取密集型并且应用程序需要重复计算这些数据时，计算模式是一个很好的选项。

优点

- 对于频繁的计算可以减少 CPU 的工作负载
- 查询变得更容易编写，而且通常更快

缺点

- 识别出需要使用此模式的的场景可能比较困难
- 除非必要，请勿过度使用此模式

##### 文档版本控制

当你需要在 MongoDB 中维护以前版本的文档时，文档版本控制模式是一种可行的解决方案。

优点

- 容易实现，即使是在现存的系统中
- 在最新版本上进行请求时，没有性能上的影响

缺点

- 写操作的数量会翻倍
- 请求需要被定位到正确的集合

##### 扩展引用

当你的应用程序使用了大量的 JOIN 操作来将频繁访问的数据集中在一起时，你会发现扩展引用模式非常有用。

优点

- 当有大量的 JOIN 操作时可以提升性能
- 读操作会更快，并且可以减少 JOIN 操作的数量

缺点

- 会有重复数据

##### 异常值

你是否发现有一些查询或文档和其它典型数据的模式不一样？这些例外情况是否驱动了你应用程序的解决方案？如果是这样，那么异常值模式就是解决这种情况的一个很好的方法。

优点

- 防止整个应用的解决方案被某些个别的文档或请求所左右
- 请求会针对那些典型的用例进行优化，而异常值仍将得到处理

缺点

- 通常会为特定的查询而进行定制，因此一些临时产生的查询可能性能不太理想
- 此模式的大部分工作是在应用程序代码中完成的

##### 预分配

当你事先知道文档的结构，而应用程序只需要用数据填充它时，预分配模式是正确的选择。

优点

- 当预先知道文档结构时，可以简化设计

缺点

- 简单和性能之间的权衡

##### 多态

当有多种文档它们的相似性比差异更多，并且需要将这些文档保存在同一个集合中时，多态模式是一种解决方案。

优点
• 实现简单
• 查询可以在单个集合中运行

模式版本控制

几乎每个应用程序都可以从模式版本控制模式中获益，因为数据模式的更改经常发生在应用程序的生命周期中。此模式允许历史版本和当前版本的文档在集合中同时存在。

优点

- 不需要停机时间
- 模式迁移可控
- 减少未来的技术债务

缺点

- 在迁移过程中，对相同的字段可能需要两个索引

##### 子集

子集模式解决了有大量数据的大文档没有被应用程序使用而导致的工作集超过 RAM 容量的问题。

优点

- 在总体上减小了工作集的大小
- 缩短了最常用数据的磁盘访问时间

缺点

- 必须管理子集
- 请求附加的数据需要额外的数据库访问

##### 树形

当数据是分层结构并且经常被查询时，树形模式就是你要使用的。

优点

- 通过避免多次 JOIN 操作提高了性能

缺点

- 需要在应用层管理图的更新