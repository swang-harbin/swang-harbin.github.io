---
title: Kafka 安装
date: '2020-07-18 00:00:00'
tags:
- MSB
- Kafka
- Java
---

# Kafka 安装

安装 jdk 并配置环变量 修改 `/etc/hostname` 修改 `/etc/hosts`

## 单机安装

1. 应用下载

   [zookeeper 下载](https://zookeeper.apache.org/releases.html)

   [kafka 下载](http://kafka.apache.org/downloads)

2. 安装 zk

   ```bash
   $ tar -zxvf apache-zookeeper-3.6.1-bin.tar.gz
   $ cd apache-zookeeper-3.6.1-bin/
   $ cp conf/zoo_sample.cfg conf/zoo.cfg
   $ mkdir data
   $ vi conf/zoo.cfg
   dataDir=/home/normal/software/apache-zookeeper-3.6.1-bin/data
   $ ./bin/zkServer.sh start conf/zoo.cfg 
   
   $ ./bin/zkServer.sh status conf/zoo.cfg
   ZooKeeper JMX enabled by default
   Using config: conf/zoo.cfg
   Client port found: 2181. Client address: localhost.
   Mode: standalone
   $ jps
   879 QuorumPeerMain
   $ ./bin/zkServer.sh stop conf/zoo.cfg 
   ```

3. 安装 kafka

   ```bash
   $ tar -zxvf ../mnt/kafka_2.12-2.5.0.tgz
   $ cd kafka_2.12-2.5.0/
   $ vi config/server.properties
   listeners=PLAINTEXT://k8s-master:9092
   log.dirs=/home/normal/software/kafka_2.12-2.5.0/kafka-logs
   zookeeper.connect=k8s-master:2181
   $ ./bin/kafka-server-start.sh -daemon config/server.properties
   $ jps
   13548 Kafka
   $ ./bin/kafka-server-stop.sh config/server.properties
   ```

4. 创建 topic，因为是单机模式，所以 1 个 topic 可以创建多个 partitions，但是 replication-factor（副本数）只能有 1 个

   ```bash
   $ ./bin/kafka-topics.sh --create --bootstrap-server=k8s-master:9092 --topic topic01 --partitions 3  --replication-factor 1
   ```

5. 启动一个 consumer，订阅 topic01，并且属于 group01，如果不指定组，系统会随机给指定一个组

   ```bash
   $ ./bin/kafka-console-consumer.sh --bootstrap-server=k8s-master:9092 --topic topic01 --group group01
   ```

6. 启动一个 producer，向 topic02 中发送消息

   ```bash
   $ ./bin/kafka-console-producer.sh --broker-list k8s-master:9092 --topic topic01
   ```

7. 此时 topic01 中有 3 个 partitions，而 group01 组中只有一个 consumer，所以该 consumer 可以接收到所有 partitions 中的消息。

   再次启动两个 consumer，订阅 topic01，并且属于 group01

   ```bash
   $ ./bin/kafka-console-consumer.sh --bootstrap-server=k8s-master:9092 --topic topic01 --group group01
   ```

8. 此时再次发送消息，可见同一个消息只会被同一组中的一个 consume 消费，证明了消息的组内均分，且是按照轮询机制来消费的（partitions 与 consumer 数量相同均为 3）。

   关闭一个 consume，再次发送消息，发现消息被负载均衡的消费掉（partitions 数 \> consume 数）

   启动一个 consumer，订阅 topic01，并且属于 group02 组

   ```bash
   $ ./bin/kafka-console-consumer.sh --bootstrap-server=k8s-master:9092 --topic topic01 --group group02
   ```

9. 此时再次发送消息，可见同一消息会被不同组的两个 consumer 同时消费，证明了消息是组间广播的

## 集群安装

1. 时钟同步

2. zk 集群安装

   ```bash
   $ tar -zxvf apache-zookeeper-3.6.1-bin.tar.gz
   $ cd apache-zookeeper-3.6.1-bin/
   $ cp conf/zoo_sample.cfg conf/zoo.cfg
   $ mkdir data
   $ vi conf/zoo.cfg
   dataDir=/home/normal/software/apache-zookeeper-3.6.1-bin/data
   
   server.1=k8s-master:2888:3888
   server.2=k8s-node1:2888:3888
   server.3=k8s-node2:2888:3888
   ```

   在每台机器的 data 目录创建一个名称为 myid 的文件，内容与上方配置的 server.后面的数字对应，比如在 k8s-master 中，使用如下命令创建内容为 1 的 myid 文件

   ```bash
   $ echo 1 > data/myid
   $ ./bin/zkServer.sh start conf/zoo.cfg
   $ ./bin/zkServer.sh status conf/zoo.cfg
   ```

   将所有 zk 均启动后查看状态，可见 1leader，多 follower 的现象

   ```bash
   ZooKeeper JMX enabled by default
   Using config: conf/zoo.cfg
   Client port found: 2181. Client address: localhost.
   Mode: leader
   
   ZooKeeper JMX enabled by default
   Using config: conf/zoo.cfg
   Client port found: 2181. Client address: localhost.
   Mode: follower
   $ ./bin/zkServer.sh stop conf/zoo.cfg 
   ```

3. kafka 集群安装

   ```bash
   $ tar -zxvf ../mnt/kafka_2.12-2.5.0.tgz
   $ cd kafka_2.12-2.5.0/
   $　vi config/server.properties
   ```

   多台机器的 broker.id 的值不能相同

   ```bash
   broker.id=0
   listeners=PLAINTEXT://k8s-master:9092
   log.dirs=/home/normal/software/kafka_2.12-2.5.0/kafka-logs
   zookeeper.connect=k8s-master:2181,k8s-node1:2181,k8s-node2:2181
   $ bin/kafka-server-start.sh -daemon config/server.properties
   ```

## topic

1. 创建 topic

   ```bash
   $ ./bin/kafka-topics.sh --bootstrap-server k8s-master:9092,k8s-node1:9092,k8s-node2:9092 --create --topic topic01 --partitions 3 --replication-factor 2
   ```

   查看每个 kafka 节点的 kafka-logs 目录，可见 topic0 共包含 3 个分区，且每个分区有有两台备份

2. 查看所有 topic

   ```bash
   $ ./bin/kafka-topics.sh --bootstrap-server k8s-master:9092,k8s-node1:9092,k8s-node2:9092 --list
   ```

3. 查看 topic 详细信息

   ```bash
   $ ./bin/kafka-topics.sh --bootstrap-server k8s-master:9092,k8s-node1:9092,k8s-node2:9092 --describe --topic topic01
   Topic: topic01	PartitionCount: 3	ReplicationFactor: 2	Configs: segment.bytes=1073741824
   	Topic: topic01	Partition: 0	Leader: 0	Replicas: 0,3	Isr: 0,3
   	Topic: topic01	Partition: 1	Leader: 3	Replicas: 3,1	Isr: 3,1
   	Topic: topic01	Partition: 2	Leader: 1	Replicas: 1,0	Isr: 1,0
   ```

3. 修改 topic

   partitions 数量只能增加，不能减少。

   ```bash
   $ ./bin/kafka-topics.sh --bootstrap-server k8s-master:9092,k8s-node1:9092,k8s-node2:9092 --alter --topic topic02 --partitions 2
   ```

4. 删除 topic

   ```bash
   $ ./bin/kafka-topics.sh --bootstrap-server k8s-master:9092,k8s-node1:9092,k8s-node2:9092 --delete --topic topic02
   $ ./bin/kafka-server-stop.sh config/server.properties
   ```
