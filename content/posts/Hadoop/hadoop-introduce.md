---
title: Hadoop 介绍
date: '2020-04-08 00:00:00'
tags:
- Hadoop
---
# Hadoop 介绍

## Hadoop 是什么

1. Hadoop 是一个由 Apache 基金会所开发的**分布式**系统**基础架构**。
2. 主要解决，海量数据的**存储**和海量数据的**分析计算**问题。
3. 广义上来说，Hadoop 通常是指一个更广泛的概念——Hadoop 生态圈。

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142848.png)

## Hadoop 发展史

1. Lucene 框架是 Doug Cutting 开创的开源软件，用 Java 书写代码，实现了与 Google 类似的全文搜索功能，它提供了全文检索引擎的架构，包括完整的查询引擎和索引引擎。
2. 2001 年年底，Lucene 成为 Apacha 基金会的一个子项目。
3. 对于海量数据的场景，Lucene 面对与 Google 同样的困难，**存储数据困难，检索速度慢**。
4. 学习和模仿 Google 解决这些问题的方法：微型版 Nutch。
5. 可以说 Google 是 Hadoop 的思想之源（Google 在大数据方面的三篇论文）
   
    - GFS --> HDFS
    - Map-Resuce --> MR
    - BigTable --> HBase
6. 2003 年至 2004 年，Google 公开了部分 GFS 和 MapReduce 思想的细节，以此为基础 Doug Cutting 等人用了 **2 年业余时间**实现了 DFS 和 MapReduce 机制，使 Nutch 性能飙升。
7. 2005 年 Hadoop 作为 Lucene 的子项目 Nutch 的一部分正式引入 Apache 基金会。
8. 2006 年 2 月份，Map-Reduce 和 Nutch Distributed File System（NDFS）分别被纳入称为 Hadoop 的项目中。
9. 名称来源于 Doug Cutting 儿子的玩具大象。
10. Hadoop 就此诞生并迅速发展，标志着大数据时代的来临。

## Hadoop 三大发行版本

Hadoop 三大发行版本：Apache、Cloudera、Hortonworks。

- Apache 版本最原始（最基础）的版本，对于入门学习最好。
- Cloudera 在大型互联网企业中用的较多，收费。
- Hortonworks 文档较好。

