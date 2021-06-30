---
title: 系统 I/O
date: '2021-02-23 20:54:00'
tags:
- MSB
- I/O
- Java
---
# 系统 I/O

## 常用工具安装

```bash
yum install -y strace lsof pmap tcpdump 
```

`pcstat` 安装

1. 下载 golang：https://studygolang.com/dl
2. 设置 GO 环境变量和代理
    ```bash
    GOROOT=/home/normal/software/go
    GOPATH=$GOROOT/gopath
    GO111MODULE=on
    GOPROXY=https://goproxy.io,direct
    PATH=$GOROOT/bin:$PATH
    export GOROOT GOPATH GO111MODULE GOPROXY PATH
    ```
3. 编译 `pcstat`，并将其移动到 */usr/local/bin* 目录
    ```bash
    go get golang.org/x/sys/unix
    go get github.com/tobert/pcstat/pcstat
    sudo cp -a $GOPATH/bin/pcstat /usr/local/bin
    ```

## 对文件描述符的理解

- 0：std_in，标准输入
- 1：std_out，标准输出
- 2：err_out，错误输出

```bash
# 创建一个文件描述符（fd, file descriptor），用于读取 xxoo.txt 中的内容
$ exec 8< xxoo.txt
# 查看当前 bash 下的 fd，可以看到包含上一步中创建的 fd，$$ 代表当前 bash 的进程号
$ ll /etc/$$/fd
lr-x------. 1 wangshuo wangshuo 64 Jul 14 01:18 8 -> /home/wangshuo/Public/xxoo.txt
# 使用 lsof 命令进行查看，可见 8 号 fd 是可读的（r 读，w 写，u 读写），类型为普通文件（REG，regular），偏移量（OFFSET）为 0
$ lsof -op $$
COMMAND PID   USER        FD    TYPE       DEVICE   OFFSET    NODE        NAME
bash    13229 wangshuo    8r    REG        253,3    0t0       3162420     /home/wangshuo/Public/xxoo.txt
# 读取 fd 为 8 的文件，将其内容赋值给变量（此处的 read 方法读到换行符\n 后，就不会继续向后读取了）
$ read a 0<& 8
# 打印变量 a，此时 a 的值为 xxoo.txt 的第一行的值
$ echo $a
abc
# 可以看到 OFFSET 变为了 4，表示文件被读了 4 个字节（abc\n）
$ lsof -op $$
COMMAND   PID     USER   FD   TYPE DEVICE OFFSET    NODE NAME
bash    13925 wangshuo    8r   REG  253,3    0t4 3162420 /home/wangshuo/Public/xxoo.txt
# 启动另一个 bash 窗口，查看其 fd 列表，发现并没有 8r 文件描述符
$ lsof -op $$
# 在该新 bash 窗口中执行下方命令，会发现不会对第一个 bash 线程中的 fd 造成影响
$ exec 8< xxoo.txt
$ read a 0<& 8
$ echo $a
$ read a 0<& 8
$ echo $a
```
系统为每个线程维护了一套自己的文件描述符，不同线程内的 FD 是互不影响的。

## linux 中一些名词的理解

1. swap：交换分区，将一部分的硬盘空间当作内存来用，当内存快被占满的时候，kernel 会根据 LRU（Least Recently Used）算法将内存中长期没有使用到的 PageCache 刷进 swap 中。
2. PageCache：在 linux 的内存中，由 kernel 进行维护，默认大小为 1 页 4KB，作为应用程序和物理磁盘之间读写数据的缓存。
- 当调用 read()方法时，先从 PageCache 中查找是否包含需要的数据块，如果包含直接返回，否则，从磁盘中找到相应的数据块缓存到 PageCache 中，再返回
- 当调用 write() 方法时，先将数据写入到 PageCache 中，然后 DMA（协处理器）定时将 PageCache 中的数据刷新到物理硬盘。内容未被保存到硬盘的 PageCache，称为脏页（Dirty Page）。
3. DMA（Direct Memory Access，直接存储器访问，协处理器）：如果使用 CPU 操控内存与 IO 设备间的数据传输，会大量占用 CPU 的时间，使得 CPU 无法处理其它应用的指令，严重影响机器性能。而使用 DMA 能使 IO 设备直接和内存之间进行成批数据的快速传送。
由于程序是先将数据写入到 PageCache，而 PageCache 是在内存中，所以，如果在程序写入数据时强制断电，会造成数据的丢失
4. MMU（Memory Management Unit，内存管理单元）：它的功能包括虚拟地址到物理地址的转换（即虚拟内存管理）、内存保护、中央处理器高速缓存的控制。
应用程序（比如一个 Java 程序）在运行时，它看到的内存是一个线性的，完全属于它自己的虚拟内存，而在真实的物理内存上，它使用的并不一定是连续的。
MMU 将应用程序中的虚拟内存地址与真实的物理内存之间进行了地址的映射，从而规避了由于应用程序可以直接访问物理内存而造成的一系列不安全的问题。
5. mmap（Memory Mapped Files）：内存映射文件，将物理磁盘上的文件映射到内核的多个 PageCache 中，此时向 PageCache 中写入数据，就相当于写入到了文件中，而真实情况是，写入的内容是在 PageCache 中，需要依赖 kernel 对赃页的处理方式，由 kernel 将 PageCache 中的数据刷入到磁盘。
6. ZoreCopy：零拷贝。传统 web 程序执行流程：内核将数据从磁盘（内核空间）拷贝到内存（内核空间），再从内存（内核空间）拷贝到应用程序（用户空间），应用程序对数据进行处理后，将处理后的数据（用户空间）写入到内存（内核空间），内核再将内存中的数据通过网络发送出去，此种方式包含两次用户态与内核态的切换。
   而零拷贝，是借助与 mmap，将应用程序获取到的数据以及处理后的数据均是放在内核管理的内存中的，就不会再有两次用户态与内核态的切换，因此称其为零拷贝，极大的提高了程序的效率。
   ![ZeroCopy](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210706123415.png)

## 文件 IO

### 最基本文件 IO

1. 编写运行脚本，简化测试
    ```bash
    rm -rf out*
    javac OsFileIo.java
    # 追踪程序的系统调用，将信息输出到 out 开头的文件中
    strace -ff -o out java OsFileIo $1
    ```
2. 修改脚本权限，并运行脚本
    ```bash
    chmod 755 run.sh
    sh run.sh 0
    ```
3. 此时，在另一窗口使用 `ll -h` 查看 jout.txt，可以看到其占用空间持续增长
    ```bash
    [normal@localhost testfileio]$ ll -h jout.txt 
    -rw-rw-r--. 1 normal normal 316K Jul 14 23:30 jout.txt
    [normal@localhost testfileio]$ ll -h jout.txt
    -rw-rw-r--. 1 normal normal 837K Jul 14 23:30 jout.txt
    ...
    [normal@localhost testfileio]$ ll -h jout.txt 
    -rw-rw-r--. 1 normal normal 2.2M Jul 14 23:30 jout.txt
    ```

4. 使用 `tail -f` 命令也可以看到向文件中写了内容
    ```
    123456789
    ...
    123456789
    ```

5. 对虚拟机进行强制关机，重新登录，查看 jout.txt，发现其文件大小为 0，可见，数据并没有直接写入磁盘，证明了 PageCache 的存在
    ```bash
    [normal@localhost testfileio]$ ll -h jout.txt 
    -rw-rw-r--. 1 normal normal 0 Jul 14 23:33 jout.txt
    ```

