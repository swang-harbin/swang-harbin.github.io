---
title: yum 安装 There are unfinished transactions remaining
date: '2019-10-25 00:00:00'
tags:
- Linux
---
# There are unfinished transactions remaining

## 原因
由于强制结束 yum 过，所以存在未完成的 yum 事物，建议运行 yum-complete-transaction 命令清除

## 解决方法

- 安装 yum-complete-transaction

  ```bash
  yum -y install yum-utils
  ```

- 清除 yum 缓存

  ```bash
  yum clearall
  ```

- 清除未完成事物

  ```bash
  yum-complete-transaction --cleanup-only
  ```

## 参考文档
[There are unfinished transactions remaining 解决方法](https://m.jb51.net/LINUXjishu/268748.html)
