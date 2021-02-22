---
layout: post
title: PostgreSQL psql的使用, SQL语法, 数据类型, 递归SQL用法
subheading: 
author: swang-harbin
categories: SQL
banner: 
tags: PostgreSQL java
---

# PostgreSQL psql的使用, SQL语法, 数据类型, 递归SQL用法

## 一. PostgreSQL交互工具的使用

`psql`工具

psql -h ip -p port -U username -d database

两个比较有用的帮助, 再psql shell中输入:

- `\?`: 可以得到psql的一些快捷命令
- `\h command`: 查看某个SQL命令的帮助, 例如`\h create table`

常用的快捷命令:

- `\dt`: 输出当前搜索路径下的表
- `\set VERBOSITY verbose`: 设置详细的打印输入, 例如可以报出问题代码

## 二. PostgreSQL数据类型介绍

查看数据库支持的所有数据类型, 包括自定义类型: `\d pg_type`或`select * from pg_type;`

```shell
                   Table "pg_catalog.pg_type"
     Column     |     Type     | Collation | Nullable | Default 
----------------+--------------+-----------+----------+---------
 oid            | oid          |           | not null | 
 typname        | name         |           | not null | 
 typnamespace   | oid          |           | not null | 
 typowner       | oid          |           | not null | 
 typlen         | smallint     |           | not null | 
 typbyval       | boolean      |           | not null | 
 typtype        | "char"       |           | not null | 
 typcategory    | "char"       |           | not null | 
 typispreferred | boolean      |           | not null | 
 typisdefined   | boolean      |           | not null | 
 typdelim       | "char"       |           | not null | 
 typrelid       | oid          |           | not null | 
 typelem        | oid          |           | not null | 
 typarray       | oid          |           | not null | 
 typinput       | regproc      |           | not null | 
 typoutput      | regproc      |           | not null | 
 typreceive     | regproc      |           | not null | 
 typsend        | regproc      |           | not null | 
 typmodin       | regproc      |           | not null | 
 typmodout      | regproc      |           | not null | 
 typanalyze     | regproc      |           | not null | 
 typalign       | "char"       |           | not null | 
 typstorage     | "char"       |           | not null | 
 typnotnull     | boolean      |           | not null | 
 typbasetype    | oid          |           | not null | 
 typtypmod      | integer      |           | not null |
 typndims       | integer      |           | not null | 
 typcollation   | oid          |           | not null | 
 typdefaultbin  | pg_node_tree | C         |          | 
 typdefault     | text         | C         |          | 
 typacl         | aclitem[]    |           |          | 
Indexes:
    "pg_type_oid_index" UNIQUE, btree (oid)
    "pg_type_typname_nsp_index" UNIQUE, btree (typname, typnamespace)
```

typstorage字段表示类型的存储结构, 包含以下值

- `p`: 以不压缩的形式存储在当前表
- `e`: 以不压缩的形式存储在外面
- `m`: 以压缩的形式存储在当前表
- `x`: 以压缩的形式存储在

按不同类型可分为如下几类

| Code |       Category        |
| :--: | :-------------------: |
|  A   |      Array types      |
|  B   |     Boolean types     |
|  C   |    Composite types    |
|  D   |    Date/time types    |
|  E   |      Enum types       |
|  G   |    Geometric types    |
|  I   | Network address types |
|  N   |     Numeric types     |
|  P   |     Pseudo-types      |
|  R   |      Range types      |
|  S   |     String types      |
|  T   |    Timespan types     |
|  U   |  User-defined types   |
|  V   |   Bit-string types    |
|  X   |     unknown type      |

### 2.1 常用类型介绍

https://www.postgresql.org/docs/9.5/datatype.html