6. 再次运行，一段时间关闭程序，查看输出的系统调用文件，可见每一次调用系统的 write()方法，写入了 10Byte 的数据。注意：每次 wirite 方法都是一次系统调用
   ```bash
    write(4, "123456789\n", 10)             = 10
    write(4, "123456789\n", 10)             = 10
    ...
   ```

### Buffered 文件 IO

1. 使用同样的脚本，修改传入的变量为 1
    ```bash
    sh run.sh 1
    ```
2. 在另一窗口使用 `ll -h` 命令查看 *jout.txt* 的大小，可见其大小一直增多，且增长的速度明显比基本 IO 方式快的多
    ```bash
    [normal@localhost testfileio]$ ll -h jout.txt 
    -rw-rw-r--. 1 normal normal 38M Jul 14 23:34 jout.txt
    [normal@localhost testfileio]$ ll -h jout.txt 
    -rw-rw-r--. 1 normal normal 99M Jul 14 23:34 jout.txt
    ...
    [normal@localhost testfileio]$ ll -h jout.txt 
    -rw-rw-r--. 1 normal normal 2.0G Jul 14 23:39 jout.txt
    ```
3. 使用 `tail -f` 命令也可以看到向文件中写了内容
    ```
    123456789
    ...
    123456789
    ```
4. 对虚拟机进行强制关机，重新登录，查看 jout.txt，发现其文件大小为 0（或小于最后一次 `ll -h` 看到的大小），可见，数据并没有直接写入磁盘，证明了 PageCache 的存在
    ```bash
    [normal@localhost testfileio]$ ll -h jout.txt 
    -rw-rw-r--. 1 normal normal 0 Jul 14 23:41 jout.txt
    ```

6. 再次运行，一段时间关闭程序，查看输出的系统调用文件，可见每一次调用系统的 write()方法，写入了 8190Byte 的数据。注意：每次 wirite 方法都是一次系统调用
   ```bash
    write(5, "123456789\n123456789\n123456789\n12"..., 8190) = 8190
    write(5, "123456789\n123456789\n123456789\n12"..., 8190) = 8190
    ...
   ```
   此处一次系统调用写入了 8190B 的数据，数据相同时，减少了系统调用的次数，显著提高了 IO 的速度

使用 `pcstat` 命令查看 PageCache 的脏页信息

1. 重新运行脚本
    ```bash
    sh run.sh 1
    ```
2. 使用 `pcstat` 命令查看 *jout.txt* 文件的信息，可见随着文件的变大，系统会将内存中的 PageCache 刷到物理磁盘中，从而空出内存空间
    ```bash
    [normal@192-168-99-100 testfileio]$ pcstat jout.txt 
    +----------+----------------+------------+-----------+---------+
    | Name     | Size (bytes)   | Pages      | Cached    | Percent |
    |----------+----------------+------------+-----------+---------|
    | jout.txt | 93963870       | 22941      | 22941     | 100.000 |
    +----------+----------------+------------+-----------+---------+
    ...
    [normal@192-168-99-100 testfileio]$ pcstat jout.txt 
    +----------+----------------+------------+-----------+---------+
    | Name     | Size (bytes)   | Pages      | Cached    | Percent |
    |----------+----------------+------------+-----------+---------|
    | jout.txt | 525434880      | 128280     | 124503    | 097.056 |
    +----------+----------------+------------+-----------+---------+
    ...
    [normal@192-168-99-100 testfileio]$ pcstat jout.txt 
    +----------+----------------+------------+-----------+---------+
    | Name     | Size (bytes)   | Pages      | Cached    | Percent |
    |----------+----------------+------------+-----------+---------|
    | jout.txt | 822444032      | 200792     | 123068    | 061.291 |
    +----------+----------------+------------+-----------+---------+
    ...
    [normal@192-168-99-100 testfileio]$ pcstat jout.txt 
    +----------+----------------+------------+-----------+---------+
    | Name     | Size (bytes)   | Pages      | Cached    | Percent |
    |----------+----------------+------------+-----------+---------|
    | jout.txt | 2127646720     | 519445     | 127132    | 024.475 |
    +----------+----------------+------------+-----------+---------+
    ...
    ```

使用如下命令可以查看到与脏页相关的系统配置信息，该配置文件为 */etc/sysctl.conf*
```bash
$ sudo sysctl -a | grep dirty
vm.dirty_background_bytes = 0
# 如果脏页占了内存的 10%，将脏页向磁盘写入
vm.dirty_background_ratio = 10
vm.dirty_bytes = 0
vm.dirty_expire_centisecs = 3000
# 如果脏页占了内存的 30%，阻塞该进程
vm.dirty_ratio = 30
vm.dirty_writeback_centisecs = 500
vm.dirtytime_expire_seconds = 43200
```

### ByteBuffer 的使用说明

使用同样的脚本，修改传入的变量为 2
    ```shell
    sh run.sh 2
    ```

程序输出结果：

```bash
position = 0
limit = 1024
capacity = 1024
mark = java.nio.DirectByteBuffer[pos=0 lim=1024 cap=1024]
------------ put(abc) ------------
mark = java.nio.DirectByteBuffer[pos=3 lim=1024 cap=1024]
------------ flip ------------
mark = java.nio.DirectByteBuffer[pos=0 lim=3 cap=1024]
------------ get ------------
mark = java.nio.DirectByteBuffer[pos=1 lim=3 cap=1024]
------------ compace ------------
mark = java.nio.DirectByteBuffer[pos=2 lim=1024 cap=1024]
------------ clear ------------
mark = java.nio.DirectByteBuffer[pos=0 lim=1024 cap=1024]
```

相应图示：

![ByteBuffer.png](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210706123203.png)


### RandomAccessFile 以及 FileChannel 随机读写 NIO

1. 使用同样的脚本，修改传入的变量为 3，同时再开启两个窗口，一个使用 `tail -f` 追踪主程序的系统调用信息，一个负责查看文件内容及大小信息
    ```bash
    sh run.sh 3
    ```
2. 当输出 `write` 之后，程序阻塞，主程序的内存调用信息包含如下的输出，说明 `raf.write` 执行了系统调用
    ```bash
    write(4, "hello world", 11)             = 11
    write(4, "hello java", 10)              = 10
    ```
    查看文件内容，为
    ```bash
    hello worldhello java
    ```
3. 输入回车，程序输出 `seek(4)`，此时使用 `cat` 命令查看 *jout.txt*，可见 *123* 是从 *hello worldhello java* 角标为 4 的位置开始写入的
    ```bash
    hell123orldhello java
    ```
    使用 `jps` 命令，查看 OsFileIo 的进程 id，使用 `lsof -p 进程号` 查看文件描述符信息，*jout.txt* 仅包含 FD 为 *5u* 的文件描述符，大小为 21Byte
    ```bash
    COMMAND  PID   USER   FD   TYPE             DEVICE OFFSET     NODE NAME
    java    2531 normal    5u   REG  253,0        21 34601606 /home/normal/testfileio/jout.txt
    ```
4. 继续回车，程序输出 `map.put(@@@)`，会发现 `map.put()` 并没有执行系统调用，查看 *jout.txt*，内容也已经写入文件
    ```bash
     @@@l123orldhello java
    ```
    使用 `lsof -p 进程号` 再次查看文件描述符信息，此时 *jout.txt* 多了一个 FD 为 *mem* 的文件描述符，表明已经进行了 mmap 内存映射，同时文件大小也变为了设置的 4096Byte
    ```bash
    COMMAND  PID   USER   FD   TYPE             DEVICE OFFSET     NODE NAME
    java    2531 normal  mem    REG              253,0      4096 34601606 /home/normal/testfileio/jout.txt
    java    2531 normal    5u   REG              253,0      4096 34601606 /home/normal/testfileio/jout.txt
    ```
