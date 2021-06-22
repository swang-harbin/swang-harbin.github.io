---
title: Windows远程连接图形化Linux
date: '2019-12-25 00:00:00'
tags:
- Linux
categories:
- Linux
---
# Windows远程连接图形化Linux

## 方式一: 使用xrdp

### 首先, 需要CentOS已安装图像化界面(GNOME)并启动
```bash
# 安装GNOME
yum groupinstall "GNOME Desktop" "Graphical Administration Tools"

# 启动
startx
```

### 安装xrdp

```bash
yum install xrdp -y
```

### 启动xrdp服务
```bash
systemctl start xrdp

# 设置为开机自启
systemctl enable xrdp
```

### 安装完成后, 使用Windows10自带的远程连接即可


## 方式二: 使用vnc

### 下载vncViewer客户端

将vncViewer安装到非受控机器

https://www.realvnc.com/en/connect/download/viewer/

### 启动linux上的vnc服务

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609143009.png)

### 输入受控机器IP即可连接

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210619224104.png)

## 参考文档

- [通过windows远程访问linux桌面的方法（简单）](https://www.cnblogs.com/lizhangshu/p/9709531.html)
- [Linux和Windows间的远程桌面访问](https://blog.csdn.net/u011054333/article/details/79905102)

