---
title: Hadoop介绍
date: '2020-04-08 00:00:00'
tags:
- Hadoop
---
# Hadoop介绍

## Hadoop是什么

1. Hadoop是一个由Apache基金会所开发的**分布式**系统**基础架构**.
2. 主要解决, 海量数据的**存储**和海量数据的**分析计算**问题.
3. 广义上来说, Hadoop通常是指一个更广泛的概念--Hadoop生态圈.

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142848.png)

## Hadoop发展史

1. Lucene框架是DOug Cutting开创的开源软件, 用Java书写代码, 实现了与Google类似的全文搜索功能, 它提供了全文检索引擎的架构, 包括完整的查询引擎和索引引擎.
2. 2001年年底, Lucene称为Apacha基金会的一个子项目.
3. 对于海量数据的场景, Lucene面对与Google同样的困难, **存储数据困难, 检索速度慢**.
4. 学习和模仿Google解决这些问题的方法: 微型版Nutch.
5. 可以说Google是Hadoop的思想之源(Google在大数据方面的三篇论文)
   
    ```
    GFS --> HDFS
    Map-Resuce --> MR
    BigTable --> HBase
    ```
6. 2003-2004年, Google公开了部分GFS和MapReduce思想的细节, 以此为基础Doug Cutting等人用了**2年业余时间**实现了DFS和MapReduce机制, 使Nutch性能飙升.
7. 2005年Hadoop作为Lucene的子项目Nutch的一部分正式引入Apache基金会.
8. 2006年2月份, Map-Reduce和Nutch Distributed File System(NDFS)分别被纳入称为Hadoop的项目中.
9. 名称来源于Doug Cutting儿子的玩具大象.
10. Hadoop就此诞生并迅速发展, 标志着大数据时代的来临.

## Hadoop三大发行版本

Hadoop三大发行版本: Apache, Cloudera, Hortonworks.

- Apache版本最原始(最基础)的版本, 对于入门学习最好.
- Cloudera在大型互联网企业中用的较多, 收费.
- Hortonworks文档较好.