5. 继续回车，程序输出如下，读取 FileChannel 中的字节数据存放到给定的 buffer 中，翻转该 buffer，将其中的数据进行读出
    ```bash
    fileChannel.read(buffer); buffer = java.nio.HeapByteBuffer[pos=4096 lim=8192 cap=8192]
    buffer.flip(); buffer = java.nio.HeapByteBuffer[pos=0 lim=4096 cap=8192]
    @@@l123orldhello java
    ```
## 网络 IO

### TCP 参数

1. 使用 `sudo tcpdump -nn -i enp0s3 port 9999` 抓取 enp0s3 网卡，9999 端口的 tcp 包
2. 启动 SocketIoProperties 服务端，程序输出信息后**阻塞**，等待客户端连接，此时 tcp 抓包没有任何信息，因为只是启动了监听，没有发送/接受数据包
3. 使用 `netstat -anp` 查看 *9999* 端口信息，可见 PID 为 14870 的应用正在监听 9999 端口
    ```bash
    Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
    tcp6       0      0 :::9999                 :::*                    LISTEN      14870/java
    ```
4. 使用 `lsof -p 14870` 查看文件描述符信息，可见其已有一个文件描述符显示为监听状态
    ```bash
    Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
    java    14870 normal    5u  IPv6            5127216       0t0      TCP *:distinct (LISTEN)
    ```
5. 启动 SocketClient 客户端，可见 `tcpdump` 抓取到了客户端与服务端的 3 次握手
    ```bash
    09:14:40.082915 IP 192.168.99.1.45554 > 192.168.99.101.9999: Flags [S], seq 2802904548, win 64240, options [mss 1460,sackOK,TS val 844799154 ecr 0,nop,wscale 7], length 0
    09:14:40.083055 IP 192.168.99.101.9999 > 192.168.99.1.45554: Flags [S.], seq 361953027, ack 2802904549, win 1152, options [mss 1460,sackOK,TS val 252766455 ecr 844799154,nop,wscale 0], length 0
    09:14:40.083378 IP 192.168.99.1.45554 > 192.168.99.101.9999: Flags [.], ack 1, win 502, options [nop,nop,TS val 844799155 ecr 252766455], length 0
    ```
6. 使用 `netstat -anp | grep 9999` 查看 9999 端口状态，在客户端与服务端还未建立连接时（因为服务端此时还在阻塞）可见系统内核中已经有了一个状态为*ESTABLISHED*的连接，同时还没有分配给应用程序，此时，该 socket 是在内核态的。
   Recv-Q 与 Send-Q 均为 0，说明没有收发信息
   
    ```bash
    Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
    tcp6       0      0 :::9999                 :::*                    LISTEN      14870/java          
    tcp6       0      0 192.168.99.101:9999     192.168.99.1:45554      ESTABLISHED -          
    ```
7. 在客户端还在阻塞时，使用客户端发送一些消息，`tcpdump` 抓取到如下信息，表明客户端与服务端可以正常正常交互
    ```bash
    09:21:59.451685 IP 192.168.99.1.45554 > 192.168.99.101.9999: Flags [P.], seq 1:2, ack 1, win 502, options [nop,nop,TS val 845237076 ecr 252766455], length 1
    09:21:59.451793 IP 192.168.99.101.9999 > 192.168.99.1.45554: Flags [.], ack 2, win 1151, options [nop,nop,TS val 253205823 ecr 845237076], length 0
    09:21:59.451837 IP 192.168.99.1.45554 > 192.168.99.101.9999: Flags [P.], seq 2:3, ack 1, win 502, options [nop,nop,TS val 845237076 ecr 252766455], length 1
    09:21:59.451852 IP 192.168.99.1.45554 > 192.168.99.101.9999: Flags [P.], seq 3:4, ack 1, win 502, options [nop,nop,TS val 845237076 ecr 252766455], length 1
    09:21:59.451859 IP 192.168.99.1.45554 > 192.168.99.101.9999: Flags [P.], seq 4:5, ack 1, win 502, options [nop,nop,TS val 845237076 ecr 252766455], length 1
    09:21:59.467476 IP 192.168.99.1.45554 > 192.168.99.101.9999: Flags [P.], seq 4:5, ack 1, win 502, options [nop,nop,TS val 845237092 ecr 253205823], length 1
    09:21:59.467531 IP 192.168.99.101.9999 > 192.168.99.1.45554: Flags [.], ack 5, win 1148, options [nop,nop,TS val 253205839 ecr 845237076,nop,nop,sack 1 {4:5}], length 0
    09:21:59.467654 IP 192.168.99.1.45554 > 192.168.99.101.9999: Flags [P.], seq 5:6, ack 1, win 502, options [nop,nop,TS val 845237092 ecr 253205839], length 1
    09:21:59.467721 IP 192.168.99.1.45554 > 192.168.99.101.9999: Flags [P.], seq 6:7, ack 1, win 502, options [nop,nop,TS val 845237092 ecr 253205839], length 1
    09:21:59.467728 IP 192.168.99.1.45554 > 192.168.99.101.9999: Flags [P.], seq 7:8, ack 1, win 502, options [nop,nop,TS val 845237093 ecr 253205839], length 1
    09:21:59.467731 IP 192.168.99.1.45554 > 192.168.99.101.9999: Flags [P.], seq 8:9, ack 1, win 502, options [nop,nop,TS val 845237093 ecr 253205839], length 1
    09:21:59.487421 IP 192.168.99.1.45554 > 192.168.99.101.9999: Flags [P.], seq 8:9, ack 1, win 502, options [nop,nop,TS val 845237112 ecr 253205839], length 1
    09:21:59.487459 IP 192.168.99.101.9999 > 192.168.99.1.45554: Flags [.], ack 9, win 1144, options [nop,nop,TS val 253205859 ecr 845237092,nop,nop,sack 1 {8:9}], length 0
    ```
8. 使用 `netstat -anp | grep 9999` 查看端口信息，Recv-Q 变为了 8，表明该 socket 还未分配给应用程序使用，但此时就已经可以接收信息了
    ```bash
    Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
    tcp6       8      0 192.168.99.101:9999     192.168.99.1:45554      ESTABLISHED -         
    ```
    tcp 三次握手是内核完成的，当完成握手之后，连接就建立了，就可以收发消息了，只不过此时是内核与客户端进行交互，还未将该 socket（文件描述符）分配给应用程序
9. 使用 `lsof -p 14870` 查看文件描述符信息，没有任何变化。
10. 在服务端窗口输入回车，使其不再阻塞，程序输出如下，客户端正常接受到了客户端发来的数据
    ```bash
      client read some data is: 8 val: 11111111
    ```
11. 再次查看 9999 端口情况，Recv-Q 变为了 0，也将该连接分配给了 14870 这个客户端程序
    ```bash
    Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
    tcp6       0      0 192.168.99.101:9999     192.168.99.1:45554      ESTABLISHED 14870/java
    ```
12. 查看文件描述符信息，多了如下 6u 描述符号，四元组 *k8s-master:distinct->host:45554* 已经为建立连接状态
    ```bash
    COMMAND   PID   USER   FD   TYPE             DEVICE  SIZE/OFF     NODE NAME
    java    14870 normal    6u  IPv6            5144029       0t0      TCP k8s-master:distinct->host:45554 (ESTABLISHED)
    ```
    **小总结**

