---
title: CentOS7 安装和卸载 Docker
date: '2019-10-19 00:00:00'
tags:
- Docker
- CentOS
---
# CentOS7 安装和卸载 Docker

## 使用 yum 命令安装 Docker

### 准备环境

**卸载旧版本**

```bash
sudo yum remove docker docker-client docker-client-lastest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine
```

### 安装社区版

#### 建立仓库

- 安装必须包

  ```bash
  sudo yum install -y yum-utils device-mapper-persistent-data lvm2
  ```

- 设置稳定的仓库(stable repository)

  ```bash
  sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  ```

    > **可选项：使用 nightly 或者 test 仓库**
    >
    > 使用 nightly 仓库
    >
    > ```bash
    > sudo yum-config-manager --enable docker-ce-nightly
    > ```
    > 使用 test 仓库
    > ```bash
    > sudo yum-config-manager --enable docker-ce-test
    > ```
    > 取消使用 nightly 或 test 库
    > ```bash
    > sudo yum-config-manager --disable docker-ce-nightly
    > ```

### 安装 Docker 引擎(Engine)

- 安装最新版本

  ```bash
  sudo yum install docker-ce docker-ce-cli containerd.io
  ```

  **注意事项：**使用 `yum install` 或 `yum update` 不指定版本，会安装/更新为最新的版本

  > 安装特定版本
  >
  > 查看所有版本
  >   ```bash
  >   sudo yum list docker-ce --shouduplicates | sort -r
  >   
  >   docker-ce.x86_64  3:18.09.1-3.el7                     docker-ce-stable
  >   docker-ce.x86_64  3:18.09.0-3.el7                     docker-ce-stable
  >   docker-ce.x86_64  18.06.1.ce-3.el7                    docker-ce-stable
  >   docker-ce.x86_64  18.06.0.ce-3.el7                    docker-ce-stable
  >   ```
  >
  > 安装特定版本
  >   ```bash
  >   sudo yum install docker-ce-<VERSION_STRING> docker-ce-cli-<VERSION_STRING> containerd.io
  >   
  >   例：
  >   sudo yum install docker-ce-18.06.0 docker-ce-cli-18.06.0 containerd.io
  >   ```


- 开启服务
```bash
sudo systemctl start docker
```

- 验证
```bash
sudo docker run hello-world
```

## 使用 rpm 包安装 Docker

### 安装 Docker

#### 下载安装包
下载地址：https://download.docker.com/linux/centos/7/x86_64/stable/Packages/

> 如需下载 nightly 或 test 版，只需将下载路径中的 stable 修改为 nightly 或 test

#### 安装
```bash
sudo yum install /path/to/package.rpm
```

#### 启动
```bash
sudo systemctl start docker
```

#### 验证
```bash
sudo docker run hello-world
```


## 卸载 Docker
### 卸载 Docker 包
```bash
sudo yum remove docker-ce
```

### 移除镜像，容器以及数据
```bash
sudo rm -rm /var/lib/docker
```

### 删除所有手动编写的配置文件

## 参考文档
[docker 官方文档](https://docs.docker.com/)
