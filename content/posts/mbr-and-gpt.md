---
title: MBR分区结构和GPT分区结构
date: '2020-04-26 00:00:00'
updated: '2020-04-26 00:00:00'
tags:
- Computer
categories:
- Computer
---
# MBR分区结构和GPT分区结构

## MBR和GPT

### MBR

MBR(Master Boot Record, 主引导记录): 是计算机硬盘驱动器的第一个扇区. 它告诉计算机硬盘驱动器的分区情况, 以及如何加载操作系统.

MBR对比GPT存在的缺点
- 最大只支持2TB的硬盘
- 每个磁盘最多可以分为4个主分区(或3个主分区+1个扩展分区)
- MBR有自己的启动代码, 一旦启动代码被破坏, 系统无法启动. 需要修复启动代码才可重新启动. GPT本身并不包含启动代码, 需要使用UEFI引导启动

### GPT

GPT(GUID partition table, GUID分区表): 是EFI标准定义的一种较新的硬盘分区表结构. 与MBR分区方案相比, GPT提供更加灵活的磁盘分区机制. 具有以下优点:
- 支持2TB以上的大硬盘(最大18EB)
- 每个磁盘的分区个数没有限制
- 分区大小没有限制
- 分区表自带备份
- 每个分区可以有一个名称(不同于卷标)


## 传统BOIS引导和UEFI引导启动

### BIOS

BIOS: Basic Input Output System, 基本输入输出系统. 是一组固化到计算机内主板上一个ROM芯片上的程序，它保存着计算机最重要的基本输入输出的程序、开机后自检程序和系统自启动程序，它可从CMOS中读写系统设置的具体信息。

老式电脑中有一个bios设置，它主要负责开机时检测硬件功能和引导操作系统启动的功能。

### [UEFI](http://www.uefi.org/)

UEFI: Unified Extensible Firmware Interface, 统一可扩展固件接口. UEFI规范为个人计算机操作系统和平台固件之间的接口定义了一个新模型。该接口由数据表组成，这些数据表包含与平台有关的信息，以及操作系统及其加载程序可用的启动和运行时服务调用。它们共同提供了用于引导操作系统和运行预引导应用程序的标准环境。

uefi引导时省去了bios自检过程，所以可加快开机启动速度


### BIOS和UEFI区别

BIOS通常用于指代植根于IBM PC设计的英特尔®架构固件实现。基于较旧的标准和方法，BIOS最初是用16位实模式x86汇编代码编码的，直到最近使用率下降之前，基本上保持不变。

相比之下，UEFI标准通过描述用于将控制权转移到操作系统或从一个或多个芯片和固件供应商构建模块化固件的抽象接口集，反映了PC发展的30年。UEFI论坛规范的抽象旨在使生产者代码和消费者代码的开发脱钩，从而使每个人都可以更独立地进行创新，并且可以更快地将两者推向市场。UEFI还克服了IBM PC设计所假定的硬件扩展限制，从而可以将其跨高端企业服务器广泛部署到嵌入式设备。UEFI是“与处理器架构无关的”，支持x86，x64，ARM和Itanium。


## FAT32和NTFS等

FAT32, NTFS, exFAT等均属于文件系统.

文件的系统是操作系统用于明确磁盘或分区上的文件的方法和数据结构；即在磁盘上组织文件的方法。


- FAT(File Allocation Table):文件配置表
- NTFS(New Technology File System)：NTFS文件系统是一个基于安全性的文件系统，是Windows NT所采用的独特的文件系统结构，它是建立在保护文件和目录数据基础上，同时照顾节省存储资源、减少磁盘占用量的一种先进的文件系统
- CDFS: CDFS是大部分的光盘的文件系统
- exFAT: Extended File Allocation Table File System, 扩展FAT. 一种适合于闪存的文件系统，为了解决FAT32等不支持4G及其更大的文件而推出
- Ext: Ext是 GNU/Linux 系统中标准的文件系统
- RAW: RAW文件系统是一种磁盘未经处理或者未经格式化产生的文件系统
- Btrfs
- ZFS
- HFS
- HFS+
- ReiserFS
- JFS
- VMFS
- XFS
- UFS
- VXFS
- ReFS
- WBFS
- PFS


## MBR（GPT）与FAT（NTFS等）区别

MBR和GPT是两种不同的磁盘分区结构，用来记录各个分区在磁盘中的位置等信息；而FAT，NTFS等是文件系统，是在对磁盘分区后，每个分区对文件的管理方式。