TCP 是面向连接的，三次握手之后，客户端与服务端都会开辟资源（文件描述符），双方通过这两个 FD 来传输信息。
即使服务端没有 accept()，客户端依旧可以向服务端发送数据，该数据会被保存在服务端网卡的缓冲区中，当服务端 accept() 后，kernel 会将缓冲区的数据发送给服务端。
如果客户端发送了超出服务端缓冲区大小的数据，并且服务端一直没有 accept()，那么内核只会在缓冲区中保留最新接收的数据。

socket 是一个四元组：服务端 IP+服务端 Port+客户端 IP+客户端 Port，保证了连接的唯一性。

**验证 BACK_LOG**

1. 将 SocketIoProperties 服务端中的 *BACK_LOG* 设置为 2
2. 启动 SocketIoProperties，并使用 `tcpdump` 进行抓包
3. 启动一个客户端，可见抓包窗口输出如下信息，客户端与服务端成功完成了三次握手
    ```bash
    17:41:26.572940 IP 192.168.99.1.42050 > 192.168.99.101.9999: Flags [S], seq 1079717590, win 64240, options [mss 1460,sackOK,TS val 875204207 ecr 0,nop,wscale 7], length 0
    17:41:26.573018 IP 192.168.99.101.9999 > 192.168.99.1.42050: Flags [S.], seq 1918656041, ack 1079717591, win 1152, options [mss 1460,sackOK,TS val 283172944 ecr 875204207,nop,wscale 0], length 0
    17:41:26.573113 IP 192.168.99.1.42050 > 192.168.99.101.9999: Flags [.], ack 1, win 502, options [nop,nop,TS val 875204207 ecr 283172944], length 0
    ```
    `netstat` 可见已经建立了一个 tcp 连接（第一个）
    
    ```bash
    tcp6       1      0 :::9999                 :::*                    LISTEN      21753/java
    tcp6       0      0 192.168.99.101:9999     192.168.99.1:42050      ESTABLISHED -                   
    ```
3. 再次启动一个客户端，可见抓包窗口输出如下信息，客户端与服务端成功完成了三次握手
    ```bash
    17:44:02.074472 IP 192.168.99.1.42152 > 192.168.99.101.9999: Flags [S], seq 2993811130, win 64240, options [mss 1460,sackOK,TS val 875359709 ecr 0,nop,wscale 7], length 0
    17:44:02.074529 IP 192.168.99.101.9999 > 192.168.99.1.42152: Flags [S.], seq 1945101284, ack 2993811131, win 1152, options [mss 1460,sackOK,TS val 283328446 ecr 875359709,nop,wscale 0], length 0
    17:44:02.074660 IP 192.168.99.1.42152 > 192.168.99.101.9999: Flags [.], ack 1, win 502, options [nop,nop,TS val 875359709 ecr 283328446], length 0
    ```
    `netstat` 可见又建立了一个 tcp 连接（第二个）
    
    ```bash
    tcp6       2      0 :::9999                 :::*                    LISTEN      21753/java          
    tcp6       0      0 192.168.99.101:9999     192.168.99.1:42050      ESTABLISHED -                   
    tcp6       0      0 192.168.99.101:9999     192.168.99.1:42152      ESTABLISHED -                       
    ```
4. 再次启动一个客户端，可见抓包窗口输出如下信息，客户端与服务端成功完成了三次握手
    ```bash
    17:46:54.537908 IP 192.168.99.1.42324 > 192.168.99.101.9999: Flags [S], seq 4026614965, win 64240, options [mss 1460,sackOK,TS val 875532172 ecr 0,nop,wscale 7], length 0
    17:46:54.538019 IP 192.168.99.101.9999 > 192.168.99.1.42324: Flags [S.], seq 4197451679, ack 4026614966, win 1152, options [mss 1460,sackOK,TS val 283500909 ecr 875532172,nop,wscale 0], length 0
    17:46:54.538131 IP 192.168.99.1.42324 > 192.168.99.101.9999: Flags [.], ack 1, win 502, options [nop,nop,TS val 875532173 ecr 283500909], length 0
    ```
   `netstat` 可见又建立了一个 tcp 连接（第三个）
   
   ```bash
    tcp6       3      0 :::9999                 :::*                    LISTEN      21753/java          
    tcp6       0      0 192.168.99.101:9999     192.168.99.1:42050      ESTABLISHED -                   
    tcp6       0      0 192.168.99.101:9999     192.168.99.1:42324      ESTABLISHED -                   
    tcp6       0      0 192.168.99.101:9999     192.168.99.1:42152      ESTABLISHED -            
   ```
5. 再次启动一个客户端，可见抓包窗口输出如下信息，客户端与服务端已经不能成功三次握手了
    ```bash
    17:49:13.752171 IP 192.168.99.101.9999 > 192.168.99.1.42408: Flags [S.], seq 2105096148, ack 2133474618, win 1152, options [mss 1460,sackOK,TS val 283640124 ecr 875666977,nop,wscale 0], length 0
    17:49:13.752315 IP 192.168.99.1.42408 > 192.168.99.101.9999: Flags [.], ack 1, win 502, options [nop,nop,TS val 875671387 ecr 283632194], length 0
    ```
    `netstat` 可见生成的 FD 状态为 SYN_RECV，表示服务端接收到了客户端的 SYN，但是服务端没有收到客户端的第二次请求（因为服务端没有给客户端回复消息），因此没有连接没有建立成功。过一段时间后，该连接会自动断开。
    
    ```bash
    tcp        0      0 192.168.99.101:9999     192.168.99.1:42408      SYN_RECV    -                   
    tcp6       3      0 :::9999                 :::*                    LISTEN      21753/java          
    tcp6       0      0 192.168.99.101:9999     192.168.99.1:42050      ESTABLISHED -                   
    tcp6       0      0 192.168.99.101:9999     192.168.99.1:42324      ESTABLISHED -                   
    tcp6       0      0 192.168.99.101:9999     192.168.99.1:42152      ESTABLISHED -            
    ```
    此时 BACK_LOG 为 2，服务端一共可以建立 3 个连接（包含两个备用连接）

**验证 TIME_OUT**

客户端和服务端均可以设置 TIMEOUT 的值，服务端的 accept 方法，默认是永久阻塞的（只要收不到客户端的消息，就一直阻塞），设置了 TIMEOUT 后，如果超过 TIMEOUT 后还没有客户端连接，就会抛出异常，进行下一次循环。
客户端的 read 方法默认是永久阻塞的（只要收不到服务端的消息，就一直阻塞），设置了 TIMEOU 后，在超过 TIMEOUT 还没有接受到客户端的消息，就会抛出异常，并继续下一次循环。

**tcpdump 中的 win**

win 代表窗口大小，双方用来协商每次发送数据包的最大大小，如果其中一方 win 满了，就会给另一方发送个消息通知对方，此时对方会拥塞，不会再发送数据包，直到接受到表明可以继续发送消息的数据包后才会解除阻塞，继续发送数据包。

可以使用 `ifconfig` 查看 *MTU（Maximum Transmission Unit，最大传输单元）*，表明当前网络接口一次最多可发送多少字节的数据包

演示向服务发送数据，当拥塞后，再次发送的数据会被丢弃的现象：

1. 启动 SocketIoProperteis 服务端，使用`nc`命令启动一个客户端，并一直向服务端发送数据

    ```bash
    nc 192.168.99.101 9999
    ```
