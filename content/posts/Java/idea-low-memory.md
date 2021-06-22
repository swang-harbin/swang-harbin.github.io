---
title: The IDE is running low on memory and this might affect performance. Please
  consider increasing available heap.
date: '2019-11-22 00:00:00'
tags:
- IDEA
- Exception
- Java
---

# The IDE is running low on memory and this might affect performance. Please consider increasing available heap.

## 报错原因

IDEA设置的堆内存过小, 需要修改IDEA的堆内存大小

## 解决方法

修改IDEA安装目录的bin目录下的**idea64.exe.vmoptions**配置文件, 将堆内存设置为2G(自定义)

```bash
-Xmx2048m
```

如果依旧出错, 在IDE页面点击**Help** -> **Change Memory Settings**, **Change Memory Settings**也可能在**Diagnostic**中

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222154640.png)

此处可以看到IDEA使用的配置文件位置, 可以通过输入框直接修改

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222154655.png)

## 参考文档

[【IDEA】The IDE is running low on memory and this might affect performance. Please consider increasing](https://blog.csdn.net/qq_36762765/article/details/102896007)
