---
layout: post
title: 后台运行jar包
subheading:
author: swang-harbin
categories: java
banner:
tags: java
---

# 后台运行jar包

## nohup介绍

run a command immune to hangups, with output to a non-tty

运行命令不被挂起, 并输出到非tty

```shell
sage: nohup COMMAND [ARG]...
  or:  nohup OPTION
运行命令, 忽略挂起信号
Run COMMAND, ignoring hangup signals.

      --help     display this help and exit
      --version  output version information and exit
如果基本输入是终端, 请从/dev/null重定向它
If standard input is a terminal, redirect it from /dev/null.
如果标准输出是终端, 将输出追加到'nohup.out'文件(如果可能), 否则追加到'$HOME/nohup.out'
If standard output is a terminal, append output to 'nohup.out' if possible, '$HOME/nohup.out' otherwise.
如果基本错误输出是终端, 请将它重定向到标准输出
If standard error is a terminal, redirect it to standard output.
将标准输出到FILE, 使用'nohup COMMAND > FILE'
To save output to FILE, use 'nohup COMMAND > FILE'.
```

将标准输出重定向到nohup.out, 此时并不会后台运行程序

```shell
nohup COMMAND
```

将标准输出重定向到指定文件, 此时并不会后台运行程序

```shell
nohup COMMAND > xxx.log
```

**nohup不会自动将命令后台运行, 你必须在命令行尾添加一个'&'来明确指定后台运行该命令**

后台运行命令, 并将标准输出重定向默认的nohup.Out

```shell
nohup COMMAND &
```

后台运行命令, 并将标准输出重定向到指定文件

```shell
nohup COMMAND > xxx.log &
```

后台运行命令, 并将标准错误重定向到标准输出, 再将标准输出重定向到指定文件

```shell
nohup COMMAND > xxx.file 2>&1 &
```

- 0: standard input
- 1: standard output
- 2: standard error

2>&1是将标准错误(2)重定向到标准输出(&1), 标准输出(&1)再被重定向输入到xxx.file文件中。

如果标准错误输出是终端, 它通常会重定向到和标准输出相同的文件描述符. 然而, 如果标准输出被关闭, 标准错误终端会代替上面的nohup.out或$HOME/nohup.out, 标准输出会输出到标准错误终端.

## 常用后台运行jar命令

```shell
nohup java -jar xxx.jar > xxx.log 2>&1 &
```