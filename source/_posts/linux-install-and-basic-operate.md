---
title: Linux系统安装与基本操作
date: 2020-04-13 22:22:57
updated: 2020-04-13 22:22:57
tags:
- Linux
categories:
- [Linux, 阿里云Linux运维学习路线, 阶段一:Linux入门]
---

# Linux系统安装与基本操作

## CentOS安装

### 分区介绍

**dev :** device, 这个目录中包含了所有Linux系统中使用的外部设备, 比如硬盘, U盘等.

多个外部设备按如下方式命名:

/dev/sda, /dev/sdb, ... /dev/sdz, /dev/sdaa ...


**基于MBR的分区类型 :**

- 主分区 : 单块硬盘中最多分出4个主分区, 其中只有一个是活动状态, 用来引导计算机启动. 命名1-4
- 扩展分区 : 单块硬盘上最多1个, 用来划分更小的分区(即逻辑分区). 扩展分区+主分区<=4, 命名1-4
- 逻辑分区 : 命名5-

**挂载 :** 给分区分配一个目录名(这个目录名叫mount point), 就叫挂载mount

**分区规划 :**
- /     : 相当于C盘
- /boot : 存放引导数据, 例如linux kernel等, 利于修复. 1G
- swap  : 交换分区, 建议是物理内存的2倍. 物理内存>=8G可以不设置或设置为1-2G, 随意.
- /data : 自定义分区, 可选
- ...   : 其他挂载点


### 文件验证

sha256sum /dev/sr0 : 计算下载文件的sha256码, 可用于验证文件是否损坏

### 安装过程中的快捷键

可以使用<kbd>Ctrl</kbd>+<kbd>Alt</kbd>+<kbd>F1~F6</kbd>来查看各种安装信息等.

可以使用`cat /proc/meminfo`查看内存等信息, 使用<kbd>Shift</kbd>+<kbd>Page Up</kbd>/<kbd>Page Down</kbd>翻页

可以使用`cat /proc/partitions`查看分区信息

`rpm -qa | wc -l`查看安装了多少个包

## Linux基本操作


- `init 3` 切换到纯字符界面
- `init 5` 切换到图形界面, 需要登陆

字符界面和图形界面称为模式, 可通过`runlevel`查看系统的运行模式

`startx` 也可以切换到图形界面, 并且不需要登陆, 该命令只是代表用户启动了一个应用, 因此不需要登陆, 并且不会修改运行模式.

init的其他命令 :

- `init 6` 相当于reboot
- `init 0` 相当于poweroff(关机并断电), halt(关机不断电)


<kbd>Ctrl</kbd>+<kbd>Alt</kbd>+<kbd>F1</kbd> 切换回图形界面

<kbd>Ctrl</kbd>+<kbd>Alt</kbd>+<kbd>FX</kbd>或`chvt X` 临时切换到字符界面, X=[2, 6]

`tty` 查看当前终端号

`whoami` 查看当前系统用户

`nmcli connection modify` 网卡相关

`cat /etc/centos-release`或`lsb_release` 查看操作系统版本

`uname -r` 查看Linux内核版本

`lscpu` 查看CPU配置

`free -h`或`cat /proc/meminfo`查看内存信息, 使用<kbd>Shift</kbd>+<kbd>Page Up</kbd>/<kbd>Page Down</kbd>翻页

`lsblk` 查看硬盘信息

`mii-tool netcardName` 查看指定(netcardName)网卡信息

`who am i` 查看的那个用户和终端以及登陆时间和IP

`who` 查看当前已经登陆的账户信息

`cat /etc/shells` 查看系统支持的shell类型

`/bin/sh` 根据shell路径切换shell

`echo $SHELL` 查看当前系统使用的shell类型

`exit`或`logout`或<kbd>Ctrl</kbd>+<kbd>D</kbd> 退出登陆

`clear`或<kbd>Ctrl</kbd>+<kbd>L</kbd>清屏

`hostname` 查看主机名

`/etc/motd` 修改每日提示语句(message of the day)


### 用户登陆

**设置开机自动登陆 :**

修改/etc/gdm/custom.conf, 添加:

```properties
[daemon]
# 开启自动登陆
AutomaticLoginEnable=true
# 自动登陆root用户
AutomaticLogin=root
```

#### root用户

- 一个特殊的管理账户
- 也被称为超级用户
- root已接近完整的系统控制
- 对系统损害几乎有无限的能力
- 除非必要, 不要登陆为root

#### 普通(非特权)用户

- 权限有限
- 造成损害的能力比较有限

使用`id -u`根据uid来查看账号类型, 0:管理员, 1:普通用户

### 终端(Terminal)

#### 设备终端

键盘鼠标显示器

#### 物理终端(/dev/console)

控制台console

#### 虚拟终端(tty: teletyperwriters, /dev/tty# #为[1-6])

