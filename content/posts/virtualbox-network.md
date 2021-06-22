---
title: VrtualBox网络相关及设置网络互通
date: '2020-06-28 00:00:00'
tags:
- VirtualBox
categories:
- VirtualBox
---
# VrtualBox网络相关及设置网络互通

[networkingdetails](https://www.virtualbox.org/manual/UserManual.html#networkingdetails)

## VirtualBox网络模式简介

| Mode        | VM -> Host |                          Host -> VM                          | VM1 -> VM2 | VM -> Net/LAN |                        Net/LAN -> VM                         |
| ----------- | :--------: | :----------------------------------------------------------: | :--------: | :-----------: | :----------------------------------------------------------: |
| Host-only   |     +      |                              +                               |     +      |       -       |                              -                               |
| Internal    |     -      |                              -                               |     +      |       -       |                              -                               |
| Bridged     |     +      |                              +                               |     +      |       +       |                              +                               |
| NAT         |     +      | [Port forward](https://www.virtualbox.org/manual/UserManual.html#natforward) |     -      |       +       | [Port forward](https://www.virtualbox.org/manual/UserManual.html#natforward) |
| NAT Network |     +      | [Port forward](https://www.virtualbox.org/manual/UserManual.html#network_nat_service) |     +      |       +       | [Port forward](https://www.virtualbox.org/manual/UserManual.html#network_nat_service) |


每个网络适配器都可以单独配置为以以下方式之一运行：

- **Not attached**: Oracle VM VirtualBox向Guest报告存在网卡, 但没有连接. 就像没有插入以太网电缆一样. 使用此模式相当于拔除了虚拟机的以太网电缆并中断连接, 可用来通知Guest操作系统没有可用的网络连接并强制进行重新配置.

- **NAT(Network Address Translation, 网络地址转换)**: 如果您只需要浏览Web, 下载文件和查看Guest内部的电子邮件, 则此默认模式就足够了.
    > Guest访问网络的所有数据都是由宿主机提供的, Guest可以访问宿主机能访问到的所有网络, Guest并不真实存在于网络中, 宿主机与网络中的任何机器都不能直接查看和访问到Guest.
    
    | 关系           | 说明                                                         |
    | -------------- | :----------------------------------------------------------- |
    | Guest与Host    | 默认只能Guest单向访问Host. 宿主机设置端口转发后Host可以通过转发的端口访问Guest上的服务(例如数据库服务) |
    | Guest与Net/LAN | 只能Guest单向访问网络中的其他主机. 宿主机设置端口转发后其他主机可以通过宿主机转发的端口访问Guest上的服务(例如数据库服务) |
    | Guest1与Guest2 | 虚拟机间完全相互独立, 不能相互访问                           |
    设置方式:
    
    > 选中虚拟机 -> Settings -> Network -> Attached to, 选中NAT即可

    IP, Gateway, DNS:
    
    > 默认IP: 10.0.2.15, 默认Gateway: 10.0.2.2, 默认DNS: 10.0.2.3. 同一Guest设置多块NAT网卡, 网段按10.0.2.0, 10.0.3.0, ...递增.
    
- **NAT Network**: NAT网络是允许出站连接的一种内部网络
  
    > 该模式的工作方式类似于家用路由器, 将使用该服务的系统分组到一个网络中, 并防止该网络外部的系统直接访问其内部的系统, 但允许内部的系统相互通信并与之通信. 外部系统在IPv4和IPv6上使用TCP和UDP.
    
    > 与NAT模式相比, 该模式增加了DHCP功能, 使得在同一网络内的Guest可以相互访问

    | 关系           | 说明                                                         |
    | -------------- | :----------------------------------------------------------- |
    | Guest与Host    | 默认只能Guest单向访问Host. 设置端口转发后Host可以访问Guest上的服务(例如数据库服务) |
    | Guest与Net/LAN | 只能Guest单向访问网络中的其他主机. 设置端口转发后其他主机可以访问Guest上的服务(例如数据库服务) |
    | Guest1与Guest2 | 虚拟机之间可以相互访问                                       |
    设置方式:
    
    > 首先创建一个NAT Network: 选中Tools -> Preferences -> Network -> NAT Networks -> Adds New NAT networks(图标) -> Edits selected NAT networks -> 设置好CIDR等信息即可
    
    > 为Guest选择使用NAT Network: 选中需要设置的Guest -> Settings -> Network -> Attached to: -> 选择NAT Network -> Name选择上一步设置的NAT network的名称即可

    IP, Gateway, DNS
    
    > 按照上方创建NAT Network时配置的CIDR及DHCP自动配置

- **Bridged networking(桥接网络)**: 这是为了满足更高级的网络需求. 例如网络仿真和在Guest中运行服务. 启用后, Oracle VM VirtualBox将连接到宿主机上已安装的网卡之一并直接交换网络数据包, 从而规避了主机操作系统的网络栈.

    > 该模式通过宿主机的网卡, 架设了一条桥, 直接接入到了宿主机所在的网络中, 所有功能与网络中的真实主机一样.
    
    > Guest与Host在同一网络中, 具有相同的网段等信息
    
    | 关系           | 说明                                                         |
    | -------------- | :----------------------------------------------------------- |
    | Guest与Host    | 可以互相访问, Guest与Host在同一网段中                        |
    | Guest与Net/LAN | 可以互相访问, Guest, Host, 以及Host所在网段中的其他机器均在同一网段 |
    | Guest1与Guest2 | 虚拟机之间可以相互访问, 原因同上                             |
    设置方法:
    
    > 选中Guest -> Settings -> Network -> Attached to: -> 选中Bridged Adapter -> Name选中宿主机中的网卡(通常选择正连接到网络中的网卡)
    
    IP, Gateway, DNS
    
    > 一般是宿主机所在网络的DHCP分配, 与宿主机在同一网段
    
- **Internal networking(内部网络)**: 可用于创建另一种基于软件的网络, 该网络对选定的虚拟机可见, 对主机上或外部世界上运行的应用程序不可见.

    > 虚拟机与外网完全断开, 只实现虚拟机与虚拟机之间的内部网络通讯模式.
    
    | 关系           | 说明                                                         |
    | -------------- | :----------------------------------------------------------- |
    | Guest与Host    | 不能相互访问, 彼此不属于同一个网络                           |
    | Guest与Net/LAN | 不能相互访问, 理由同上                                       |
    | Guest1与Guest2 | 可以相互访问, 前提是设置网络时, 两台虚拟机设置同一个网络名称 |
    
    设置方法:
    
    > 选中Guest -> Settings -> Network -> Attached to: -> 选中Internal Network -> Name中可以使用默认的, 也可以手动输入
    
    > Name相同的Guest可以相互访问
    
    IP, Gateway, DNS
    
    > VirtualBox的DHCP服务器会为它分配IP, 也可以手动设置静态IP
    
- **Host-only networking(仅主机)**: 用于创建包含主机和一组虚拟机的网络, 并且无需主机的物理网络接口. 在主机上创建类似于环回接口的虚拟网络接口, 以提供虚拟机和主机之间的相互连接.

- **Generic networking**: 通过允许用户选择可以包含在Oracle VM VirtualBox中或可以在扩展包中分发的驱动程序, 可以使用共享相同通用网络接口的罕见模式. 以下子模式可用:
    - **UDP Tunnel**: 用于通过现有网络基础结构直接, 轻松, 透明地互连在不同主机上运行的虚拟机.
    - **VDE(Virtual Distributed Ethernet) networking**: 用于连接Linux或FreeBSD主机上的虚拟分布式以太网交换机. 目前, 此选项需要从源代码编译Oracle VM VirtualBox, 因为Oracle软件包不包括它.

https://www.virtualbox.org/manual/UserManual.html#networkingdetails
[VirtualBox的四种网络连接方式](https://www.cnblogs.com/jpfss/p/8616613.html)


## 使用NAT + Host Only解决宿主机(host)与虚拟机(guest), 虚拟机与虚拟机, 虚拟机与外网之间的访问

