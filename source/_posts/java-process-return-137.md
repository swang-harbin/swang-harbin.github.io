---
title: Java使用Process.waitFor()返回137
date: '2020-06-10 00:00:00'
updated: '2020-06-10 00:00:00'
tags:
- Exception
- Java
categories:
- Java
---

# Java使用Process.waitFor()执行python返回137

在Java中使用Process类的waitFor()方法执行python程序, 返回结果值为137. 参考如下Linux程序退出状态码:

| 状态码 | 含义                                     |
| :----- | :--------------------------------------- |
| 0      | 命令成功结束                             |
| 1      | 一般性未知错误                           |
| 2      | 不适合的shell命令                        |
| 126    | 命令不可执行                             |
| 127    | 没找到命令                               |
| 128    | 无效的退出参数                           |
| 128+x  | 与Linux信号x相关的严重错误, 相当于kill x |
| 130    | 通过Ctrl+C终止的命令                     |
| 255    | 正常范围之外的退出状态码                 |

137 = 128 + 9, 即python程序被`kill -9`命令杀死了

参考

- [解析java结果137](https://www.jb51.cc/java/122123.html)
- [Linux内核OOM killer机制](https://blog.csdn.net/s_lisheng/article/details/82192613)

使用如下命令查看日志

```bash
egrep -i -r 'killed process' /var/log
```

可见

```bash
/var/log/messages:Jun 10 09:28:33 10-20-73-69 kernel: Killed process 56524 (python) total-vm:7681564kB, anon-rss:6813304kB, file-rss:24kB
```

使用主机内存共15G, 可用内存11G, 同时跑两个该python程序即可造成OOM, 所以Linux内核将不可运行的算法程序直接kill掉了

## 参考文档

- [解析java结果137](https://www.jb51.cc/java/122123.html)
- [Linux内核OOM killer机制](https://blog.csdn.net/s_lisheng/article/details/82192613)

- [Linux命令退出状态码](http:)
- [Linux内核OOM killer机制](http:)
