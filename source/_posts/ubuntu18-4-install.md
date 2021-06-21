---
title: Ubuntu18.4LST安装
date: '2020-04-27 00:00:00'
updated: '2020-04-27 00:00:00'

tags:
- Linux
- Ubuntu
categories:
- [Linux, Ubuntu]
---
# Ubuntu18.4LST安装

**已提供的软件包说明**
- ubuntu-18.04.4-desktop-amd64.iso: Ubuntu官方ISO镜像
- dbeaver-ce_latest_amd64.deb: 数据库管理工具
- google-chrome-stable_current_amd64.deb: 谷歌Chrome浏览器
- jetbrains-toolbox: 用于安装IDEA, PyCharm等开发工具
- wps-office_11.1.0.9505_amd64.deb: WPS的Linux版安装包

## 下载镜像

软件包中已经给准备好了: 

- [官方镜像版本库](http://releases.ubuntu.com/)
- [官方18.04.4ISO镜像下载](http://releases.ubuntu.com/18.04.4/ubuntu-18.04.4-desktop-amd64.iso)

## 制作U盘启动盘

- [在Windows上创建USB启动盘](https://ubuntu.com/tutorials/tutorial-create-a-usb-stick-on-windows)

### 制作启动盘的准备工作

- 一个大于4GB的U盘
- Windows XP以上的操作系统
- [Rufus](https://rufus.ie/), 一个开源的制作启动盘的软件
- Ubuntu的ISO镜像文件

### 选择使用的USB

使用Rufus执行以下操作来配置U盘

1. 启动Rufus
2. 插入U盘
3. Rufus将会在**Device**处显示插入的U盘信息
4. 通过下拉框选中作为启动盘的U盘

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142959.png)

### 选择引导方式和分区方案

- *Boot selection*选择**FreeDOS**
- *Partition scheme*选择**MBR**

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609143000.png)

### 选择Ubuntu ISO文件

点击*Boot selection*右侧的**SELECT**选择下载的Ubuntu ISO文件

选择适当的ISO文件, 然后单击"Open"

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609143001.png)

### 将ISO文件写入启动盘

*Volume label*会根据Ubuntu镜像自动更新

将其他参数保留其默认值, 然后单击**START**启动写入流程

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609143002.png)

### 附加文件下载

可能会提醒您Rufus需要附加文件才能完成ISO写入. 如果出现下方对话框, 请选择**YES**

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609143003.png)

### 写入警告提醒

选择*Write in ISO Image mode selected*并且点击**OK**

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609143004.png)

Rufus会警告在所选的U盘上的数据会被清除. ==请确认选中的设备是否正确, 会清除所有数据的!!==. 确认后点击**OK**即可

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609143005.png)

### 正式编写ISO文件

现在Rufus会将ISO写入到U盘, 进度条中会有提示信息, 总时间显示在Rufus的右下角. 大约10分钟左右可以写入完毕, 视电脑配置而定.

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609143006.png)

### 写入完成

当Rufus完成写入后, 状态栏会变为绿色, 并且在中心位置显示**READY**(就绪)字样. 选择**CLOSE**以完成写入过程.

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609143007.png)


## 开始安装系统

## 进入Ubuntu安装程序

1. 将启动盘插入电脑, 重启计算机, 并连续点击**ESC**按键

2. 出现下方页面后, 按**F9**

   ```
   启动菜单
   
   F1      系统信息
   F2      系统检测
   F9      启动设备选项
   F10     设置BIOS
   F11     系统恢复
   F12     网络启动
   
   ENTER - 继续启动
   
   更多咨询, 请参考:www.hp.com/go/techcenter/startup
   ```

3. 使用**↑↓**选择启动盘的名称, 按**Enter**. 我的启动盘是*USB硬盘(UEFI) - Generic STORAGE DEVICE (GENERIC STORAGE DEVICE)*

   ```
   启动选项菜单
   
   操作系统的管理员(UEFI) - ubuntu (SK hynix SC311 SATA 128GB)
   USB硬盘(UEFI) - Generic STORAGE DEVICE (GENERIC STORAGE DEVICE)
   内置网络设备(IPv4 UEFI)
   内置网络设备(IPv6 UEFI)
   从EFI文件启动
   
   及移动选择, **ENTER**确定.
   按**F10**进入**BIOS**设置, **ESC**退出.
   ```

