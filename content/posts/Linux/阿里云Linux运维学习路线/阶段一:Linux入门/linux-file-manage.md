---
title: 文件管理
date: '2020-04-11 22:26:45'
tags:
- Linux
---

# 文件管理

## 文件系统结构元素

### 文件系统

- 文件和目录被组织成一个单根倒置树结构
- 文件系统从根目录开始, 用`/`表示
- 根文件系统(rootfs): root filesystem
- 文件名区分大小写(具体来说是由文件系统决定的, 而不是操作系统决定)
- 以`.`开头的文件为隐藏文件
- 路径分隔符`/`
- 文件有两类数据
    - 元数据 : metadata, 就是文件的属性
    - 数据 : data, 就是文件的具体内容
- 文件系统分层结构: LSB(Linux Standard Base)
- FHS: Filesystem Hierarchy Standard
    http://www.pathname.com/fhs/


#### Linux标准目录结构

```bash
/
├── bin
├── boot
├── dev
├── etc
├── home
├── lib
├── lib64
├── media
├── mnt
├── proc
├── root
├── run
├── sbin
├── sys
├── tmp
├── usr
└── var
```

- boot : 引导文件存放目录, 内核文件(vmlinuz), 引导加载器(bootloader, grub)都存放在此目录
    ```bash
    Linux内核 :
    -rwxr-xr-x. 1 root root 8.9M Oct 22 03:34 vmlinuz-5.3.7-301.fc31.x86_64
    ```
- dev : 设备, 例如硬盘, 光盘等, 也包含逻辑上的设备
    ```bash
    硬盘, b: block, 块设备
    brw-rw----. 1 root disk 8, 0 Jan  8 22:22 /dev/sda
    
    光盘
    
    字符设备, c: charactor, 字符设备
    crw-rw-rw-. 1 root root 1, 5 Jan  8 20:02 /dev/zero
    
    黑洞, 会吞噬所有东西
    crw-rw-rw-. 1 root root 1, 3 Jan  8 20:02 /dev/null
    
    用于产生随机数
    crw-rw-rw-. 1 root root 1, 8 Jan  8 20:02 /dev/random
    ```
- etc : 配置文件存放目录
- home/USERNAME : 普通用户家目录
    ```
    上图中home目录下包含三个用户的家目录, alice, bob, eve
    ```
- root : root用户的家目录
- run : 运行中生成的数据
- bin : 所有用户使用的基本命令; 不能关联至独立分区, OS启动即会用到的程序
- sbin : 管理类的基本命令; 不能关联至独立分区, OS启动即会用到的程序
- tmp : 临时数据
- usr : 操作系统大部分的数据
- var : variable data files, 存放可变的内容
    - cache: 应用程序缓存数据目录
    - lib: 应用程序状态信息数据
    - local: 专用于为/usr/local下的应用程序存储可变数据
    - lock: 锁文件
    - log: 日志目录及文件
    - opt: 专用于为/opt下的应用程序存储可变数据
    - run: 运行中的进程相关数据, 通常用于存储进程pid文件
    - spool: 应用程序数据池
    - tmp: 保存系统两次重启之间产生的临时数据

- lib : 启动时程序依赖的基本共享库文件以及内核模块文件(/lib/modules)
- lib64 : 专用于x86_64系统上的辅助共享库文件存放位置

#### Linux其他目录

- proc: process, 用于输出内核与进程信息相关的虚拟文件系统, 不在内存上
- sys: 用于输出当前系统上硬件设备相关信息的虚拟文件系统
    ```
    虚拟机刷新硬盘
    echo '- - -' > /sys/class/scsi_host/hostX/scan X为对应的数字
    ```
- mnt: mount, 做外围设备挂载点
- media: 便携式移动设备挂载点
- selinux: security enhanced Linux, selinux相关的安全策略等信息的存储位置

### Linux上的应用程序的组成部分

- 二进制程序: /bin, /sbin, /usr/bin, /usr/sbin, /usr/local/bin, /usr/local/sbin
- 库文件: /lib, /lib64, /usr/lib, /usr/lib64, /usr/local/lib, /usr/local/lib64
- 配置文件: /etc, /etc/DIRECTORY, /usr/local/etc
- 帮助文件: /usr/share/man, /usr/share/doc, /usr/local/share/man, /usr/local/share/doc

### 文件名规则

- 文件名最长255个字节
- 包括路径在内文件名称最长4095个字节
- 蓝色->目录 绿色->可执行文件 红色->压缩文件 浅蓝色->链接文件 灰色->其他文件, 在`/etc/DIR_COLORS`文件中配置
- 除了斜线和NUL, 所有字符都有效. 但使用特殊字符的目录名和文件不推荐使用, 有些字符需要用引号来引导他们
- 标准Linux文件系统(如ext4), 文件名大小写敏感
    ```bsah
    例如: MAIL, Mail, mail, mAil
    ```

