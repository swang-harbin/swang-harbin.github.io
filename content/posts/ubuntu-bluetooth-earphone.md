---
title: Ubuntu连接不上蓝牙耳机
date: '2020-07-10 00:00:00'
tags:
- Linux
- Ubuntu
categories:
- Linux
- Ubuntu
---
# Ubuntu连接不上蓝牙耳机

[Kali-Linux安装驱动并使用Blueman连接蓝牙耳机](https://www.cnblogs.com/bobdylan/p/6933784.html)

## 安装蓝牙驱动

我使用的是台式机+蓝牙控制器，首先需要安装蓝牙驱动，否则开机会报错(最后一行)：

![img](https://images2015.cnblogs.com/blog/866825/201706/866825-20170602155643008-1958706418.jpg)

bluetooth hci0: firmware: failed to load brcm/BCM20702A1-0a5c-21ec.hcd (-2)

根据错误信息，上网搜索对应的蓝牙驱动，我在GitHub上找到了这个[BCM20702A1-0a5c-21ec.hcd](https://github.com/winterheart/broadcom-bt-firmware/blob/master/brcm/BCM20702A1-0a5c-21ec.hcd)驱动，下载后放到 /lib/firmware/brcm 目录下，重启即可加载。

## 安装Blueman

启动dbus和蓝牙服务(使用service或/etc/init.d/均可)：

```bash
service dbus start
/etc/init.d/bluetooth start
```

Blueman是个非常方便的图形化蓝牙管理软件，使用apt-get可以直接安装它：

```bash
apt-get install blueman
```

完成后左下角会出现蓝牙图标（也可使用blueman-applet手动启动）。

```bash
apt-get install pulseaudio pulseaudio-module-bluetooth pavucontrol bluez-firmware
```

安装音频相关模块，如果缺少这些模块的话，连接耳机将会出现
blueman.bluez.errors.DBusFailedError: Resource temporarily unavailable 的错误信息。

![img](https://images2015.cnblogs.com/blog/866825/201706/866825-20170602155720493-1374962365.png)

```bash
service bluetooth restart
killall pulseaudio
```

重启完蓝牙服务，这时候就可以与蓝牙耳机配对了，不过音质很差，需要在音频配置里选择高保真回放（A2DP信宿），如果报错的话，则还需要对配置文件进行一些修改。

## A2DP出错解决方案：

如果安装了模块，但是 pactl load-module module-bluetooth-discover 加载不了模块的话，需要手动修改一下配置。
参考[A2DP Bluetooth headset issues with PulseAudio 6.0](https://bbs.archlinux.org/viewtopic.php?id=194006)
帖子中17楼的做法：

1.编辑 /etc/pulse/default.pa 文件。

```bash
vim /etc/pulse/default.pa
```

2.找到load-module module-bluetooth-discover 并在前面加#将它注释掉：

```bash
# load-module module-bluetooth-discover
```

3.编辑 /usr/bin/start-pulseaudio-x11 文件

```bash
vim /usr/bin/start-pulseaudio-x11
```

找到下面的代码，并在它下面另其一行

```bash
if [ x”$SESSION_MANAGER” != x ] ; then
  /usr/bin/pactl load-module module-x11-xsmp “display=$DISPLAY session_manager=$SESSION_MANAGER” > /dev/null
fi
```

在它下面写入(两个fi中间) /usr/bin/pactl load-module module-bluetooth-discover，完整如下：

```bash
if [ x”$SESSION_MANAGER” != x ] ; then
  /usr/bin/pactl load-module module-x11-xsmp “display=$DISPLAY session_manager=$SESSION_MANAGER” > /dev/null
fi
  /usr/bin/pactl load-module module-bluetooth-discover
fi
```

重启服务：

```bash
service bluetooth restart
sudo pkill pulseaudio
```

![img](https://images2015.cnblogs.com/blog/866825/201706/866825-20170602160013211-54447082.png)

![img](https://images2015.cnblogs.com/blog/866825/201706/866825-20170602160031868-239402414.png)

这时候就可以在音频配置里选择A2DP了，音质瞬间变好了很多。

## Protocol not available错误解决方案：

输入命令加载module-bluetooth-discover模块即可：

```bash
# pactl load-module module-bluetooth-discover
```

