---
title: 使用 WireGuard 建立 VPN
date: '2020-06-14 00:00:00'
tags:
- Linux
- VPN
---
# 使用 WireGuard 建立 VPN

VPN：Virtual Private Network，虚拟专用网络，在公用网络上建立专用网络，进行加密通讯。可理解为将两台机器组建为一个局域网进行加密的点对点传输。

翻墙：而所谓的“翻墙”是在 VPN 的基础上，又对服务器进行了请求转发的设置，将客户端发送到服务器的请求，以服务器发送出去，在将接收到的信息返回给客户端，服务器相当于一个代理人。

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609143010.png)

[WireGuard](https://www.wireguard.com/) 是一种利用最新加密技术的及其简单，快速，现代化的 VPN。它旨在比 IPsec 更快，更简单，更精简，更有用，同时避免造成严重的麻烦。它打算比 OpenVPN 具有更高的性能。WireGuard 被设计为通用 VPN，可在嵌入式接口和超级计算机上运行，适用于许多不同的情况。最初针对 Linux 内核发布，现在已跨平台（Window、macOS、BSD、IOS、Android）并广泛部署。它目前正在积极开发中，但是已被认为是业界最安全，最易用，最简单的 VPN 解决方案。

WireGuard 配置就像设置 SSH 一样简单。通过服务器和客户端之间的公共密钥交换来建立连接。仅允许在其相应的服务器配置文件中具有其公钥的客户端连接。WireGuard 设置了标准的网络接口（例如 wg0 和 wg1），其行为与常见的 eth0 接口非常相似。这样就可以使用`ifconfig`和` ip`等标准工具来配置和管理 WireGuard 接口。


## 准备工作

需要具备服务器的 root 访问权限或者用户具有`sudo`权限

## 安装 WireGuard

具体安装可见 [官方安装文档](https://www.wireguard.com/install/)，部分常用系统的安装方式如下

### Fedora

```bash
$ sudo dnf install wireguard-tools
```

### CentOS

CentOS 8
```bash
$ sudo yum install elrepo-release epel-release
$ sudo yum install kmod-wireguard wireguard-tools
```

CentOS 7
```bash
$ sudo yum install epel-release https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm
$ sudo yum install yum-plugin-elrepo
$ sudo yum install kmod-wireguard wireguard-tools
```

### Ubuntu

Ubuntu >= 19.10
```bash
$ sudo apt install wireguard
```

Ubuntu <= 19.04
```bash
$ sudo add-apt-repository ppa:wireguard/wireguard
$ sudo apt-get update
$ sudo apt-get install wireguard
```

### Debian

```bash
# apt install wireguard
```

## 配置 WireGuard 服务器端

1. 在服务器上生成一对密钥

   ```bash
   umask 077
   wg genkey | tee privatekey | wg pubkey > publickey
   ```

   该操作会在当前目录生成两个文件 *publickey* 和 *privatekey*，可使用 `cat` 查看。

2. 创建配置文件 */etc/wireguard/wg0.conf* 并添加以下内容。将 `<Private Key>` 替换为刚生成的 `privatekey` 中的内容，该服务器在新建 VPN 网络中的 IP 在 *Address* 中设置。**此处注意需要将 PostUp 和 PostDown 中的 eth0 替换对应的网络接口名称**

   ```properties
   [Interface]
   PrivateKey = <Private Key>
   Address = 192.168.2.1/24
   ListenPort = 51820
   PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE; ip6tables -A FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
   PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE; ip6tables -D FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
   SaveConfig = true
   ```

   - **Address** 定义 WireGuard 服务器的专用 IPv4 和 IPv6 地址。VPN 网络中的每个对等方对于此字段均应具有唯一值。可以在后方添加 IPv6 地址，类似于 *Address = 192.168.2.1/24，fd86:ea04:1115::1/64*

   - **ListenPort** 指定 WireGuard 监听传入连接的端口。

   - **PostUp** and **PostDown** 分别定义在打开或关闭接口后要运行的步骤。当前使用 `iptables` 设置 Linux IP 伪装规则，以允许所有客户端共享服务器的 IPv4 和 IPv6 地址。一旦隧道断开，规则将被清除。

   - **SaveConfig** 在服务运行时每当添加新对等项时自动更新配置文件

## 设置防火墙规则

1. 允许 SSH 连接和 WireGuard 的 VPN 端口

   ```bash
   # Fedora/CentOS/RedHat
   sudo firewall-cmd --zone=public --add-port=22/tcp --permanent
   sudo firewall-cmd --zone=public --add-port=51820/udp --permanent
   sudo systemctl restart firewalld
   sudo systemctl enable firewalld
   
   # Ubuntu
   sudo ufw allow 22/tcp
   sudo ufw allow 51820/udp
   sudo ufw enable
   ```

2. 验证

   ```bash
   # Fedora/CentOS/RedHat
   firewall-cmd --zone=public --list-ports
   
   # Ubuntu
   sudo ufw status verbose
   ```

## 启动 WireGuard 服务端

1. 打开接口

   ```bash
   wg-quick up wg0
   ```

   `wg-quick` 是 *wg* 中许多常用功能的便捷包装。您可以使用 `wg-quick down wg0` 关闭 *wg0* 接口。

   此时使用 `ip addr` 可查看到多了一个 *wg0* 的网络接口，*wg0.conf* 配置文件名称与其对应，其 IP 地址即为配置文件中配置的 *Address* 中的内容

2. 设置 WireGuard 服务开机自启动

   ```bash
   sudo systemctl enable wg-quick@wg0
   ```

3. 检查 VPN 隧道是否正在运行

   ```bash
   sudo wg show
   ```

   会看到类似如下的结果

   ```bash
       user@localhost:~$ sudo wg show
           interface: wg0
           public key: vD2blmqeKsV0OU0GCsGk7NmVth/+FLhLD1xdMX5Yu0I=
           private key: (hidden)
           listening port: 51820
   ```

   ```bash
   ifconfig wg0
   ```

   会看到类似如下的输出

   ```bash
       user@localhost:~$ ifconfig wg0
       wg0: flags=209  mtu 1420
              inet 192.168.2.1 netmask 255.255.255.0  destination 192.168.0.1
              inet6 fd86:ea04:1115::1  prefixlen 64  scopeid 0x0
              unspec 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00  txqueuelen 1000  (UNSPEC)
              RX packets 0  bytes 0 (0.0 B)
              RX errors 0  dropped 0  overruns 0  frame 0
              TX packets 0  bytes 0 (0.0 B)
              TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
   ```

## 设置 WireGuard 客户端

设置客户端的过程类似与服务端，唯一区别就是配置文件不同

1. 生成客户端的一对密钥

   ```bash
   umask 077
   wg genkey | tee privatekey | wg pubkey > publickey
   ```

2. 客户端和服务器的配置文件 */etc/wireguard/wg0.conf* 之间的主要区别在于，该文件必须包含自己的 IP 地址，并且不包含 *ListenPort*，*PostUP*，*PostDown* 和 *SaveConfig*值。

   ```bash
   [Interface]
   PrivateKey = <Output of privatekey file that contains your private key>
   Address = 192.168.2.2/24
   ```

## 将客户端与服务端进行连接

有两种方法可以将对等信息添加到 WireGuard

### 方法一

1. 第一个方法是在客户端配置文件 */etc/wireguard/wg0.conf* 中添加服务器端的*公钥*，*公网 IP*，以及*端口号*

   ```bash
   [Peer]
   PublicKey = <Server Public key>
   Endpoint = <Server Public IP>:<Server ListenPort>
   AllowedIPs = 192.168.2.1/24
   PersistentKeepalive = 25
   ```

   - **AllowedIPs** 带有 CIDR 掩码的 IP（v4 或 v6）地址的逗号分隔列表，允许该对等方的传入流量从该 IP 访问，该对等方的出站流量定向到该列表（难以理解，换种方式说 拦截当前客户端发送给该 IP 列表的请求，通过 VPN 定向到服务器），可以使用*0.0.0.0/0*来匹配所有 IPv4 地址，以及*::/0*来匹配所有 IPv6 地址（换句话说，拦截客户端所有的请求均定向到服务器）。可以指定多次。

   - **PersistentKeepalive** 为了使状态防火墙或 NAT 映射永久保持有效的目的，将经过身份验证的空数据包发送到对等方的频率间隔（以秒为单位），介于 1 到 65535 之间。例如，如果接口很少发送流量，但是它随时可能从对等方接收流量，并且它位于 NAT 之后，则接口可能会受益于 25 秒的持续 keepalive 间隔。如果设置为 *0* 或 *off*，则禁用此选项。默认情况下或未指定时，此选项处于关闭状态。大多数用户将不需要设置此参数。

2. 在客户端和服务端均启动*wg*服务

   ```bash
   wg-quick up wg0
   systemctl enable wg-quick@wg0
   ```

### 方法二

1. 添加对等信息的第二种方法是使用命令行。由于 Wireguard 服务器的配置文件中指定了*SaveConfig*选项，因此该信息将自动添加到配置文件中。

   在服务端运行以下命令。将示例信息替换为客户端的

   ```bash
   sudo wg set wg0 peer <Client Public Key> endpoint <Client IP address>:<Client ListenerPort> allowed-ips <ip1>/<cidr1>,<ip2>/<cidr2>
   ```

   例如：

   ```bash
   sudo wg set wg0 peer <Client Public Key> endpoint 192.168.2.2:33879 allowed-ips 192.168.2.1/24
   ```

   客户端端口号可在客户端使用 `sudo wg show` 命令进行查看

2. 在客户端和服务端使用如下命令进行验证是否设置成功

   ```bash
   sudo wg
   ```

不管选择哪种方法将对等信息添加到 WireGuard，如果安装成功，在 `sudo wg` 命令的输出中应该有一个 **Peer** 部分。

```bash
user@localhost:~$ sudo wg
interface: wg0
 public key: vD2blmqeKsV0OU0GCsGk7NmVth/+FLhLD1xdMX5Yu0I=
 private key: (hidden)
 listening port: 51820

peer: iMT0RTu77sDVrX4RbXUgUBjaOqVeLYuQhwDSU+UI3G4=
 endpoint: 10.0.0.2:33879
 allowed ips: 192.168.2.1/24
```

重新启动服务后，此对等部分将自动添加到 *wg0.conf* 中。如果要立即将此信息添加到配置文件中，可以运行

```bash
wg-quick save wg0
```

可以使用相同的过程添加其他客户端。

## 测试连接

1. 在客户端中 ping 服务端

   ```bash
   ping 192.168.2.1
   sudo wg
   ```

   `wg`输出的最后两行会有如下类似信息

   ```bash
   latest handshake: 1 minute, 17 seconds ago
          transfer: 98.86 KiB received, 43.08 KiB sent
   ```

这表明您现在在服务器和客户端之间建立了专用连接。您也可以从服务器 ping 客户端，以验证连接是否可以同时进行。

## 翻墙

1. 在服务端开启 IP 转发功能

   - 临时生效

   ```bash
   echo 1 >/proc/sys/net/ipv4/ip_forward
   ```

   - 永久生效：在*/etc/sysctl.conf*添加

   ```bash
   net.ipv4.ip_forward = 1
   ```

   ```bash
   sysctl -p
   ```

2. 关闭客户端

   ```bash
   sudo wg-quite down wg0
   ```

3. 修改客户端 WireGurad 配置文件，表示服务器的 Peer 中 *AllowedIPs* 修改为 `AllowedIPs = 0.0.0.0/0, ::/0`

   ```bash
   [Peer]
   PublicKey = <Server Public key>
   Endpoint = <Server Public IP>:<Server ListenPort>
   AllowedIPs = 0.0.0.0/0, ::/0
   PersistentKeepalive = 25
   ```

   - AllowedIPs 的理解：对客户端向该地址列表发出的请求进行拦截转发，如果为 0.0.0.0/0，则将客户端发出的所有请求均进行拦截和转发。

4. 启动客户端

   ```bash
   sudo wg-quite up wg0
   ```

## 调试信息

如果您使用的是 Linux 内核模块，并且内核支持动态调试，则可以通过为模块启用动态调试来获得有用的运行时输出

```bash
# modprobe wireguard && echo module wireguard +p > /sys/kernel/debug/dynamic_debug/control
```