### Linux下的文件类型

- `-` 普通文件
- `d` 目录文件
- `b` 块设备
- `c` 字符设备
- `l` 符号链接文件
- `p` 管道文件pipe
- `s` 套接字文件socket

### 显示当前工作目录

- 每个shell和系统进程都有一个当前的工作目录
- CWD: current work directory
- 显示当前shell CWD的绝对路径
  
    `pwd`: printing working directory
    ```bash
    -P 显示真实物理路径
    -L 显示链接路径(默认)
    ```

**绝对和相对路径**

- 绝对路径
    - 以正斜杠开始
    - 完整的文件的位置路径
    - 可用于任何想指定一个文件名的时候
- 相对路径
    - 不以斜线开始
    - 指定相对于当前工作目录或某目录的位置
    - 可以作为一个简短的形式指定一个文件名
- 基名: basename
    ```bash
    $ basename /etc/sysconfig/network-scripts/
    > network-scripts
    ```
- 目录名: dirname
    ```bash
    $ dirname /etc/sysconfig/network-scripts/
    > /etc/sysconfig
    ```

### 更改目录

- `cd`: change directory, 改变目录
  
    - 使用绝对或相对路径:
    ```bash
    cd /home/wang/
    cd home/wang
    ```
    - 切换至父目录: `cd ..`
    - 切换至当前用户主目录: `cd` 或 `cd ~`
    - 切换至指定用户主目录: `cd ~username`
    - 切换至以前的工作目录: `cd -`
- 选项: `-P`, 切换到软链接的真实目录
- 相关的环境变量:
    - `PWD`: 当前目录路径, `echo $PWD`
    - `OLDPWD`: 上一次目录路径, `echo $OLDPWD`

### 列出目录内容

- 列出当前目录的内容或指定目录
- 用法: `ls [options] [files_or_dirs]`
- 示例:
    - `ls -a` 显示隐藏文件
    - `ls -l` 显示额外的信息
    - `ls -R` 目录递归通过, 列出所有子目录
    - `ls -ld` 目录和符号链接信息, 显示目录本身属性
    - `ls -1` 文件分行显示
    - `ls -S` 按文件从大到小排序
    - `ls -t` 按mtime(modify time)排序
    - `ls -u` 配合-t选项, 显示并按atime(access time)从新到旧排序
    - `ls -U` 按文件创建时间排序
    - `ls -X` 按文件后缀排序
    - `ls -r` 反转顺序
    - `ls --time=mtime/atime/ctime` 显示修改/访问/元数据改变时间
    - `stat file` 同时显示修改, 访问, 元数据改变时间

### 查看文件状态

- `stat`
  
    ```bash
    Usage: stat [OPTION]... FILE...
    Display file or file system status.
    ```
- 文件: 
    - metadata: 元数据, 文件的属性
    - data: 数据, 文件的真实数据
- 三个时间戳:
    - access time: 访问时间, atime, 读取文件内容
    - modify time: 修改时间, mtime， 改变文件内容(数据)
    - change time: 改变时间, ctime, 元数据发生改变

### 文件通配符

- `*` 匹配零个或多个字符
- `?` 匹配任何单个字符
- `~` 当前用户家目录
- `~mage` 用户mage的家目录
- `~+` 当前工作目录
- `~-` 前一个工作目录
- `[0-9]` 匹配数字范围
- `[a-z]` 字母
- `[A-Z]` 字母
- `[abcd]` 匹配列表中的任何一个字符
- `[^abcd]` 匹配列表中的所有字符以外的字符
- 预定义的字符类 `man 7 glob`
    - `[:digit:]` 任意数字, 相当于0-9
    - `[:lower:]` 任意小写字母
    - `[:upper:]` 任意大写字母
    - `[:alpha:]` 任意大小写字母
    - `[:alnum:]` 任意数字或字母
    - `[:blank:]` 水平空白字符
    - `[:space:]` 水平或垂直空白字符
    - `[:punct:]` 标点符号
    - `[:print:]` 可打印字符
    - `[:cntrl:]` 控制(非打印)字符
    - `[:graph:]` 图形字符
    - `[:xdigit:`] 十六进制字符
    - `[[:lower:]]` 代表一小写字母

**练习**
- 显示/var目录下所有以l开头, 以一个小写字母结尾, 且中间出现至少一位数字的文件或目录
    ```bash
    ls -d /var/l*[[:digit:]]*[[:lower:]]
    ```
- 显示/etc目录下以任意一位数字开头, 且以非数字结尾的文件或目录
    ```bash
    ls -d /etc/[0-9]*[^0-9]
    ```
- 显/etc目录下以非字母开头, 后面跟了一个字母及其他任意长度任意字符的文件或目录
    ```bash
    ls -d /etc/[^[:alpha:]][[:alpha:]]*
    ```
