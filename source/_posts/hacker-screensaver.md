---
title: 黑客屏保
date: '2020-04-26 00:00:00'
updated: '2020-04-26 00:00:00'
tags:
- Linux
categories:
- Linux
---
# 黑客屏保

1. 安装所需依赖包

   ```bash
   sudo dnf install ncurses*
   ```

2. 下载源码包

   ```bash
   wget https://jaist.dl.sourceforge.net/project/cmatrix/cmatrix/1.2a/cmatrix-1.2a.tar.gz
   ```

3. 解压源码包

   ```bash
   tar -zxvf cmatrix-1.2a.tar.gz
   ```

4. 进入源码包

   ```bash
   cd cmatrix-1.2a/
   ```

5. 释放编译文件

   ```bash
   sudo ./configure --prefix=/opt/cmatrix/
   ```

6. 编译

   ```bash
   sudo make
   ```

7. 安装

   ```bash
   sudo make install
   ```

8. 可将命令建立软链接到bin

   ```bash
   sudo ln -s /opt/cmatrix/bin/cmatrix /bin/cmatrix
   ```


## 参考文档

[Linux下cmatrix的安装和使用(黑客屏保)](https://www.lxh1.com/2019/12/06/linux_appendix/Linux%E4%B8%8Bcmatrix%E7%9A%84%E5%AE%89%E8%A3%85%E5%92%8C%E4%BD%BF%E7%94%A8(%E9%BB%91%E5%AE%A2%E5%B1%8F%E4%BF%9D)/)