4. 如下页面使用**↑↓**选择**Install Ubuntu**, 然后单击**Enter**

   ```
   Try Ubuntu without installing
   Install Ubuntu
   OEM install (for manufacturers)
   Check disc for defects
   ```

5. 此时正式进入Ubuntu的安装页面.

## 选择安装语言

默认选择*English*, 可以选择为*Chinese*, 选中后点击**Continue**

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609143008.png)

## 选择键盘样式

默认即可, 关于输入法, 需要后续手动安装.

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210621210357.png)

## 选择安装类型

可以选择标准安装或最小化安装, 此处选择标准安装

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210621210401.png)

## 是否清空磁盘

为了安装一个干净的系统, 建议提前将数据备份到外部存储设备, 此处选择删除所有数据.

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210621210402.png)

## 选择系统安装位置

将操作系统安装在哪个磁盘上, 因为公司电脑是128固态+1T机械的组合方式, 所以将系统安装到固态硬盘中, 系统运行速度会更快.

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210621210403.png)

## 手动分配存储空间

点击3.6中的++advanced partitioning tool++, 手动对磁盘进行分区

### 提前说明

先给一个我的分区方式, 如果各位对分区有更好的方式, 请告诉我, 因为我对此处也不是很了解.

- 固态硬盘

  ```
  /boot 1024M 1G
  /tmp 5120M 5G
  / 其余
  ```

- 机械硬盘

  ```
  /home 204800M   200G
  /var   204800M 200G
  /usr 204800M 200G
  /usr/local 102400M  100G
  /opt 102400M 100G
  剩余 200G 以后哪里需要挂哪里
  ```

再给一份分好后的样式

固态硬盘:
![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210621210404.png)

机械硬盘
![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210621210406.png)


### 实际操作

1. 首先点击**减号-**, 将除了*Type*为**efi**的分区全部删除.
2. 请观察*/dev/sda*, */dev/sdb*下**free space**的空间大小, 较小的是固态硬盘, 较大的是机械硬盘. 在我这sdb为固态硬盘, sda为机械硬盘, 分区规划按硬盘类型分, 而不是按盘符, 请自己查看对应关系.
3. 选中固态硬盘的**free space**后, 点击**加号+**, 弹出如下页面, 在*Size*框中输入分区的大小, 在*Mount point*处选择将分区挂载到哪个挂载点. 点击**OK**即可. 重复该步骤, 按照上方所给的分区规划, 进行分区(也可自行安排).

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210621210408.png)

4. *Device for boot loader installation*注意选择我们的固态硬盘!!
5. 分区完毕后点击**Install Now**开始安装.

## 选择时区

此处请选择中国, 用鼠标点击以下中国区域后, 点击**Continue**即可(图片有误, 请选择中国)

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210621210409.png)

## 创建一个普通用户

添加一个普通用户, 用来使用Ubuntu, 请勿在正式环境使用root用户执行所有操作

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210621210410.png)

## 正在安装

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210621210412.png)


## 安装成功, 重启电脑

出现如下提示, 证明系统已经安装完毕, 点击**Restart Now**会自动重启电脑, 此时可以将启动盘拔出电脑了.

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210621210413.png)

## 安装完毕后的一些设置

### 修改apt包管理器的源为国内源

点击**Super键**, 也叫**Win键**, **徽标键**. 在搜索框中搜索**Software&Updates**, 鼠标点击启动.

点击下方选项框, 选择**Other..** -> **China**, 此处我选择使用阿里的镜像

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210621210414.png)

### 安装无线网卡驱动

Ubuntu18.4和Ubuntu20.4均不自带无线网卡驱动, 这样是连不了wifi的.