- 显示/etc目录下所有以rc开头, 并后面是0-6之间的数字, 其他为任意字符的文件或目录
    ```bash
    ls -d /etc/rc[0-6]*
    ```
- 显示/etc目录下, 所有以.d结的文件或目录
    ```bash
    ls -d /etc/*d
    ```
- 显示/etc目录下, 所有以.con结尾, 且以m, n, r, p开头的文件或目录
    ```bash
    ls -d /etc/[mnrp]*.con
    ```
- 只显示/root下的隐藏文件和目录
    ```bash
    ls -d /root/.*
    ls -daI "[^.]*""
    ```
- **只显示/etc下的非隐藏目录**
    
    ```bash
    ls -d /etc/*/
    ```

## 创建和查看文件

### 创建空文件和刷新时间

- `touch`命令
- 格式: `touch [OPTION] ... FILE ...`
    - `-a` 仅改变atime和ctime
    - `-m` 仅改变mtime和ctime
    - `-t [[CC]YY]MMDDhhmm[.ss]` 指定atime和mtime的时间戳
    - `-c` 如果文件不存在, 则不予创建

**练习**

1. 创建`-a`文件
```bash
touch -- -a 或 touch ./-a
```
2. 创建`~filename`文件
```bash
touch '~filename' 或 touch ./~filename
```

## 复制, 转移和删除文件

## 复制文件和目录cp(copy)

- `cp [OPTION]... [-T] SOURCE DEST`
- `cp [OPTION]... SOURCE... DIRECTORY`
- `cp [OPTION]... -t DIRECTORY SOURCE...`

| 目标<br>/<br>源      | 不存在                                              | 存在且为文件                                                | 存在且为目录                                                 |
| -------------------- | --------------------------------------------------- | ----------------------------------------------------------- | ------------------------------------------------------------ |
| 一个文件             | 新建DEST, 并将SRC中内容填充至DEST中                 | 将SRC中的内容覆盖至DEST中<br>注意数据丢失风险! 建议用-i选项 | 在DEST下新建与原文件同名的文件, 并将SRC中内容填充至新文件中  |
| 多个文件             | 提示错误                                            | 提示错误                                                    | 在DESC下新建与原文件同名的文件, 并将原文件内容复制进新文件中 |
| 目录<br>需使用-r选项 | 创建指定DEST同名目录, 复制SRC目录中所有文件至DEST下 | 提示错误                                                    | 在DEST下新建与原目录同名的目录, 并将SRC中内容复制至新目录中  |

**cp常用选项**

- `-i` 覆盖前提示
- `-n` 不覆盖
- `-r`, -R 递归复制目录及内部的所有内容
- `-a` 归档, 相当于-dR --preserv=all
- `-d` 不复制原文件, 只复制链接名, 相当于--no-dereference --preserv=links
- `-p` 等同--preserv=mode,ownership,timestamp
- `-v --verbose` 打印复制过程
- `-f --force` 强制复制, 如果会覆盖原文件, 不会有提示
- `-u --update` 只复制比目标更新或不存在的文件
- `-b` 目标存在, 覆盖前先备份
- `--backup=numbered` 目标存在, 覆盖前先备份, 加数字后缀
- `--preserv[=ATTR_LIST]`
    - `mode` 权限
    - `ownership` 属主属组
    - `timestamp`
    - `links`
    - `xatt`
    - `context`
    - `all`

特殊文件使用cp会出问题, 例如`cp /dev/sdb ./`, 该命令会将整个硬盘复制过来, 应该使用`cp -a /dev/sdb`命令, 复制所有属性, 8代表设备类型, 16代表该设备的编号
```bash
[root@localhost ~]# ll -a /dev/sdb
brw-rw----. 1 root disk 8, 16 Jan 13 19:58 /dev/sdb
[root@localhost ~]# cp /dev/sdb .
立即Ctrl+C
[root@localhost ~]# ll -a /dev/sdb ./sdb
brw-rw----. 1 root disk     8, 16 Jan 13 19:58 /dev/sdb
-rw-r-----. 1 root root 101433344 Jan 13 21:09 ./sdb
[root@localhost ~]# cp -a /dev/sdb .
[root@localhost ~]# ll -a /dev/sdb ./sdb
brw-rw----. 1 root disk 8, 16 Jan 13 19:58 /dev/sdb
brw-rw----. 1 root disk 8, 16 Jan 13 19:58 ./sdb
```

**练习**
1. 定义别名命令baketc, 每天将/etc/目录下所有文件, 被分到/app独立的子目录下, 并要求子目录格式为backupYYYY-mm-dd, 备份过程可见

   ```bash
   mkdir /app/
   alias baketc='cp -av /etc/ /app/backup`date +%F`'
   baketc
   ```

