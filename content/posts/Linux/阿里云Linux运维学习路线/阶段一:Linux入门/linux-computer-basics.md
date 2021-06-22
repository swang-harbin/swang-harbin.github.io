---
title: 计算机基础
date: '2020-01-04 21:56:18'
tags:
- Linux
---

# 计算机基础

计算机系统由硬件(Hardware)系统和软件(Software)系统两大部分组成

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210603220214.png)

## 计算机硬件

计算机(Computer): 俗称电脑, 是一种能**接收**和**存储**信息, 并按照存储在其内部的程序对海量数据进行自动, 高速的**处理**, 然后把处理结果**输出**的现代化智能电子设备

### 发展历史

- 第一代计算机(1946-1957)   电子管时代
- 第二代计算机(1958-1964)   晶体管时代
- 第三代计算机(1965-1970)   集成电路时代
- 第四代计算机(1971以后)    大规模集成电路时代

### 世界上第一台计算机ENIAC

1946年, 世界上第一台计算机ENIAC(electronic numerical integerator and calculator)在美国宾州大学诞生, 是美国奥伯丁武器试验场为了满足计算弹道需要而研制成的. 使用了17468只电子管, 占地179平方米, 重达30吨, 耗电174千瓦, 耗资40多万美元. 每秒可进行5000次加法或减法运算.

### 冯诺依曼体系

1946年数学家冯诺依曼提出, 计算机硬件由运算器, 控制器, 存储器, 输入设备和输出设备五大部分组成

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210603220418.png)

主存储器: 运行内存, 所有被计算机处理的数据都需要放在主存储器
辅助存储器: 硬盘, 用来持久化存储数据
运算器: 进行加减乘除与或非运算
控制器: 协调(指挥)各种设备间通讯


### 进制

Linux中自带bc计算器
```bash
# 进入计算器
$ bc
# 输出2进制, o(output)
obase=2
12
1100
# 退出计算器
quit
# 设置输入二进制
ibase=2
1100
12
```

### 摩尔定律

由英特尔(Intel)创始人之一戈登摩尔于1965年提出:

当价格不变时, 集成电路上可容纳的元器件数目, 约每隔18-24个月便会增加一倍, 性能也将提升一倍.

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210603220445.png)

### 按规模分类计算机

[超级计算机排行](http://www.top500.org)

- 巨型计算机: 应用于国防尖端技术和现代科学计算机中. 巨型计算机的运算速度可达每秒百万亿次以上, "天河一号"为我国首台千万亿次级的计算机.
- 大型计算机: 具有较高的运算速度, 每秒可以执行几千万条指令, 而且有较大的存储空间. 往往用与科学计算, 数据处理或作为网络服务器使用, 如IBM z13 mainframe
- 小型计算机: 规模较小, 结构简单, 运行环境要求较低, 一般应用于工业自动控制, 测量仪器, 医疗设备中的数据采集等方面.
- 微型计算机: 中央处理器(CPU)采用微处理芯片, 体积小巧轻便, 官方用于商业, 服务业, 工厂的自动控制, 办公自动化以及大众化的信息处理

### 服务器

服务器Server是计算机的一种, 是网络中客户端计算机提供各种服务的高性能的计算机, 服务器在网络操作系统的控制下, 将与其连接的硬盘, 磁带, 打印机及昂贵的专用通讯设备提供给网络上的客户站点共享, 也能为网络用户提供集中计算, 信息发布及数据管理等服务

阿里提出的去IOE: IBM(小型机), Oracle(数据库), EMC(存储)

#### 服务器按应用功能可分为:

- Web服务器: apache, nginx
- 数据库服务器: mysql, oracle
- 文件服务器: NFS, SAMBA, FTP
- 中间件应用服务器: Tomcat
- 日志服务器: RSYSLOG
- 监控服务器: ZABBIX
- 程序版本控制服务器: GIT, SVN
- 虚拟机服务器: KVM, Docker, K8S
- 邮件服务器: SendMail
- 打印服务器: 
- 域控制服务器: Domain Controller(DC)
- 多媒体服务器:
- 通讯服务器: 
- ERP服务器等

#### 按外形分类:

##### 塔式Tower服务器

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210603220516.png)

