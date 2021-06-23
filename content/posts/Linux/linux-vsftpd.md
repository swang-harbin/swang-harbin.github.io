---
title: linux 使用 vsftpd 搭建 FTP 服务器
date: '2020-05-30 00:00:00'
tags:
- Linux
- FTP
---
# linux 使用 vsftpd 搭建 FTP 服务器

测试使用的系统 Ubuntu18.4，CentOS7，vsftpd 版本 3.0.3, vsftpd-3.0.2 与其配置文件有差别，暂未测试

## 安装 vsftpd

CentOS
```bash
$ sudo dnf install vsftpd
```

Ubuntu
```bash
$ sudo apt-get install vsftpd
```

## 配置 FTP 服务

vsftpd-3.0.3 的配置文件为 /etc/vsftpd.conf，该文件本身有详细的文档说明，所以这里只修改一些有用的配置，使你能快速的搭建起 FTP 服务。关于配置的详细信息可以使用 man 手册查看
```bash
man vsftpd.conf
```

### 允许对 FTP 服务器的文件系统进行修改

将 `write_enable` 设置为 `YES`，来允许用户（匿名，本地，虚拟用户均可）可以对文件系统进行修改，包括删除/修改以及向 FTP 服务器上传文件等。

```properties
write_enable=YES
```

### 允许本地用户登录 FTP 服务

允许 */etc/passwd* 中的用户登录 ftp 服务
```properties
local_enable=YES
```

### 允许匿名用户登录

```properties
# Allow anonymous login
anonymous_enable=YES
# No password is required for an anonymous login (Optional)
no_anon_password=YES
# Maximum transfer rate for an anonymous client in Bytes/second (Optional)
anon_max_rate=30000
# Directory to be used for an anonymous login (Optional)
anon_root=/example/directory/
```

### Chroot Jail

为防止用户访问除其 home 目录外的文件夹，修改/添加如下属性

```properties
chroot_list_enable=YES 
chroot_list_file=/etc/vsftpd.chroot_list
```
