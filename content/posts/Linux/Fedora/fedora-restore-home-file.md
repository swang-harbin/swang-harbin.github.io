---
title: Fedora 恢复 Home 目录
date: '2020-01-04 00:00:00'
tags:
- Linux
- Fedora
---
# Fedora 恢复 Home 目录

Fedora 误删了 home 目录下的文件夹，重建后，不显示图标，垃圾箱失效等问题。

1. 修改 ~/.config/user-dirs.dirs

   ```bash
   # This file is written by xdg-user-dirs-update
   # If you want to change or add directories, just edit the line you're
   # interested in. All local changes will be retained on the next run.
   # Format is XDG_xxx_DIR="$HOME/yyy", where yyy is a shell-escaped
   # homedir-relative path, or XDG_xxx_DIR="/yyy", where /yyy is an
   # absolute path. No other format is supported.
   # 
   XDG_DESKTOP_DIR="$HOME/Desktop"
   XDG_DOWNLOAD_DIR="$HOME/Downloads"
   XDG_TEMPLATES_DIR="$HOME/Templates"
   XDG_PUBLICSHARE_DIR="$HOME/Public"
   XDG_DOCUMENTS_DIR="$HOME/Documents"
   XDG_MUSIC_DIR="$HOME/Music"
   XDG_PICTURES_DIR="$HOME/Pictures"
   XDG_VIDEOS_DIR="$HOME/Videos"
   ```

2. 运行

   ```bash
   xdg-user-dirs-update
   ```

3. 如果隐藏文件也被删除了，家目录的模板文件夹在 /etc/skel 目录下，可以将其中的所有文件复制到家目录下，具体位置可查看 /etc/default/useradd 文件中的 SKEL 属性

   ```bash
   cp -r /etc/skel /home/用户名
   chown -R 用户名.主组 /home/用户名
   chmod 700 /home/用户名
   ```

