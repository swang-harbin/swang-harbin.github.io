---
title: MySQL用户及权限管理
date: '2020-03-31 00:00:00'
updated: '2020-03-31 00:00:00'
tags:
- MySQL
categories:
- database
---

# MySQL的用户及权限管理

MySQL版本: 5.7

# 一. 用户相关常用命令

用户相关信息存储在mysql.user表中

- 修改用户密码

```mysql
ALTER USER 'user'@'host' IDENTIFIED BY 'new_password';
```

执行ALTER USER指令, 必须具有全局的CREATE USER权限或mysql系统数据库的UPDATE权限. 如果数据库系统设置了read only属性, 则还需添加SUPER权限.

- 创建用户

```mysql
CREATE USER 'user'@'host';
CREATE USER 'user'@'host' IDENTIFIED BY 'password';
```

如果不指定host, 默认的host为'%', 代表任意ip均可使用

执行CREATE USER指令, 必须具有全局的CREATE USER权限或mysql系统数据库的INSERT权限. 如果数据库系统设置了read only属性, 则还需添加SUPER权限.

- 删除用户

```mysql
DROP USER 'user'@'host'
```

执行DROP USER指令, 必须具有全局的CREATE USER权限或mysql系统数据库的DELETE权限. 如果数据库系统设置了read only属性, 则还需添加SUPER权限.

- 修改用户名

```mysql
RENAME USER 'user'@'host' TO 'new_user'@'new_host';
```

# 二. 权限相关常用命令

用户信息及全局权限信息保存在mysql.user表中, 数据库权限信息保存在mysql.db表中, 表权限信息保存在mysql.tables_priv表中, 列权限信息保存在mysql.columns_priv表中.

- 常用格式

```mysql
GRANT priv_type[ ,priv_type ,...] ON priv_level TO 'user'@'host' [WITH GRANT OPTION]
```

priv_type包含

| Privilege               | Meaning and Grantable Levels                                 |
| ----------------------- | ------------------------------------------------------------ |
| ALL [PRIVILEGES]        | Grant all privileges at specified access level except GRANT OPTION and PROXY |
| ALTER                   | Enable use of ALTER TABLE Statement                          |
| ALTER TABLE             | Levels: Global, database, table.                             |
| ALTER ROUTINE           | Enable stored routines to be altered or dropped. Levels: Global, database, routine. |
| CREATE                  | Enable database and table creation. Levels: Global, database, table. |
| CREATE ROUTINE          | Enable stored routine creation. Levels: Global, database.    |
| CREATE TABLESPACE       | Enable tablespaces and log file groups to be created, altered, or dropped. Level: Global. |
| CREATE TEMPORARY TABLES | Enable use of CREATE TEMPORARY TABLE. Levels: Global, database. |
| CREATE USER             | Enable use of CREATE USER, DROP USER, RENAME USER, and REVOKE ALL PRIVILEGES. Level: Global. |
| CREATE VIEW             | Enable views to be created or altered. Levels: Global, database, table. |
| DELETE                  | Enable use of DELETE. Level: Global, database, table.        |
| DROP                    | Enable databases, tables, and views to be dropped. Levels: Global, database, table. |
| EVENT                   | Enable use of events for the Event Scheduler. Levels: Global, database. |
| EXECUTE                 | Enable the user to execute stored routines. Levels: Global, database, routine. |
| FILE                    | Enable the user to cause the server to read or write files. Level:Global. |
| GRANT OPTION            | Enable privileges to be granted to or removed from other accounts. Levels: Global, database, table, routine, proxy. |
| INDEX                   | Enable indexes to be created or dropped. Levels: Global, database, table. |
| INSERT                  | Enable use of INSERT. Levels: Global, database, table, column. |
| LOCK TABLES             | Enable use of LOCK TABLES on tables for which you have the SELECT privilege. Levels: Global, database. |
| PROCESS                 | Enable the user to see all processes with SHOW PROCESSLIST. Level: Global. |
| PROXY                   | Enable user proxying. Level: From user to user.              |
| REFERENCES              | Enable foreign key creation. Levels: Global, database, table, column. |
| RELOAD                  | Enable use of FLUSH operations. Level: Global.               |
| REPLICATION CLIENT      | Enable the user to ask where master or slave servers are. Level: Global. |
| REPLICATION SLAVE       | Enable replication slaves to read binary log events from the master.Level: Global. |
| SELECT                  | Enable use of SELECT. Levels: Global, database, table, column. |
| SHOW DATABASES          | SHOW DATABASES to show all databases. Level: Global.         |
| SHOW VIEW               | Enable use of SHOW CREATE VIEW. Levels: Global, database, table. |
| SHUTDOWN                | Enable use of mysqladmin shutdown. Level: Global.            |
| SUPER                   | Enable use of other administrative operations such as CHANGE MASTER TO, KILL, PURGE BINARY LOGS, SET GLOBAL, and mysqladmin debug command. Level: Global. |
| TRIGGER                 | Enable trigger operations. Levels: Global, database, table.  |
| UPDATE                  | Enable use of UPDATE. Levels: Global, database, table, column. |
| USAGE                   | Synonym for no privileges                                    |

```mysql
priv_level: {
    *
  | *.*
  | db_name.*
  | db_name.tbl_name
  | tbl_name
  | db_name.routine_name
}
```

- 授予某用户所有权限

```mysql
GRANT ALL ON *.* TO 'user'@'host';
```

- 授予某用户对某个数据库的所有权限

```mysql
GRANT ALL ON db_name.* TO 'user'@'host';
```

- 授予某用户所有权限, 包括GRANT权限

```mysql
GRANT ALL ON *.* TO 'user'@'host' WITH GRANT OPTION;
```

- 取消授权

  > 格式与GRANT基本相同, 只需将TO修改为FROM

```mysql
REVOKE priv_type[ ,priv_type ,... ,GRANT OPTION] ON priv_level FROM 'user'@'host' ;
```

- 查看某用户具有的权限

```mysql
SHOW GRANTS FOR 'user'@'host';
```

# 三. MySQL对用户权限的判断流程

1. 首先判断GLOABLE权限(mysql.user表), 如果具备权限, 则不再向下一级别判断.
2. 然后判断database级权限(mysql.db表), 如果具备权限, 则不再向下一级别判断.
3. 然后判断table级权限(mysql.tables_priv表), 如果具备权限, 则不再向下一级别判断.
4. 然后判断columns权限(mysql.columns_priv表), 如果具备权限, 则不再向下一级别判断.

示例 : 如果mysql.user表中, wang@%用户具有SELECT权限 则其对所有数据库均具有SELECT权限, 即使mysql.db表中, wang@%用户对testdatabase数据库没有SELECT权限, 其也可以使用SELECT语句查询testdatabase数据库中的信息, 因为在判断GLOABLE权限时, 即已经确认具有权限.

如果mysql.user表中, wang@%用户不具有INSERT权限, 则其对数据库是否能够INSERT, 需要去下一级别的表中查找, 如果在mysql.db表中, wang@%用户对testdatabase数据库具有INSERT权限, 则其可以对testdatabase数据库进行INSERT操作, 对其他数据表/列是否具备INSERT权限, 需要逐级去mysql.tables_priv, 甚至mysql.columns_priv表查看.

[官网: account-management-statements](https://dev.mysql.com/doc/refman/5.7/en/account-management-statements.html)