##### 刀片式Blade服务器

![clipboard](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210603220548.png)

##### 机架式Rack服务器

![clipboard](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210603220619.png)

### 服务器硬件组成

![clipboard](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210603220640.png)

### 服务器配置示例

![clipboard](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210603220656.png)

CPU: 家用I系列, 服务器Xeon至强系列

### 服务器硬件

#### CPU

CPU是Central Processing Unit的缩写, 即中央处理器. 由控制器和运算器组成, 是整个计算机系统中最重要的部分

**服务器CPU公司 :**

- Intel
    - Xeon    智强
    - Itanium 安腾
    
    ![clipboard](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210603220719.png)
    
- AMD
    - Althlon MP
    
    ![clipboard](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210603220735.png)
    
- IBM
    - Power
    
    ![clipboard](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210603220753.png)

**CPU性能指标 :**

linux使用`lscpu`查看cpu信息

-主频: 主频是CPU的始终频率(CPU Clock Speed), 是CPU运算时的工作的频率(1秒内发生的同步脉冲数)的简称. 单位是Hz. 一般来说, 主频越高, CPU的速度越快, 由于内部结构不同, 并非所有的时钟频率相同的CPU的性能都一样
- 外频: 系统总线的工作频率, CPU与外部(主板芯片组)交换数据, 指令的工作时钟频率
- 倍频: 倍频指CPU外频与主频相差的倍数
- 三者关系是: 主频 = 外频 × 倍频
- 高速缓存(cache): 高速交换的存储器. CPU缓存分为一级, 二级, 三级缓存, 即L1, L2, L3. 可将内存中的部分数据缓存到cache中, 当CPU用到这部分数据时, 可从cache中快速读取, 不用去读取内存中的数据(CPU的速度比内存快得多)
- 内存总线速度(Memory-Bus Speed): 一般等于CPU的外频, 指CPU与二级缓存(L2)和内存之间的通信速度
- 地址总线宽度: 决定了CPU可以访问的物理地址空间. 32位/64位处理器.

**CPU类型 :** 

- x86
- x64(CISC)
- ARM(Acorn RISC Machine)
- m6800, m68k(moto)
- Power(IBM)
- Powerpc(apple, ibm, moto)
- Ultrasparc(Sun)
- Alpha(HP)
- 安腾(compaq)

**服务器按CPU分类 :**

- 非x86服务器: 
  
    > 使用RISC(精简指令集)或EPIC(并行指令代码)处理器, 并且主要采用UNIX和其他专用操作系统的服务器, 指令系统相对简单, 他只要求硬件执行很有限且最常用的那部分指令, CPU主要有Compaq的Alpha, HP的PA_RISC, IBM的Power PC, MIPS的MIPS和SUN的Sparc, Intel研发的EPIC安腾处理器等. 这种服务器价格昂贵, 体系封闭, 但是稳定性好, 性能强, 主要用在金融, 电信等大型企业的核心系统.

- x86服务器: 
  
    > 又称CISC(复杂指令集)架构服务器, 即通常所讲的PC服务器, 他是基于PC机体系结构, 使用Intel或其他兼容x86指令集的处理器芯片的服务器. 目前主要为intl的Xeon E3, E5, E7系列, 价格相对便宜, 兼容性好, 稳定性较差, 安全性不算太高.

#### 主板(mainboard)

主板(mainboard), 系统板(systemboard)或母板(motherboard), 安装在机箱内, 是计算机最基本的也是最后总要的部件之一

主板一般为矩形电路板, 上面安装了组成计算机的主要电路系统, 一般有BIOS芯片, I/O控制芯片, 键盘和面板控制开关接口, 指示灯插接件, 扩展插槽, 主板及插卡的直流电源供电接插件等元件

![clipboard](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210603220819.png)

#### 内存和外存

**内存 :** 是介于CPU和外部存储之间, 是CPU对外部存储中程序与数据进行高速运算时存放程序指令, 数据和中间结果的临时场所, 它的物理实质就是一组具备数据输入输出和数据存储功能的高速集成电路