2. 随着发送数据使用 `netstat` 查看服务端的 Recv-Q 信息，会发现其一直会增长，到达某一数值后便不再增加
    ```bash
    tcp6    1152      0 192.168.99.100:9999     192.168.99.1:52202      ESTABLISHED -         
    ```
3. 向服务端发送一个与之前数据有明显区别的数据，在服务端窗口输入回车，解除阻塞，可见服务端并没有接受到最后发送的数据，说明当 Recv-Q 存满后，会丢弃之后再发送过来的数据包

**验证客户端 TcpNoDelay 和 SendBufferSize**

TcpNoDelay 是否延迟发送，SocketClient 类中从 Terminal 读取数据是一批一批读的，但是向服务端写是 1 个字节 1 个字节写的，并且没有手动调用 flush 方，当客户端一个字节一个字节的发送数据时，每个包中有用的数据只有 1 字节，同时会有 40 多个字节的标题数据等，会极大增加网络传输的消耗，因此可以将这些数据攒一些后，按批发送。

1. SocketClient 客户端中将 TcpNoDelay 设置为 false（延迟），SendBufferSize 设置为 20
    ```
    client.setSendBufferSize(20);
    client.setTcpNoDelay(false);
    ```
2. 启动 SocketIoProperties 并回车，开始接收客户端的连接
3. 启动 SocketClient，并向服务端发送数据
    ```bash
    1
    123
    1234567890123456789012345678901234
    ```
4. 服务端窗口打印出如下信息，可见当 TcpNoDelay 为 false 时，发出的一个包的大小是可以超过设置的缓冲区 20 的限制的。
    ```bash
    client IP: /192.168.99.1 Port: 49026
    client read some data is: 1 val: 1
    client read some data is: 1 val: 1
    client read some data is: 2 val: 23
    client read some data is: 1 val: 1
    client read some data is: 33 val: 234567890123456789012345678901234
    ```
5. 将 TcpNoDelay 设置为 true（不延迟），重新启动 SocketClient，向服务端发送一些数据
    ```bash
    123
    1234567890123456789012345678901234
    ```
6. 客户端窗口打印如下信息，可见当发送数据量较大时，会尽快发送（客户端是 1 个字节 1 个字节发送的），不会积攒数据。
    ```bash
    client IP: /192.168.99.1 Port: 49550
    client read some data is: 3 val: 123
    client read some data is: 4 val: 1234
    client read some data is: 4 val: 5678
    client read some data is: 4 val: 9012
    client read some data is: 4 val: 3456
    client read some data is: 4 val: 7890
    client read some data is: 4 val: 1234
    client read some data is: 8 val: 56789012
    client read some data is: 2 val: 34
    ```

**验证 OOBInline（Out-Of-Band data，带外数据）**

没啥用默认 false 就行。具体不理解。

**验证 KeepAlive**

再服务端为 client 开启 KEEPALIVE 后，如果客户端与服务端一直不互相发送数据，服务端就会定时向客户端发送一个数据包，来判断客户端是否还存活。

KEEPALIVE 受 Linux 系统参数 *net.ipv4.tcp_keepalive_time*，*net.ipv4.tcp_keepalive_intvl*，*net.ipv4.tcp_keepalive_probes*，的影响
- net.ipv4.tcp_keepalive_time：客户端与服务端多久不发送数据包，开始进行 KEEPALIVE 检测，默认是 7200 秒
- net.ipv4.tcp_keepalive_intvl：两次 KEEPALIVED 间的时间间隔，默认 75 秒
- net.ipv4.tcp_keepalive_probes：发送多少次探测包后，对方仍没有反应，就关闭与对方的连接，默认 9 次

1. 修改 SocketIoProperties 中 CLI_KEEPALIVE 值为 true
2. 为了让服务端尽快发送探测包，将 net.ipv4.tcp_keepalive_time 设置为 1 秒
    ```bash
    sudo echo 1 > /proc/sys/net/ipv4/tcp_keepalive_time
    ```
3. 启动服务端，并回车，在另一窗口使用 `tcpdump` 抓包。
4. 启动客户端，服务端显示客户端已连接，此时双方均不发送消息，可见 tcpdump 依旧会抓取到如下信息
    ```bash
    21:16:27.908536 IP 192.168.99.101.9999 > 192.168.99.1.45698: Flags [.], ack 1, win 1152, options [nop,nop,TS val 1506131435 ecr 3043275146], length 0
    21:16:27.908869 IP 192.168.99.1.45698 > 192.168.99.101.9999: Flags [.], ack 1, win 502, options [nop,nop,TS val 3043352011 ecr 1506053503], length 0
    ```

### 网络 IO 变化 模型

同步：发出一个功能调用时，再没有得到结果之前，该调用就不返回或继续执行后续操作。即同步只能一件一件事做，要等前一件做完了才能做下一件事。
异步：发出一个功能调用后，还没有得到结果，就去做其他的事情了，该调用的结果可以通过轮询状态或通知或回调的方式来返回给调用放。即异步可以同时做多个不同的事。

阻塞：调用一个功能后，在没有得到结果之前，该线程就一直等待返回结果
非阻塞：调用一个功能后，在不能立即得到结果之前，该函数不会阻塞当前线程

同步阻塞
同步非阻塞
异步非阻塞

### 异步（Async） 阻塞 IO（BIO）

需要使用 j2se1.4 的 jdk 来操作，才能看到如下效果，因为老版本 JDK 使用的是纯 BIO 的方式，新版本的 JDK 对源码编译后会使用单连接单 poll 的方式，在效果上与阻塞 IO 相同。

1. 使用下方命令编译并运行 AsyncBlockSocketIo，同时追踪系统调用信息
    ```bash
    javac AsyncBlockSocketIo.java && strace -ff -o out java AsyncBlockSocketIo
    ```
2. 使用 `nc 192.168.99.101 9999` 启动一个客户端，查看服务器系统调用信息，可以看到发生如下系统调用

