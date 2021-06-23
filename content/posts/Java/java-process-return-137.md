---
title: Java 使用 Process.waitFor()执行 python 返回 137
date: '2020-06-10 00:00:00'
tags:
- Exception
- Java
---

# Java 使用 Process.waitFor()执行 python 返回 137

在 Java 中使用 Process 类的 waitFor() 方法执行 python 程序，返回结果值为 137。参考如下 Linux 程序退出状态码

| 状态码 | 含义                                     |
| :----- | :--------------------------------------- |
| 0      | 命令成功结束                             |
| 1      | 一般性未知错误                           |
| 2      | 不适合的 shell 命令                        |
| 126    | 命令不可执行                             |
| 127    | 没找到命令                               |
| 128    | 无效的退出参数                           |
| 128+x  | 与 Linux 信号 x 相关的严重错误，相当于 kill x |
| 130    | 通过 Ctrl+C 终止的命令                     |
| 255    | 正常范围之外的退出状态码                 |

137 = 128 + 9，即 python 程序被 `kill -9` 命令杀死了

使用如下命令查看日志

```bash
egrep -i -r 'killed process' /var/log
```

可见

```bash
/var/log/messages:Jun 10 09:28:33 10-20-73-69 kernel: Killed process 56524 (python) total-vm:7681564kB, anon-rss:6813304kB, file-rss:24kB
```

使用主机内存共 15G，可用内存 11G，同时跑两个该 python 程序即可造成 OOM，所以 Linux 内核将不可运行的算法程序直接 kill 掉了

## 参考文档

- [解析 java 结果 137](https://www.jb51.cc/java/122123.html)
- [Linux 内核 OOM killer 机制](https://blog.csdn.net/s_lisheng/article/details/82192613)