| Name                                          | Aliases                      | Description                                        |
| :-------------------------------------------- | :--------------------------- | :------------------------------------------------- |
| `bigint`                                      | `int8`                       | signed eight-byte integer                          |
| `bigserial`                                   | `serial8`                    | autoincrementing eight-byte integer                |
| `bit [ (*`n`*) ]`                             |                              | fixed-length bit string                            |
| `bit varying [ (*`n`*) ]`                     | `varbit [ (*`n`*) ]`         | variable-length bit string                         |
| `boolean`                                     | `bool`                       | logical Boolean (true/false)                       |
| `box`                                         |                              | rectangular box on a plane                         |
| `bytea`                                       |                              | binary data (“byte array”)                         |
| `character [ (*`n`*) ]`                       | `char [ (*`n`*) ]`           | fixed-length character string                      |
| `character varying [ (*`n`*) ]`               | `varchar [ (*`n`*) ]`        | variable-length character string                   |
| `cidr`                                        |                              | IPv4 or IPv6 network address                       |
| `circle`                                      |                              | circle on a plane                                  |
| `date`                                        |                              | calendar date (year, month, day)                   |
| `double precision`                            | `float8`                     | double precision floating-point number (8 bytes)   |
| `inet`                                        |                              | IPv4 or IPv6 host address                          |
| `integer`                                     | `int`, `int4`                | signed four-byte integer                           |
| `interval [ *`fields`* ] [ (*`p`*) ]`         |                              | time span                                          |
| `json`                                        |                              | textual JSON data                                  |
| `jsonb`                                       |                              | binary JSON data, decomposed                       |
| `line`                                        |                              | infinite line on a plane                           |
| `lseg`                                        |                              | line segment on a plane                            |
| `macaddr`                                     |                              | MAC (Media Access Control) address                 |
| `macaddr8`                                    |                              | MAC (Media Access Control) address (EUI-64 format) |
| `money`                                       |                              | currency amount                                    |
| `numeric [ (*`p`*, *`s`*) ]`                  | `decimal [ (*`p`*, *`s`*) ]` | exact numeric of selectable precision              |
| `path`                                        |                              | geometric path on a plane                          |
| `pg_lsn`                                      |                              | PostgreSQL Log Sequence Number                     |
| `point`                                       |                              | geometric point on a plane                         |
| `polygon`                                     |                              | closed geometric path on a plane                   |
| `real`                                        | `float4`                     | single precision floating-point number (4 bytes)   |
| `smallint`                                    | `int2`                       | signed two-byte integer                            |
| `smallserial`                                 | `serial2`                    | autoincrementing two-byte integer                  |
| `serial`                                      | `serial4`                    | autoincrementing four-byte integer                 |
| `text`                                        |                              | variable-length character string                   |
| `time [ (*`p`*) ] [ without time zone ]`      |                              | time of day (no time zone)                         |
| `time [ (*`p`*) ] with time zone`             | `timetz`                     | time of day, including time zone                   |
| `timestamp [ (*`p`*) ] [ without time zone ]` |                              | date and time (no time zone)                       |
| `timestamp [ (*`p`*) ] with time zone`        | `timestamptz`                | date and time, including time zone                 |
| `tsquery`                                     |                              | text search query                                  |
| `tsvector`                                    |                              | text search document                               |
| `txid_snapshot`                               |                              | user-level transaction ID snapshot                 |
| `uuid`                                        |                              | universally unique identifier                      |
| `xml`                                         |                              | XML data                                           |

#### 数字类型

| Name               | Storage Size | Description                     | Range                                                        |
| ------------------ | ------------ | ------------------------------- | ------------------------------------------------------------ |
| `smallint`         | 2 bytes      | small-range integer             | -32768 to +32767                                             |
| `integer`          | 4 bytes      | typical choice for integer      | -2147483648 to +2147483647                                   |
| `bigint`           | 8 bytes      | large-range integer             | -9223372036854775808 to +9223372036854775807                 |
| `decimal`          | variable     | user-specified precision, exact | up to 131072 digits before the decimal point; up to 16383 digits after the decimal point |
| `numeric`          | variable     | user-specified precision, exact | up to 131072 digits before the decimal point; up to 16383 digits after the decimal point |
| `real`             | 4 bytes      | variable-precision, inexact     | 6 decimal digits precision                                   |
| `double precision` | 8 bytes      | variable-precision, inexact     | 15 decimal digits precision                                  |
| `smallserial`      | 2 bytes      | small autoincrementing integer  | 1 to 32767                                                   |
| `serial`           | 4 bytes      | autoincrementing integer        | 1 to 2147483647                                              |
| `bigserial`        | 8 bytes      | large autoincrementing integer  | 1 to 9223372036854775807                                     |

serial, 自增的int类型, 会创建一个序列

#### 字符类型

常用的类型