2. 创建/app/rootdir目录, 并复制/root下所有文件到该目录内, 要求保留原有权限

   ```bash
   mkdir /app/rootdir
   cp -rp /root/ /app/rootdir
   ```

3. 复制file, file.bak

   ```bash
   cp file{,.bak} 相当于 cp file file.bak
   ```

## 移动和重命名文件mv(move)

- `mv [OPTION]... [-T] SOURCE DEST`
- `mv [OPTION]... SOURCE... DIRECTORY`
- `mv [OPTION]... -t DIRECTORY SOURCE...`

**常用选项**

- `-i` 交互式
- `-f` 强制
- `-b` 目标存在, 复制前先备份

**rename**

- `rename [options] <expression> <replacement> <file>...`


把*.conf文件中的conf替换为conf.bak
```bash
rename conf conf.bak *.conf
```


## 删除rm(remove)

- `rm [OPTION]... [FILE]...`

**常用选项**

- `-i` 交互式
- `-f` 强制删除
- `-r` 递归删除
- `--no-preserve-root` 不保留根, 从`/`目录开始删除

**示例**

`rm -rf /`


**练习**

1. 将`rm file`命令修改为`mv file /data`

   ```bash
   alias rm='mv -t /data'
   ```

2. 删除目录下的-foo文件

   ```ba
   rm -- -foo
   或
   rm ./-foo
   ```

3. 已被删除但未释放空间的操作

   在/boot目录下创建一个800M的bigfile文件, `if(input file), of(output file), bs(block store), count`

   ```bash
   dd if=/dev/zero of=/boot/bigfile bs=1M count=800
   ```

   查看已被删除, 但没有释放的文件

   ```bash
   lsof | grep deleted
   ```

   将已存在的文件内存置为0

   ```bash
   > /boot/bigfile
   ```

## 目录操作

- `tree` 显示目录树
    - `-d` 只显示目录
    - `-L level` 指定显示的层级数目
    - `-P` 只显示由指定pattern匹配到的路径

- `mkdir`(make directory) 创建目录
    - `-p parent`, 如果存在不报错, 不存在会创建当前目录及父级目录
    - `-v` 显示详细信息
    - `-m MODE` 创建目录时直接指定权限

- `rmdir`(remove directory) 删除空目录
    - `-p` 递归删除父空目录
    - `-v` 显示详细信息

- `rm -f` 递归删除目录树

**练习**

1. 如何创建/testdir/dir1/x, /testdir/dir1/y, /testdir/dir1/x/a, /testdir/dir1/x/b, /test/dir1/y/a, /testdir/dir1/y/b

   ```bash
   /testdir
   └── dir1
       ├── x
       │   ├── a
       │   └── b
       └── y
           ├── a
           └── b
   
   mkdir -p /testdir/dir1/{x,y}/{a,b}
   ```

2. 如何创建/testdir/dir2/x, /testdir/dir2/y, /testdir/dir2/x/a, /testdir/dir2/x/b

   ```bash
   /testdir
   └── dir2
       ├── x
       │   ├── a
       │   └── b
       └── y
   
   mkdir -p /testdir/dir2/{x/{a,b},y}
   ```

3. 如何创建/testdir/dir3, /testdir/dir4, /testdir/dir5/dir6, /testdir/dir5/dir7

   ```bash
   /testdir
   ├── dir3
   ├── dir4
   └── dir5
       ├── dir6
       └── dir7
   mkdir -p /testdir/dir{3,4,5/dir{6,7}}
   ```

## 索引节点

### 索引节点介绍

- `inode`(index node) : 索引节点表中包含文件系统所有文件列表
- 一个节点(索引节点)是索引节点表中的一个表项, 包含有关文件的信息(元数据), 包括
    - 文件类型, 权限, UID, GID
    - 链接数(指向这个文件名路径名称个数)
    - 该文件的大小和不同的时间戳
    - 指向磁盘上文件的数据块指针
    - 有关文件的其他数据
- 文件和目录
    - 文件引用是一个inode号
    - 人是通过文件名来引用一个文件, 计算机使用inode
    - 一个目录是目录下所有文件的文件名和文件inode号之间的映射
    ![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210607235655.png)

### inode表结构

![inode.png](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210607235656.png)


1. 前12个直接指针, 直接之上内存的数据区域

   > 如Blocks大小为4096B, 则前12个直接指针就可以保存48KB文件

2. 一级指针可存储文件大小计算

   > 假设每个指针占用4个字节, 则一级指针指向的Block可保存4096/4个指针, 即可指向1024个Block, 一级指针可存储文件数据大小为1024*4096=4MB

3. 二级指针可存储文件大小计算

   > 同样假设Blocks大小为4094, 则二级指针可保存的Block指针数量为(4096/4)\*(4096/4)=1014\*1024, 则二级指针可保存的文件数量大小为(1024\*1024)\*4096=4GB

