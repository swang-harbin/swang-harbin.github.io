---
title: Linux创建桌面启动图标
date: '2019-12-25 00:00:00'
tags:
- Linux
categories:
- Linux
---
# Linux创建桌面启动图标


使用vim命令在Desktop目录下创建app-name.desktop文件, app-name自定义

可参考QQ的桌面图标进行编写

```properties
[Desktop Entry]
Version=2.0.0-b1
Encoding=UTF-8
Name=腾讯QQ
Comment=腾讯QQ
Exec=/usr/share/tencent-qq/qq
Icon=/usr/share/tencent-qq/qq.png
Terminal=false
Type=Application
Categories=Application;Network;Tencent Software;
StartupNotify=true
Name[zh_CN]=腾讯QQ
GenericName[zh_CN]=
Comment[zh_CN]=腾讯QQ
```

