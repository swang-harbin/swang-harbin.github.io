---
title: Win10挂载linux盘
date: '2019-10-26 00:00:00'
tags:
- Windows
- Linux
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