内存是CPU能直接寻址的存储空间, 由半导体器件制成. 内存的特点是存取速度快

**外存:** 硬盘, U盘, 软盘, 光盘

**内存和外存的区别 :**
- 内存断电后数据丢失
- 外存断电后数据可以保存

**容量:** 即该内存的存储容量, 单位一般为"MB"或"GB"

**内存带宽 :**

- 内存带宽是指内存与北桥芯片之间的数据传输率
- 单通道内存节制器一般都是64-bit的, 8个二进制位相当于一字节, 换算成字节是64/8=8, 再乘以内存的运行频率, 如果是DDR内存就要再乘以2
- 计算公式: 
  
    > 内存带宽 = 内存总线频率 × 数据总线位数/8

- 示例: DDR内存带宽计算
    ```
    DDR2 667, 运行频率为333MHz, 带宽为
    333×2×64/8=5400MB/s=5.4GB/s
    DDR2 800, 运行频率为600MHz, 带宽为
    400×2×64/8=6400MB/s=6.4GB/s
    ```

**保证内存中数据不丢失的技术 :**

- 在线备用内存技术
    - 当主内存或者是扩展内存中的内存出现多位错误或者物理内存故障时, 服务器仍继续运行
    - 由备用内存接替出现故障内存的工作
    - 备用的内存区域必须比其他区域的内存容量大或相同
    
- 内存镜像
    - 镜像为系统在出现多位错或内存物理故障时提供数据保护功能, 以保证呢个系统仍能正常运行
    - 数据同时写入两个镜像的内存区域
    - 从一个区域进行数据的读取
    
    ![clipboard](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210603220843.png)

#### 硬盘

##### 机械硬盘

###### 结构:

存储介质(Medis) : 盘片
> 盘片的基板是金属或玻璃材质制成, 为达到高密度高稳定的质量, 基板要求表面光滑平整, 不可有任何瑕疵.

读与写(Read Write Head) : 磁头
> 磁头是硬盘读取数据的关键部件, 它的主要作用就是将存储在硬盘盘片上的磁信息转化为电信号向外传输

马达(Spindle Motor&Voice Coil Motor) : 
> 马达上装有一至多片盘片, 以7200, 10000, 15000RPM等定速旋转, 为保持其平衡不可抖动, 所以其质量要求严谨, 不产生高温噪音

![clipboard](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210603220913.png)

###### 基本参数

- 容量: 
  
    > 容量是硬盘最主要的参数. 单位有MB, GB, TB
- 转速: 
  
    > 转速是指硬盘盘片每分钟转动的圈数, 单位为RPM. 现在硬盘转速已经达到10000rpm, 15000rpm
- 传输速率
  
    > 传输速率(Data Transfer Rate). 指硬盘速写数据的速度, 单位为兆字节每秒(MB/s)
- 缓存
  
    > 硬盘缓存的目的是为了解决系统前后级读写速度不匹配的问题, 以提高硬盘的读写速度

###### 接口类型
- IDE接口 : 硬盘接口规范, 采用ATA技术规范
- SCSI接口: 应用于小型机上的高速数据传输技术
- SATA接口: Serial ATA, 提高传输速率, 支持热插拔
- SAS接口: Serial Attached SCSI, 兼容SATA

目前主流的硬盘接口为SATA(家用)和SAS(服务器用)接口


###### 服务器的性能短板
木桶效应, 如果CPU每秒处理1000个服务请求的能力, 各种总线的负载能力达到500个, 但网卡只能接受200个请求, 而硬盘只能承担150个的话, 那么这台服务器的处理能力只能是150个请求/秒, 有85%的处理器计算能力浪费了.

在计算机系统中, 硬盘的读写速率已经成为影像系统性能进一步提高的瓶颈, 因此可使用固态硬盘提升.

##### 固态硬盘(SSD)

