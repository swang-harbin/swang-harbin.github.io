---
title: 在 Linux 中安装 Minikube
date: '2020-06-11 00:00:00'
tags:
- Kubernetes
---
# 在 Linux 中安装 Minikube

Minikube 是一种可以轻松在本地运行 Kubernetes 的工具。Minikube 在笔记本电脑的虚拟机（VM）内运行一个单节点 Kubernetes 集群，以供希望试用 Kubernetes 或每天使用它开发的用户使用。引用自 [Installing Kubernetes with Minikube](https://kubernetes.io/docs/setup/learning-environment/minikube/)

## 安装 kubectl

要安装 MiniKube 需要首先安装 kubectl

[kubectl 官方文档](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

### 在 Linux 上使用 curl 安装 kubectl 的二进制程序

1. 下载最新的发布程序

   ```bash
   curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
   ```

2. 给 kubectl 二进制文件添加可执行权限

   ```bash
   chmod +x ./kubectl
   ```

3. 移动二进制文件到 PATH 目录

   ```bash
   sudo mv ./kubectl /usr/local/bin/kubectl
   ```

4. 测试以确定安装的版本信息

   ```bash
   kubectl version --client
   ```

   安装成功会输出类似如下的信息

   ```
   Client Version: version.Info{Major:"1", Minor:"18", GitVersion:"v1.18.0", GitCommit:"9e991415386e4cf155a24b1da15becaa390438d8", GitTreeState:"clean", BuildDate:"2020-03-25T14:58:59Z", GoVersion:"go1.13.8", Compiler:"gc", Platform:"linux/amd64"}
   ```

### 启用 shell 自动补全功能

1. 安装 bash-completion

   ```bash
   yum/dnf/apt install bash-completion
   ```

2. 设置自动开启 kubectl 自动补全

   ```bash
   echo "source <(kubectl completion bash)" >> ~/.bashrc
   ```

## 安装 VirtualBox

Minikube 在 Linux 上支持 [VirtualBox](https://yq.aliyun.com/go/articleRenderRedirect?spm=a2c4e.11153940.0.0.7dd54cec5PSU1S&url=https%3A%2F%2Fwww.virtualbox.org%2Fwiki%2FDownloads)，[KVM2](https://yq.aliyun.com/go/articleRenderRedirect?spm=a2c4e.11153940.0.0.7dd54cec5PSU1S&url=https%3A%2F%2Fminikube.sigs.k8s.io%2Fdocs%2Fdrivers%2Fkvm2%2F)，[Docker](https://yq.aliyun.com/go/articleRenderRedirect?spm=a2c4e.11153940.0.0.7dd54cec5PSU1S&url=https%3A%2F%2Fminikube.sigs.k8s.io%2Fdocs%2Fdrivers%2Fdocker%2F)驱动，需要首先在系统上安装三个中的一个，阿里推荐使用 VirtualBox。

下载对应版本，使用 Linux 自带包管理器安装即可

## 安装 MiniKube

1. 通过阿里提供的国内镜像进行安装

   ```bash
   curl -Lo minikube https://kubernetes.oss-cn-hangzhou.aliyuncs.com/minikube/releases/v1.11.0/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
   ```

2. 启动 minikube, 使用 virtualbox 驱动和国内 docker 镜像

   ```bash
   minikube start --vm-driver=virtualbox --registry-mirror=https://xxxxxxxx.mirror.aliyuncs.com
   ```
   
   启动过程会输入如下类似信息
   
   ```bash
   😄  minikube v1.11.0 on Ubuntu 18.04
   ✨  Using the virtualbox driver based on existing profile
   👍  Starting control plane node minikube in cluster minikube
   🏃  Updating the running virtualbox "minikube" VM ...
   🐳  Preparing Kubernetes v1.18.3 on Docker 19.03.8 ...
       > download many file ...
   🔎  Verifying Kubernetes components...
   🌟  Enabled addons: default-storageclass, storage-provisioner
   🏄  Done! kubectl is now configured to use "minikube"
   ```

## 其他可能用到的命令

1. 重置 minikube, 删除所有缓存的镜像，重头开始

   ```bash
   rm -rf ~/.minikube
   ```

2. 查看 minikube 状态

   ```bash
   minikube status
   ```

3. 打开 minikube 的 dashboard

   ```bash
   minikube dashboard
   ```

4. 停止 minikube

   ```bash
   minikube stop
   ```

## 参考文档
- [Install Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/)
- [Minikube - Kubernetes 本地实验环境](https://yq.aliyun.com/articles/221687)
- [安装 minikuber](https://www.jianshu.com/p/f8ff367761b9)