### Apache Hadoop
- [官网地址](http://hadoop.apache.org/) 
- [下载地址](https://archive.apache.org/dist/hadoop/common/)

### Cloudera Hadoop

- [官网地址](https://www.cloudera.com/)
- [下载地址](http://archive-primary.cloudera.com/cdh5/cdh5/)

1. 2008 年成立的 Cloudera 是最早将 Hadoop 商用的公司，为合作伙伴提供 Hadoop 的商用解决方案，主要是包括支持、咨询服务、培训。
2. 2009 年 Hadoop 的创始人 Doug Cutting 也加盟 Cloudera 公司。Cloudera 产品主要为 CDH、Coudera Manager、Cloudera Support。
3. CDH 是 Cloudera 的 Hadoop 发行版，完全开源，比 Apache Hadoop 在兼容性，安全性，稳定性上有所增强。
4. Cloudera Manager 是集群的软件分发及管理监控平台，可以在几小时内部署好一个 Hadoop 集群，并对集群的节点及服务进行实时监控。Cloudera Suppert 即是对 Hadoop 的技术支持。
5. Cloudera 的标价为每年每个节点 4000 美元。Cloudera 开发并贡献了可实时处理大数据的 Impala 项目。

### Hortonworks Hadoop

- [官网地址](https://hortonworks.com/)
- [下载地址](https://hortonworks.com/downloads/#data-platform)

1. 2011 年成立的 Hortonworks 是雅虎与硅谷风投公司 Benchmark Capital 合资组建。
2. 公司成立之初就吸纳了大约 25 名至 30 名专门研究 Hadoop 的雅虎工程师。上述工程师在 2005 年开始协助雅虎开发 Hadoop，贡献了 Hadoop 80% 的代码。
3. 雅虎工程副总裁，雅虎 Hadoop 开发团队负责人 Eric Baldeschwieler 出任 Hortonworks 的首席执行官。
4. Hortonworks 的主打产品是 Hortonworks Data Platform（HDP），也同样是 100% 开源的产品，HDP 除常见的项目外还包括了 Ambari，一款开源的安装和管理系统。
5. HCatalog，一个元数据管理系统，HCatelog 现已集成到 Facebook 开源的 Hive 中。

## Hadoop 的优势（4 高）

1. 高可靠性：Hadoop 底层维护多个数据副本（至少 3 份），所以即使 Hadoop 某个计算元素或存储出现故障，也不会导致数据的丢失。
2. 高扩展性：在集群分配任务数据，可方便的扩展数以千计的节点。
3. 高效性：在 MapReduce 的思想下，Hadoop 是并行工作的，以加快任务的处理速度。
4. 高容错性：能够自动将失败的任务重新分配。

## Hadoop 组成（面试重点）

### Hadoop1.x 和 Hadoop2.x 区别

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142851.png)

在 Hadoop1.x 时代，Hadoop 中的 MapResuce 同时处理业务逻辑运算和资源的调度，耦合性较大，在 Hadoop2.x 时代，增加了 Yarn。Yarn 只负责资源的调度，MapResuce 只负责运算。

### HDFS 架构概述

HDFS：Hdoop Distributed File System，Hadoop 分布式文件系统

1. NameNode（nn）：存储文件的元数据，如文件名、文件目录结构、文件属性（生成时间、副本数、文件权限），以及每个文件的块列表和块所在的 DataNode 等。

   相当于目录

2. DataNode（dn）：在本地文件系统存储文件块数据，以及块数据的校验和。

   相当于目录指向的大量数据

3. Secondary NameNode（2nn）：用来监控 HDFS 状态的辅助后台程序，每隔一段时间获取 HDFS 元数据的快照。

   辅助 NameNode 的

### YARN 架构

YARN：Yet Another Resource Negotiator，另一种资源协调者

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142854.png)

1. ResourceManager（RM）主要作用如下
    - 处理客户端请求
    - 监控 NodeManager
    - 启动或监控 ApplicationMaster
    - 资源的分配与调度

2. NodeManager（NM）主要作用如下
    - 管理单个节点上的资源
    - 处理来自 ResourceManager 的命令
    - 处理来自 ApplicationManager 的命令

3. ApplicationMaster（AM）作用如下
    - 负责数据的切分
    - 为应用程序申请资源并分配给内部的任务
    - 任务的监控与容错

4. Container
    Container 是 YARN 中的资源抽象，它封装了某个节点上的多维度资源，如内存、CPU、磁盘、网络等。

### MapReduce 架构概述

MapReduce 将计算过程分为两个阶段：Map 和 Reduce

1. Map 阶段并行处理输入数据
2. Reduce 阶段对 Map 结果进行汇总

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142856.png)

## 大数据技术生态体系

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142900.png)


## Hadoop 推荐系统框架图

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142908.png)

# Hadoop 运行环境搭建

## 虚拟机环境准备

1. 克隆虚拟机

2. 修改克隆虚拟机的静态 IP

   /etc/sysconfig/network-scripts/ifcfg-eth0

   ```properties
   TYPE="Ethernet"
   PROXY_METHOD="none"
   BROWSER_ONLY="no"
   BOOTPROTO="static"
   IPADDR="192.168.122.101"
   GATEWAY="192.168.122.1"
   NETMASK="255.255.255.0"
   DNS1="8.8.8.8"
   DEFROUTE="yes"
   IPV4_FAILURE_FATAL="no"
   IPV6INIT="yes"
   IPV6_AUTOCONF="yes"
   IPV6_DEFROUTE="yes"
   IPV6_FAILURE_FATAL="no"
   IPV6_ADDR_GEN_MODE="stable-privacy"
   NAME="eth0"
   UUID="a5227980-3d9c-4718-8125-0b2023521442"
   DEVICE="eth0"
   ONBOOT="yes"
   ```

3. 修改主机名

   /etc/hostname

   ```
   192-168-122-101
   ```

   在 /etc/hosts 文件中添加

   ```properties
   192.168.122.101 192-168-122-101
   192.168.122.102 192-168-122-102
   ```

4. 关闭防火墙

   ```bash
   systemctl stop firewalld
   ```

5. 创建 hadooptest 用户

   ```bash
   useradd hadooptest
   ```

6. 配置 hadooptest 用户具有 root 权限

   /etc/sudoers，在如下部分添加 hadooptest 用户

   ```bash
   ## Allow root to run any commands anywhere 
   root    ALL=(ALL)       ALL
   hadooptest    ALL=(ALL)    ALL
   ```

7. 在 /opt 目录下创建文件夹

   1. 创建 module 和 software 文件夹

   2. 将这两个文件夹所有者和所属组给 hadooptest 用户和 hadooptest 组

## 安装 JDK，并设置环境变量

解压 software 文件夹中的 jdk-8u241-linux-x64.tar.gz 到 module 目录

```bash
tar -zxvf /opt/software/jdk-8u241-linux-x64.tar.gz -C /opt/module
```

配置环境 ~/.bash_profile
```bash
# Java Environment
JAVA_HOME=/opt/module/jdk1.8.0_241
PATH=$JAVA_HOME/bin:$PATH
CLASSPATH=.:$JAVA_PATH/lib

export JAVA_HOME PATH CLASSPATH
```

使配置生效
```bash
source ~/.bash_profile
```

## 安装 Hadoop

解压 software 文件夹中的 hadoop-2.7.7.tar.gz 到 module 目录

```bash
tar -zxvf /opt/software/hadoop-2.7.7.tar.gz -C /opt/module
```

配置环境 ~/.bash_profile
```bash
# Hadoop Environment
HADOOP_HOME=/opt/module/hadoop-2.7.7
PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH

export HADOOP_HOME PATH
```

使配置生效
```bash
source ~/.bash_profile
```

## Hadoop 目录结构

- bin：
    - hadoop：管理 hadoop 集群
    - hdfs：管理 hdfs
    - yarn：管理资源调度
- etc：配置文件
- include：其他代码的源文件
- lib：本地库
- sbin：hadoop 及集群的启动和停止
    - hadoop-daemon.sh：
    - slaves.sh：启动集群时使用
    - start-all.sh：启动整个集群
    - start-dfs.sh：启动文件系统
    - start-yarn.sh：启动 yarn
    - yarn-daemon.sh：
    - stop-xxx.sh：停止
- share：
    - doc：说明文档
    - hadoop：官方提供的案例

# Hadoop 运行模式

Hadoop 运行模式包括：本地模式，伪分布式模式以及完全分布式模式。

Hadoop 官方网站：http://hadoop.apache.org/

## 本地运行模式

## 官方 Grep 案例

查找符合 'dfs[a-z.]+' 正则表达式的字段

```bash
$ mkdir input
$ cp etc/hadoop/*.xml input
$ bin/hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.7.jar grep input output 'dfs[a-z.]+'
$ cat output/*
```
注：output 文件夹一定不能存在

```bash
1	dfsadmin
```

## 官方 WordCount 案例

1. 创建输入文件夹

   ```bash
   $ mkdir wcinput
   ```

2. 创建输入文件

   ```bash
   $ vim wcinput/wc.input
   ```

   内容

   ```
   tianyi huichao lihua
   zhangchen xiaoheng
   xinbo xinbo
   gaoyang gaoyang yanjing yanjing
   ```

3. 运行程序

   ```bash
   bin/hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.7.jar wordcount wcinput wcoutput
   ```

4. 查看结果

   ```bash
   cat wcoutput/*
   ```

   ```
   gaoyang	2
   huichao	1
   lihua	1
   tianyi	1
   xiaoheng	1
   xinbo	2
   yanjing	2
   zhangchen	1
   ```

## 伪分布式模式

### 修改配置文件

1. etc/hadoop/hadoop-env.sh，修改 JAVA_HOME 位置

   ```bash
   # Set Hadoop-specific environment variables here.
   
   # The only required environment variable is JAVA_HOME.  All others are
   # optional.  When running a distributed configuration it is best to
   # set JAVA_HOME in this file, so that it is correctly defined on
   # remote nodes.
   
   # The java implementation to use.
   export JAVA_HOME=/opt/module/jdk1.8.0_241
   ```

2. [etc/hadoop/core-site.xml](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/core-default.xml)

   ```xml
   <configuration>
       <!-- 指定 HDFS 中 NameNode 的地址 -->
       <property>
           <name>fs.defaultFS</name>
           <value>hdfs://localhost:9000</value>
       </property>
   
       <!-- 指定 Hadoop 运行时产生文件的存储目录-->
       <property>
           <name>hadoop.tmp.dir</name>
           <!-- 默认：/tmp/hadoop-${user.name} -->
           <value>/opt/module/hadoop-2.7.7/data/tmp</value>
       </property>
   </configuration>
   ```

3. [etc/hadoop/hdfs-site.xml](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-hdfs/hdfs-default.xml)

   ```xml
   <configuration>
       <!-- 指定 HDFS 副本的数量 -->
       <property>
           <name>dfs.replication</name>
           <value>1</value>
       </property>
   </configuration>
   ```

如果只有 1 台服务器，value 设置为 \>1 的值，也只有 1 份备份。在添加足够节点后，会自动将指定数量的数据备份到其他节点


### 启动集群

1. 格式化 NameNode（第一次启动时格式化，以后就不要总格式化）

   ```bash
   $ bin/hdfs namenode -format
   ```

   在格式化之前要关闭 NameNode 和 DataNode 进程，删除 data 和 logs 目录。

   执行结束后会创建 hadoop.tmp.dir 指定的文件夹，并在该目录下生成相应数据。

2. 启动 NameNode daemon 和 DataNode daemon

   ```bash
   $ sbin/hadoop-daemon.sh start namenode
   $ sbin/hadoop-daemon.sh start datanode
   ```

   或

   ```bash
   $ sbin/start-dfs.sh
   ```

   hadoop daemon 的日志默认输出在 \$HADOOP_LOG_DIR 目录（默认值为 \$HADOOP_HOME/logs）。

   使用 `jps` 命令可以查看是否启动成功

   ```bash
   $ jps
   3027 NameNode
   3125 DataNode
   3197 Jps
   ```

3. NameNode 信息的浏览器访问接口，默认是：`http://localhost:9870/` 或 `http://localhost:50070/`

4. 设置执行 MapReduce 作业所需的 HDFS 目录（集群使用的目录）

   ```bash
   $ bin/hdfs dfs -mkdir /user
   $ bin/hdfs dfs -mkdir -p /user/<username>
   
   示例
   $ bin/hdfs dfs -mkdir -p /user/hadooptest/input
   ```

   此时，可在通过访问 NameNode 信息的浏览器访问接口 Utilities → Browse the file system 查看创建的文件信息

   ![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142913.png)

5. 输入文件复制到分布式文件系统中：

   ```bash
   $ bin/hdfs dfs -mkdir input
   $ bin/hdfs dfs -put etc/hadoop/*.xml input
   
   示例
   $ bin/hdfs dfs -put etc/hadoop/*.xml /user/hadooptest/input
   ```

6. 运行 hadoop 官方提供的 grep 示例

   ```bash
   $ bin/hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-3.2.1.jar grep input output 'dfs[a-z.]+'
   
   示例
   $ bin/hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.7.jar grep /user/hadooptest/input /user/hadooptest/output 'dfs[a-z.]+'
   ```

7. 检查输出文件：将输出文件从分布式文件系统复制到本地文件系统并检查它们：

   ```bash
   $ bin/hdfs dfs -get output output
   $ cat output/*
   
   示例
   $ mkdir ./output
   $ bin/hdfs dfs -get /user/hadooptest/output/* ./output
   $ cat output/*
   ```

   或，查看分布式文件系统上的输出文件

   ```bash
   $ bin/hdfs dfs -cat output/*
   
   示例
   $ bin/hdfs dfs -cat /user/hadooptest/output/*
   ```

8. 停止 hadoop daemon

   ```bash
   $ sbin/stop-dfs.sh
   ```


## 查看日志文件

hadoop daemon 的日志默认输出在 \$HADOOP_LOG_DIR 目录（默认值为 \$HADOOP_HOME/logs）.

```
hadoop-hadooptest-namenode-192-168-122-101.log
hadoop-hadooptest-datanode-192-168-122-101.log
```

### 单节点启动 YARN 并运行 MapReduce 程序

您可以通过设置一些参数并另外运行 ResourceManager 守护程序和 NodeManager 守护程序，以伪分布式模式在 YARN 上运行 MapReduce 作业。

#### 分析

 - 配置集群在 YARN 上运行 MR
 - 启动，测试集群增，删，查
 - 在 YARN 上执行 WordCount 案例

#### 执行步骤

1. 配置 etc/hadoop/yarn-env.sh

   ```bash
   # some Java parameters
   export JAVA_HOME=/opt/module/jdk1.8.0_241
   ```

2. [etc/hadoop/yarn-site.xml](https://hadoop.apache.org/docs/stable/hadoop-yarn/hadoop-yarn-common/yarn-default.xml)

   ```xml
   <configuration>
       <!-- Reducer 获取数据的方式 -->
       <property>
           <name>yarn.nodemanager.aux-services</name>
           <value>mapreduce_shuffle</value>
       </property>
       <!-- 指定 YARN 的 ResourceManager 的地址 -->
       <property>
           <name>yarn.resourcemanager.hostname</name>
           <value>192-168-122-101</value>
       </property>
   
       <property>
           <name>yarn.nodemanager.env-whitelist</name>
           <value>JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PREPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_MAPRED_HOME</value>
       </property>
   </configuration>
   ```
3. etc/hadoop/mapred-env.sh

   ```bash
   # export JAVA_HOME=/home/y/libexec/jdk1.6.0/
   export JAVA_HOME=/opt/module/jdk1.8.0_241
   ```

4. [etc/hadoop/mapred-site.xml:](https://hadoop.apache.org/docs/stable/hadoop-mapreduce-client/hadoop-mapreduce-client-core/mapred-default.xml)

   ```bash
   $ cp etc/hadoop/mapred-site.xml.template etc/hadoop/mapred-site.xml
   ```

   ```xml
   <configuration>
       <!-- 指定 MR 运行在 YARN 上 -->
       <property>
           <name>mapreduce.framework.name</name>
           <!-- 默认是 local，可以的值 local，classic 或 yarn -->
           <value>yarn</value>
       </property>
       <property>
           <name>mapreduce.application.classpath</name>
           <value>$HADOOP_MAPRED_HOME/share/hadoop/mapreduce/*:$HADOOP_MAPRED_HOME/share/hadoop/mapreduce/lib/*</value>
       </property>
   </configuration>
   ```

5. 启动 ResourceManager daemon 和 NodeManager daemon

   ```bash
   $ sbin/yarn-daemon.sh start resourcemanager
   $ sbin/yarn-daemon.sh start nodemanager
   ```

   或

   ```bash
   $ sbin/start-yarn.sh
   ```

   使用 `jps` 查看启动状态

   ```bash
   $ jps
   3027 NameNode
   5267 NodeManager
   5299 Jps
   5012 ResourceManager
   3125 DataNode
   ```

6. ResourceManager 的浏览器访问接口，默认为：http://localhost:8088/

7. 运行一个 MapReduce 任务

   ```bash
   # 删除之前在 hdfs 中生成的 output 文件夹
   $ hdfs dfs -rm -r /user/hadooptest/output
   # 运行官方示例 grep
   $ hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.7.jar  grep /user/hadooptest/input/*.xml /user/hadooptest/output 'dfs[a-z.]+'
   ```

   可在 http://localhost:8088/ 接口查看执行信息

   ![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142916.png)

8. 停止 daemons

   ```bash
   $ sbin/stop-yarn.sh
   ```

### 配置历史服务器

MapReduce 任务执行结束后，可以看到如下图的 `HISTORY`

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142917.png)

如需查看历史信息，需要配置历史服务器

#### 配置 etc/hadoop/mapred-site.xml

```xml
<configuration>
    <!-- 历史服务器端地址 -->
    <property>
        <name>mapreduce.jobhistory.address</name>
        <value>192-168-122-101:10020</value>
    </property>
    <!-- 历史服务器 web 端地址 -->
    <property>
        <name>mapreduce.jobhistory.webapp.address</name>
        <value>192-168-122-101:19888</value>
    </property>
</configuration>
```
#### 启动历史服务
```bash
$ sbin/mr-jobhistory-daemon.sh start historyserver
```

#### 查看历史服务器是否启动
```bash
$ jps
6702 JobHistoryServer
```

#### 查看 HISTORY 历史信息

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142919.png)

此处可能需要在客户机的 /etc/hosts 文件中添加域名和 IP 的映射关系，例如

    ```
    192.168.122.101 192-168-122-101
    ```

### 配置日志的聚集

- 日志聚集概念：应用运行完成以后，将程序运行日志信息上传到 HDFS 系统上

- 日志聚集功能好处：可以方便的查看到程序运行详情，方便开发测试

**注意：开启日志聚集功能，需要重新启动 NodeManager，ResourceManager 和 HistoryManager.**

#### 配置 etc/hadoop/yarn-site.xml

```xml
<configuration>
    <!-- 开启日志聚集功能 -->
    <property>
        <name>yarn.log-aggregation-enable</name>
        <value>true</value>
    </property>
    <!-- 日志保留时间设置 7 天 -->
    <property>
        <name>yarn.log-aggregation.retain-seconds</name>
        <value>604800</value>
    </property>
</configuration>
```

#### 关闭 HistoryManager，ResourceManager 和 NodeManager

```bash
$ sbin/mr-jobhistory-daemon.sh stop historyserver
$ sbin/yarn-daemon.sh stop resourcemanager
$ sbin/yarn-daemon.sh stop nodemanager
```

#### 启动 NodeManager，ResourceManager 和 HistoryManager
```bash
$ sbin/yarn-daemon.sh start nodemanager
$ sbin/yarn-daemon.sh start resourcemanager
$ sbin/mr-jobhistory-daemon.sh start historyserver
```

#### 删除 HDFS 上已经存在的输出文件

```bash
bin/hdfs dfs -rm -r /user/hadooptest/output
```

#### 执行 Grep 程序
```bash
$ bin/hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.7.jar grep /user/hadooptest/input /user/hadooptest/output 'dfs[a-z.]+'
```

#### 查看日志

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142920.png)


