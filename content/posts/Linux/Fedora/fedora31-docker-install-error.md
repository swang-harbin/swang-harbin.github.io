---
title: Fedora31安装Docker报错
date: '2020-03-11 00:00:00'
tags:
- Docker
- Fedora
---
# Fedora31安装Docker报错

## 报错信息

```bash
docker: Error response from daemon: 
OCI runtime create failed: container_linux.go:346: starting container process caused "process_linux.go:297: 
applying cgroup configuration for process caused \"open /sys/fs/cgroup/docker/cpuset.cpus.effective: no such file or directory\"": unknown.
```

## 产生原因

fedora31默认使用cgroups v2, docker暂不支持cgroups v2.

[官方说明](https://fedoraproject.org/wiki/Common_F31_bugs#Docker_package_no_longer_available_and_will_not_run_by_default_.28due_to_switch_to_cgroups_v2.29) :
> The Docker package has been removed from Fedora 31. It has been replaced by the upstream package moby-engine, which includes the Docker CLI as well as the Docker Engine. However, we recommend instead that you use Package-x-generic-16.pngpodman, which is a Cgroups v2-compatible container engine whose CLI is compatible with Docker's. Fedora 31 uses Cgroups v2 by default. The moby-engine package does not support Cgroups v2 yet, so if you need to run the moby-engine or run the Docker CE package, then you need to switch the system to using Cgroups v1, by passing the kernel parameter systemd.unified_cgroup_hierarchy=0. To do this permanently, run:
```bash
sudo grubby --update-kernel=ALL --args="systemd.unified_cgroup_hierarchy=0"
```

## 解决方法

### 法1: 修改/etc/default/grub文件

1. 在该文件的GRUB_CMDLINE_LINUX=里面新增内容

   ```bash
   systemd.unified_cgroup_hierarchy=0
   ```

2. 保存退出后, 执行 :

   ```bash
   grub2-mkconfig
   ```

3. 重启机器


### 法2: 参照官方文档

执行:
```bash
sudo grubby --update-kernel=ALL --args="systemd.unified_cgroup_hierarchy=0"
```


## 参考文档
[Fedora 31安装docker](https://blog.csdn.net/QQ_DNS/article/details/103542133)
