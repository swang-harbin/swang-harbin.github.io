---
title: NFS需要开启的端口
date: '2019-10-26 00:00:00'
tags:
- Linux
- NFS
categories:
- Linux
---
# NFS需要开启的端口

1. nfs  tcp 2049 这个很明显到处都是
2. sunrpc tcp 111 这个很明显到处都是
3. sunrpc udp 111 其中这个很难发现，仔细排查才看到
4. acp-proto udp 4046 其中仔细看udp的会找到


## 参考文档
[NFS挂载的时候需要开通那几个端口的访问权限。](https://blog.csdn.net/fhqsse220/article/details/45668057/)
