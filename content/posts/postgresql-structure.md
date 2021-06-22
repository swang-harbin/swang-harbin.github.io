---
title: PostgreSQL物理, 逻辑, 进程结构及系统表系统函数
date: '2020-03-17 00:00:00'
updated: '2020-03-17 00:00:00'
tags:
- PostgreSQL
- Java
categories:
- Java
---

# PostgreSQL物理, 逻辑, 进程结构以及系统表系统函数

## PostgreSQL逻辑结构概貌

![postgre逻辑结构](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222182838.png)

- Cluster: 执行`init`命令后, 会自动生成一个用来存放数据库的簇, 可通过`cd $PGDATA`进入到其文件夹
- Database(s): 在CLuster下可以创建多个互相隔离的数据库
- Schema(s): 默认有一个public的schema
- Object: 包含Tables, Index, View, Function(s), 序列Sequence(s), Other(s)
- Field: Tables中还包含Row和Col

## PostgreSQL物理结构概貌

![物理](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222182854.png)

- 每一个Object都有相对应的数据文件(Datafile), 大小为编译时通过`--with-segsize`指定, 默认1GB.
- Controlfile: 控制文件
- WALs: 日志文件
- Archived: 归档文件

## PostgreSQL进程结构概貌

1. 用户(APP)先与postmaster主进程联系, 主进程fork出一个backend process进程与APP进行后续操作.
2. WAL writer负责将WAL buffer写入到XLOGs日志, backend process发现WAL buffer满了(等情况)后, 也会将WAL buffer中的信息写入到XLOGs日志
3. bgwriter负责将Shared buffer中的信息写入到Datafiles, 当backed process中新来了一条插入语句, 但是Shared buffer满了(等情况)的话, backed process也会将Shared buffer中的数据写入到Datafiles
4. Archiver将写满的XLOG文件归档到ARCH FILEs

## PostgreSQL部分命令

**Informational**

(options: `S` = 显示系统对象, `+` = 附加详细信息)

- `\d[S+]`: 查看tables, views和sequences
- `\d[S+] NAME`: tables, views, sequences或index的描述

## PostgreSQL系统表介绍