4. 三级指针可存储文件大小计算

   > 以一级, 二级指针计算方法类推, 三级指针可存储的文件数据大小为(1024\*1024\*1024)\*4096=4TB


![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210607235657.png)


#### 示例

查看每个分区最大的节点编号

```bash
[root@localhost ~]# df -i
Filesystem               Inodes IUsed   IFree IUse% Mounted on
...
/dev/vda1                524288   326  523962    1% /boot
...
```

查看每个分区的容量
```bash
[root@localhost ~]# df -h
Filesystem               Size  Used Avail Use% Mounted on
...
/dev/vda1               1014M  136M  879M  14% /boot
...
```
可知/boot目录的最大节点编号为524288, 最大可用内存为879M

此时, 在/boot文件夹中创建一个大文件, 每块1M, 创建900块, 共占用900M>879M
```bash
dd if=/dev/zero of=/boot/bigfile bs=1M count=900
```
错误提示:
```bash
dd: error writing ‘/boot/bigfile’: No space left on device
878+0 records in
877+0 records out
919797760 bytes (920 MB) copied, 1.58615 s, 580 MB/s
```
此时, 节点编号还有剩余, 硬盘内存已被占满
```bash
[root@localhost ~]# df -i
Filesystem               Inodes IUsed   IFree IUse% Mounted on
...
/dev/vda1                  2192   327    1865   15% /boot
...
[root@localhost ~]# df -h
Filesystem               Size  Used Avail Use% Mounted on
...
/dev/vda1               1014M 1014M  840K 100% /boot
...
```
删除刚创建的大文件, 还原到初始环境
```bash
[root@localhost ~]# rm -f /boot/bigfile
```
因为/boot下最多包含524288个节点, 因此创建524288万个文件进行测试(1个文件可能占用多个节点编号)
```bash
[root@localhost ~]# echo /boot/dir/f{1..524288} | xargs touch
```
错误提示
```bash
touch: cannot touch ‘f523963’: No space left on device
touch: cannot touch ‘f523964’: No space left on device
...
touch: cannot touch ‘f524287’: No space left on device
touch: cannot touch ‘f524288’: No space left on device
```
此时, 硬盘内存并未占满, 节点号已经用光了
```bash
[root@localhost boot]# df -h
Filesystem               Size  Used Avail Use% Mounted on
...
/dev/vda1               1014M  411M  604M  41% /boot
...
[root@localhost boot]# df -i
Filesystem               Inodes  IUsed   IFree IUse% Mounted on
...
/dev/vda1                524288 524288       0  100% /boot
...
```
还原环境
```bash
[root@localhost boot]# rm -rf /boot/dir/*
```

**内存占满或节点耗尽的提示均为 :**
```bash
No space left on device
```

### mv, cp与inode的关系

#### mv与inode关系
`mv`一个文件时

1. 链接数递减, 从而释放的inode号可以被重用
2. 把数据块放在空闲列表中
3. 删除目录项
4. 数据实际上不会马上删除, 但当另一个文件使用数据块时将被覆盖


#### cp与inode关系
`cp`一个文件时

1. 分配一个空闲的inode号, 在inode表中生成新条目
2. 在目录中创建一个目录项, 将名称与inode编号关联
3. 拷贝数据, 生成新文件


## 软链接和硬链接

### 硬链接

对一个文件起多个名字

- 创建硬链接会增加额外的记录项以引用文件
- 对应与同一文件系统上一个物理文件
- 每个文件引用相同的inode号
- 创建时链接数递增
- 删除文件时
    - rm命令递减链接计数
    - 文件要存在, 至少有一个链接数
    - 当链接数为0时, 该文件被删除
- 不能跨驱动器或分区创建
- 语法:
    ```bash
    ln filename [linkname]
    ```

### 软链接(符号链接)

- 一个符号链接指向另一个文件
- `ls -l` 显示链接的名称和引用的文件
- 一个符号链接的内容是它引用文件的名称
- 可以对目录创建软链接
- 可以跨分区
- 指向的是另一个文件的路径; 齐大小为指向的路径字符串的长度; 不增加或减少目录文件inode的引用计数;
- 语法
    ```bash
    ln -s filename [linkname]
    ```
    filename一般使用相对路径, 该相对路径一定是相对于linkname指定文件的路径

### 硬链接和软链接的区别

1. 硬链接和原文件是同一个文件, 只是名称不同
2. 硬链接不能跨分区创建, 软链接可以跨分区创建
3. 硬链接会增加链接数, 软链接不会增加链接数
4. 硬链接的inode号与原文件相同, 软链接有自己的inode号
5. 删除原文件, 通过硬链接依旧可以访问文件, 而软链接不可以
6. 硬链接的大小就是原文件的大小, 软链接文件的大小是其链接文件的路径大小
7. 硬链接不支持目录, 软链接支持目录(目录默认链接数为2, 因为其内有一个"."目录, 代表当前目录)
8. 硬链接的相对路径是相对当前所在目录, 软链接的相对路径是相对被链接文件的相对路径


