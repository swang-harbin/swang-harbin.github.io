---
title: Linux 内存 buff/cache 占用过多
date: '2019-10-30 00:00:00'
tags:
- Linux
---
# Linux 内存 buff/cache 占用过多

## free 命令说明
使用 free 命令可以查看系统内存使用情况
```bash
Usage:
 free [options]

Options:
 -b, --bytes         show output in bytes
 -k, --kilo          show output in kilobytes
 -m, --mega          show output in megabytes
 -g, --giga          show output in gigabytes
     --tera          show output in terabytes
     --peta          show output in petabytes
 -h, --human         show human-readable output
     --si            use powers of 1000 not 1024
 -l, --lohi          show detailed low and high memory statistics
 -t, --total         show total for RAM + swap
 -s N, --seconds N   repeat printing every N seconds
 -c N, --count N     repeat printing N times, then exit
 -w, --wide          wide output

     --help     display this help and exit
 -V, --version  output version information and exit

For more details see free(1).

```

## buff/cache 说明
### 什么是 buff/cache

buffer 和 cache 是两个在计算机技术中被用滥的名词，放在不通语境下会有不同的意义。在 Linux 的内存管理中，这里的 buffer 指 Linux 内存的：Buffer cache。这里的 cache 指 Linux 内存中的：Page cache。翻译成中文可以叫做缓冲区缓存和页面缓存。在历史上，它们一个（buffer）被用来当成对 io 设备写的缓存，而另一个（cache）被用来当作对 io 设备的读缓存，这里的 io 设备，主要指的是块设备文件和文件系统上的普通文件。但是现在，它们的意义已经不一样了。在当前的内核中，page cache 顾名思义就是针对内存页的缓存，说白了就是，如果有内存是以 page 进行分配管理的，都可以使用 page cache 作为其缓存来管理使用。当然，不是所有的内存都是以页（page）进行管理的，也有很多是针对块（block）进行管理的，这部分内存使用如果要用到 cache 功能，则都集中到 buffer cache 中来使用。（从这个角度出发，是不是 buffer cache 改名叫做 block cache 更好？）然而，也不是所有块（block）都有固定长度，系统上块的长度主要是根据所使用的块设备决定的，而页长度在 X86 上无论是 32 位还是 64 位都是 4k。

### 什么是 page cache
Page cache 主要用来作为文件系统上的文件数据的缓存来用，尤其是针对当进程对文件有 read/write 操作的时候。如果你仔细想想的话，作为可以映射文件到内存的系统调用：mmap 是不是很自然的也应该用到 page cache？在当前的系统实现里，page cache 也被作为其它文件类型的缓存设备来用，所以事实上 page cache 也负责了大部分的块设备文件的缓存工作。

### 什么是 buffer cache
Buffer cache 则主要是设计用来在系统对块设备进行读写的时候，对块进行数据缓存的系统来使用。这意味着某些对块的操作会使用 buffer cache 进行缓存，比如我们在格式化文件系统的时候。一般情况下两个缓存系统是一起配合使用的，比如当我们对一个文件进行写操作的时候，page cache 的内容会被改变，而 buffer cache 则可以用来将 page 标记为不同的缓冲区，并记录是哪一个缓冲区被修改了。这样，内核在后续执行脏数据的回写（writeback）时，就不用将整个 page 写回，而只需要写回修改的部分即可

## 如何回收 cache

Linux 内核会在内存将要耗尽的时候，触发内存回收的工作，以便释放出内存给急需内存的进程使用。一般情况下，这个操作中主要的内存释放都来自于对 buffer/cache 的释放。尤其是被使用更多的 cache 空间。既然它主要用来做缓存，只是在内存够用的时候加快进程对文件的读写速度，那么在内存压力较大的情况下，当然有必要清空释放 cache，作为 free 空间分给相关进程使用。所以一般情况下，我们认为 buffer/cache 空间可以被释放，这个理解是正确的。

但是这种清缓存的工作也并不是没有成本。理解 cache 是干什么的就可以明白清缓存必须保证 cache 中的数据跟对应文件中的数据一致，才能对 cache 进行释放。所以伴随着 cache 清除的行为的，一般都是系统 IO 飙高。因为内核要对比 cache 中的数据和对应硬盘文件上的数据是否一致，如果不一致需要写回，之后才能回收

**手动回收 cache**

```bash
# 查看当前清理缓存的级别
cat /proc/sys/vm/drop_caches
```

- `echo 1 > /proc/sys/vm/drop_caches` : 表示清除 pagecache。
- `echo 2 > /proc/sys/vm/drop_caches`：表示清除回收 slab 分配器中的对象（包括目录项缓存和 inode 缓存）。slab 分配器是内核中管理内存的一种机制，其中很多缓存数据实现都是用的 pagecache。
- `echo 3 > /proc/sys/vm/drop_caches`：表示清除 pagecache 和 slab 分配器中的缓存对象。

## 参考文档
[解决 Linux buffer/cache 内存占用过高的办法](https://blog.csdn.net/ailice001/article/details/80353924)