SSD(Solid State Disk): 泛指使用NAND Flash组成的固态硬盘. 其特别之处在于没有机械结构, 以区块写入和抹除的方式作读写的功能, 因此在读写的效率上, 非常依赖于读写技术上的设计, SSD读写存取速度快, 性能稳定, 防震性高, 发热低, 耐低温, 电耗低, 无噪音. 因为没有机械部分, 所以长时间使用出现故障几率也比较小. 缺点: 价格高, 容量小, 在普通硬盘前毫无性价比优势

![clipboard](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210603220932.png)

#### 阵列卡(Raid)

![clipboard](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210603220951.png)

用来实现RAID的建立和重建, 检测和修复多位错误, 错误磁盘自动检测等功能. RAID芯片使CPU的资源得以释放

**RAID卡作用 :**
- 阵列卡把若干硬盘驱动器按照一定要求组成一个整体, 由阵列控制器管理的系统.
- 阵列卡用来提高磁盘子系统的性能及可靠性

**阵列卡参数 :**
- 支持的RAID级别
- 阵列卡缓存
- 电池保护


#### 电源和风扇

![clipboard](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210603221012.png)

- 支持服务器的电力负载
- 支持冗余, 防止电源故障
    - 故障预警和防止
    - 故障之前的预防性维护
    - 保证服务器持续运行
- 电源子系统包括
    - 智能电源和风扇
- 冗余电源和风扇

#### 显卡

服务器都在主板上集成了显卡, 但是显存容量不高, 一般为16M或32M.

GPU : Graphic Processing Unit, 即"图形处理器"

![clipboard](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210603221037.png)

#### 网卡

服务器都在主板上集成了网卡, 传输速率为1Gbps, 即千兆网卡, 特殊应用需要高端网卡, 如光纤网卡, Infiniband网卡等, 传输速率能达到10Gbps, 20Gbps, 即万兆网卡.

1Gbps : 1Gbit/second, 1Gbit/8 = 512MB, 512MB/s
![clipboard](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210603221056.png)

#### 热插拔技术

称为热交换技术(Hot Swap), 允许在不关机的状态下更换故障热插拔设备

常见的热插拔设备: 硬盘, 电源, PCI设备, 风扇等

热插拔技术与RAID技术配合起来, 可以使服务器在不关机的状态下恢复故障硬盘上的数据, 同时并不影响网络用户对数据的使用.

![clipboard](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210603221120.png)

#### 机柜

机柜式服务器-服务器放置在机柜中

通常使用的是42U(约2米高)机柜(1U=44.45mm)

外观尺寸一般为款600*深1000*高2000(mm)

大部分网络设备(交换机, 路由器等)深600mm即可

![clipboard](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210603221144.png)

机柜配件

![clipboard](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210603221201.png)

### 存储基础知识

用于存放数据信息的设备和介质, 是计算机系统的外部存储, 数据可安全存放, 长期驻留

**传统存储 :**

![clipboard](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210603221224.png)

**磁盘阵列 :**

![clipboard](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210603221243.png)

**存储网络类型 :**

- DAS : 直接连接存储(Direct Attached Storage)
- NAS : 网络连接存储(Network Attached Storage)
  
    > 通过局域网在多个文件服务器之间实现了互联, 基于文件的协议(NFS, SMB/CIFS等), 实现文件共享. 只对文件有使用能力.
    >
    > ![clipboard](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210603221311.png)
    > - 集中管理数据, 从而释放带宽, 提高性能
    > - 可提供跨平台文件共享功能
    > - 可靠性较差, 适用于局域网络或较小的网络

- SAN : 存储区域网络(Storage Area Networks)
  
    > 利用高速的光纤网络链接服务器与存储设备, 基于SCSI, IP, ATM等多种高级协议, 实现存储共享. 对文件有管理能力.
    >
    > ![clipboard](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210603221327.png)
    >
    > - 服务器跟存储装置两者各司其职
    > - 利用光纤信道来传输数据, 以达到一个服务器与存储装置之间多对多的高效能, 高稳定度的存储环境
    > - 实施复杂, 管理成本高

区别 :