![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142924.png)


### 配置文件说明

Hadoop 配置文件分为两类：默认配置文件和自定义配置文件，只有用户想修改某一默认配置值时，才需要修改自定义配置文件，更改相应属性值。

1. 默认配置文件

要获取的默认文件 | 文件存放在 Hadoop 的 jar 包中的位置
--- | ---
[core-default.xml](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/core-default.xml) | haddop-common-2.7.7.jar/core-default.xml
[hdfs-defalult.xml](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-hdfs/hdfs-default.xml) | hadoop-hdfs-2.7.7.jar/hdfs-default.xml
[yarn-defaulte.xml](https://hadoop.apache.org/docs/stable/hadoop-yarn/hadoop-yarn-common/yarn-default.xml) | hadoop-hdfs-2.7.7.jar/yarn-default.xml
[mapred-default.xml](https://hadoop.apache.org/docs/stable/hadoop-mapreduce-client/hadoop-mapreduce-client-core/mapred-default.xml) | hadoop-mapreduce-client-core-2.7.7.jar/mapred-default.xml

2. 自定义配置文件

**core-site.xml**，**hdfs-site.xml**，**yarn-site.xml**，**mapred-site.xml** 四个配置文件存放在 `$HADOOP_HOME/etc/hadoop` 这个路径下，用户可根据项目需求重新进行修改配置。

## 完全分布式运行模式（开发重点）

### 虚拟机准备

参考 [Hadoop 运行环境搭建](#Hadoop 运行环境搭建）

步骤分析

1. 准备 3 台客户机（**关闭防火墙**，**设置静态 IP**，**修改主机名称**）
2. 安装 JDK
3. 配置环境变量
4. 安装 Hadoop
5. 配置环境变量
6. 配置集群
7. 单点启动
8. 配置 ssh
9. 群起并测试集群

### 编写集群分发脚本 xsync

#### scp（secure copy）安全拷贝

- scp 定义：scp 可以实现服务器与服务器之间的数据拷贝。（from server1 to server2）
- 基本语法
    ```bash
    scp     -r      $pdir/$fname            $user@$host:$pdir/$fname
    命令    递归    要拷贝的文件路径/名称   用户名@主机：目的路径/名称
    ```

#### rsync 远程同步工具

rsync 主要用于备份和镜像。具有速度快，避免复制相同内容和支持符号链接的优点。

rsync 和 scp 区别：用 rsync 做文件的复制要比 scp 的速度快，rsync 只对差异文件做更新。scp 是把所有文件都复制过去。

基本语法
```bash
rsync   -rvl        $pdir/$fname            $user@$host:$pdir/$fname
命令    选项参数    要拷贝的文件路径/名称   目的用户@主机：目的路径/名称
```
选项参数和说明
选项 | 功能
--- | ---
-r | 递归
-v | 显示复制过程
-l | 拷贝符号链接

#### xsync 集群分发脚本

- 1. 需求：循环复制文件到所有节点的相同目录下
- 2. 需求分析
    - rsync 命令原始拷贝
        ```bash
        rsync -rvl /opt/module root@192.168.122.103:/opt/module
        ```
    - 期望脚本
        xsync 要同步的文件名称
    - 说明：在 /home/hadooptest/bin 这个目录下存放的脚本，hadooptest 用户可以在系统任何地方直接执行
- 3. 脚本实现
    - 在 /home/hadooptest 目录下创建 bin 目录，并在 bin 目录下 xsync 创建文件，内容如下
  
      ```bash
      [hadooptest@192-168-122-101 ~]$ ls
      [hadooptest@192-168-122-101 ~]$ mkdir bin
      [hadooptest@192-168-122-101 ~]$ cd bin
      [hadooptest@192-168-122-101 bin]$ touch xsync
      [hadooptest@192-168-122-101 bin]$ vim xsync
      ```
  
      在该文件中编写如下代码
  
      ```bash
      #!/bin/bash
      #1 获取输入参数个数，如果没有参数，直接退出
      pcount=$#
      if((pcount==0)); then
      echo no args;
      exit;
      fi
      
      #2 获取文件名称
      p1=$1
      fname=`basename $p1`
      echo fname=$fname
      
      #3 获取上级目录到绝对路径
      pdir=`cd -P $(dirname $p1); pwd`
      echo pdir=$pdir
      
      #4 获取当前用户名称
      user=`whoami`
      
      #5 循环
      for((host=102; host<104; host++)); do
          echo ----------192-168-122-$host----------
          rsync -rvl $pdir/$pname $user@192-168-122-$host:$pdir
      done
      ```
  
    - 修改 xsync 具有执行权限
  
      ```bash
      $ chmod 777 xsync
      ```
  
    - 调用脚本形式：xsync 文件名称
  
      ```bash
      xsync /home/hadooptest/bin
      ```
  
      **注意：如果将 xsync 放到 /home/hadooptest/bin 目录下仍然不能实现全局使用，可以将 xsync 移动到 /user/local/bin 目录下。**

### 集群配置

#### 集群部署规划

-| 192-168-122-101 | 192-168-122-102 | 192-168-122-103
--- | --- | --- | ---
HDFS | NameNode</br>DataNode | </br>DataNode | SecondaryNameNode</br>DataNode 
YARN | </br>NodeManager | ResourceManager</br>NodeManager | </br>NodeManager

NameNode 和 SecondaryNameNode 占用内存 1:1，所以尽量避免将这两个放在同一个节点上

ResourceManager 占用内存也较大，所以也要和 NameNode，SecondaryNameNode 分开

#### 配置集群

1. 核心配置文件

   配置 etc/hadoop/core-site.xml

   ```xml
   <configuration>
       <!-- 指定 HDFS 中 NameNode 的地址 -->
       <property>
           <name>fs.defaultFS</name>
           <value>hdfs://192-168-122-101:9000</value>
       </property>
       <!-- 指定 Hadoop 运行时产生文件的存储目录-->
       <property>
           <name>hadoop.tmp.dir</name>
           <value>/opt/module/hadoop-2.7.7/data/tmp</value>
       </property>
   </configuration>
   ```

2. HDFS 配置文件

   配置 etc/hadoop/hadoop-env.sh

   ```bash
   # The only required environment variable is JAVA_HOME.  All others are
   # optional.  When running a distributed configuration it is best to
   # set JAVA_HOME in this file, so that it is correctly defined on
   # remote nodes.
   
   # The java implementation to use.
   export JAVA_HOME=/opt/module/jdk1.8.0_241
   ```

   配置 etc/hadoop/hdfs-site.xml

   ```xml
   <configuration>
       <!-- 指定 HDFS 副本的数量 -->
       <property>
           <name>dfs.replication</name>
           <value>3</value>
       </property>
       <!-- 指定 Hadoop 辅助名称节点主机配置 -->
       <property>
           <name>dfs.namenode.secondary.http-address</name>
           <value>192-168-122-103:50090</value>
       </property>
   </configuration>
   ```

3. YARN 配置文件

   配置 etc/hadoop/yarn-env.sh

   ```bash
   # some Java parameters
   export JAVA_HOME=/opt/module/jdk1.8.0_241
   ```

   配置 etc/hadoop/yarn-site.xml

   ```xml
   <configuration>
   
       <!-- Site specific YARN configuration properties -->
       <!-- Reducer 获取数据的方式 -->
       <property>
           <name>yarn.nodemanager.aux-services</name>
           <value>mapreduce_shuffle</value>
       </property>
       <!-- 指定 YARN 的 ResourceManager 的地址 -->
       <property>
           <name>yarn.resourcemanager.hostname</name>
           <value>192-168-122-102</value>
       </property>
   
       <property>
           <name>yarn.nodemanager.env-whitelist</name>
           <value>JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PREPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_MAPRED_HOME</value>
       </property>
   </configuration>
   ```

4. MapReduce 配置文件

   配置 etc/hadoop/mapred-env.sh

   ```bash
   # export JAVA_HOME=/home/y/libexec/jdk1.6.0/
   export JAVA_HOME=/opt/module/jdk1.8.0_241
   ```

   配置 etc/hadoop/mapred-site.xml

   ```xml
   <configuration>
       <!-- 指定 MR 运行在 YARN 上 -->
       <property>
           <name>mapreduce.framework.name</name>
           <value>yarn</value>
       </property>
       <property>
           <name>mapreduce.application.classpath</name>
           <value>$HADOOP_MAPRED_HOME/share/hadoop/mapreduce/*:$HADOOP_MAPRED_HOME/share/hadoop/mapreduce/lib/*</value>
       </property>
   </configuration>
   ```

#### 在集群上分发配置好的 Hadoop 配置文件

```bash
$ xsync /opt/module/hadoop-2.7.7/
```

### 集群单点启动

关掉所有节点 `jps` 显示的进程，删除所有节点 data 和 logs 目录

初始化 101 上的 hdfs 文件系统
```bash
[hadooptest@192-168-122-101 hadoop-2.7.7]$ bin/hdfs namenode -format
```

启动 101 上的 NameNode 和 DataNode
```bash
[hadooptest@192-168-122-101 hadoop-2.7.7]$ sbin/hadoop-daemon.sh start namenode
[hadooptest@192-168-122-101 hadoop-2.7.7]$ sbin/hadoop-daemon.sh start datanode
[hadooptest@192-168-122-101 hadoop-2.7.7]$ jps
2474 Jps
2380 DataNode
2287 NameNode
```

启动 102 上的 DataNode
```bash
[hadooptest@192-168-122-102 hadoop-2.7.7]$ sbin/hadoop-daemon.sh start datanode
[hadooptest@192-168-122-103 hadoop-2.7.7]$ jps
1698 SecondaryNameNode
1739 Jps
1597 DataNode
```

启动 103 上的 DataNode
```bash
[hadooptest@192-168-122-103 hadoop-2.7.7]$ sbin/hadoop-daemon.sh start datanode
```

启动 103 上的 secondarynamenode
```bash
[hadooptest@192-168-122-103 hadoop-2.7.7]$ sbin/hadoop-daemon.sh start secondarynamenode
[hadooptest@192-168-122-103 hadoop-2.7.7]$ jps
1698 SecondaryNameNode
1739 Jps
1597 DataNode
```
查看 NameNode 访问接口
```bash
http://192.168.122.101:50070
```

**此处暂未使用单点启动 yarn，可使用后续配置群集启动 HDFS 和 YARN**


### SSH 无密登录配置

#### 配置 ssh

1. 基本语法

   ```bash
   ssh 另一台电脑的 IP 地址
   ```

2. ssh 连接时出现 Host key verification failed 的解决方法


3. 


#### 免密登录原理

1. 流程介绍

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142932.png)

- A 服务器生成公钥（A）和私钥（A）
- 将公钥（A）拷贝到服务器 B 中
- A 服务器通过 ssh 与 B 建立链接，向 B 发送使用私钥（A）进行加密后的数据
- 服务器 B 接收到数据后，使用公钥（A）进行解密
- 服务器 B 通过 ssh 向服务器 A 发送使用公钥（A）加密后的数据
- 服务器 A 使用私钥（A）对数据进行解密

2. 在 101 服务器（服务器 A）上生成密钥对

   ```bash
   [hadooptest@192-168-122-101 .ssh]$ cd ~/.ssh
   [hadooptest@192-168-122-101 .ssh]$ ssh-keygen -t rsa
   ```

   一路回车，生成如下两个文件

   - id_rsa：私钥

   - id_rsa.pub：公钥

3. 将 101 服务器（服务器 A）的公钥拷贝到 102 服务器（服务器 B）

   ```bash
   [hadooptest@192-168-122-101 .ssh]$ ssh-copy-id 192.168.122.102
   ```

   此时查看 102 服务器（服务器 B）的 .ssh 文件夹，已生成如下文件

   ```bash
   [hadooptest@192-168-122-102 .ssh]$ ls
   authorized_keys
   ```

4. 此时从 101 服务器（服务器 A）登录 102 服务器（服务器 B）不在需要输入密码

   ```bash
   [hadooptest@192-168-122-101 .ssh]$ ssh 192.168.122.102
   Last login: Thu Apr  9 12:02:31 2020 from gateway
   [hadooptest@192-168-122-102 ~]$ 
   ```

5. 依次将 101 服务器（服务器 A）的公钥拷贝到 103 和 101 上

   ```bash
   [hadooptest@192-168-122-101 .ssh]$ ssh-copy-id 192.168.122.103
   [hadooptest@192-168-122-101 .ssh]$ ssh-copy-id 192.168.122.101
   ```

6. 此时使用如下命令连接 101、102、103 不在需要输入密码

   ```bash
   [hadooptest@192-168-122-101 .ssh]$ ssh 192.168.122.10X
   ```

**注意事项说明及后续必须操作**

- 此处需要将 101 服务器的公钥拷贝到自己服务器上一份，是因为通过 `ssh 192.168.122.101` 连接本机的时候也需要输入密码。

- 为 101 设置免登录到 102、103 是因为 101 上的 NameNode 需要访问另外两个节点上的 DataNode

- 还需要使用相同方法，为 102 服务器生成密钥对，并将公钥拷贝到 101 和 103，因为 102 上的 ResourceManager 需要管理 101 和 103 上的 NodeManager，

  ```bash
  [hadooptest@192-168-122-102 .ssh]$ ssh-keygen -t rsa
  [hadooptest@192-168-122-102 .ssh]$ ssh-copy-id 192.168.122.101; ssh-copy-id 192.168.122.102; ssh-copy-id 192.168.122.103
  ```

- 还需在 101 上采用 root 帐号，配置以下无密登录到 101、102、103。

  ```bash
  [hadooptest@192-168-122-101 .ssh]$ su root
  [root@192-168-122-101 .ssh]# cd ~/.ssh
  [root@192-168-122-101 .ssh]# ssh-keygen -t rsa
  [root@192-168-122-101 .ssh]# ssh-copy-id 192.168.122.101; ssh-copy-id 192.168.122.102; ssh-copy-id 192.168.122.103;
  ```

#### .ssh 文件夹下（~/.ssh）的文件功能解释

文件名 | 作用
--- | ---
known_hosts | 记录 ssh 访问过计算机的公钥（public key）
id_rsa | 生成的私钥
id_rsa.pub | 生成的公钥
authorized_keys | 存放授权过得无密登录服务器公钥


### 群起集群

#### 配置 etc/hadoop/slaves

在文件中添加如下信息

```
192-168-122-101
192-168-122-102
192-168-122-103
```

此处存放的是所有 DataNode 节点

**注意：该文件中添加的内容结尾不允许有空格，文件中不允许有空行。**

同步所有节点配置文件

```bash
xsync etc/hadoop/slaves
```

#### 关闭之前启动的所有进程

- 101 服务器

  ```bash
  [hadooptest@192-168-122-101 hadoop-2.7.7]$ sbin/hadoop-daemon.sh stop datanode
  [hadooptest@192-168-122-101 hadoop-2.7.7]$ sbin/hadoop-daemon.sh stop namenode
  ```

- 102 服务器

  ```bash
  [hadooptest@192-168-122-102 hadoop-2.7.7]$ sbin/hadoop-daemon.sh stop datanode
  ```

- 103 服务器

  ```bash
  [hadooptest@192-168-122-103 hadoop-2.7.7]$ sbin/hadoop-daemon.sh stop datanode
  [hadooptest@192-168-122-103 hadoop-2.7.7]$ sbin/hadoop-daemon.sh stop secondarynamenode
  ```

#### 启动集群

在 101 上启动 dfs，因为 NameNode 在 101 上
```bash
[hadooptest@192-168-122-101 hadoop-2.7.7]$ sbin/start-dfs.sh
```

> dfs.sh 会启动集群上的所有 NameNode、DataNode、SecondaryNameNode


在 102 上启动 yarn，因为 ResourceManager 在 102 上

```bash
[hadooptest@192-168-122-102 hadoop-2.7.7]$ sbin/start-yarn.sh
```

**注意：NameNode 和 ResourceManager 如果不是同一台机器，不能在 NameNode 上启动 YARN，应该在 ResourceManger 所在的机器上启动 YARN。**

#### 集群基本测试

- 依次使用 `jps` 查看各节点上启动的进程，对比开始的架构设计表

- 查看 NameNode 的管理页面：http://192.168.122.101:50070/

- 查看 ResourceManager 管理界面：http://192.168.122.102:8088/

- 使用命令创建几个文件，并在 NameNode 管理界面查看是否创建成功

##### 上传文件到集群

上传小文件
```bash
[hadooptest@192-168-122-101 hadoop-2.7.7]$ hdfs dfs -mkdir -p /user/hadooptest/input
[hadooptest@192-168-122-101 hadoop-2.7.7]$ hdfs dfs -put ./README.txt /user/hadooptest/input/README.txt
```

上传大文件
```bash
[hadooptest@192-168-122-101 hadoop-2.7.7]$ hdfs dfs -put /opt/software/hadoop-2.7.7.tar.gz /user/hadooptest/input
```

- 由下图可见，已对文件生成了 3 个副本，同时块大小为 128M

    ![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142935.png)
- 由下图可见，文件大小小于 128M，只有 1 块
    ![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142938.png)
- 由下图可见，文件大小大于 128M，将文件分成了 2 (多）块，第 0 块大小为 128M
    ![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142940.png)


```bash
[hadooptest@192-168-122-101 hadoop-2.7.7]$ cd data/tmp/dfs/data/current/BP-1241632574-192.168.122.101-1586406239550/current/finalized/subdir0/subdir0/
```

##### 上传文件后查看文件存放在什么位置

1. 查看 HDFS 文件存储路径

   ```bash
   /opt/module/hadoop-2.7.7/data/tmp/dfs/data/current/BP-1241632574-192.168.122.101-1586406239550/current/finalized/subdir0/subdir0
   ```

2. 查看 HDFS 在磁盘存储文件内容

   ```bash
   [hadooptest@192-168-122-101 subdir0]$ cat blk_1073741825
   For the latest information about Hadoop, please visit our website at:
   ...此处省略若干行...
   ```

3. 拼接大文件

   ```bash
   [hadooptest@192-168-122-101 subdir0]$ cat blk_1073741826 >> temp.text
   [hadooptest@192-168-122-101 subdir0]$ cat blk_1073741827 >> temp.text 
   ```

4. 解压

   ```bash
   tar -zxvf temp.text
   ```

   > 会发现解压后的文件和上传的 tar.gz 解压后的文件完全一致

5. 下载

   ```bash
   [hadooptest@192-168-122-101 hadoop-2.7.7]$ hadoop fs -get /user/hadooptest/input/hadoop-2.7.7.tar.gz ./
   ```

### 集群启动停止方式总结

#### 各个服务组件逐一启动/停止

1. 分别启动/停止 HDFS 组件

   ```bash
   sbin/hadoop-daemon.sh start/stop namenode/datanode/secondarynamenode
   ```

2. 启动/停止 YARN

   ```bash
   sbin/yarn-daemon.sh start/stop resourcemanager/nodemanager
   ```

#### 各个模块分开启动/停止（配置 ssh 是前提）*常用*

1. 整体启动/停止 HDFS

   ```bash
   sbin/start-dfs.sh / sbin/stop-dfs.sh
   ```

2. 整体启动/停止 YARN

   ```bash
   sbin/start-yarn.sh / sbin/stop-yarn.sh
   ```

   **官网不建议使用 start-all.sh 和 stop-all.sh**

### 集群时间同步

#### crond 系统定时任务介绍

重新启动 crond 服务

```bash
systemctl restart crond
```

**crontab 定时任务设置**

1. 基本语法

   ```bash
   crontab [选项]
   ```

2. 选项说明

    选项 | 功能
    --- | ---
    -e | 编辑 crontab 定时任务 
    -l | 查询 crontab 任务 
    -r | 删除当前用户所有的 crontab 任务 

3. 参数说明

   ```bash
   crontab -e
   ```

   进入 crontab 编辑页面。会打开 vim 编辑你的工作。

   格式：`* * * * *` 执行的任务

项目 | 含义 | 范围
--- | --- | ---
第一个`*` | 一小时当中的第几分钟 | 0-59
第二个`*` | 一天中的第几小时 | 0-23
第三个`*` | 一个月当中的第几天 | 1-31
第四个`*` | 一年中的第几个月 | 1-12
第五个`*` | 一周中的星期几 | 0-7（0 和 7 都代表星期日）

特殊符号

特殊符号 | 含义
--- | ---
`*` | 代表任何时间。比如第一个 `*` 就代表一小时中每分钟都执行依次的意思 
`,` | 代表不连续的时间。比如 `0 8,12,16 * * * 命令`，就代表在每天的 8 点、12 点、16 点都执行一次命令。
`-` | 代表连续的时间。比如 `0 5 * * 1-6 命令`，代表在周一到周六的凌晨 5 点执行命令 
`*/n` | 代表每隔多久执行一次。比如 `*/10 * * * * 命令`，代表每隔 10 分钟执行依次 

特定时间执行命令

时间 | 含义
--- | ---
`45 22 * * * 命令` | 在 22 点 45 分执行命令 
`0 17 * * 1 命令` | 在每周 1 的 17 点执行命令 
`0 5 1,15 * * 命令` | 每月 1 号和 15 号的凌晨 5 点执行命令 
`40 4 * * 1-5 命令` | 每周一到周五的凌晨 4 点 40 分执行一次命令 
`*/10 4 * * * 命令` | 每天的凌晨 4 点开始，每隔 10 分钟执行一次命令 
`0 0 1,15 * 1 命令` | 每月 1 号和 15 号，每周 1 的 0 点 0 分都会执行命令。注意：星期几和几号最好不要同时出现，因为他们定义的都是天，非常容易让管理员混乱。

4. 案例实操

   每隔 1 分钟，向 /root/bailongma.txt 文件中添加一个 11 的数字

   ```bash
   */1 * * * * /bin/echo "11" >> /root/bailongma.txt
   ```

#### 集群时间同步

时间同步的方式：找一台机器，作为时间服务器，所有的机器与这台集群时间进行定时的同步。比如，每隔 10 分钟同步一次时间。


```mermaid
graph LR
时间服务器 101-- 102 定时去获取 101 时间服务器主机的时间-->其他机器 102
```

**对时间服务器 101 的操作**

1. 检查 ntp 是否安装
2. 修改 ntp 配置文件
    - 修改 1：授权 192.168.122.0-192.168.122.255 网段上的所有机器可以从这台机器上查询和同步时间
    - 修改 2：集群在局域网中，不使用其他互联网上的时间
    - 添加 3：当该节点丢失网络连接，依然可以采用本地时间作为时间服务器为集群中的其他节点提供时间同步
3. 修改 /etc/sysconfig/ntpd 文件，让硬件时间与系统时间一起同步
4. 重新启动 ntpd 服务
5. 设置 ntpd 服务开机启动

**对其他机器 102 的操作**

1. 在其他机器配置 10 分钟与时间服务器同步一次
    ```bash
    # crontab -e
    ```
    编写内容如下
    ```bash
    */10 * * * * /user/sbin/ntpdate 192.168.122.101
    ```
2. 修改任意机器时间
3. 十分钟后查看机器是否与时间服务器同步


#### 实际操作步骤

1. 时间服务器配置（必须 root 用户）

   检查 ntp 是否安装

   ```bash
   [root@192-168-122-101 ~]# rpm -qa | grep ntp
   fontpackages-filesystem-1.44-8.el7.noarch
   ntp-4.2.6p5-29.el7.centos.x86_64
   ntpdate-4.2.6p5-29.el7.centos.x86_64
   ```

   修改 ntp 配置文件

   ```bash
   [root@192-168-122-101 ~]# vim /etc/ntp.conf
   ```

   - 修改 1：授权 192.168.122.0-192.168.122.255 网段上的所有机器可以从这台机器上查询和同步时间

     ```bash
     # Hosts on local network are less restricted.
     # restrict 192.168.1.0 mask 255.255.255.0 nomodify notrap
     restrict 192.168.122.0 mask 255.255.255.0 nomodify notrap
     ```

   - 修改 2：集群在局域网中，不使用其他互联网上的时间

     ```bash
     # Use public servers from the pool.ntp.org project.
     # Please consider joining the pool (http://www.pool.ntp.org/join.html).
     # 注释掉所有
     # server 0.centos.pool.ntp.org iburst
     # server 1.centos.pool.ntp.org iburst
     # server 2.centos.pool.ntp.org iburst
     # server 3.centos.pool.ntp.org iburst
     ```

   - 添加 3：当该节点丢失网络连接，依然可以采用本地时间作为时间服务器为集群中的其他节点提供时间同步

     ```bash
     # Enable writing of statistics records.
     #statistics clockstats cryptostats loopstats peerstats
     # 如果没有网络使用本地时间
     server 127.127.1.0
     # 配置时间的准确度等级
     fudge 127.127.1.0 stratum 10
     ```

修改 /etc/sysconfig/ntpd 文件
```bash
[root@192-168-122-101 ~]# vim /etc/sysconfig/ntpd
# 增加如下内容（让硬件时间与系统时间一起同步）
SYNC_HWCLOCK=yes
```
重新启动 ntpd 服务
```bash
[root@192-168-122-101 ~]# systemctl restart ntpd
```

设置 ntpd 服务开机自启
```bash
[root@192-168-122-101 ~]# systemctl enable ntpd
```

2. 其他机器配置（必须 root 用户）

   - 在其他机器配置 10 分钟与时间服务器同步一次

     ```bash
     [root@192-168-122-102 hadooptest]# crontab -e
     ```

     添加如下内容

     ```bash
     */10 * * * * /usr/sbin/ntpdate 192.168.122.101
     ```

   - 修改其他机器时间，过 10 分钟再次查看是否自动同步

     ```bash
     [root@192-168-122-102 hadooptest]# date -s "2018-11-11 11:11:11"
     
     [root@192-168-122-102 hadooptest]# date
     ```

https://edu.aliyun.com/lesson_1800_15237#_15237

# 常见错误及解决方案

## a

## b

## c

## d

## e

## f

## g

## h

## DataNode 和 NameNode 进程同时只能有一个工作问题分析

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142945.png)

```bash
# 查看 namenode 版本信息
$ cat data/tmp/dfs/name/current/VERSION
#Wed Apr 08 15:06:15 CST 2020
namespaceID=2123298218
clusterID=CID-72ce9cc8-d69a-46eb-99bb-35f61fa021b2
cTime=0
storageType=NAME_NODE
blockpoolID=BP-532632266-192.168.122.101-1586329575011
layoutVersion=-63
# 查看 datanode 版本信息
$ cat data/tmp/dfs/data/current/VERSION
#Wed Apr 08 15:10:36 CST 2020
storageID=DS-7b7060fc-7b94-44e3-bd96-99a0328234e4
clusterID=CID-72ce9cc8-d69a-46eb-99bb-35f61fa021b2
cTime=0
datanodeUuid=8ffe08fd-6105-4154-8c86-7a6b29361d42
storageType=DATA_NODE
layoutVersion=-56
```
