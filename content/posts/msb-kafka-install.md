---
title: Kafka安装
date: '2020-07-18 00:00:00'
tags:
- MSB
- Kafka
- Java
categories:
- Java
---

# Kafka安装

安装jdk并配置环变量 修改`/etc/hostname` 修改`/etc/hosts`

## 单机安装

[zookeeper下载](https://zookeeper.apache.org/releases.html)

[kafka下载](http://kafka.apache.org/downloads)

安装zk

```shell
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

安装kafka

```shell
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

创建topic, 因为是单机模式, 所以1个topic可以创建多个partitions, 但是replication-factor(副本数)只能有1个

```shell
$ ./bin/kafka-topics.sh --create --bootstrap-server=k8s-master:9092 --topic topic01 --partitions 3  --replication-factor 1
```

启动一个consumer, 订阅topic01, 并且属于group01, 如果不指定组, 系统会随机给指定一个组

```shell
$ ./bin/kafka-console-consumer.sh --bootstrap-server=k8s-master:9092 --topic topic01 --group group01
```

启动一个producer, 向topic02中发送消息

```shell
$ ./bin/kafka-console-producer.sh --broker-list k8s-master:9092 --topic topic01
```

此时topic01中有3个partitions, 而group01组中只有一个consumer, 所以该consumer可以接收到所有partitions中的消息.

再次启动两个consumer, 订阅topic01, 并且属于group01

```shell
$ ./bin/kafka-console-consumer.sh --bootstrap-server=k8s-master:9092 --topic topic01 --group group01
```

此时再次发送消息, 可见同一个消息只会被同一组中的一个consume消费, 证明了消息的组内均分, 且是按照轮询机制来消费的(partitions与consumer数量相同均为3).

关闭一个consume, 再次发送消息, 发现消息被负载均衡的消费掉(partitions数>consume数)

启动一个consumer, 订阅topic01, 并且属于group02组

```shell
$ ./bin/kafka-console-consumer.sh --bootstrap-server=k8s-master:9092 --topic topic01 --group group02
```

此时再次发送消息, 可见同一消息会被不同组的两个consumer同时消费, 证明了消息是组间广播的

## 集群安装

时钟同步

zk集群安装

```shell
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

在每台机器的data目录创建一个名称为myid的文件, 内容与上方配置的server.后面的数字对应, 比如在k8s-master中, 使用如下命令创建内容为1的myid文件

```shell
$ echo 1 > data/myid
$ ./bin/zkServer.sh start conf/zoo.cfg
$ ./bin/zkServer.sh status conf/zoo.cfg
```

将所有zk均启动后查看状态, 可见1leader, 多follower的现象

```shell
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

kafka集群安装

```shell
$ tar -zxvf ../mnt/kafka_2.12-2.5.0.tgz
$ cd kafka_2.12-2.5.0/
$　vi config/server.properties
```

多台机器的broker.id的值不能相同

```shell
broker.id=0
listeners=PLAINTEXT://k8s-master:9092
log.dirs=/home/normal/software/kafka_2.12-2.5.0/kafka-logs
zookeeper.connect=k8s-master:2181,k8s-node1:2181,k8s-node2:2181
$ bin/kafka-server-start.sh -daemon config/server.properties
```

## topic

创建topic

```shell
$ ./bin/kafka-topics.sh --bootstrap-server k8s-master:9092,k8s-node1:9092,k8s-node2:9092 --create --topic topic01 --partitions 3 --replication-factor 2
```

查看每个kafka节点的kafka-logs目录, 可见topic0共包含3个分区, 且每个分区有有两台备份

查看所有topic

```shell
$ ./bin/kafka-topics.sh --bootstrap-server k8s-master:9092,k8s-node1:9092,k8s-node2:9092 --list
```

查看topic详细信息

```shell
$ ./bin/kafka-topics.sh --bootstrap-server k8s-master:9092,k8s-node1:9092,k8s-node2:9092 --describe --topic topic01
Topic: topic01	PartitionCount: 3	ReplicationFactor: 2	Configs: segment.bytes=1073741824
	Topic: topic01	Partition: 0	Leader: 0	Replicas: 0,3	Isr: 0,3
	Topic: topic01	Partition: 1	Leader: 3	Replicas: 3,1	Isr: 3,1
	Topic: topic01	Partition: 2	Leader: 1	Replicas: 1,0	Isr: 1,0
```

修改topic

partitions数量只能增加, 不能减少.

```shell
$ ./bin/kafka-topics.sh --bootstrap-server k8s-master:9092,k8s-node1:9092,k8s-node2:9092 --alter --topic topic02 --partitions 2
```

删除topic

```shell
$ ./bin/kafka-topics.sh --bootstrap-server k8s-master:9092,k8s-node1:9092,k8s-node2:9092 --delete --topic topic02
$ ./bin/kafka-server-stop.sh config/server.properties
```