| Name                                 | Storage Size                | Description                |
| ------------------------------------ | --------------------------- | -------------------------- |
| `character varying(n)`, `varchar(n)` | variable(can store n chars) | variable-length with limit |
| `character(n)`, `char(n)`            | n chars                     | fixed-length, blank padded |
| `text`                               | variable                    | variable unlimited length  |

- `varchar(n)`的长度表示的是字符的长度, 不是字节(byte), 与编码无关.
- `text`最大支持存储1GB

特殊的类型

| Name     | Storage Size | Description                    |
| -------- | ------------ | ------------------------------ |
| `"char"` | 1 byte       | single-byte internal type      |
| `name`   | 64 bytes     | internal type for object names |

- `"char"`单字节的内部使用的类型
- `name`:

#### 日期/时间类型

| Name                                      | Storage Size | Description                        | Low Value        | High Value      | Resolution                |
| ----------------------------------------- | ------------ | ---------------------------------- | ---------------- | --------------- | ------------------------- |
| `timestamp [ (p) ] [ without time zone ]` | 8 bytes      | both date and time (no time zone)  | 4713 BC          | 294276 AD       | 1 microsecond / 14 digits |
| `timestamp [ (p) ] with time zone`        | 8 bytes      | both date and time, with time zone | 4713 BC          | 294276 AD       | 1 microsecond / 14 digits |
| `date`                                    | 4 bytes      | date (no time of day)              | 4713 BC          | 5874897 AD      | 1 day                     |
| `time [ (p) ] [ without time zone ]`      | 8 bytes      | time of day (no date)              | 00:00:00         | 24:00:00        | 1 microsecond / 14 digits |
| `time [ (p) ] with time zone`             | 12 bytes     | times of day only, with time zone  | 00:00:00+1459    | 24:00:00-1459   | 1 microsecond / 14 digits |
| `interval [ fields ] [ (p) ]`             | 16 bytes     | time interval                      | -178000000 years | 178000000 years | 1 microsecond / 14 digits |

此处timestamp在postgresql中默认是without time zone的, 即存入的时间是什么, 取出的就是什么, 而timestamp with time zone, 也表示为timestampz, 当服务器的时区改变了, 查出来的时间是变化的.

```shell
// 创建test_timestamp表, 第一列使用不带时区信息的tamesstamp, 第二列使用带时区的timestamp
timetest=# create table test_timestamp(timestamp timestamp without time zone, timestampz timestamp with time zone);
// 查看当前系统时区, 当前为UTC时区
timetest=# show timezone;
 TimeZone 
----------
 Etc/UTC
(1 row)
// 向test_timestamp表中插入一条数据, 时间相同.
timetest=# insert into test_timestamp values('2020-02-02 00:00:00', '2020-02-02 00:00:00');
INSERT 0 1
// 查询插入的数据, 可发现timestampz列后方包含+00, 代表在0时区(即UTC)
timetest=# select * from test_timestamp;
      timestamp      |       timestampz       
---------------------+------------------------
 2020-02-02 00:00:00 | 2020-02-02 00:00:00+00
(1 row)
// 将时区修改为PRC(中华人民共和国)
timetest=# set timezone=PRC;
SET
// 查询刚才的时间, 发现timestamp没有变化, 而timestampz时间增加了8小时, 并且后方+00变为了+08, 代表当前时区为东八区
timetest=# select * from test_timestamp;
      timestamp      |       timestampz       
---------------------+------------------------
 2020-02-02 00:00:00 | 2020-02-02 08:00:00+08
(1 row)
```

另外注意, 在MySQL中timestamp是带时区信息的(相当于PostgreSQL的timestampz), 而datetime是不带时区的(相当于PostgreSQL的timestamp).

**特殊日期/时间的输入**

| Input String | Valid Types                 | Description                                    |
| ------------ | --------------------------- | ---------------------------------------------- |
| `epoch`      | `date`, `timestamp`         | 1970-01-01 00:00:00+00 (Unix system time zero) |
| `infinity`   | `date`, `timestamp`         | later than all other time stamps               |
| `-infinity`  | `date`, `timestamp`         | earlier than all other time stamps             |
| `now`        | `date`, `time`, `timestamp` | current transaction's start time               |
| `today`      | `date`, `timestamp`         | midnight (`00:00`) today                       |
| `tomorrow`   | `date`, `timestamp`         | midnight (`00:00`) tomorrow                    |
| `yesterday`  | `date`, `timestamp`         | midnight (`00:00`) yesterday                   |
| `allballs`   | `time`                      | 00:00:00.00 UTC                                |

