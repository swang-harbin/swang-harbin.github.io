---
title: Ubuntu20.4 无线网卡 rtl8821ce 驱动安装
date: '2020-04-27 00:00:00'
tags:
- Linux
- Ubuntu
---
# Ubuntu20.4 无线网卡 rtl8821ce 驱动安装

## 问题描述

新换的电脑，安装的 Ubuntu20.4 LST 版本的系统，回家之后发现没有 wifi 按钮连接不了 wifi。

## 查看系统是否有无线网卡

使用 `ip addr` 显示如下，发现没有无线网卡
```bash
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eno1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc fq_codel state DOWN group default qlen 1000
    link/ether f8:b4:6a:24:22:04 brd ff:ff:ff:ff:ff:ff
```

使用 `iwconfig` 显示如下，依旧没有无线网卡
```bash
lo        no wireless extensions.

eno1      no wireless extensions.
```

使用 `lspci -v` 显示如下，发现包含 `PCIe Wireless`，即电脑是有无线网卡的，网卡型号为 `RTL8821CE`
```bash
02:00.0 Network controller: Realtek Semiconductor Co., Ltd. RTL8821CE 802.11ac PCIe Wireless Network Adapter
```

该网卡在 Ubuntu 上缺少驱动，需要手动安装

## 解决方式

百度搜了一堆，都是从 git 上拉取源文件，然后修改 Makefile，`make`，`make install`，`modprobe -a 8821ce`，均未解决实际问题。

在 [github 的该项目](https://github.com/tomaspinho/rtl8821ce) 处，发现如下描述

> Ubuntu & Debian
> ```bash
> sudo apt install bc module-assistant build-essential dkms
> sudo m-a prepare
> ```
> Ubuntu users may also install the prebuilt [rtl8821ce-dkms](https://packages.ubuntu.com/bionic-updates/rtl8821ce-dkms) package, an older version of the driver maintained by the Ubuntu MOTU Developers group for bionic, eoan and focal. It has been known to work in cases where the newer driver available here does not. Bugs and issues with that package should be reported at Launchpad rather than here.


点击上方 **rtl8821ce-dkms** 是 18.04 版本的 deb 包，安装后不符合要求，因此通过 [packages.ubuntu.com](https://packages.ubuntu.com/) 搜索 `rtl8821ce-dkms`，获取到了对应版本的 deb 包，安装成功后，重启电脑，就可以使用无线网卡进行连接了。下方图片红色框中的红色字对应不同 Ubuntu 版本的名称。

![image.png](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210619223814.png)

全部执行命令如下:

```bash
$ sudo apt install bc module-assistant build-essential dkms
$ sudo m-a prepare
$ sudo dpkg -i rtl8821ce-dkms_5.5.2.1-0ubuntu3_all.deb
$ sudo reboot
```
