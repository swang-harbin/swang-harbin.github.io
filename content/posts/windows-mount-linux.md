---
title: Win10挂载linux盘
date: '2019-10-26 00:00:00'
updated: '2019-10-26 00:00:00'
tags:
- Windows
- Linux
categories:
- Windows
---
# Win10挂载linux盘

## CentOS安装rpcbind和nfs-utils
```bash
yum install rpcbind nfs-utils
```
说明:
> NFS是一个RPC服务,启动任何一个RPC服务都需要做好端口映射,该工作是由rpcbind负责的.因此,需要在启动NFS之前启动rpcbind.

> nfs-utils是nfs的主程序,提供rpc.nfsd和rpc.mountd两个服务以及其他文档文件等.

## 启动服务
```bash
systemctl start rpcbind # 启动rpc服务
systemctl start nfs nfs-secure # 启动nfs服务和nfs安全传输服务
```

## 放行服务和端口
1. 配置防火墙放行nfs服务

   ```bash
   firewall-cmd --zone=public --add-service=nfs --permanent
   ```

2. 修改挂载监听端口

   ```bash
   vim /etc/sysconfig/nfs
   取消MOUNTD_PORT=892的注释,则需要开放的端口为892
   ```

3. 开放端口

   ```bash
   # 放行rpc端口
   firewall-cmd --zone=public --add-port=111/tcp --permanent
   firewall-cmd --zone=public --add-port=111/udp --permanent
   # 放行nfs端口
   firewall-cmd --zone=public --add-port=892/tcp --permanent
   firewall-cmd --zone=public --add-port=892/udp --permanent
   ```

4. 重新加载防火墙

   ```bash
   firewall-cmd --reload
   ```

**注意**

可以对指定IP开放服务和端口

## 配置挂载目录和客户端权限
```bash
创建共享文件夹
mkdir /shard
编辑配置文件
vim /etc/exports
```
**添加格式**

共享目录路径 允许访问的客户端(权限参数) 允许访问的客户端(权限参数)
```bash
/shard *(rw) #任意主机都有读写权限
/public 192.168.125.31(rw,sync,no_root_squash) # 192.168.125.31主机具有读写权限,并且使用root用户登录时,具有root权限
/public 192.168.0.0/24(rw,sync,no_root_squash)
/public 192.168.0.0/24(rw,sync,no_root_squash) *(ro)
```
**更新配置**

```bash
systemctl reload nfs
或
exportfs -a
```
**NFS主要配置文件**
- 主要配置文件：/etc/exports
这是 NFS 的主要配置文件了。该文件是空白的，有的系统可能不存在这个文件，主要手动建立。NFS的配置一般只在这个文件中配置即可。
- 分享资源的登录档：/var/lib/nfs/*tab
在 NFS 服务器的登录文件都放置到 /var/lib/nfs/ 目录里面，在该目录下有两个比较重要的登录档， 一个是 etab ，主要记录了 NFS 所分享出来的目录的完整权限设定值；另一个 xtab 则记录曾经链接到此 NFS 服务器的相关客户端数据。
- NFS系统配置文件:/etc/sysconfig/nfs,可以指定NFS的端口等信息

**NFS主要指令**
- NFS 文件系统维护指令：/usr/sbin/exportfs
这个是维护 NFS 分享资源的指令，可以利用这个指令重新分享 /etc/exports 变更的目录资源、将 NFS Server 分享的目录卸除或重新分享。
- 客户端查询服务器分享资源的指令：/usr/sbin/showmount
这是另一个重要的 NFS 指令。exportfs 是用在 NFS Server 端，而 showmount 则主要用在 Client 端。showmount 可以用来察看 NFS 分享出来的目录资源。

**/etc/exports参数说明**

参数 | 作用
--- | ---
ro | 只读
rw | 读写
root_squash | 当NFS客户端以root用户访问时,映射为NFS服务器的匿名用户
no_root_squash | 当NFS客户端以root用户访问时,映射为NFS服务器的root用户
all_squash | 无论NFS客户端使用什么账户访问,均映射为NFS服务器的匿名用户
sync | 同时将数据写入到内存与硬盘中,保证不丢失数据
async | 优先将数据保存到内存,然后再写入磁盘;效率更高,但可能丢失数据

## 开启Windows客户端上的NFS(Network File System)网络文件系统

- 开启NFS

  控制面板 -> 打开或关闭windows功能 -> 勾选NFS及其子节点 -> 立即重启计算机

- 验证结果

  cmd输入`mount -h`

## 如遇权限问题,修改Windows客户端用户UID和GID
Win+R输入regedit进入注册表编辑器 -> HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ClientForNFS\CurrentVersion\Default下新建两个DWORD(32)位值,添加AnonymousUid和AnonymousGid,值均为0.

**说明**

因为CentOS7中root用户的uid=0,gid=0.可以使用`id 用户名`查看用户id信息,如`id root`.如果是其他用户应该可以修改为对应的id.

## 挂载NFS

cmd输入`mount \\\\NFS的IP地址或者主机名\nfs目录名 挂载点 `
用法:  mount [-o options] [-u:username] [-p:<password | *>] <\\computername\sharename> <devicename | *>

```bash
mount -u:username -p:password \\192.168.121.128\mynfs x:
```

## 取消挂载
cmd输入`umount 挂载点`

```bash
umount x:
```

## 参考文档
- [如何在Windows上挂载Linux系统分区](https://www.cnblogs.com/pyng/p/10173404.html)
- [NFS服务器搭建与配置](https://blog.csdn.net/qq_38265137/article/details/83146421)
