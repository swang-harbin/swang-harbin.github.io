---
title: Linux 服务器运维基本操作
date: '2020-06-01 22:46:44'
tags:
- Linux
---

# Linux 服务器运维基本操作

## SSH 远程连接

SSH 为 Secure Shell 的缩写，是一种网络安全协议，转为远程登录会话和其他网络服务提供安全性的协议。通过使用 SSH，可以把传输的数据进行加密，有效防止远程管理过程中的信息泄露问题。

从客户端来看，有两种验证方式

- 基于密码
- 基于密钥


**非对称加密**

有一对密钥：公钥和私钥

公钥用来加密，私钥用来解密


### 基于用户名密码验证

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210607235658.png)

1. 当客户端发起 ssh 请求，服务器会把自己的公钥发送给用户
2. 用户会根据服务器发来的公钥对密码进行加密
3. 加密后的信息回传给服务器，服务器用自己的私钥解密，如果密码正确，则用户登录成功

### 基于密钥验证

https://edu.aliyun.com/lesson_1718_14301#_14301

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210607235659.png)


## 挂载（mount）命令

在 Linux 系统中，挂载是指将一个设备（通常是存储设备）挂接到一个已存在的目录上。通过访问这个挂载目录来访问存储设备中的文件。

命令格式：
```bash
mount [-t vfstype] [-o options] device dir
```

- `-t vfstype`：指定文件系统类型，通常不必指定，mount 会自动选择正确的类型。
  
    常用类型有：
    - 光盘或光盘镜像：iso9660
    - DOS fat16 文件系统：msdos
    - Windows 9x fat32 文件系统
    - Windows NT ntfs 文件系统：ntfs
    - UNIX（Linux）文件网络共享：nfs
    
- `-o options`：主要用来描述设备的挂载方式。
    常用类型有：
    - loop：用来把一个文件当成硬盘分区挂接上系统
    - ro：采用只读方式挂接设备
    - rw：采用读写方式挂接设备
    - iocharset：指定访问文件系统所用的字符集

- `device`：要挂接（mount）的设备
- `dir`：设备在系统上的挂载点（mount point）

### 挂载光盘镜像文件

1. 建立挂载点

   ```bash
   mkdir /mnt/vcdrom
   ```

2. 挂载 iso 文件

   ```bash
   # mount -t iso9660 -o loop /path/to/iso/myiso.iso /mnt/vcdrom
   ```

其他相关命令：

- 将当前光驱中的光盘制作成镜像文件

  ```bash
  # cp /dev/cdrom /path/to/output/ios/myiso.iso
  或
  # dd if=/dev/cdrom of=/path/to/ouput/iso/myios.ios
  ```

- 将文件和目录制作成光盘镜像文件

  ```bash
  # mkisofs -r -J -V myiso -o /path/to/output/iso/myiso.iso /path/to/input/
  ```

上方命令将 */path/to/input/* 目录下的所有目录和文件制作成光盘镜像文件 */path/to/output/iso/myiso.iso*，卷标为：*myiso*

### 挂载移动硬盘/U 盘

对 Linux 系统而言，USB 接口的移动设备当作 SCSI 设备对待。

1. 插入移动硬盘之前，应先用 `fdisk -l` 或 `more /proc/partitions` 查看系统的硬盘和硬盘分区情况

   ```bash
   # fdisk -l
   ```

2. 插入移动硬盘/U 盘后

   ```bash
   # fdisk -l
   ```

   系统会多了一个 SCSI 硬盘 /dev/sdc 和磁盘分区 /dev/sdc1，/dev/sdc1 就是我们要挂载的 U 盘。可能为 /dev/sd 开头的任意设备

3. 创建挂载点

   ```bash
   # mkdir -p /mnt/usb
   ```

4. 挂载设备

   ```bash
   # mount -t vfat /dev/sdc1 /mnt/usb
   ```

5. 如果汉字文件名显示为乱码或不显示，可使用如下命令

   ```bash
   # mount -t vfat -o iocharset=cp936 /dev/sdc1 /mnt/usb
   ```

### 挂载 Windows 文件共享

Windows 网络共享的核心是 SMB/CIFS，在 linux 下要挂载 windows 的磁盘共享，就必须安装和使用 samba 软件包。如果未安装，可在 `www.samba.org` 下载。此处没有关于 Windows 设置共享的说明

1. 创建挂载点

   ```bash
   # mkdir -p /mnt/samba
   ```

2. 挂载

   ```bash
   # mount -t smbfs -o username=administrator,password=1234 //192.168.1.105/c$ /mnt/samba
   ```

   `administrator` 和 `1234` 是 ip 地址为 `192.168.1.105` 的 Windows 计算机的一个用户名和密码，`c$` 是这台计算机的一个磁盘共享。

