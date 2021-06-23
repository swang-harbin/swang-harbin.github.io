---
title: Windows 远程连接图形化 Linux
date: '2019-12-25 00:00:00'
tags:
- Linux
---
# Windows 远程连接图形化 Linux

## 方式一：使用 xrdp

### 首先，需要 CentOS 已安装图像化界面（GNOME）并启动
```bash
# 安装 GNOME
yum groupinstall "GNOME Desktop" "Graphical Administration Tools"

# 启动
startx
```

### 安装 xrdp

```bash
yum install xrdp -y
```

### 启动 xrdp 服务
```bash
systemctl start xrdp

# 设置为开机自启
systemctl enable xrdp
```

### 安装完成后，使用 Windows10 自带的远程连接即可


## 方式二：使用 vnc

### 下载 vncViewer 客户端

将 vncViewer 安装到非受控机器

https://www.realvnc.com/en/connect/download/viewer/

### 启动 linux 上的 vnc 服务

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609143009.png)

### 输入受控机器 IP 即可连接

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210619224104.png)

## 参考文档

- [通过 windows 远程访问 linux 桌面的方法（简单）](https://www.cnblogs.com/lizhangshu/p/9709531.html)
- [Linux 和 Windows 间的远程桌面访问](https://blog.csdn.net/u011054333/article/details/79905102)