| \        | DAS                                                          | NAS                                                          | SAN                                        |
| -------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------ |
| 传输类型 | SCSI, FC                                                     | IP                                                           | IP, FC, SAS                                |
| 数据类型 | 数据块                                                       | 文件                                                         | 数据块                                     |
| 典型应用 | 任何                                                         | 文件服务器                                                   | 数据库应用                                 |
| 优点     | 磁盘与服务器分离, 便于统一管理                               | 不占用应用服务器资源</br> 广泛支持操作系统</br>扩展较容易</br>即插即用, 安装简单方便 | 高扩展性</br>高可用性</br>数据集中, 易管理 |
| 缺点     | 连接距离短</br>数据分散, 共享困难</br>存储空间利用率不高</br>扩展性有限 | 不适合存储量大的块级应用</br>数据备份及恢复占用网络带宽      | 相比NAS成本较高</br>安装和升级比NAS复杂    |

## 计算机软件

![clipboard](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210603221349.png)

### 操作系统

**OS :** Operating System, 通用目的的软件程序, 包含如下功能
- 硬件驱动
- 进程管理
- 内存管理
- 网络管理
- 安全管理
- 文件管理

**OS分类 :**

- 服务器OS: RHEL, CentOS, Windows Server, AIX
- 桌面OS: Windows 10, Windows 7, Mac OS, Fedora
- 移动设备OS: Andriod, IOS, YunOS

### 开发接口标准

**ABI : Application Binary Interface**
> ABI描述了应用程序与OS之间的底层接口, 允许编译好的目标代码在使用兼容ABI的系统中无需改动就能运行

**API : Application Binary Interface**
> API定义了源代码和库之间的接口, 因此同样的源代码可以在支持这个API的任何系统中编译

**POSIX : Portable Operating System Interface**
> IEEE在操作系统上定义的一系列API标准</br>
> POSIX兼容的程序可以在其他POSIX操作系统编译执行


**运行程序格式 :**
- Windows: EXE, dll(dynamic link library), .lib
- Linux: ELF, .so(shared object), .a

### Library function和system call

函数库和系统调用

![clipboard](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210603221409.png)

用户的应用程序包含函数库(Library), 函数库通过系统调用(system call)来操作内核(Kernel), 内核通过硬件驱动(Device Dirver)从硬件(Hardware)中获取数据

单核CPU同一时间只能做一件事, 所以, 同一时间只能在一个空间中工作, 当运行程序时, CPU在用户空间和内核空间之间切换工作, 称为上下文切换, 保留在上一空间正在处理的数据状态.

### 用户空间和内核空间

**用户空间(User Space) :**

用户程序的运行空间. 为了安全, 他们是隔离的, 即使用户的程序崩溃, 内核也不受影响.

只能执行简单的运算, 不能直接调用系统资源, 必须通过系统接口(system call), 才能向内核发出指令

**内核空间(Kernel Space) :**

是Linux内核的运行空间

可以执行任意命令, 调用系统的一切资源

**示例 :**

str = "www.baidu.com"   //用户空间</br>
x = x + 10              // 用户空间</br>
file.write(str)         // 切换到内核空间</br>
y = x + 200             // 切换回用户空间</br>

**说明 :** 第一行和第二行都是简单的赋值运算, 在User space执行. 第三行需要写入文件, 就要切换到Kernel space, 因为用户不能直接写文件, 必须通过内核安排. 第四行又是赋值运算, 就切换回User space.

![clipboard](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210603221436.png)

### 编程语言

- 低级语言
    > 机器语言: 0和1
    > 汇编语言: 和机器语言一一对应, 与硬件相关的特有代码, 驱动程序开发

- 中级语言: C
  
    > 系统级应用, 驱动程序
    
- 高级语言: java, python, go, php, Objective-C, C#
  
    > 应用级程序开发

**C: hello.c**

```
# include <stdio.h>

int main(void)
{
    printf("Hello, world\n");
}
```

**Java: hello.java**
```
class Hello{
    public static void main(String[] agrs){
        System.out.println("Hello Java");
    }
}
```

**Perl: hello.pl**
```
#!/usr/bin/perl
print "hello perl\n"
```

**Python hello.py**
```
#!/usr/bin/python
print 'Hello Python'
```

将中级语言和高级语言编译为低级语言(0与1), 才能被计算机执行.

