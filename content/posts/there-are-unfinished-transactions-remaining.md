---
title: yum安装There are unfinished transactions remaining
date: '2019-10-25 00:00:00'
tags:
- Linux
categories:
- Linux
---
# There are unfinished transactions remaining

## 原因
由于强制结束yum过,所以存在未完成的yum事物,建议运行yum-complete-transaction命令清除

## 解决方法

- 安装yum-complete-transaction

  ```bash
  yum -y install yum-utils
  ```

- 清除yum缓存

  ```bash
  yum clearall
  ```

- 清除未完成事物

  ```bash
  yum-complete-transaction --cleanup-only
  ```

## 参考文档
[There are unfinished transactions remaining解决方法](https://m.jb51.net/LINUXjishu/268748.html)