## 确定文件内容

- 文件可以包含多种类型的数据
- 检查文件的类型, 然后确定适当的打开命令或应用程序使用
- `file [options] <filename> ...`
- 常用选项
    - `-b` 列出文件辨识结果时, 不显示文件名称
    - `-f filelist` 列出filelist文本文件中包含的文件名的文件类型
    - `-F` 使用指定分隔符号替换输出文件名后默认的":"分割符
    - `-L` 查看对应软链接对应文件的文件类型
    - `--help` 显示命令在线帮助

每个文件的头部都包含magic number(魔数), 根据魔数可知文件的类型.


## 标准IO及管道

### 标准输入和输出

- 程序: 指令 + 数据
    - 读入数据: Input
    - 输出数据: Output
- 打开的文件都有一个`fd`: file descriptor(文件描述符)
- Linux给程序提供三种I/O设备
    - 标准输入(STDIN): `0`, 默认接受来自键盘的输入
    - 标准输出(STDOUT): `1`, 默认输出到终端窗口
    - 标准错误(STDERR): `2`, 默认输出到终端窗口
- I/O重定向: 改变默认位置

**文件描述符 :** 
> 每个运行中的程序都有一个进程号, 在`/proc/进程号/fd`目录下即可看到该进程的输出输出等信息

### 把输出和错误重定向到文件

- STDOUT和STDERR可以被重定向到文件
    ```bash
    命令 操作符号 文件名
    ```
    - 支持的操作符包括
        - `>`, `1>`, `>>`, `1>>` 把STDOUT重定向到文件
        - `2>`, `2>>` 把STDERR重定向到文件
        - `&>`, `&>>` 把所有输出重定向到文件

- `>` 覆盖重定向标准输出数据流
  
    - 使用`set -C`命令禁止将内容覆盖到已有文件, 但可追加
    - 使用`>| file`强制覆盖
    - 使用`set +C`允许覆盖
    
- `>>` 追加重定向标准输出数据流
- `2>` 覆盖重定向标准错误输出数据流
- `2>>` 追加重定向标准错误输出数据流
- 将标准输出和标准错误输出重定向不同位置
    ```bash
    COMMAND > /path/to/file.out 2> /path/to/error.out
    例如
    $ ls /existfile /noexistfile > file1 2> file2
    ```
- 合并标准输出和错误输出为同一个数据流进行重定向
    - 将标准输出和标准错误输出重定向到file
    
      ```bash
      $ ls /existfile /noexistfile &> file
      或
      $ ls /existfile /noexistfile > file 2>&1
      第二种需要注意顺序, 
      $ ls /existfile /noexistfile 2>$1 > file
      此种情况将标准错误重定向到标准输出后, 会立即将错误信息输出到控制台, 然后将之后的标准输出再输出到文件
      ```
    
    - 将标准输出和错误输出都隐藏
    
      ```bash
      $ ls /existfile /noexistfile &> /dev/null
      $ ls /existfile /noexistfile > /dev/null 2>&1
      $ ls /existfile /noexistfile 2> /dev/null >&2
      ```
- `()` 合并多个程序的STDOUT
  
    ```bash
    (cal 2007;cal 2008) > all.txt
    ```
### 将文件的内容作为标准输入

- `<` 将标准输入重定向
- 某些命令能够接受从文件中导入的STDIN
 - `tr 'a-z' 'A-Z' < /etc/issue`

   > 此命令会把/etc/issue中的小写字符都转换成大写字符

- `<<k` 多行输入重定向, k代表终止词, 一般使用EOF, 即`<<EOF`, End Of File

    - 直到k位置的所有文本都发送给STDIN

    - 有时被称为就地文本(heretext)

      ```bash
      $ mail -s "Please Call" admin@example.com <<END
      > Hi Wang,
      > 
      > Please give me a call when you yet in. We may need
      > to do some maintenance on server1
      > 
      > Details when you're on-site
      > Zhang
      > END
      ```

#### tr命令

- `tr [OPTION]... SET1 [SET2]` 转换和删除字符
- 选项 :
    - `-c`, `-C`, `--complement`: 取字符集的补集
    - `-d`, `--delete`: 删除所有属于第一字符集的字符
    - `-s`, `--squeeze-repeats`: 把连续重复的字符以单独一个字符表示
    - `-t`, `--truncate-set1`: 将第一个字符集对应字符转化为第二字符集对应的字符