依旧使用4.1中的**Software&Updates**, 点击菜单中的**Additional Drivers**, 按下图方式选中使用, 如果没有请稍等一会, 记得需要插网线哦.

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210621210416.png)

### 给root用户设置个密码

```bash
$ sudo passwd root
```
根据提示输入两次密码即可

## 一些常用软件的安装

### 输入法的安装

[RIME输入法官网](https://rime.im/)

此处安装RIME输入法, 搜狗官方也提供有搜狗输入法, 如需安装请自行了解

```bash
sudo apt -f install ibus-rime

ibus engine rime
```

如果执行第二条命令后发生报错或警告, 请重启电脑即可.
```bash
$ reboot
```

#### 设置输入法

1. 点击右上角右上角, 弹出框中的扳手图标.

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210621210417.png)

2. 点击**Region&Language**

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210621210418.png)

3. 点击**加号+*, 选择**Chinese**, 然后选择**Chinese(Rime)**

4. 稍等片刻, 使用`Super+Space`即可切换输入法. 

### Docker

#### 安装docker

[docker官方安装文档](https://docs.docker.com/engine/install/ubuntu/)

按顺序执行如下命令即可, 已将安装包下载源修改为Alibaba镜像源

```bash
$ sudo apt-get remove docker docker-engine docker.io containerd runc
$ sudo apt-get update
$ sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
$ curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
$ sudo add-apt-repository "deb [arch=amd64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
$ sudo apt-get update
$ sudo apt-get install docker-ce docker-ce-cli containerd.io
```

#### 修改docker库使用阿里镜像仓库

[阿里云容器镜像服务](https://cr.console.aliyun.com)

进入[阿里云docker镜像加速器](https://cr.console.aliyun.com/cn-hangzhou/instances/mirrors), 使用支付宝扫码登录后, 按照提示操作即可.

#### 将当前用户添加到docker组

将当前用户加入到docker组后, 在执行`docker`命令时, 就不需要添加`sudo`了

1. 查看docker组id

   ```bash
   $ sudo cat /etc/group | grep docker
   docker:x:999:
   ```

   我的docker组id为999, 如果有不同的, 请将后续命令中的id号更改为对应的

2. 将当前用户添加到docker组

   ```bash
   $ sudo usermod -aG 999 `whoami`
   ```

3. 重启计算机, 因为用户的组信息需要重新登录才会加载到内存

   ```bash
   $ reboot
   ```

4. 查看是否已在docker组中

   ```bash
   $ id
   ```

### 安装IntelliJ IDEA

最近发现JetBrains提供的ToolBox挺好的, 可以管理其公司旗下的所有软件, 例如PyCharm, WebStrom, IDEA等. 此处使用ToolBox安装IDEA. ToolBox安装包已提供

1. 安装toolbox

   ```bash
   $ ./jetbrains-toolbox
   ```

2. 使用toolbox安装IDEA, 启动Toolbox后, 需要等待一会, 现在IntelliJ IDEA Ultimate已经更新到2020.1版本, 点击Install按钮右侧的倒三角可以选择版本安装. 

### 数据库管理工具DBeaver安装

开源的, 使用JAVA语言基于eclipse开发的数据库管理工具. 已提供安装包
```bash
$ sudo apt -f install dbeaver-ce_latest_amd64.deb
```
### Google Chrome浏览器安装

已提供安装包
```bash
$ sudo apt -f install google-chrome-stable_current_amd64.deb
```

### WPS安装

首先使用`Ctrl+Alt+F3`进入到纯命令行界面, 如果F3不行就试试F4, F5.

```bash
$ sudo apt -f install wps-office_11.1.0.9505_amd64.deb
```
全程确认即可

### 截图软件安装

我使用Flameshot

```bash
$ sudo apt -f install flameshot
```

### GIMP安装

GIMP, 类似于PhotoShop的图像处理软件, 开源免费
```bash
$ sudo apt -f install gimp
```

## 其他说明

## 软件自启管理

<kbd>Super</kbd>键, 然后搜索**Startup Application**进行设置即可