### 服务器三大操作系统

#### Windows

#### Linux

GNU/Linux

#### Unix

1969年Ken Thompson

- System: Bell Lab
    - AIX(IBM)
    - Solaris(SUN)
    - HP-UX(HP)

- BSD: (BSRG)Berkeley System Distribution
    - NetBSD
    - OpenBSD
    - FreeBSD

### 兼容分时系统

![clipboard](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210603221457.png)

只有一台主机, 配置多个键盘和显示器, 给多个用户用.

主机同一时刻只能处理一个用户的请求.

为进一步强化大型主机功能, 让主机的资源可以提供更多的是使用着来利用, 在1964年, 贝尔实验室, 麻省理工学院及奇艺公司共同发起了Multic(多路信息计算系统)计划, 目的是让大型主机可以同时支持300个以上的终端机连线使用. 不过到了1969年前后, 由于计划进度缓慢, 资金短缺, 所以计划虽然继续研究, 但贝尔实验室退出了.

1966年加州大学伯克利分校毕业的Ken Thompson加入了贝尔实验室. 参与了Multics系统的研发, 并基于该系统开发了'star travel'游戏. 当贝尔实验室退出该项目后, 意味着Ken将没有机器可以再玩这个游戏. 所以Ken找到了一台老式的PDP-7, 并在这台机器上重写了他的游戏. 利用PDP-7上的汇编语言, 花费一个月时间完成了操作系统的内核. 一周一个内核, 一个文件系统, 一个编译器和一个编译程序, 该操作系统内核就是unix的起源.

### GNU

由于UNIX开始收费, 相应的软件也开始收费, 所以GNU诞生了, 提供开源免费的, 运行在Unix上的应用软件.

GNU(GNU is Not Unix)

- 1984年由Richard Stallman发起并创建
- 目标是编写大量兼容于Unix系统的自由软件
- 官方网站: http://www.gnu.org
- 
GPL: (GNU General Public License)

- 自由软件基金会: Free Software Foundation
- 允许用户任意复制, 传递, 修改及再发布
- 基于自由软件修改再次发布的软件, 仍需遵循GPL
- 
LGPL(Lesser General Public License)
- LGPL相对于GPL较为宽松, 允许不公开全部源代码

GNU操作系统: Hurd Hird of Unix-Replacing Daemons

官网: http://www.gnu.org/home.html

### Linux起源

1991年10月5日, Torvalds在comp.os.minix新闻组上发布消息, 宣布他自行编写的完全自由免费的内核诞生(Freeminix-like kernel sources for 386-AT)-FREAX, 英文含义是怪诞的, 怪物, 异想天开

类Unix内核, 在GPL下发布

官网: www.kernel.org

Linux操作系统包含 :
- 完整的类Unix操作系统
- Linux内核 + GNU工具


### Linux发行版

**slackware :** SUSE Linux Enterprise Server(SLES)
    OpenSuse桌面

**debian :** ubuntu, mint

**redhat :** RHEL: RedHat Enterprise Linux ,每18个月发行一个新版本

- CentOS: 兼容RHEL的格式
- 中标麒麟: 中标软件
- Fedora: 每6个月发行一个新版本

**ArchLinux :** 轻量简洁

**Gentoo :** 极致性能

**LFS :** Linux From sratch自定制Linux, **需要深入理解Linux可以去看官网文档**

**Android :** kernel+busybox(工具集)+java虚拟机

**Linux分支参考网站 :**

- http://www.futurist.se/gldt/
- http://www.mindpin.com/d3js-demo/linux/

### Linux内核

![clipboard](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210603221527.png)

```bash
$ uname -r
3.10.0-1062.1.2.el7.x86_64
$ cat /etc/redhat-release
CentOS Linux release 7.7.1908 (Core)
```

### 开源许可证

![clipboard](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210603221546.png)

GPL最严格, MIT最宽松

### Linux哲学思想

- 一切都是一个文件(包括硬件)
- 小型, 单一用途的程序
- 链接程序, 共同完成复杂的任务
- 避免令人困惑的用户界面
- 配置数据存储在文本中