### Apache Hadoop
- [官网地址](http://hadoop.apache.org/) 
- [下载地址](https://archive.apache.org/dist/hadoop/common/)

### Cloudera Hadoop

- [官网地址](https://www.cloudera.com/)
- [下载地址](http://archive-primary.cloudera.com/cdh5/cdh5/)

1. 2008年成立的Cloudera是最早将Hadoop商用的公司, 为合作伙伴提供Hadoop的商用解决方案, 主要是包括支持, 咨询服务, 培训.
2. 2009年Hadoop的创始人Doug Cutting也加盟Cloudera公司. Cloudera产品主要为CDH, Coudera Manager, Cloudera Support.
3. CDH是Cloudera的Hadoop发行版, 完全开源, 比Apache Hadoop在兼容性, 安全性, 稳定性上有所增强.
4. Cloudera Manager是集群的软件分发及管理监控平台, 可以在几小时内部署好一个Hadoop集群, 并对集群的节点及服务进行实时监控. Cloudera Suppert即是对Hadoop的技术支持.
5. Cloudera的标价为每年每个节点4000美元. Cloudera开发并贡献了可实时处理大数据的Impala项目.

### Hortonworks Hadoop

- [官网地址](https://hortonworks.com/)
- [下载地址](https://hortonworks.com/downloads/#data-platform)

1. 2011年成立的Hortonworks是雅虎与硅谷风投公司Benchmark Capital合资组建.
2. 公司成立之初就吸纳了大约25名至30名专门研究Hadoop的雅虎工程师. 上述工程师在2005年开始协助雅虎开发Hadoop, 贡献了Hadoop80%的代码.
3. 雅虎工程副总裁, 雅虎Hadoop开发团队负责人Eric Baldeschwieler出任Hortonworks的首席执行官.
4. Hortonworks的主打产品是Hortonworks Data Platform(HDP), 也同样是100%开源的产品, HDP除常见的项目外还包括了Ambari, 一款开源的安装和管理系统.
5. HCatalog, 一个元数据管理系统, HCatelog现已集成到Facebook开源的Hive中.

## Hadoop的优势(4高)

1. 高可靠性: Hadoop底层维护多个数据副本(至少3份), 所以即使Hadoop某个计算元素或存储出现故障, 也不会导致数据的丢失.
2. 高扩展性: 在集群分配任务数据, 可方便的扩展数以千计的节点.
3. 高效性: 在MapReduce的思想下, Hadoop是并行工作的, 以加快任务的处理速度.
4. 高容错性: 能够自动将失败的任务重新分配.

## Hadoop组成(面试重点)

### Hadoop1.x和Hadoop2.x区别

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142851.png)

在Hadoop1.x时代, Hadoop中的MapResuce同时处理业务逻辑运算和资源的调度, 耦合性较大, 在Hadoop2.x时代, 增加了Yarn. Yarn只负责资源的调度, MapResuce至负责运算.

### HDFS架构概述

HDFS: Hadoop Distributed File System, Hadoop分布式文件系统

1. NameNode(nn): 存储文件的元数据, 如文件名, 文件目录结构, 文件属性(生成时间, 副本数, 文件权限), 以及每个文件的块列表和块所在的DataNode等.

   > 相当于目录

2. DataNode(dn): 在本地文件系统存储文件块数据, 以及块数据的校验和.

   > 相当于目录指向的大量数据

3. Secondary NameNode(2nn): 用来监控HDFS状态的辅助后台程序, 每隔一段时间获取HDFS元数据的快照.

   > 辅助NameNode的

### YARN架构

YARN: Yet Another Resource Negotiator, 另一种资源协调者

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142854.png)

1. ResourceManager(RM)主要作用如下:
    - 处理客户端请求
    - 监控NodeManager
    - 启动或监控ApplicationMaster
    - 资源的分配与调度

2. NodeManager(NM)主要作用如下
    - 管理单个节点上的资源
    - 处理来自ResourceManager的命令
    - 处理来自ApplicationManager的命令

3. ApplicationMaster(AM)作用如下
    - 负责数据的切分
    - 为应用程序申请资源并分配给内部的任务
    - 任务的监控与容错

4. Container
    Container是YARN中的资源抽象, 它封装了某个节点上的多维度资源, 如内存, CPU, 磁盘, 网络等.

### MapReduce架构概述

MapReduce将计算过程分为两个阶段: Map和Reduce

1. Map阶段并行处理输入数据
2. Reduce阶段对Map结果进行汇总

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142856.png)

## 大数据技术生态体系

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142900.png)


## Hadoop推荐系统框架图

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142908.png)

# Hadoop运行环境搭建

## 虚拟机环境准备

1. 克隆虚拟机

2. 修改克隆虚拟机的静态IP

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

   在/etc/hosts文件中添加

   ```properties
   192.168.122.101 192-168-122-101
   192.168.122.102 192-168-122-102
   ```

4. 关闭防火墙

   ```bash
   systemctl stop firewalld
   ```

5. 创建hadooptest用户

   ```bash
   useradd hadooptest
   ```

6. 配置hadooptest用户具有root权限

   /etc/sudoers, 在如下部分添加hadooptest用户

   ```bash
   ## Allow root to run any commands anywhere 
   root    ALL=(ALL)       ALL
   hadooptest    ALL=(ALL)    ALL
   ```

7. 在/opt目录下创建文件夹

   1. 创建module和software文件夹

   2. 将这两个文件夹所有者和所属组给hadooptest用户和hadooptest组

## 安装JDK, 并设置环境变量

解压software文件夹中的jdk-8u241-linux-x64.tar.gz到module目录

```bash
tar -zxvf /opt/software/jdk-8u241-linux-x64.tar.gz -C /opt/module
```

配置环境~/.bash_profile
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

## 安装Hadoop

解压software文件夹中的hadoop-2.7.7.tar.gz到module目录

```bash
tar -zxvf /opt/software/hadoop-2.7.7.tar.gz -C /opt/module
```

配置环境~/.bash_profile
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

## Hadoop目录结构

- bin:
    - hadoop: 管理hadoop集群
    - hdfs: 管理hdfs
    - yarn: 管理资源调度
- etc: 配置文件
- include: 其他代码的源文件
- lib: 本地库
- sbin: hadoop及集群的启动和停止
    - hadoop-daemon.sh: 
    - slaves.sh: 启动集群时使用
    - start-all.sh: 启动整个集群
    - start-dfs.sh: 启动文件系统
    - start-yarn.sh: 启动yarn
    - yarn-daemon.sh: 
    - stop-xxx.sh:停止
- share: 
    - doc: 说明文档
    - hadoop: 官方提供的案例

# Hadoop运行模式

Hadoop运行模式包括: 本地模式, 伪分布式模式以及完全分布式模式.

Hadoop官方网站: http://hadoop.apache.org/

## 本地运行模式

## 官方Grep案例

查找符合'dfs[a-z.]+'正则表达式的字段

```bash
$ mkdir input
$ cp etc/hadoop/*.xml input
$ bin/hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.7.jar grep input output 'dfs[a-z.]+'
$ cat output/*
```
注: output文件夹一定不能存在

```bash
1	dfsadmin
```

## 官方WordCount案例

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

1. etc/hadoop/hadoop-env.sh, 修改JAVA_HOME位置

   ```bash
   # Set Hadoop-specific environment variables here.
   
   # The only required environment variable is JAVA_HOME.  All others are
   # optional.  When running a distributed configuration it is best to
   # set JAVA_HOME in this file, so that it is correctly defined on
   # remote nodes.
   
   # The java implementation to use.
   export JAVA_HOME=/opt/module/jdk1.8.0_241
   ```

2. [etc/hadoop/core-site.xml](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/core-default.xml):

   ```xml
   <configuration>
       <!-- 指定HDFS中NameNode的地址 -->
       <property>
           <name>fs.defaultFS</name>
           <value>hdfs://localhost:9000</value>
       </property>
   
       <!-- 指定Hadoop运行时产生文件的存储目录-->
       <property>
           <name>hadoop.tmp.dir</name>
           <!-- 默认: /tmp/hadoop-${user.name} -->
           <value>/opt/module/hadoop-2.7.7/data/tmp</value>
       </property>
   </configuration>
   ```

3. [etc/hadoop/hdfs-site.xml](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-hdfs/hdfs-default.xml):

   ```xml
   <configuration>
       <!-- 指定HDFS副本的数量 -->
       <property>
           <name>dfs.replication</name>
           <value>1</value>
       </property>
   </configuration>
   ```

如果只有1台服务器, value设置为>1的值, 也只有1份备份. 在添加足够节点后, 会自动将指定数量的数据备份到其他节点


### 启动集群

1. 格式化NameNode(第一次启动时格式化, 以后就不要总格式化)

   ```bash
   $ bin/hdfs namenode -format
   ```

   在格式化之前要关闭NameNode和DataNode进程, 删除data和logs目录.

   执行结束后会创建hadoop.tmp.dir指定的文件夹, 并在该目录下生成相应数据.

2. 启动NameNode daemon和DataNode daemon:

   ```bash
   $ sbin/hadoop-daemon.sh start namenode
   $ sbin/hadoop-daemon.sh start datanode
   ```

   或

   ```bash
   $ sbin/start-dfs.sh
   ```

   hadoop daemon的日志默认输出在$HADOOP_LOG_DIR目录(默认值为$HADOOP_HOME/logs).

   使用`jps`命令可以查看是否启动成功

   ```bash
   $ jps
   3027 NameNode
   3125 DataNode
   3197 Jps
   ```

3. NameNode信息的浏览器访问接口, 默认是

   NameNode - `http://localhost:9870/`或`http://localhost:50070/`

4. 设置执行MapReduce作业所需的HDFS目录(集群使用的目录)

   ```bash
   $ bin/hdfs dfs -mkdir /user
   $ bin/hdfs dfs -mkdir -p /user/<username>
   
   示例:
   $ bin/hdfs dfs -mkdir -p /user/hadooptest/input
   ```

   此时, 可在通过访问NameNode信息的浏览器访问接口 Utilities -> Browse the file system查看创建的文件信息

   ![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142913.png)

5. 输入文件复制到分布式文件系统中：

   ```bash
   $ bin/hdfs dfs -mkdir input
   $ bin/hdfs dfs -put etc/hadoop/*.xml input
   
   示例:
   $ bin/hdfs dfs -put etc/hadoop/*.xml /user/hadooptest/input
   ```

6. 运行hadoop官方提供的grep示例

   ```bash
   $ bin/hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-3.2.1.jar grep input output 'dfs[a-z.]+'
   
   示例:
   $ bin/hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.7.jar grep /user/hadooptest/input /user/hadooptest/output 'dfs[a-z.]+'
   ```

7. 检查输出文件: 将输出文件从分布式文件系统复制到本地文件系统并检查它们：

   ```bash
   $ bin/hdfs dfs -get output output
   $ cat output/*
   
   示例
   $ mkdir ./output
   $ bin/hdfs dfs -get /user/hadooptest/output/* ./output
   $ cat output/*
   ```

   或, 查看分布式文件系统上的输出文件:

   ```bash
   $ bin/hdfs dfs -cat output/*
   
   示例
   $ bin/hdfs dfs -cat /user/hadooptest/output/*
   ```

8. 停止hadoop daemon

   ```bash
   $ sbin/stop-dfs.sh
   ```


## 查看日志文件

hadoop daemon的日志默认输出在$HADOOP_LOG_DIR目录(默认值为$HADOOP_HOME/logs).

```
hadoop-hadooptest-namenode-192-168-122-101.log
hadoop-hadooptest-datanode-192-168-122-101.log
```

### 单节点启动YARN并运行MapReduce程序

您可以通过设置一些参数并另外运行ResourceManager守护程序和NodeManager守护程序，以伪分布式模式在YARN上运行MapReduce作业。

#### 分析

 - 配置集群在YARN上运行MR
 - 启动, 测试集群增, 删, 查
 - 在YARN上执行WordCount案例

#### 执行步骤

1. 配置etc/hadoop/yarn-env.sh

   ```bash
   # some Java parameters
   export JAVA_HOME=/opt/module/jdk1.8.0_241
   ```

2. [etc/hadoop/yarn-site.xml](https://hadoop.apache.org/docs/stable/hadoop-yarn/hadoop-yarn-common/yarn-default.xml):

   ```xml
   <configuration>
       <!-- Reducer获取数据的方式 -->
       <property>
           <name>yarn.nodemanager.aux-services</name>
           <value>mapreduce_shuffle</value>
       </property>
       <!-- 指定YARN的ResourceManager的地址 -->
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
       <!-- 指定MR运行在YARN上 -->
       <property>
           <name>mapreduce.framework.name</name>
           <!-- 默认是local,  可以的值local, classic或yarn -->
           <value>yarn</value>
       </property>
       <property>
           <name>mapreduce.application.classpath</name>
           <value>$HADOOP_MAPRED_HOME/share/hadoop/mapreduce/*:$HADOOP_MAPRED_HOME/share/hadoop/mapreduce/lib/*</value>
       </property>
   </configuration>
   ```

5. 启动ResourceManager daemon 和 NodeManager daemon:

   ```bash
   $ sbin/yarn-daemon.sh start resourcemanager
   $ sbin/yarn-daemon.sh start nodemanager
   ```

   或

   ```bash
   $ sbin/start-yarn.sh
   ```

   使用`jps`查看启动状态

   ```bash
   $ jps
   3027 NameNode
   5267 NodeManager
   5299 Jps
   5012 ResourceManager
   3125 DataNode
   ```

6. ResourceManager的浏览器访问接口, 默认为:

   ResourceManager - http://localhost:8088/

7. 运行一个MapReduce任务

   ```bash
   # 删除之前在hdfs中生成的output文件夹
   $ hdfs dfs -rm -r /user/hadooptest/output
   # 运行官方示例grep
   $ hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.7.jar  grep /user/hadooptest/input/*.xml /user/hadooptest/output 'dfs[a-z.]+'
   ```

   可在http://localhost:8088/接口查看执行信息

   ![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142916.png)

8. 停止 daemons

   ```bash
   $ sbin/stop-yarn.sh
   ```

### 配置历史服务器

MapReduce任务执行结束后, 可以看到如下图的`HISTORY`

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142917.png)

如需查看历史信息, 需要配置历史服务器

#### 配置etc/hadoop/mapred-site.xml

```xml
<configuration>
    <!-- 历史服务器端地址 -->
    <property>
        <name>mapreduce.jobhistory.address</name>
        <value>192-168-122-101:10020</value>
    </property>
    <!-- 历史服务器web端地址 -->
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

#### 查看HISTORY历史信息

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142919.png)

> 此处可能需要在客户机的/etc/hosts文件中添加域名和IP的映射关系, 例如:

    ```
    192.168.122.101 192-168-122-101
    ```

### 配置日志的聚集

- 日志聚集概念: 应用运行完成以后, 将程序运行日志信息上传到HDFS系统上

- 日志聚集功能好处: 可以方便的查看到程序运行详情, 方便开发测试

**注意: 开启日志聚集功能, 需要重新启动NodeManager, ResourceManager和HistoryManager.**

#### 配置etc/hadoop/yarn-site.xml

```xml
<configuration>
    <!-- 开启日志聚集功能 -->
    <property>
        <name>yarn.log-aggregation-enable</name>
        <value>true</value>
    </property>
    <!-- 日志保留时间设置7天 -->
    <property>
        <name>yarn.log-aggregation.retain-seconds</name>
        <value>604800</value>
    </property>
</configuration>
```

#### 关闭HistoryManager, ResourceManager和NodeManager

```bash
$ sbin/mr-jobhistory-daemon.sh stop historyserver
$ sbin/yarn-daemon.sh stop resourcemanager
$ sbin/yarn-daemon.sh stop nodemanager
```

#### 启动NodeManager, ResourceManager和HistoryManager
```bash
$ sbin/yarn-daemon.sh start nodemanager
$ sbin/yarn-daemon.sh start resourcemanager
$ sbin/mr-jobhistory-daemon.sh start historyserver
```

#### 删除HDFS上已经存在的输出文件

```bash
bin/hdfs dfs -rm -r /user/hadooptest/output
```

#### 执行Grep程序
```bash
$ bin/hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.7.jar grep /user/hadooptest/input /user/hadooptest/output 'dfs[a-z.]+'
```

#### 查看日志

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142920.png)


![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142924.png)


### 配置文件说明

Hadoop配置文件分为两类: 默认配置文件和自定义配置文件, 只有用户想修改某一默认配置值时, 才需要修改自定义配置文件, 更改相应属性值.

1. 默认配置文件

要获取的默认文件 | 文件存放在Hadoop的jar包中的位置
--- | ---
