---
title: ocker 用集装箱装运（Containerizing）一个应用
date: '2019-10-19 00:00:00'
tags:
- Docker
---
# Docker 用集装箱装运（Containerizing）一个应用

## 描述
1. Create and test individual containers for each component of your application by first creating Docker images.
2. Assemble your containers and supporting infrastructure into a complete application, expressed either as a Docker stack file or in Kubernetes YAML.
3. Test, share and deploy your complete containerized application.

## 建立

### 拉取示例代码
```bash
git clone -b v1 https://github.com/docker-training/node-bulletin-board
cd node-bulletin-board/bulletin-board-app
```

### 编写 Dockerfile
```dockerfile
FROM node:6.11.5    

WORKDIR /usr/src/app
COPY package.json .
RUN npm install    
COPY . .

CMD [ "npm", "start" ] 
```

**说明**

- `FROM`

  指定程序使用的基础镜像，必须为第一个命令

- `WORKDIR`

  指定文件中后续的指令执行时所在的目录

- `COPY`

  将主机上的文件拷贝到镜像中

- `RUN`

  在镜像中执行的命令

参考文档

- [Dockerfile 文件详解](https://www.cnblogs.com/panwenbin-logs/p/8007348.html)
- [官方说明](https://docs.docker.com/get-started/part2/)

## 构建和测试镜像

### 构建一个新镜像
```bash
docker image build -t bulletinboard:1.0 .
```

### 基于该镜像启动一个容器
```bash
docker container run --publish 8000:8080 --detach --name bb bulletinboard:1.0
```
**说明**

- `--publish 8000:8080`

  指定入方向端口为 8000，出方向端口为 8080，并且，防火墙规则默认禁止网路访问该容器

- `--detach`

  要求 Docker 后台运行该容器

- `--name`

  指定一个容器名称，在之后的操作中可以引用该名称

**注意：**在启动容器的时候我们不需要输入其他任何的指定，因为在 Dockerfile 的 `CMD` 中我们已经指定了需要执行的命令，Docker 会自动去执行那些命令。

### 测试
使用浏览器访问 localhost:8000

### 删除容器
```bash
docker container rm --force bb
```