- SET的值 :
    - `\NNN`: 八进制
    - `\\`: 反斜线
    - `\a`: audible BEL
    - `\b`: 退格键
    - `\f`: form feed
    - `\n`: 换行符
    - `\r`: 回车符
    - `\t`: 水平的Tab键
    - `\v`: 垂直的Tab键
    - `CHAR1-CHAR2`: ASCII表中从CHAR1到CHAR2的所有字符
    - `[CHAR*]`: in SET2, copies of CHAR until length of SET1
    - `[CHAR*REPEAT]`: REPEAT copies of CHAR, REPEAT octal if starting with 0
    - `[:alnum:]`: 字母和数字
    - `[:alpha:]`: 字母
    - `[:blank:]`: all horizontal whitespace
    - `[:cntrl:]`: 控制(非打印)字符
    - `[:digit:]`: 数字
    - `[:graph:]`: 可打印的图形字符, 不包括空白字符
    - `[:lower:]`: 小写字母
    - `[:print:]`: 可打印的字符, 包括空白字符
    - `[:punct:]`: 标点符号
    - `[:space:]`: 空白字符
    - `[:upper:]`: 大写字母
    - `[:xdigit:]`: 十六进制字符
    - `[=CHAR=]`: all characters which are equivalent to CHAR

### 管道

- 管道(使用符号"|"表示), 用来连接命令
    ```bash
    命令1 | 命令2 | 命令3 | ...
    ```
    - 将命令1的STDOUT发送给命令2的STDIN, 命令2的STDOUT发送给命令3的STDIN
    - STDERR默认不能通过管道转发, 可利用`2>&1`或`|&`实现
    - 最后一个命令会在当前shell进程的子shell进程中执行用来
    - 组合多种工具的功能: `ls | tr 'a-z' 'A-Z'`
- 一些支持管道的命令
    - `less`: 一页一页地查看输入
        ```bash
        ls -l /etc | less
        ```
    - `mail`: 通过电子邮件发送输入
        ```bash
        echo "test email" | mail -s "test" user@example.com
        ```
    - `lpr`: 把输入发送给打印机
        ```bash
        echo "test print" | lpr -P printer_name
        ```
- 管道中的`-`符号
  
    > 示例: 将/home里面的文件打包, 但打包的数据不是记录到文件, 而是传送到stdout, 经过管道后, 将`tar -cvf - /home`传送给后面的`tar -xvf -`, 后面的这个`-`则是取前一个命令的stdout, 因此, 就不需要使用临时file了
    
    ```bash
    $ tar -cvf - /home | tar -xvf -
    ```
- 重定向到多个目标(tee)
    - `命令1 | tee [-a] 文件名 | 命令2`
    
      > 把命令1的STDOUT保存在文件中, 作为命令2的输入
      > `-a` 追加
    
    - 使用: 
        - 保存不通阶段的输出
        - 复杂管道的故障排除
        - 同时查看和记录输出


### 练习

1. 将/etc/issue文件中的内容转换为大写后保存至/tmp/issue.out文件中

   ```bash
   $ tr a-z A-Z < /etc/issue > /tmp/issue.out
   ```

2. 将当前系统登录用户的信息转换为大写后保存至/tmp/who.out文件中

   ```bash
   $ whoami > whoami
   $ tr a-z A-z < whoami > /tmp/who.out
   或
   $ whoami | tr a-z A-Z > /tmp/who.out
   ```

3. 一个linux用户给root发邮件, 要求邮件标题为"help", 邮件正文如下:`Hello, I am 用户名. The system version is here, please help me to check it, thanks! 操作系统版本信息`

   ```bash
   [username@local ~]$ mail -s "help" root <<EOF
   > Hello, I am $USER. The system version is here, please help me to check it, thanks! `cat /etc/centos-release`
   > EOF
   ```

4. 将/root/下文件列表显示成一行, 并且文件名之间用空格隔开

   ```bash
   $ ls > ls.txt
   $ tr -t '\n' ' ' < ls.txt
   或
   $ ls | tr -t '\n' ' '
   ```

5. 计算1+2+3+...+99+100的总和

   ```bash
   $ echo {1..100} > sum.txt 
   $ tr -t ' ' '+' < sum.txt > rep.txt
   $ bc < rep.txt
   或
   $ echo {1..100} | tr -t ' ' '+' | bc
   ```

6. 删除Windows文本文件中的'^M'字符

   ```bash
   $ tr -d ^M < Windows
   ```

7. 处理字符串"xt.,l 1 jr#!&.logmn2 c*/fe 3 uz 4", 只保留其中的数字和空格

   ```bash
   $ echo 'xt.,l 1 jr#!&.logmn2 c*/fe 3 uz 4' | tr -dc '[0-9 ]'
   ```

8. 将PATH变量每个目录显示在独立的一行

   ```bash
   $ echo $PATH > PATH.txt
   $ tr -t : '\n' < PATH.txt
   或
   $ echo $PATH | tr -t : '\n'
   ```