上方方法未进行测试，之前使用的挂载方式如下

```bash
# mount -t cifs -o username=administractor,password=1234,uid=1001,gid=1001 //192.168.1.105/share /mnt/windows
```

将 192.168.1.105 机器上的共享文件夹 share 挂载到 /mnt/windows 目录下，其中 username，password 为 Windows 机器的一个用户名和密码，uid 和 gid 为 linux 上一个用户的 uid 和 gid，指定 uid 和 gid 可使当前挂载点所属者和所属组为指定用户，否则默认为 root 用户

### 挂载 UNIX 系统 NFS 文件共享

#### Linux 服务端配置

在 Linux 客户端挂载 NFS 磁盘共享前，必须先配置好 NFS 服务端。

1. 服务端安装 nfs-utils 和 rpcbind

   ```bash
   // CentOS
   # yum install -y nfs-utils rpcbind
   
   // Ubuntu
   # apt install nfs-kernel-server
   ```

2. 修改 *etc/exports*，添加共享目录

   ```bash
   /home/export/dir1 192.168.1.101(rw)
   /home/export/dir2 *(rw)
   /home/export/dir3 linux-client-hostname(rw)
   ```

   此处 */home/export*下的 *dir1*，*dir2*，*dir3* 为共享目录，*192.168.1.101*，*\**，*linux-client-hostname* 是被允许挂载此共享 linux 客户机的 IP 地址或主机名。如果要使用主机名 *linux-client-hostname*，必须在服务端主机 */etc/hosts* 文件中添加  *linux-client-hostname* 主机 IP 定义。

   ```bash
   192.168.1.103 linux-client-hostname
   ```

3. 启动 rpcbind 和 NFS 服务

   ```bash
   # systemctl start rpcbind
   # systemctl start nfs
   ```

   或

   ```bash
   # /etc/rc.d/init.d/rpcbind start
   # /etc/rc.d/init.d/nfs start
   ```

4. 如对 */etc/export* 的配置进行了修改，使用如下命令重新加载配置

   ```bash
   # exportfs -rv
   ```

   或

   ```bash
   # systemct restart rpcbind
   # systemctl restart nfs
   ```

#### Linux 客户端配置

1. linux 客户端挂载其他类 Unix 系统的 NFS 共享，客户端安装 nfs 客户端

   ```bash
   // CentOS
   # yum install -y nfs-utils
   // Ubuntu
   # apt install nfs-common
   ```

2. 在客户端（192.168.1.101）查看服务端（192.168.1.105）分享盘信息

   ```bash
   showmount -e 192.168.1.105
   ```

3. 创建挂载点

   ```bash
   mkdir -p /mnt/nfs
   ```

4. 挂载

   ```bash
   # mount -t nfs -o rw 192.168.1.105:/home/export/dir2 /mnt/nfs
   ```

   此处挂载失败可以尝试

   ```bash
   # mount -t nfs -o rw -o v3 192.168.1.105:/home/export/dir2 /mnt/nfs
   ```

其他命令：

- `rpcinfo -p localhost`：查看 rpcbind 服务注册的端口列表
- 服务端其他参数
    | 参数             | 说明                                                         |
    | ---------------- | :----------------------------------------------------------- |
    | ro               | 只读访问                                                     |
    | rw               | 读写访问                                                     |
    | sync             | 所有数据在请求时写入共享                                     |
    | async            | nfs 在写入数据前可以响应请求                                 |
    | secure           | nfs 通过 1024 以下的安全 TCP/IP 端口发送                     |
    | insecure         | nfs 通过 1024 以上的端口发送                                 |
    | wdelay           | 如果多个用户要写入 nfs 目录，则归组写入（默认）                |
    | no_wdelay        | 如果多个用户要写入 nfs 目录，则立即写入，当使用 async 时，无需此设置 |
    | hide             | 在 nfs 共享目录中不共享其子目录                              |
    | no_hide          | 共享 nfs 目录的子目录                                        |
    | subtree_check    | 如果共享 /usr/bin 之类的子目录时，强制 nfs 检查父目录的权限（默认） |
    | no_subtree_check | 不检查父目录权限                                             |
    | all_squash       | 共享文件的 UID 和 GID 映射匿名用户 anonymous，适合公用目录   |
    | no_all_squash    | 保留共享文件的 UID 和 GID（默认）                              |
    | root_squash      | root 用户的所有请求映射成如 anonymous 用户一样的权限（默认）   |
    | no_root_squash   | root 用户具有根目录的完全管理访问权限                        |
    | anonuid=xxx      | 指定 nfs 服务器 /etc/passwd 文件中匿名用户的 UID             |
    | anongid=xxx      | 指定 nfs 服务器 /etc/passwd 文件中匿名用户的 GID             |

### 取消挂载

```bash
# umount /mnt/nfs
```