| Java                                         | 系统调用          | 生成                                    |
| :------------------------------------------  | :-------------- | :-------------------------------------  |
| ServerSocket server = new ServerSocket();    | socket          | 服务端生成文件描述符 fd3                   |
| server.bind(new InetSocketAddress(9999));    | bind(fd3, 9999) | -                                      |
| getImpl().listen(backlog);                   | listen(fd3)     | 在 bind() 方法内部包含对 listen 方法的调用     |
| server.accept();                             | accept(fd3      | 此处是第一处阻塞                         |
| new Thread().start()                         | clone(          | 服务端为每个客户端都抛一个线程             |
| reader.readLine();                           | recv(fd5        | 此处是第二次阻塞                        |

**BIO 弊端**

阻塞：由于阻塞所以需要为每个客户端抛出一个线程来解决阻塞的问题，进而造成低效。

**C10K 压力测试**

- [The C10K problem](http://www.kegel.com/c10k.html)

如果宿主机的网卡与虚拟机网卡有不连通的，需要下方命令为宿主机/虚拟机添加路由跳转

```bash
sudo route add -host 192.168.1.102 gw 192.168.99.1
```

1. 使用下方命令编译并运行 AsyncBlockSocketIo
    ```bash
    javac AsyncBlockSocketIo.java && java AsyncBlockSocketIo
    ```
2. 启动 C10kClient，观察客户端输出及速度，连接端口号均是成对出现的
    ```bash
    step1：server start, bind port 9999...
    step2：client connected, IP：/192.168.99.1, port：10000, 当前已连接客户端总数：1
    step2：client connected, IP：/192.168.1.102, port：10000, 当前已连接客户端总数：2
    ...
    step2：client connected, IP：/192.168.99.1, port：11935, 当前已连接客户端总数：3857
    step2：client connected, IP：/192.168.1.102, port：11935, 当前已连接客户端总数：3858
    ```
3. 在达到共 4000 个左右连接后，会报如下异常（root 用户可能不会报错）
    ```bash
    [65.753s][warning][os,thread] Failed to start thread - pthread_create failed (EAGAIN) for attributes: stacksize: 1024k, guardsize: 0k, detached.
    Exception in thread "main" java.lang.OutOfMemoryError: unable to create native thread: possibly out of memory or process/resource limits reached
        at java.base/java.lang.Thread.start0(Native Method)
        at java.base/java.lang.Thread.start(Thread.java:803)
        at AsyncBlockSocketIo.main(AsyncBlockSocketIo.java:57)
    ```
4. 上述问题是由于 Linux 对普通用户使用系统资源的数量进行了限制，可以使用如下命令查看
    ```bash
    $ ulimit -a
    core file size          (blocks, -c) 0
    data seg size           (kbytes, -d) unlimited
    scheduling priority             (-e) 0
    file size               (blocks, -f) unlimited
    pending signals                 (-i) 3871
    max locked memory       (kbytes, -l) 64
    max memory size         (kbytes, -m) unlimited
    open files                      (-n) 1024
    pipe size            (512 bytes, -p) 8
    POSIX message queues     (bytes, -q) 819200
    real-time priority              (-r) 0
    stack size              (kbytes, -s) 8192
    cpu time               (seconds, -t) unlimited
    max user processes              (-u) 3871
    virtual memory          (kbytes, -v) unlimited
    file locks                      (-x) unlimited
    ```
   上方 *max user processes              (-u) 3871* 限制了当前用户最多可以启动 3871 个进程，当前程序已经启动了 3858 个进程，再加上其他系统进程超过限制后就会发生该异常。
   root 用户虽然会显示限制信息，但一般限制不生效。

### 同步（Sync）非阻塞 IO（NIO）

1. 编译并运行 NonBlockSocketIo，并追踪系统调用信息
    ```bash
    javac NonBlockSocketIo.java && strace -ff -o out java NonBlockSocketIo
    ```
2. 当没有客户端连接时，终端窗口会一直输出 `client is null ......`
3. 查看系统调用信息可见如下信息，调用系统的 accept 方法后不会阻塞，返回值为 -1，代表没有客户端连接
    ```bash
    accept(4, 0x7fbf482817c0, [28])         = -1 EAGAIN (Resource temporarily unavailable)
    ...
    accept(4, 0x7fbf482817c0, [28])         = -1 EAGAIN (Resource temporarily unavailable)
    ```
4. 使用 `nc` 命令创建几个客户端，并发送一些消息，服务端可以在单线程中即处理客户端的连接，又接收客户端发送来的数据

    ```bash
    client IP：/192.168.99.101, port：39524 当前已连接客户端总数：1
    received：dfasdfsaf
     send by client IP：/192.168.99.101, port：39524
    client IP：/192.168.99.101, port：39586 当前已连接客户端总数：2
    received：1234
    send by client IP：/192.168.99.101, port：39586
    ```

**C10K 压力测试**

1. 注释掉 NonBlockSocketIo 中的如下两行代码，重新编译运行服务端
    ```Java
    // Thread.sleep(1000);
    // System.out.println("client is null ......");
    ```
    
2. 使用 C10kClient 测试，会发现建立连接速度比 AsyncBlockSocketIo 快很多。
同时，随着客户端连接数的增长，连接速度会变慢，是由于将已连接的客户端保存在了集合中，随着连接客户端的增多，每次遍历已连接的客户端都会调用 client 的 read 方法，用户态和内核态切换次数变多。

3. 超过 4000 多个连接后，会报如下异常
    ```bash
    client IP：/192.168.99.101, port：12045 当前已连接客户端总数：4090
    java.io.IOException: Too many open files
        at java.base/sun.nio.ch.ServerSocketChannelImpl.accept0(Native Method)
        at java.base/sun.nio.ch.ServerSocketChannelImpl.accept(ServerSocketChannelImpl.java:533)
        at java.base/sun.nio.ch.ServerSocketChannelImpl.accept(ServerSocketChannelImpl.java:285)
        at NonBlockSocketIo.main(NonBlockSocketIo.java:40)
    ```
    
4. 使用 `ps` 命令查看当前服务端的进程号，在使用 `cat` 命令查看当前进程的限制信息，可见当前 *Max open files* 限制了该进程最多可以打开 4096 个 FD

    ```bash
    $ ps -ef | grep NonBlockSocketIo
    normal   16704  2423 42 15:54 pts/0    00:00:13 java NonBlockSocketIo
    $ cat /proc/16704/limits
    Limit                     Soft Limit           Hard Limit           Units     
    Max cpu time              unlimited            unlimited            seconds   
    Max file size             unlimited            unlimited            bytes     
    Max data size             unlimited            unlimited            bytes     
    Max stack size            8388608              unlimited            bytes     
    Max core file size        0                    unlimited            bytes     
    Max resident set          unlimited            unlimited            bytes     
    Max processes             3871                 3871                 processes 
    Max open files            4096                 4096                 files     
    Max locked memory         65536                65536                bytes     
    Max address space         unlimited            unlimited            bytes     
    Max file locks            unlimited            unlimited            locks     
    Max pending signals       3871                 3871                 signals   
    Max msgqueue size         819200               819200               bytes     
    Max nice priority         0                    0                    
    Max realtime priority     0                    0                    
    Max realtime timeout      unlimited            unlimited            us
    ```

**NIO 对比 BIO 的优点**

可以设置服务端和客户端为非阻塞，使用单线程即可处理所有客户端的连接和接收数据

**NIO 弊端**

将已经连接的客户端存放在了集合中，每次遍历已连接的客户端尝试接收客户端数据时，都会调用 client 的 read 方法（是系统调用），当客户端连接数很多时，导致大量用户态和内核态的切换，并且很多调用是无用的。

### 多路复用器

**多路复用器（SELECT/POLL，EPOLL）对比 NIO**

- 多路复用器与 NIO 都是同步非阻塞模型。
- 无论 NIO 还是多路复用器（SELECT/POLL），都需要遍历所有的 FD 询问状态。NIO 是应用程序自己维护了一个 FD 列表，在程序中自己询问 FD 状态，每询问一个 FD 都会有一次系统调用；
SELECT/POLL 也是应用程序自己维护了一个 FD 列表，不同的是只需要将 FD 列表传给 select()/poll()进行一次系统调用，即可获取所有 FD 的状态
- 应用程序使用 SELECT/POLL 将 FD 列表从用户空间传递到内核空间并调用内核函数 select()/poll()，在内核方法中对传入的 FD 列表进行了遍历，将有状态的 FD 进行返回，
此处存在了两个问题，第一：如果 FD 列表过大，从用户空间向内核空间拷贝该 FD 列表的开销会很大；第二：内核方法中依旧对所有的 FD 进行了全量遍历，时间复杂度是 O(n)。
而 EPOLL 可以理解为 event poll，其在内核层面维护了一个红黑树用来存放需要监视的 FD 和一个双向链表用来存放有状态的 FD，并提供了三个系统函数 epoll_create，epoll_ctl 和 epoll_wait 对 FD 进行修改等操作。
当创建 ServerSocket 或者有 Socket 进行连接时，就会调用 epoll_create 方法，为其创建 FD，然后调用 epoll_ctl 将该 FD 存入到红黑树中，如果该 Socket 发送了数据，则在红黑树中会标记其是有状态的，并将其插入到双向链表中，此时如果调用 epoll_wait，则会将双向链表中的所有 FD（均是有状态的）返回。

**多路复用器分类**

- SELECT：POSIX 标准，synchronous I/O multiplexing，受 FD_SETSIZE 大小的限制，一个 SELECT 只能接收 1024 个 fd

    > int select(int nfds, fd_set *readfds, fd_set *writefds,
                        fd_set *exceptfds, struct timeval *timeout);
    > select()  and  pselect()  allow  a  program to monitor multiple file descriptors, waiting until one or more of the file
             descriptors become "ready" for some class of I/O operation (e.g., input possible).  A  file  descriptor  is  considered
             ready  if  it  is  possible to perform a corresponding I/O operation (e.g., read(2) without blocking, or a sufficiently
             small write(2)).
- POLL：与 SELECT 一置，唯一区别就是没有 FD_SETSIZE 大小的限制

    > int poll(struct pollfd *fds, nfds_t nfds, int timeout);
    
    > poll()  performs  a similar task to select(2): it waits for one of a set of file descriptors to become ready to perform
             I/O.

- EPOLL：event poll, I/O event notification facility

    > int epoll_create(int size); - open an epoll file descriptor

    > int epoll_ctl(int epfd, int op, int fd, struct epoll_event *event); - control interface for an epoll file descriptor

    > int epoll_wait(int epfd, struct epoll_event *events, int maxevents, int timeout); - wait for an I/O event on an epoll file descriptor

无论是 SELECT，POLL 还是 EPOLL，在 Java 中均被抽象为了 Selector，可通过在启动时指定 `-Djava.nio.channels.spi.SelectorProvider=sun.nio.ch.PollSelectorProvider` 来选择使用哪种多路复用器，默认会选择系统支持的较好的

#### TCP 四次挥手及 POLL 与 EPOLL 追踪系统调用对比

**服务端在客户端断开连接后，不调用 `client.close()`**

1. 注释掉 MultiplexingSocketIoSingleThread 中的 `client.close()`，使用如下命令指定使用 POLL 多路复用器进行启动并追踪系统调用（为了对比 POLL 和 EPOLL）
    ```bash
    javac MultiplexingSocketIoSingleThread.java && strace -ff -o poll java -Djava.nio.channels.spi.SelectorProvider=sun.nio.ch.PollSelectorProvider MultiplexingSocketIoSingleThread
    ```
2. 启动后使用 `netstat -antp` 查看系统端口情况，并使用 `lsof -op 10371` 查看当前应用开辟的 FD，可见当前 Java 程序已经监听了 9999 端口，并且生成了一个文件描述符 4u
    ```bash
    Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
    tcp6       0      0 :::9999                 :::*                    LISTEN      10371/java
    ```
    ```bash
    java    10371 normal    4u  IPv6             365461        0t0      TCP *:distinct (LISTEN)
    ```
3. 使用 `nc 127.0.0.1 9999` 创建一个客户端连接到服务端，服务端输出如下信息，说明端口号为 55598 的客户端已经连接
    ```bash
    新客户端连接，IP：/127.0.0.1，port：55598
    ```
4. 再次使用 `netstat -antp` 和 `lsof -op 10371` 进行查看，可见内核中存在了两个 ESTABLISHED 状态的连接，并且生成了新的文件描述符 7u
    ```bash
    Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
    tcp        0      0 127.0.0.1:55598         127.0.0.1:9999          ESTABLISHED 11600/nc
    tcp6       0      0 127.0.0.1:9999          127.0.0.1:55598         ESTABLISHED  10371/java
    ```
    ```bash
    COMMAND   PID   USER   FD      TYPE DEVICE     OFFSET     NODE NAME
    java    10371 normal    7u  IPv6 365466        0t0      TCP localhost:distinct->localhost:55598 (ESTABLISHED)
    ```
5. 在客户端窗口使用 <kbd>Ctrl</kbd>+<kbd>c</kbd> 关闭，使用 `netstat -antp` 和 `lsof -op 10371` 进行查看，可见客户端的连接状态变为了 FIN_WAIT2，服务端的连接状态变为 CLOSE_WAIT，同时代表连接的文件描述符 7u 立即消失了。
   过一会后内核中代表客户端的连接也会消失，而代表服务端的连接，会一直存在，并且状态一直为 CLOSE_WAIT
   
    ```bash
    Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
    tcp        0      0 127.0.0.1:55598         127.0.0.1:9999          FIN_WAIT2   -
    tcp6       0      0 127.0.0.1:9999          127.0.0.1:55598         CLOSE_WAIT  10371/java
    ```
6. 关闭服务端，代表服务端的，状态为 CLOSE_WAIT 的连接立即消失

Ctrl+C 后，客户端向服务端发送了 FIN，然后接收到服务端返回的 ACK，但是由于服务端并调用`client.close（)`，所以客户端接收不到第二个 FIN，因此客户端状态变为 FIN_WAIT2(会在 2MSL 后断开），而服务端也接收不到客户端的 ACK，因此会一直为 CLOSE_WAIT 状态。

**服务端在客户端断开连接后，调用 `client.close()`**

1. 取消 MultiplexingSocketIoSingleThread 中的 `client.close()`注释，使用如下命令指定使用 POLL 多路复用器进行启动并追踪系统调用（Java 在 Linux 系统中一般默认选择 EPOLL）
    ```bash
    javac MultiplexingSocketIoSingleThread.java && strace -ff -o epoll java MultiplexingSocketIoSingleThread
    ```
2. 启动后使用 `netstat -antp` 查看系统端口情况，并使用 `lsof -op 11814` 查看当前应用开辟的 FD，可见当前 Java 程序已经监听了 9999 端口，并且生成了一个文件描述符 4u 和 7u(eventpoll fd, epfd)
    ```bash
    Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
    tcp6       0      0 :::9999                 :::*                    LISTEN      11814/java
    ```
    ```bash
    COMMAND   PID   USER   FD      TYPE DEVICE     OFFSET     NODE NAME
    java    11814 normal    4u     IPv6 364652        0t0      TCP *:distinct (LISTEN)
    java    11814 normal    7u  a_inode   0,10        0t0     5366 [eventpoll]
    ```
3. 使用 `nc 127.0.0.1 9999` 创建一个客户端连接到服务端，服务端输出如下信息，说明端口号为 55602 的客户端已经连接
    ```bash
    新客户端连接，IP：/127.0.0.1，port：55602
    ```
4. 再次使用 `netstat -antp` 和 `lsof -op 11814` 进行查看，可见内核中存在了两个 ESTABLISHED 状态的连接，并且生成了新的文件描述符 8u
    ```bash
    Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
    tcp        0      0 127.0.0.1:55602         127.0.0.1:9999          ESTABLISHED 11850/nc
    tcp6       0      0 127.0.0.1:9999          127.0.0.1:55602         ESTABLISHED 11814/java
    ```
    ```bash
    COMMAND   PID   USER   FD      TYPE DEVICE     OFFSET     NODE NAME
    java    11814 normal    8u     IPv6 365060        0t0      TCP localhost:distinct->localhost:55602 (ESTABLISHED)
    ```
5. 在客户端窗口使用 <kbd>Ctrl</kbd>+<kbd>c</kbd> 关闭，使用 `netstat -antp` 和 `lsof -op 11814` 进行查看，可见内核中客户端的连接变为了 TIME_WAIT 状态，服务端变为 LISTEN 状态，而代表客户端和连接的描述符已经消失了。
   过一会后，代表客户端的连接也会消失。
   
    ```bash
    Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
    tcp        0      0 127.0.0.1:55602         127.0.0.1:9999          TIME_WAIT   -                   
    tcp6       0      0 127.0.0.1:9999          127.0.0.1:55602         LISTEN 11814/java
    ```
6. 关闭服务端，代表服务端的，状态为 LISTEN 的连接立即消失

<kbd>Ctrl</kbd>+<kbd>c</kbd> 后，客户端会向服务端发送 FIN，然后接收到服务端的 ACK，因为服务端调用了 `client.close()`，所以服务端会向客户端发送 FIN，然后客户端会返回 ACK，并且会在 2MSL 后断开连接，在此期间会一直为 TIME_WAIT 状态。

**POLL，EPOLL 系统调用查看**

- POLL

  ```bash
  # server = ServerSocketChannel.open(); 创建 ServerSocket，生成一个文件描述符 4
  socket(AF_INET6, SOCK_STREAM, IPPROTO_IP) = 4
  # server.bind(new InetSocketAddress(9999)); 绑定并监听 9999 端口
  bind(4, {sa_family=AF_INET6, sin6_port=htons(9999), inet_pton(AF_INET6, "::", &sin6_addr), sin6_flowinfo=htonl(0), s        in6_scope_id=0}, 28) = 0
  listen(4, 50)
  # server.configureBlocking(Boolean.FALSE); 设置 server 非阻塞
  fcntl(4, F_SETFL, O_RDWR|O_NONBLOCK)    = 0
  # selector = Selector.open(); 创建 POLL，生成监视数组（没有系统调用，没有系统调用，在程序中创建的数组）
  
  # System.out.println("server start......");
  write(1, "server start......", 18)      = 18
  # server.register(selector, SelectionKey.OP_ACCEPT); 将 server 的 FD4 放入监视数组中（无系统调用）
  
  # while (selector.select(50) > 0) 将监视数组中的 FD 作为参数调用内核函数 poll
  poll([{fd=5, events=POLLIN}, {fd=4, events=POLLIN}], 2, 50) = 0 (Timeout)
  # SocketChannel client = ssc.accept(); 有客户端进行连接，生成 socket 四元组，对应 FD7
  accept(4, {sa_family=AF_INET6, sin6_port=htons(55598), inet_pton(AF_INET6, "::ffff:127.0.0.1", &sin6_addr), sin6_flo        winfo=htonl(0), sin6_scope_id=0}, [28]) = 7
  # client.configureBlocking(Boolean.FALSE); 设置客户端非阻塞
  fcntl(7, F_SETFL, O_RDWR|O_NONBLOCK)
  # client.register(selector, SelectionKey.OP_READ, ByteBuffer.allocateDirect(4096)); 将客户端也添加到监视数组中（无系统调用）
  
  # while (selector.select(50) > 0) 循环对数组中的 FD 进行状态查询，返回有状态的 FD
  poll([{fd=5, events=POLLIN}, {fd=4, events=POLLIN}, {fd=7, events=POLLIN}], 3, 50) = 0 (Timeout)
  # read = client.read(buffer); 客户端发送了一些数据
  read(7, "12345\n", 4096)                = 6
  # client.write(buffer); 写回给客户端
  write(7, "12345\n", 6)                  = 6
  # while (selector.select(50) > 0) 循环对数组中的 FD 进行状态查询，返回有状态的 FD
  poll([{fd=5, events=POLLIN}, {fd=4, events=POLLIN}, {fd=7, events=POLLIN}], 3, 50) = 0 (Timeout)
  ```

- EPOLL

  ```bash
  # server = ServerSocketChannel.open(); 创建 ServerSocket，生成一个文件描述符 4
  socket(AF_INET6, SOCK_STREAM, IPPROTO_IP) = 4
  # server.bind(new InetSocketAddress(9999)); 绑定并监听 9999 端口
  bind(4, {sa_family=AF_INET6, sin6_port=htons(9999), inet_pton(AF_INET6, "::", &sin6_addr), sin6_flowinfo=htonl(0), sin      6_scope_id=0}, 28) = 0
  listen(4, 50)
  # server.configureBlocking(Boolean.FALSE); 设置 server 非阻塞
  fcntl(4, F_SETFL, O_RDWR|O_NONBLOCK)    = 0
  # selector = Selector.open(); 创建 EPOLL，生成 EPFD7，生成监视红黑树以及存放有状态 FD 的双向链表
  epoll_create(256)                       = 7
  # System.out.println("server start......");
  write(1, "server start......", 18)      = 18
  # server.register(selector, SelectionKey.OP_ACCEPT); 将 ServerSocket 的 FD4 添加到 EPOLL 的 EPFD7 中
  # 💡 注意输出 server start 和该语句的顺序，Java 代码中输出 server start 在 server.register()之后，而 write()系统调用在此处系统调用在之前，是因为此处有懒加载机制，在调用 select()之前才会将该 FD 添加到监视红黑树中
  epoll_ctl(7, EPOLL_CTL_ADD, 4, {EPOLLIN, {u32=4, u64=140381006069764}}) = 0
  # while (selector.select(50) > 0) 获取所有有状态的 FD
  epoll_wait(7, [], 4096, 50)             = 0
  # SocketChannel client = ssc.accept(); 有客户端进行连接
  accept(4, {sa_family=AF_INET6, sin6_port=htons(55602), inet_pton(AF_INET6, "::ffff:127.0.0.1", &sin6_addr), sin6_flowi      nfo=htonl(0), sin6_scope_id=0}, [28]) = 8
  # client.configureBlocking(Boolean.FALSE); 设置客户端非阻塞
  fcntl(8, F_SETFL, O_RDWR|O_NONBLOCK)    = 0
  # client.register(selector, SelectionKey.OP_READ, ByteBuffer.allocateDirect(4096)); 将客户端添加到监视红黑树中
  epoll_ctl(7, EPOLL_CTL_ADD, 8, {EPOLLIN, {u32=8, u64=8}}) = 0
  # while (selector.select(50) > 0) 获取有状态的 FD
  epoll_wait(7, [], 4096, 50)             = 0
  # client.read(buffer); 客户端发送了一些数据
  read(8, "123\n", 4096)                  = 4
  # client.write(buffer); 将客户端发送的数据返回
  write(8, "123\n", 4)                    = 4
  # while (selector.select(50) > 0) 获取有状态的 FD
  epoll_wait(7, [], 4096, 50)             = 0
  ```

#### 多路复用器代码的演变

1. MultiplexingSocketIoSingleThread：仅包含对 server 的 OP_ACCEPT 和 client 的 OP_READ 事件的监听
2. MultiplexingSocketIoSingleThreadPlus：对比 MultiplexingSocketIoSingleThread，添加了对 client 的 OP_WRITE 事件的监听
3. MultiplexingSocketIoMultiThread：对比 MultiplexingSocketIoSingleThreadPlus，为了解决单线程处理 client 的 read 和 write 会阻塞问题，分别开辟新线程处理 client 的 read 和 write
4. 对比 MultiplexingSocketIoMultiThread，为了解决多线程需要频繁调用 cancel() 方法（是系统调用），考虑到使用多线程，在每个线程中均包含一个 Selector，单个线程的内部使用单线程的方式进行处理（参考 MultiplexingSocketIoSingleThreadPlus），而多个单线程构成多线程的处理方式（分治的思想）。

## Netty

![NettyReactor](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210706123502.png)