- 系统表, 系统表之间基本上都是oid(隐藏字段)关联. 例如pg_attrdef.adrelid关联pg_class.oid
- 查询所有系统表: `\dS`或`select relkind, relname from pg_class where relnamespace = (select oid from pg_namespace where nspname='pg_catalog') and relkind='r' order by 1,2;\`

| relkind | relname                 | 用途                                                         |
| ------- | ----------------------- | ------------------------------------------------------------ |
| r       | pg_aggregate            | 聚合函数信息, 包括聚合函数的中间函数, 中间函数的初始值, 最终函数等. |
| r       | pg_am                   | 系统支持的索引访问方法.(如bree, hash, gist, gin, spgist)`select amname from pg_am;` |
| r       | pg_amop                 | 存储每个索引访问方法操作符家族(pg_opfamily)中的详细操作符信息 |
| r       | pg_amproc               | 存储每个索引访问方法操作符家族(pg_opfamily)支持的函数信息.   |
| r       | pg_attrdef              | 存储数据表列的默认值(例如创建表时指定了列的default值)        |
| r       | pg_attribute            | 存储数据表列的详细信息. 包括隐含的列(ctid, cmin, cmax, xmin, xmax) |
| r       | pg_auth_memebers        | 数据库用户的成员关系信息                                     |
| r       | pg_authid               | 存储数据库用户的详细信息(包括是否超级用户, 是否允许登录, 密码(加密与否和创建用户时是否指定encrypted有关), 密码失效时间等). |
| r       | pg_cast                 | 数据库的显性类型转换路径信息, 包括内建和自定义的.            |
| r       | pg_class                | 几乎包括了数据库的所有对象信息(r=ordinary table, i=index, S=sequence, v=view, m=materialized view, c=composite type, t=TOAST table, f=foreign table) |
| r       | pg_collation            | 集信息, 包括encoding, collate, ctype等.                      |
| r       | pg_constraint           | 存储列上定义的约束信息(例如PK, FK, UK, 排他约束, check约束, 但是不包括非空约束) |
| r       | pg_conversion           | 字符集之间的转换相关信息                                     |
| r       | pg_database             | 集群中的数据库信息                                           |
| r       | pg_db_role_setting      | 基于角色和数据库组合的定制参数信息. (alter role set...)      |
| r       | pg_default_acl          | 存储新创建对象的初始权限信息                                 |
| r       | pg_depend               | 数据库对象之间的依赖信息                                     |
| r       | pg_description          | 数据库对象的描述信息                                         |
| r       | pg_enum                 | 枚举类型信息                                                 |
| r       | pg_event_trigger        | 事件触发器信息                                               |
| r       | pg_extension            | 扩展插件信息                                                 |
| r       | pg_foreign_data_wrapper | FDW信息                                                      |
| r       | pg_foreign_table        | 外部表信息                                                   |
| r       | pg_index                | 索引信息                                                     |
| r       | pg_inherits             | 继承表的继承关系信息                                         |
| r       | pg_language             | 过程语言信息                                                 |
| r       | pg_largeobject          | 大对象的切片后的真实数据存储在这个表里                       |
| r       | pg_largeobject_metadata | 大对象的元信息, 包括大对象的owner, 访问权限.                 |
| r       | pg_namespace            | 数据库中欧哪个的schema信息(pg中称为namespace)                |
| r       | pg_opclass              | 索引访问方法的操作符分类信息                                 |
| r       | pg_operator             | 操作符信息                                                   |
| r       | pg_opfamily             | 操作符家族信息                                               |
| r       | pg_pltemplate           | 过程语言的模板信息                                           |
| r       | pg_proc                 | 数据库服务端函数信息                                         |
| r       | pg_range                | 范围类型信息                                                 |
| r       | pg_rewrite              | 表和试图的重写规则信息                                       |
| r       | pg_seclable             | 安全标签信息(SELinux)                                        |
| r       | pg_shdepend             | 数据库中的对象之间或者集群中的共享对象之间的依赖关系         |
| r       | pg_shdescription        | 共享对象的描述信息                                           |
| r       | pg_shseclable           | 共享对象的安全标签信息(SELinux)                              |
| r       | pg_statistic_analyze    | 生成的统计信息, 用于查询计划器计算成本                       |
| r       | pg_tablespace           | 表空间相关的信息                                             |
| r       | pg_trigger              | 表上的触发器信息                                             |
| r       | pg_ts_config            | 全文检索的配置信息                                           |
| r       | pg_ts_config_map        | 全文检索配置映射信息                                         |
| r       | pg_ts_dict              | 全文检索字典信息                                             |
| r       | pg_ts_parser            | 全文检索解析器信息                                           |
| r       | pg_ts_template          | 全文检索模板信息                                             |
| r       | pg_type                 | 数据库中的类型信息                                           |
| r       | pg_user_mapping         | foregin server的用户配置信息                                 |

## PostgreSQL系统视图介绍

- 获取所有系统视图: `\dvS`或`select relkind, relname from pg_class where relnamespace = (select oid from pg_namespace where nspname='pg_catalog') and relkind='v' order by 1,2;`

| relkind | relname                         | 用途                                             |
| ------- | ------------------------------- | ------------------------------------------------ |
| v       | pg_available_extension_versions | 显示当前系统已经编译的扩展插件的版本信息         |
| v       | pg_available_extensions         | 显示但那给钱系统已经编译的扩展插件信息           |
| v       | pg_cursors                      | 当前可用的游标                                   |
| v       | pg_group                        | 用户组信息                                       |
| v       | pg_indexes                      | 索引信息                                         |
| v       | pg_locks                        | 锁信息                                           |
| v       | pg_matviews                     | 物化视图信息                                     |
| v       | pg_prepared_statements          | 当前会话中使用prepare语法写的预处理SQL信息       |
| v       | pg_prepared_xacts               | 二阶事物信息                                     |
| v       | pg_roles                        | 数据库角色信息                                   |
| v       | pg_rules                        | 数据库中使用create rule创建的规则信息            |
| v       | pg_seclables                    | 安全标签信息                                     |
| v       | pg_settings                     | 当缉拿数据库集群的参数设置信息                   |
| v       | pg_shadow                       | 数据库用户信息                                   |
| v       | pg_stat_activity                | 会话活动信息                                     |
| v       | pg_stat_all_indexes             | 查询用户权限范围内的所有索引的统计信息           |
| v       | pg_stat_all_tables              | 查询用户权限范围内的所有表的统计信息             |
| v       | pg_stat_bgwriter                | bgwriter进程的统计信息                           |
| v       | pg_stat_database                | 数据库即别的统计信息                             |
| v       | pg_stat_database_conflicts      | 数据库冲突统计信息                               |
| v       | pg_stat_replication             | 流复制相关的统计信息                             |
| v       | pg_stat_sys_indexes             | 系统表相关的索引统计信息                         |
| v       | pg_stat_sys_tables              | 系统表统计信息                                   |
| v       | pg_stat_user_function           | 用户函数统计信息                                 |
| v       | pg_stat_user_indexes            | 用户表的索引相关的统计信息                       |
| v       | pg_stat_user_tables             | 用户表统计信息                                   |
| v       | pg_stat_xact_all_tables         | 当前事物的表级统计信息, 显示用户可以放问的所有表 |
| v       | pg_stat_xact_sys_tables         | 当前事务的表级统计信息, 仅显示系统表             |
| v       | pg_stat_xact_user_functions     | 当前事务的用户函数的统计信息                     |
| v       | pg_stat_xact_user_tables        | 当前事务的用户表的统计信息                       |
| v       | pg_statio_all_indexes           | 所有索引io相关的统计信息                         |
| v       | pg_statio_all_sequences         | 所有序列io相关的统计信息                         |
| v       | pg_statio_all_tables            | 所有表io相关的统计信息                           |
| v       | pg_statio_sys_indexes           | 系统索引io相关的统计信息                         |
| v       | pg_statio_sys_sequences         | 系统序列io相关的统计信息                         |
| v       | pg_statio_sys_tables            | 系统表io相关的统计信息                           |
| v       | pg_statio_user_indexes          | 用户索引io相关的统计信息                         |
| v       | pg_statio_user_sequences        | 用户序列io相关的统计信息                         |
| v       | pg_statio_user_tables           | 用户表io相关的统计信息                           |
| v       | pg_stats                        | 数据库中的统计信息, 以列为最小统计单位输出       |
| v       | pg_tables                       | 数据库中的表对象的信息                           |
| v       | pg_timezone_abbrevs             | 时区缩写信息                                     |
| v       | pg_timezone_names               | 时区信息, 包含全名                               |
| v       | pg_user                         | 用户信息                                         |
| v       | pg_user_mappings                | 外部表的用户映射权限信息                         |
| v       | pg_views                        | 视图信息                                         |

## PostgreSQL管理函数

- https://www.postgresql.org/docs/9.3/functions-admin.html

### 配置函数

| Name                                          | Return Type | Description                        |
| --------------------------------------------- | ----------- | ---------------------------------- |
| current_setting(setting_name)                 | text        | get current value of setting       |
| set_config(setting_name, new_value, is_local) | text        | set parameter and return new value |

**示例**

- 查询配置信息: `show enable_seqscan;` <=> `select * from current_setting(enable_seqscan);`

- 设置配置信息(会话级别的):

   

  ```sql
  select * from set_config('enable_seqcan', 'off', false)
  ```

  > 可通过`begin`开启一个事务, 然后设置事务级别的配置

### 服务端信号发送函数

| Name                         | Return Type | Description                                                  |
| ---------------------------- | ----------- | ------------------------------------------------------------ |
| pg_cancel_backend(pidint)    | boolean     | Cancel a backend's current query. You can execute this against another backend that has exactly the same role as the user calling the function. In all other cases, you must be a superuser. (关闭当前查询) |
| pg_reload_conf()             | boolean     | Cause server processes to reload their configuration files(重读配置文件pg_hba.conf, postgresql.conf) |
| pg_rotate_logfile()          | boolean     | Rotate server's log file. (将日志写到新文件中)               |
| pg_terminate_backend(pidint) | boolean     | Terminate a backend. You can execute this against another backend that has exactly the same role as the user calling the function. In all other cases, you must be a superuser. (关闭当前终端会话) |

**示例**

- 重读配置文件: `pg_ctl reload`或`select pg_reload_conf();`或`kill -s SIGHUP 进程号`
- 将日志写到新建的文件中: `select pg_rotate_logfile();`

### 备份控制函数

| Name                                                    | Return Type              | Description                                                  |
| ------------------------------------------------------- | ------------------------ | ------------------------------------------------------------ |
| pg_create_restore_point(name text)                      | text                     | Create a named point for performing restore(restricted to superusers) |
| pg_current_xlog_insert_location()                       | text                     | Get current transaction log insert location                  |
| pg_current_xlog_location()                              | text                     | Get current transaction log write location                   |
| pg_start_backup(label text [, fast boolean])            | text                     | Prepare for performing on-line backup(restricted to superusers or replication roles) |
| pg_stop_backup()                                        | text                     | Finish performing on-line backup(restricted to superusers or replication roles) |
| pg_is_in_backup()                                       | bool                     | True if an on-line exclusive backup in progress              |
| pg_backup_start_time()                                  | timestamp with time zone | Get start time of an on-linie exclusive backup in progress.  |
| pg_switch_xlog()                                        | text                     | Force switch to a new transaction log file(restricted to superusers) |
| pg_xlogfile_name(location text)                         | text                     | Convert transaction log location string file name            |
| pg_xlogfile_name_offset(location text)                  | text, integer            | Convert transaction log location string to file name and decimal byte offset within file |
| pg_xlogfile_location_diff(location text, location text) | numeric                  | Calculate the difference between two transaction log locations |

### 恢复信息函数

| Name                            | Return Type              | Description                                                  |
| ------------------------------- | ------------------------ | ------------------------------------------------------------ |
| pg_is_in_recovery()             | bool                     | True if recovery is still in progress.                       |
| pg_last_xlog_receive_location() | text                     | Get last transaction log location received and synced to disk by streaming replication. While streaming replication is in progress this will increase monotonically. If recovery has completed this will remain static at the value of the last WAL record received and synced to disk during recovery. If streaming replication is disabled, or if it has not yet started, the function returns NULL. |
| pg_last_xlog_replay_location()  | text                     | Get last transaction log location replayed during recovery. If recovery is still in progress this will increase monotonically. If recovery has completed then this value will remain static at the value of the last WAL record applied during that recovery. When the server has been started normally without recovery the function returns NULL. |
| pg_last_xact_replay_timestamp() | timestamp with time zone | Get time stamp of last transaction replayed during recovery. This is the time at which the commit or abort WAL record for that transaction was generated on the primary. If no transactions have been replayed during recovery, this function returns NULL. Otherwise, if recovery is still in progress this will increase monotonically. If recovery has completed then this value will remain static at the value of the last transaction applied during that recovery. When the server has been started normally without recovery the function returns NULL. |

### 恢复控制函数

| Name                       | Return Type | Description                         |
| -------------------------- | ----------- | ----------------------------------- |
| pg_is_xlog_replay_paused() | bool        | True if recovery is paused.         |
| pg_xlog_replay_pause()     | void        | Pauses recovery immediately.        |
| pg_xlog_replay_resume()    | void        | Restarts recovery if it was paused. |

### 事务镜像导出函数

| Name                 | Return Type | Description                                         |
| -------------------- | ----------- | --------------------------------------------------- |
| pg_export_snapshot() | text        | Save the current snapshot and return its identifier |

### 数据库对象管理函数

| Name                                           | Return Type | Description                                                  |
| ---------------------------------------------- | ----------- | ------------------------------------------------------------ |
| pg_column_size(any)                            | int         | Number of bytes used to store a particular value (possibly compressed) |
| pg_database_size(oid)                          | bigint      | Disk space used by the database with the specified OID       |
| pg_database_size(name)                         | bigint      | Disk space used by the database with the specified name      |
| pg_indexes_size(regclass)                      | bigint      | Total disk space used by indexes attached to the specified table |
| pg_relation_size(relation regclass, fork text) | bigint      | Disk space used by the specified fork ('main', 'fsm', 'vm', or 'init') of the specified table or index |
| pg_relation_size(relation regclass)            | bigint      | Shorthand for pg_relation_size(..., 'main')                  |
| pg_size_pretty(bigint)                         | text        | Converts a size in bytes expressed as a 64-bit integer into a human-readable format with size units |
| pg_size_pretty(numeric)                        | text        | Converts a size in bytes expressed as a numeric value into a human-readable format with size units |
| pg_table_size(regclass)                        | bigint      | Disk space used by the specified table, excluding indexes (but including TOAST, free space map, and visibility map) |
| pg_tablespace_size(oid)                        | bigint      | Disk space used by the tablespace with the specified OID     |
| pg_tablespace_size(name)                       | bigint      | Disk space used by the tablespace with the specified name    |
| pg_total_relation_size(regclass)               | bigint      | Total disk space used by the specified table, including all indexes and TOAST data |

### 数据库对象存储位置管理函数

| Name                                    | Return Type | Description                               |
| --------------------------------------- | ----------- | ----------------------------------------- |
| pg_relation_filenode(relation regclass) | oid         | Filenode number of the specified relation |
| pg_relation_filepath(relation regclass) | text        | File path name of the specified relation  |

### 文件访问函数

| Name                                                         | Return Type | Description                        |
| ------------------------------------------------------------ | ----------- | ---------------------------------- |
| pg_ls_dir(dirname text)                                      | setof text  | List the contents of a directory   |
| pg_read_file(filename text [, offset bigint, length bigint]) | text        | Return the contents of a text file |
| pg_read_binary_file(filename text [, offset bigint, length bigint]) | bytea       | Return the contents of a file      |
| pg_stat_file(filename text)                                  | record      | Return information about a file    |

### 应用锁函数, 对于长时间持锁的应用非常有效. 因为长时间的数据库重量锁会带来垃圾回收的问题

Name | Return Type | Description 
--- | --- | ---
pg_advisory_lock(key bigint) | void | Obtain exclusive session level advisory lock pg_advisory_lock(key1 int, key2 int) | void | Obtain exclusive session level advisory lock pg_advisory_lock_shared(key bigint) | void | Obtain shared session level advisory lock pg_advisory_lock_shared(key1 int, key2 int) | void | Obtain shared session level advisory lock pg_advisory_unlock(key bigint) | boolean | Release an exclusive session level advisory lock pg_advisory_unlock(key1 int, key2 int) | boolean | Release an exclusive session level advisory lock pg_advisory_unlock_all() | void | Release all session level advisory locks held by the current session pg_advisory_unlock_shared(key bigint) | boolean | Release a shared session level advisory lock pg_advisory_unlock_shared(key1 int, key2 int) | boolean | Release a shared session level advisory lock pg_advisory_xact_lock(key bigint) | void | Obtain exclusive transaction level advisory lock pg_advisory_xact_lock(key1 int, key2 int) | void | Obtain exclusive transaction level advisory lock pg_advisory_xact_lock_shared(key bigint) | void | Obtain shared transaction level advisory lock pg_advisory_xact_lock_shared(key1 int, key2 int) | void | Obtain shared transaction level advisory lock pg_try_advisory_lock(key bigint) | boolean | Obtain exclusive session level advisory lock if available pg_try_advisory_lock(key1 int, key2 int) | boolean | Obtain exclusive session level advisory lock if available pg_try_advisory_lock_shared(key bigint) | boolean | Obtain shared session level advisory lock if available pg_try_advisory_lock_shared(key1 int, key2 int) | boolean | Obtain shared session level advisory lock if available pg_try_advisory_xact_lock(key bigint) | boolean | Obtain exclusive transaction level advisory lock if available pg_try_advisory_xact_lock(key1 int, key2 int) | boolean | Obtain exclusive transaction level advisory lock if available pg_try_advisory_xact_lock_shared(key bigint) | boolean | Obtain shared transaction level advisory lock if available pg_try_advisory_xact_lock_shared(key1 int, key2 int) | boolean | Obtain shared transaction level advisory lock if available

## PostgreSQL进程结构

进程源码大部分再: src/backend/postmaster

- postmaster: 所有数据库进程的主进程(负责监听和fork子进程)
- startup: 主要用于数据库恢复的进程
- syslogger: 记录系统日志
- pgstat: 收集统计信息
- pgarch: 如果开启了归档, 那么postmaster会fork一个归档进程
- checkpointer: 负责检查点的进程
- bgwriter: 负责把shared buffer中的脏数据写入磁盘的进程
- autovacuum lanucher: 负责回收垃圾数据的进程, 如果开启了autovacuum, 那么postmaster会fork此进程
- autovacuum worker: 负责回收垃圾数据的work进程, 是lanucher进程fork出来的

## PostgreSQL物理结构

对象对应的物理文件再哪里?

```shell
postgres=# select pg_relation_filepath('pg_class'::regclass);
    pg_realation_filepath
-----------------------------
```