9. 将指定文件中0-9分别替换成a-j

   ```bash
   $ tr -t 0-9 a-j < file
   ```

10. 将文件/etc/cenos-release中每个单词(由字母组成)显示在独立一行, 并无空行

    ```bash
    
    ```

## 文件查找和压缩


### locate命令

- `locate`命令依赖与mlocate数据库进行搜索, 对新创建或刚删除的数据不会立即更新数据库, 因此可能搜索不到或搜索到已删除的数据, 可以使用`updatedb`命令来手动更新mlocate数据库. 
- locate命令搜索很快, 因此适合搜索磁盘上稳定不变的数据.
- 语法: `locate [OPTIONS]... KEYWORD`
- 选项
    - `-i`: 不区分大小写的搜索
    - `-n N`: 只列举前N个匹配项目
    - `-r`: 使用正则表达式

### find命令

- 实时查找工具, 通过遍历指定路径完成文件查找
- 工作特点
    - 查找速度略慢
    - 精确查找
    - 实时查找
    - 可能只搜索用户具备读取和执行权限的目录
- 语法: `find [OPTION]... [查找路径] [查找条件] [处理动作]`
    - 查找路径: 指定具体目标路径; 默认为当前目录
    - 查找条件: 指定的查找标准, 可以文件名, 大小, 类型, 权限等标准进行; 默认为找出指定路径下的所有文件
    - 处理动作: 对符合条件的文件做操作, 默认输出至屏幕
- 查找条件
    - 指定搜索层级
        - `maxdepth level`: 最大搜索目录深度, 指定目录为第1级
        - `mindepth level`: 最小搜索目录深度
    - 先处理目录内的文件, 再处理目录
        - `depth`
    - 根据文件名和inode查找:
        - `-name "文件名称"`: 支持使用通配符, `*`, `?`, `[]`, `[^]`
        - `-iname "文件名称"`: 不区分字母大小写
        - `-inum n`: 按inode号查找
        - `-samefile name`: 相同inode号的文件
        - `-links n`: 链接数为n的文件
        - `-regex "PATTERN"`: 以PATTERN匹配整个文件路径, 而非文件名称
    - 根据属主, 属组查找
        - `-user USERNAME`: 查找属主为指定用户(UID)的文件
        - `-group GRPNAME`: 查找属组为指定组(GID)的文件
        - `-uid UserID`: 查找属主为指定的UID号的文件
        - `-gid GroupID`: 查找属组为指定的GID号的文件
        - `-nouser`: 查找没有属主的文件
        - `-nogroup`: 查找没有属组的文件
    - 根据文件类型查找
        - `-type TYPE`
            - `f`: 普通文件
            - `d`: 目录文件
            - `l`: 符号链接文件
            - `s`: 套接字文件
            - `b`: 块设备文件
            - `c`: 字符设备文件
            - `p`: 管道文件
    - 根据文件大小来查找:
        - `-size [+|-]#UNIT`: 常用单位: k, M, G, c(byte)
            - `#UNIT`: (#-1, #), 如6k表示(5k, 6k]
            - `-#UNIT`: [0, #-1], 如-6k表示[0, 5k]
            - `+#UNIX`: (#, ∞), 如+6k表示(6k, ∞)
    - 空文件或目录
        - `-empty`: `find /app -type d -empty`
    - 组合条件
        - `-a`: 与
        - `-o`: 或
        - `-not`, `!`: 非
    - 德·摩根定律
        - (非A)或(非B) = 非(A且B)
        - (非A)且(非B) = 非(A或B)
          示例:
        
          > !A -o !B = !(A -a B)
          > !A -a !B = !(A -o B)
- 示例
    - `find -name sonw.png`
    - `find -iname snow.png`
    - `find / -name "*.txt"`
    - `find /var -name "*log"`
    - `find -user joe -group joe`
    - `find -user joe -not -group joe`
    - `find -user joe -o -user jane`
    - `find -not \(-user joe -o -user jane\)`
    - `find / -user joe -o -uid 500`
    - 找出/tml目录下, 属主不是root, 且文件名不以f开头的文件
        ```bash
        find /tmp \(-not -user root -a -not -name 'f*'\) -ls
        find /tmp -not \(-user root -o -name 'f*'\) -ls
        ```
    - 排除目录:
        - 查找/etc下, 除了/etc/sane.d目录的其他所有.conf后缀的文件
        
          ```bash
          find /etc -path 'etc/sane.d' -a -prune -o -name '*.conf'
          ```
        
        - 查找/etc下, 除了/etc/sane.d和/etc/fonts两个目录的所有.conf后缀的文件
        
          ```bash
          find /etc \(-path 'etc/sane.d' -o -path 'etc/fonds'\) -a -prune -o -name '*.conf'
          ```
