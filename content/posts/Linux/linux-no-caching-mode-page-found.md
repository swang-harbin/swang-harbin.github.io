---
title: No Caching mode page found
date: '2019-12-03 00:00:00'
tags:
- Linux
- Exception
---
# No Caching mode page found

## 错误原因
使用UltraISO只做的启动盘安装CentOS7时, 提示No Caching mode page found, 稍后会一直弹出信息, 这是因为CentOS找不到镜像位置造成的

## 解决办法

在如下界面按<kbd>Tab</kbd>,调出命令行

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142955.png)

将
```bash
vmlinuz initrd=initrd.img inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 quiet
```
修改为
```bash
vmlinuz initrd=initrd.img linux dd quiet
```
按<kbd>Enter</kbd>查看U盘信息

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142958.png)

重启电脑
将

```bash
vmlinuz initrd=initrd.img inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 quiet
```
修改为

```bash
# /dev/sdb4为安装盘的盘符
vmlinuz initrd=initrd.img inst.stage2=hd:/dev/sdb4 quiet

或

#由于系统位数限制, 将LABEL=CentOS\x207\x20x8之后的数据截断了, 相应删除即可
vmlinuz initrd=initrd.img inst.stage2=hd:LABEL=CentOS\x207\x20x8 quiet
```
<kbd>Enter</kbd>