tty可有n个, <kbd>Ctrl</kbd>+<kbd>Alt</kbd>+<kbd>F[1-6]</kbd>

#### 图形终端(/dev/tty7) startx, xwindows

- CentOS 6: <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>F7</kbd>
- CentOS 7: 在哪个终端启动, 即位于哪个虚拟终端

#### 串行终端(/dev/ttyS#)

ttyS

#### 伪终端(pty: pseudo-tty, /dev/pts/#)

pty, SSH远程连接

#### 查看当前的终端设备

```bash
tty
```

### 交互式接口

交互式接口: 启动终端后, 在终端设备附加一个交互式应用程序

#### GUI: Graphic User Interface

X protocol, window manager, desktop

- Desktop :
    - GNOME(C, 图形库gtk)
    - KDE(C++, 图形库qt)
    - XFCE(轻量级桌面)

#### CLI: Command Line Interface

shell程序(命令解释器): sh(b类型嗯ourn 史蒂夫·伯恩), csh, tcsh, ksh(korn), bash(bourn again shell), zsh


### 什么是shell

- shell是Linux系统的用户界面, 提供了用户与内核进行交互操作的一种接口.

- shell也被称为Linux的命令解释器(command interpreter)

- shell是一种高级程序设计语言

### bash shell

- GNU Bourne-Again Shell(bash)是GNU计划中重要的工具软件之一, 目前也是Linux标准的shell, 与sh兼容

- CentOS默认使用

- 显示当前使用的shell

    `echo ${SHELL}`

- 显示当前系统使用的所有shell

    `cat /etc/shells`

### 命令提示符

- 命令提示符号: prompt

    ```bash
    [root@localhost ~]#
        # 管理员
        $ 普通用户
    ```
    
- 显示提示符格式

    ```bash
    [root@localhost ~]# echo $PS1
    ```
    
- 修改提示符格式
    - 设置颜色:
        ```bash
        \[\e[F;Bm\]
        ```
        示例: 
        ```bash
        白底黑字
        \[\e[30;47m\]
        ```
        - 背景色和特殊背景可以同时使用, 特殊背景可以同时使用多个, 使用格式: 
            ```bash
            \[\e[F;B;Bm\]
            ```
            示例:
            ```bash
            白底黑字高亮
            \[\e[30;47;1m\] 或 \[\e[30;1;47m\] 
            白底黑字高亮闪烁
            \[\e[30;47;5;1m\] 或 \[\e[30;1;47;5m\] 
            ```
        - 颜色说明
        
            | 字体颜色(F) | 背景色(B) | 特殊背景(B)    |
            | ----------- | --------- | -------------- |
            | 30 黑       | 40 黑     | 0 关闭所有颜色 |
            | 31 红       | 41 深红   | 1 高亮         |
            | 32 绿       | 42 绿     | 2 低亮         |
            | 33 黄       | 43 黄     | 3 斜体         |
            | 34 蓝       | 44 蓝     | 4 下划线       |
            | 35 紫       | 45 紫     | 5 闪烁         |
            | 36 深绿     | 46 深绿   | 6 闪烁         |
            | 37 白       | 47 白     | 7 反显         |
            | null        | null      | 8 隐藏         |
            | null        | null      | 9 删除线       |
            
            可将其放到任意提示符前面, 来对他后面的命令提示符颜色进行修改
        
    - 命令提示符符号说明
    ```bash
    PS1="\[\e[1;5;41;33m\][\u@\h \W]\\$\[\e[0m\]"
    ```
    
    | 符号      | 说明                                                 |
    | --------- | ---------------------------------------------------- |
    | `\e[F;Bm` | 设置颜色                                             |
    | `\u`        | 当前用户名                                           |
    | `\H`        | 主机名全称                                           |
    | `\h`        | 主机名简称                                           |
    | `\W`        | 当前工作目录基名                                     |
    | `\w`        | 当前工作目录全名                                     |
    | `\d`        | 当前日期, 格式: weekday month date, 例如: Fri Apr 03 |
    | `\t`        | 24小时格式时间, HH:mm:ss                             |
    | `\T`        | 12小时格式时间, HH:mm:ss                             |
    | `\A`        | 24小时格式时间, HH:mm                                |
    | `\v`        | BASH版本信息                                         |
    | `\!`       | 命令历史数                                           |
    | `\#`       | 开机后命令历史数                                     |
    | `\\$`     | 用户身份提示字符                                     |

通过命令行修改, 重新登陆后会失效, 可通过添加文件的方式持久化修改:

```bash
vi /etc/profile.d/xxx.sh
添加
PS1="\[\e[1;33m\][\u@\h \W]\\$\[\e[0m\]"
```

### 执行命令

**输入命令后回车 :**

提醒shell程序找到键入命令所对应的可执行程序或代码, 并由其分析后提交给内核分配资源, 将其运行起来. 