示例:

```shell
postgres=# select timestamp 'epoch', date 'infinity', time 'now', date 'today', time 'allballs';
      timestamp      |   date   |      time       |    date    |   time   
---------------------+----------+-----------------+------------+----------
 1970-01-01 00:00:00 | infinity | 10:18:37.459504 | 2020-05-23 | 00:00:00
(1 row)
```

**时间输入输出风格**

| Style Specification | Description            | Example                        |
| ------------------- | ---------------------- | ------------------------------ |
| `ISO`               | ISO 8601, SQL standard | `1997-12-17 07:37:16-08`       |
| `SQL`               | traditional style      | `12/17/1997 07:37:16.00 PST`   |
| `Postgres`          | original style         | `Wed Dec 17 07:37:16 1997 PST` |
| `German`            | regional style         | `17.12.1997 07:37:16.00 PST`   |

| `datestyle` Setting | Input Ordering       | Example Output                 |
| ------------------- | -------------------- | ------------------------------ |
| `SQL, DMY`          | `day`/`month`/`year` | `17/12/1997 15:37:16.00 CET`   |
| `SQL, MDY`          | `month`/`day`/`year` | `12/17/1997 07:37:16.00 PST`   |
| `Postgres, DMY`     | `day`/`month`/`year` | `Wed 17 Dec 07:37:16 1997 PST` |

可使用`show datestyle;`查看当前日期风格, 使用`set datestyle='SQL, MDY';`修改日期风格

```shell
postgres=# show datestyle;
 DateStyle 
-----------
 ISO, MDY
(1 row)

postgres=# select now();
              now              
-------------------------------
 2020-05-23 10:37:21.941571+00
(1 row)

postgres=# set datestyle='SQL, DMY';
SET
postgres=# select now();
              now               
--------------------------------
 23/05/2020 10:37:50.654245 UTC
(1 row)
```

