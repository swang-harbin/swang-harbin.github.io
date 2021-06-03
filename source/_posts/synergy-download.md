---
title: 下载安装Synergy
date: '2019-12-25 00:00:00'
updated: '2019-12-25 00:00:00'
tags:
- Synergy
- Computer
categories:
- Computer
---
# 下载安装Synergy

## 下载

通过该网站下载即可

https://sourceforge.net/projects/synergy-stable-builds/

我下载的是v1.8.8-stable.tar.gz



Synergy需要设置一个服务端, 可以设置多个客户端, 可将最常用的电脑设置为服务端. 

本教程以Windows10系统的电脑作为服务端, CentOS7系统的电脑作为客户端.

## Windows服务端安装

找到对应版本, 傻瓜式安装. 

### 设置为服务端

选中**Server**, 将该电脑设置为服务端

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142832.png)

### 设置屏幕名称

依次点击 **编辑** -> **设置**

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142836.png)

弹出如下设置框, 自定义一个屏幕名称, 稍后会用到

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142837.png)

### 设置服务端

点击 **设置服务端···**

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142838.png)

弹出如下窗口, 设置服务器的屏幕名

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142839.png)

按下图操作, 添加客户端屏幕

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142841.png)

### 启动服务端

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142842.png)


## CentOS7客户端安装

### 设置为客户端

前提需要安装GNOME图形界面, 并启动
```bash
# 安装图形界面
yum groupinstall "GNOME Desktop" "Graphical Administration Tools" -y
# 启动
startx
```

安装synergy
```bash
yum install synergy-v1.8.8-stable-Linux-x86_64.rpm -y
```

打开Synergy, 选择作为Client
![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142843.png)

### 设置客户端屏幕名

该客户端屏幕名需与服务端设置的对应屏幕名相同

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142844.png)

### 设置为客户端, 并设置服务端IP

Windows上使用cmd命令```ipconfig```查看网卡信息

![image](https://note.youdao.com/yws/res/52870/211F65CC3DC54C96BABE4CA1213107EA)

以此作为服务端IP, 并选中Client

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142845.png)

此处屏幕名可能不会立即改变, 关闭后重启就会变成自己设置的了.

### 启动客户端

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142846.png)
