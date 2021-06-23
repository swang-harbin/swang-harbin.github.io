---
title: 'bad interpreter: No such file or directory'
date: '2019-12-09 00:00:00'
tags:
- Linux
---
# bad interpreter: No such file or directory

## 错误提示
- bash: /usr/bin/yum: /usr/bin/python: 坏的解释器：没有那个文件或目录

- bash: /usr/bin/yum: /usr/bin/python: bad interpreter: No such file or directory

## 解决办法

查看 /usr/bin 目录中包含的 python 版本
```bash
ll /usr/bin | grep python
```

查看 /usr/bin/yum 文件（yum 的配置文件）
```bash
vim /usr/bin/yum
```

将已存在的 **pythonX** 修改为 **python**, 记得先备份一下 **pythonX**.
```bash
cp python2 python2.bak
mv python2 python
```

## 参考文档
[安装完 python3 之后，执行 yum 出错，bash: /usr/bin/yum: /usr/bin/python: 坏的解释器：没有那个文件或目录](https://blog.csdn.net/wtwcsdn123/article/details/84836064)