**在shell中可执行的命令有两类**

- 内部命令: 由shell自带的, 而且通过某命令形式提供
    - `help` 内部命令列表
    - `enable` 内部命令列表
    - `enable cmd` 启用内部命令
    - `enable -n cmd` 禁用内部命令
    - `enable -n` 查看所有禁用的内部命令

- 外部命令: 在文件系统路径下有对应的可执行程序文件
    - 查看路径: `which -a | --skip-alis`或 `whereis`

**区别指定的命令是内部或外部命令**

```bash
type COMMAND
```

```bash
# 查看某个命令的列表
type -a COMMAND
```

当输入一个命令后, 先去寻找内部命令,  如果没有再去找外部命令

### 执行外部命令

**Hash缓存表 :** 

系统初始hash表为空, 当外部命令执行时, 默认会从PATH路径下寻找该命令, 找到后会将这条命令的路径记录到hash表中, 当再次使用该命令时, shell解释器首先会查看hash表, 存在将执行之, 如果不存在, 将会去PATH路径下寻找, 利用hash缓存表可大大提高命令的调用速率

**hash常见用法 :**

- `hash` 显示hash缓存
- `hash -l` 显示hash缓存, 可作为输入使用
- `hash -p path name` 将命令全路径path起别名为name
- `hash -t name` 打印缓存中name的路径
- `hash -d name` 清除name缓存
- `hash -r` 清除缓存

shell解析器查找命令优先级: **alias>内部命令>hash表>$PATH**


### 命令别名

**显示当前shell进程所有可用的别名 :**

```bash
alias
```

**定义别名NAME, 其相当于执行命令VALUE :**
```bash
alias NAME='VALUE'
```

**在命令行中定义的别名, 仅对当前shell进程有效**

**如果想要永久有效, 要定义在配置文件中 :**
- 仅对当前用户有效: ~/.bashrc
- 对所有用户有效: /etc/bashrc

**编辑配置给出的新配置不会立即生效, bash进程重新读取配置文件 ：**
- source /path/to/config_file
- . /path/to/config_cile

**撤销别名 :**
```bash
unalias [-a] NAME [name ...]
-a 取消所有别名
```

**如果别名同原命令同名, 如果要执行原命令, 可使用 :**

```bash
\ALIASNAME
"ALIASNAME"
'ALIASNAME'
command ALIASNAME
# 只适合外部命令
/path/command
```

### 命令格式

**格式 :** `COMMAND [OPTIONS...] [ARGUMENTS...]`

- OPTIONS: 用于启动或关闭命令的某个或某些功能
    - 短选项: `-c` 例如: `-l`, `-h`
    - 长选项: `--word` 例如: `--all`, `--human-readable`
- ARGUMENTS: 命令的作用对象, 比如文件名, 用户名等

**注意 :**
- 多个选项以及多个参数命令之间使用空白字符分隔
- 取消和结束命令执行: <kbd>Ctrl</kbd>+<kbd>c</kbd>, <kbd>Ctrl</kbd>+<kbd>d</kbd>
- 多个命令可以用`;`符号分开
- 一个命令可以用`\`分成多行

### 日期和时间

**Linux的两种时钟 :**

- 系统时钟: 由Linux内核通过CPU的工作频率进行的
- 硬件时钟: 主板

**相关命令 :**
- `date`: 显示和设置系统时间
    - `date +%s`
    - `date -d @1509536033`
    - `date MMDDHHmmYYYY.ss`
- `hwclock`, `clock`: 显示硬件时钟
    - `-s, --hctosys` 以硬件时钟为准, 校正系统时钟
    - `-w, --systohc` 以系统时钟为准, 校正硬件时钟

**时区 :**
/etc/localtime

```bash
[root@localhost ~]# ll /etc/localtime 
lrwxrwxrwx. 1 root root 35 Dec 30 23:45 /etc/localtime -> ../usr/share/zoneinfo/Asia/Shanghai
```

**调整时区**

```bash
# 查看所有时区
timedatectl list-timezones
# 修改时区
timedatectl set-timezone Asia/Shanghai

或
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```

**与网络时间同步**

1. 安装ntp

   ```bash
   # yum install ntp
   ```

2. 停止ntpd服务

   ```bash
   # systemctl stop ntpd
   ```

3. 设置同步的网站

   ```bash
   # ntpdate ntp.api.bz
   ```

4. 启动ntpd服务

   ```bash
   # systemctl start ntpd
   ```

5. 同步硬件时钟与系统时钟相同

   ```bash
   # hwclock -w
   ```

6. 设置ntpd服务开机启动

   ```bash
   # systemctl enable ntpd
   ```

7. 查看当前时间信息

   ```bash
   # timedatectl
   ```

**显示日历 :**
```bash
cal
cal -y
cal 2019
cal 9 1752
```
