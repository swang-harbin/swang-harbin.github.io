---
title: Linux 创建桌面启动图标
date: '2019-12-25 00:00:00'
tags:
- Linux
---
# Linux 创建桌面启动图标


使用 vim 命令在 Desktop 目录下创建 app-name.desktop 文件，app-name 自定义

可参考 QQ 的桌面图标进行编写

```properties
[Desktop Entry]
Version=2.0.0-b1
Encoding=UTF-8
Name=腾讯 QQ
Comment=腾讯 QQ
Exec=/usr/share/tencent-qq/qq
Icon=/usr/share/tencent-qq/qq.png
Terminal=false
Type=Application
Categories=Application;Network;Tencent Software;
StartupNotify=true
Name[zh_CN]=腾讯 QQ
GenericName[zh_CN]=
Comment[zh_CN]=腾讯 QQ
```

