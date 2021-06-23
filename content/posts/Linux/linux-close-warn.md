---
title: 关闭 Linux 警告声
date: '2020-04-09 00:00:00'
tags:
- Linux
---
# 关闭 Linux 警告声

可以通过下面的命令关掉它
```bash
rmmod pcspkr
```
如果你想重新打开它，可以使用下面的方法
```bash
modprobe pcspkr
```
当然，上面的方法只是临时起效，重新启动后 beep 依旧，彻底关掉 beep 的方法如下

如果用的是 bash 作 shell，在 ~/.bashrc 的最后添加
```bash
setterm -blength 0
xset -b
```

在 console 下
```bash
setterm -blength 0
```
在 X-win 的 terminal 下
```bash
xset -b
```


## 参考文档
[去掉 linux 警告音 嘟嘟声 错误提示音关闭方法](https://blog.csdn.net/yishengzhiai005/article/details/12705101/)
