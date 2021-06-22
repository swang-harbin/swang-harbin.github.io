---
title: CentOS7挂载exFAT格式的U盘
date: '2019-12-26 00:00:00'
tags:
- Linux
- CentOS
---
# CentOS7挂载exFAT格式的U盘

## 安装依赖包

```bash
$ yum install http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm -y
```

```bash
$ yum install exfat-utils fuse-exfat -y
```

## 查看所有分区

```bash
$ fdisk -l

Disk /dev/sdb: 62.1 GB, 62109253632 bytes, 121307136 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x3c3fff2d

   Device Boot      Start         End      Blocks   Id  System
/dev/sdb1   *          63   121307135    60653536+   7  HPFS/NTFS/exFAT
```

## 挂载分区

将/dev/sdb1挂载到/mnt下
```bash
$ mount /dev/sdb1 /mnt
```

## 卸载分区

```bash
umount /dev/sdb1
```