> 更多日期/时间输入/输入格式可见[官方文档](https://www.postgresql.org/docs/9.5/datatype-datetime.html)

**时间间隔interval**

输入格式:

- `[@] quantity unit [quantity unit...] [direction]`

  > quantity是可以带符号的数值, unit是时间单位, direction可以在前也可以在后, @是可选的噪声.

  > 可以指定日, 时, 分, 秒, 而不需显示的指定标记, 例如: '1 12:59:10'和'1 day 12 hours 59 min 10 sec'是一样的.

  > 年和月也可以使用"-"进行分割, 例如: '200-10'和'200 years 10 months'是一样的

- `P quantity unit [ quantity unit ...] [ T [ quantity unit ...]]`

  > 该格式是ISO 8601规定的格式, 必须以P开头, 并且可以包含引入时间单位的T, 可以省略单位, 并且可以指定任意顺序, 但是表示时间的字符串必须在T之后出现. M表示的含义取决于其在T之前还是之后

  ISO 8601 Interval Unit Abbreviations

  | Abbreviation | Meaning                    |
  | ------------ | -------------------------- |
  | Y            | Years                      |
  | M            | Months (in the date part)  |
  | W            | Weeks                      |
  | D            | Days                       |
  | H            | Hours                      |
  | M            | Minutes (in the time part) |
  | S            | Seconds                    |

- `P [ years-months-days ] [ T hours:minutes:seconds ]`

  > 备用格式, 必须以P开头, T分割日期和时间

  > 在使用*fields*规范编写间隔常量时, 或将字符串分配给使用*fields*规范定义的间隔列时, 未标记量的解释取决于*fields*. 例如: INTERVAL'1'YEAR读为1年, 而INTERVAL'1'表示1秒. 同样, *fields*规范允许的最低有效字段"向右"的字段值会被静默丢弃. 例如: 写INTERVAL'1 day 2:03:04'HOUR TO MINUTE将导致丢弃second字段, 而不是day字段.

  > 根据SQL标准, 间隔值的所有字段必须具有相同的符号, 因此前导负号适用于所有字段; 例如, 间隔文字" -1 2:03:04"中的负号适用于日期和小时/分钟/秒部分. PostgreSQL允许字段具有不同的符号, 并且传统上将文本表示形式中的每个字段视为独立签名, 因此在此示例中, 小时/分钟/秒部分被视为正数. 如果将IntervalStyle设置为sql_standard, 则认为前导符号适用于所有字段（仅当没有其他符号出现时. 否则, PostgreSQL使用传统的解释. 为避免歧义, 如果任何字段为负, 建议在每个字段上附加一个显式符号.

  > 在冗长的输入格式中, 以及在某些更紧凑的输入格式的字段中, 字段值可以包含小数部分; 例如"1.5 week"或" 01:02:03:45". 此类输入将转换为适当的月数, 天数和秒数以进行存储. 如果这将导致小数个月或天, 那么该分数将使用1个月= 30天和1天= 24小时的转换因子添加到低阶字段中. 例如, " 1.5 month"变为1个月15天. 在输出中, 仅秒将显示为小数.

  - 示例:

  | Example                                            | Description                                                  |
  | -------------------------------------------------- | ------------------------------------------------------------ |
  | 1-2                                                | SQL standard format: 1 year 2 months                         |
  | 3 4:05:06                                          | SQL standard format: 3 days 4 hours 5 minutes 6 seconds      |
  | 1 year 2 months 3 days 4 hours 5 minutes 6 seconds | Traditional Postgres format: 1 year 2 months 3 days 4 hours 5 minutes 6 seconds |
  | P1Y2M3DT4H5M6S                                     | ISO 8601 "format with designators": same meaning as above    |
  | P0001-02-03T04:05:06                               | ISO 8601 "alternative format": same meaning as above         |

输出格式:

> 可以使用命令`SET intervalstyle`将间隔类型的输出格式设置为sql_standard, postgres, postgres_verbose或iso_8601四种样式之一. 默认为postgres格式.

- 间隔输出样例:

| 样式规格           | 年月间隔     | 白天间隔           | 混合间隔                        |
| ------------------ | ------------ | ------------------ | ------------------------------- |
| `sql_standard`     | 1-2          | 3 4:05:06          | -1-2 +3 -4：05：06              |
| `Postgres`         | 1年2个月     | 3天04:05:06        | -1年-2个月+3天-04：05：06       |
| `postgres_verbose` | @ 1年2星期一 | @ 3天4小时5分钟6秒 | @ 1年2星期一-3天4小时5分钟6秒前 |
| `iso_8601`         | P1Y2M        | P3DT4H5M6S         | P-1Y-2M3DT-4H-5M-6S             |

#### 布尔类型

| Name      | Storage Size | Description            |
| --------- | ------------ | ---------------------- |
| `boolean` | 1 byte       | state of true or false |

布尔常量在SQL查询中, 用SQL关键字TRUE, FALSE, NULL表示.

以下输入均表示"true":

- true
- yes
- on
- 1
- t
- T

以下输入均表示"false"

- false
- no
- off
- 0
- f
- F

使用上方非true, false外的值进行输入时, 需要在值后添加`::boolean`.

```shell
test=# insert into bool_test values('yes'::boolean),('no'::boolean),('on'::boolean),('off'::boolean),('1'::boolean),('0'::boolean),('t'::boolean),('f'::boolean),('T'::boolean),('F'::boolean);
```

解析器会自动理解TRUE和FALSE输入boolean类型, 而NULL因为可以是任何类型, 在某些情况下, 可能必须强制转换NULL转换为boolean, 使用`NULL::boolean`. 相反, 在解析器可以推断文字必须为boolean的情况下, 可以省略使用`::boolean`进行强制转换.

布尔类型输出函数总是输出t或者f, 如果为NULL, 则无输出.

```shell
// 插入3条数据, 分别为true, false, null
test=# insert into bool_test values(true),(false),(null);
INSERT 0 3
// 查询插入的数据, 第三行为null的显示效果
test=# select * from bool_test ;
 boolval 
---------
 t
 f
 
(3 rows)
```

#### 枚举类型

枚举类型是包含一组静态有序的值的类型.

**创建一个枚举类型**

使用`CREATE TYPE`创建枚举类型, 例如:

```shell
CREATE TYPE mood AS ENUM ('sad', 'ok', 'happy');
```

创建完成后, 该枚举类型可以像其他类型一样被用在表和函数定义中:

```shell
CREATE TYPE mood AS ENUM ('sad', 'ok', 'happy');
CREATE TABLE person (
    name text,
    current_mood mood
);
INSERT INTO person VALUES ('Moe', 'happy');
SELECT * FROM person WHERE current_mood = 'happy';
 name | current_mood 
------+--------------
 Moe  | happy
(1 row)
```

如果向枚举类型的列中插入其他值, 会报错

```shell
INSERT INTO person VALUES('Wang', 'hap');
ERROR:  invalid input value for enum mood: "hap"
LINE 1: INSERT INTO person VALUES('Wang', 'hap');
```

**枚举类型中的顺序**

枚举类型中值的顺序是在创建时列出值的顺序. 枚举支持所有标准比较运算符和相关的聚合函数.

```shell
test=# INSERT INTO person VALUES('Larry', 'sad');
INSERT 0 1
test=# INSERT INTO person VALUES('Curly', 'ok');
INSERT 0 1
test=# SELECT * FROM person WHERE current_mood > 'sad';
 name  | current_mood 
-------+--------------
 Moe   | happy
 Curly | ok
(2 rows)

test=# SELECT * FROM person WHERE current_mood > 'sad' ORDER BY current_mood;
 name  | current_mood 
-------+--------------
 Curly | ok
 Moe   | happy
(2 rows)

test=# SELECT name FROM person WHERE current_mood = (SELECT MIN(current_mood) FROM person);
 name  
-------
 Larry
(1 row)
```

**类型安全**

每个枚举类型都是单独的, 不能与其他枚举类型进行比较.

```shell
test=# CREATE TYPE happiness AS ENUM ('happy', 'very happy', 'ecstatic');
CREATE TYPE
test=# CREATE TABLE holidays (num_weeks integer, happiness happiness);
CREATE TABLE
test=# INSERT INTO holidays VALUES(4, 'happy'), (6, 'very happy'), (8, 'ecstatic');
INSERT 0 3
test=# INSERT INTO holidays VALUES(2, 'sad');
ERROR:  invalid input value for enum happiness: "sad"
LINE 1: INSERT INTO holidays VALUES(2, 'sad');
                                       ^
test=# SELECT person.name, holidays,num_weeks FROM person, holidays WHERE person.current_mood = holidays.happiness;
ERROR:  operator does not exist: mood = happiness
LINE 1: ...s FROM person, holidays WHERE person.current_mood = holidays...
```

如果你确实需要执行类似操作, 则可以编写自定义运算符, 也可以在查询中添加显示强制转换:

```shell
test=# SELECT person.name, holidays.num_weeks FROM person, holidays WHERE person.current_mood::text = holidays.happiness::text;
 name | num_weeks 
------+-----------
 Moe  |         4
(1 row)
```

**实现细节**

枚举类型是区分大小写的, 所以'happy'和'HAPPY'是不相同的. 标签中的空格也很重要.

尽管枚举类型主要用于静态值集合, 同时它也支持向其中添加新的值, 并且可以重命名已存在的值.(详见[ALTER TYPE](https://www.postgresql.org/docs/9.5/sql-altertype.html)).

```shell
# 向枚举类型中添加值, 添加枚举元素尽量不要改变原来的元素位置, 尽量新增到最后, 否则可能会带来性能问题.
ALTER TYPE name ADD VALUE [ IF NOT EXISTS ] new_enum_value [ { BEFORE | AFTER } existing_enum_value ]
# 修改枚举类型名
ALTER TYPE name RENAME TO new_name
```

不能从枚举类型中删除现有值, 也不能更改此类值的排列顺序, 除非删除并重新创建枚举类型.

一个枚举值在磁盘上占用4个byte. 它的长度受编译时*NAMEDATALEN*属性的影响. 在标准版中, 最多支持63bytes.

从内部枚举值到文本标签的转换保存在系统表*[pg_enum](https://www.postgresql.org/docs/9.5/catalog-pg-enum.html)*中.

#### 货币类型

https://www.postgresql.org/docs/9.5/datatype-enum.html

https://developer.aliyun.com/lesson_52_1756?spm=5176.8764728.0.0.17434d56DGYhHf#_1756

0:15:50

表操作(创建, 插入, 更新, 删除, 截断, 删除, 重命名, 修改表的属性...)