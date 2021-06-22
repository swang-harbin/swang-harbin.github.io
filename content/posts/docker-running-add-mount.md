---
title: 给已运行的容器添加挂载点
date: '2020-03-13 00:00:00'
tags:
- Docker
categories:
- Docker
---
# 给运行中的容器添加挂载点

## 方式一: 修改配置文件方式

**注 :** 此方式需要重启docker服务

1. 查看需要修改的容器ID

   ```bash
   [root@localhost ~]# docker ps
   CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                      NAMES
   b19505cec84d        tomcat              "catalina.sh run"        3 days ago          Up 4 minutes        0.0.0.0:8888->8080/tcp     affectionate_driscoll
   ```

2. 停止docker服务

   ```bash
   systemctl stop docker
   ```

3. 修改配置文件
    `/var/lib/docker/containers/{container-id}/hostconfig.json`, 在Binds中添加一个挂载点数组, ":"前为宿主机目录, 后面为docker容器目录

  ```json
  {
      "Binds":[
          "/host/folder:/container/folder",
          "/host/folder2:/container/folder2"
      ],
      "ContainerIDFile":"",
      "LogConfig":{
          "Type":"json-file",
          "Config":{
  
          }
      },
  ```

4. 修改配置文件
    `/var/lib/docker/containers/{container id}/config.v2.json`, 修改MountPoints的配置, 注意对应关系

  ```json
      "MountLabel":"",
      "ProcessLabel":"",
      "RestartCount":0,
      "HasBeenStartedBefore":true,
      "HasBeenManuallyStopped":false,
      "MountPoints":{
          "/container/folder":{
              "Source":"/host/folder",
              "Destination":"/container/folder",
              "RW":true,
              "Name":"",
              "Driver":"",
              "Type":"bind",
              "Propagation":"rprivate",
              "Spec":{
                  "Type":"bind",
                  "Source":"/host/folder",
                  "Target":"/container/folder"
              },
              "SkipMountpointCreation":false
          },
          "/container/folder2":{
              "Source":"/host/folder2",
              "Destination":"/container/folder2",
              "RW":true,
              "Name":"",
              "Driver":"",
              "Type":"bind",
              "Propagation":"rprivate",
              "Spec":{
                  "Type":"bind",
                  "Source":"/host/folder2",
                  "Target":"/container/folder2"
              },
              "SkipMountpointCreation":false
          }
      },
      "SecretReferences":null,
      "ConfigReferences":null,
      "AppArmorProfile":"",
  ```

5. 启动docker服务

   ```bash
   systemctl start docker
   ```

6. 启动docker容器

   ```bash
   docker start container-id
   ```

## 方式二: 提交现有容器为镜像, 然后重新运行

1. 查看当前容器

   ```bash
   [root@localhost ~]# docker ps
   CONTAINER ID        IMAGE               COMMAND             CREATED              STATUS              PORTS               NAMES
   1c12559054c6        tomcat              "catalina.sh run"   About a minute ago   Up About a minute   8080/tcp            mount-test
   ```

2. 将当前容器提交为新镜像

   ```bash
   docker commit old-container-id new-image-name
   
   docker commit 1c12559054c6 mount-test-temp
   ```

3. 查看镜像

   ```bash
   [root@localhost ~]# docker images
   REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
   mount-test-temp     latest              9df6912cea3f        6 seconds ago       529MB
   ```

4. 使用该镜像运行新的容器, 并添加挂载目录

   ```bash
   docker run -itd -v /host/folder:/container/folder image-name
   
   docker run -itd -v /host/folder:/container/folder mount-test-temp
   ```

5. 如需将新容器名称修改为与旧容器相同

   - 停止并删除旧容器

     ```bash
     docker stop old-container-id; docker rm old-container-id
     ```

   - 重命名新容器

     ```bash
     docker rename new-container-id old-container-name
     ```

## 方式三: export容器为镜像, 使用import为新镜像

1. 将容器导出为文件

   ```bash
   docker export -o outfile/path/outfile.tar container-id
   ```

   > -o: 将输入内容写到文件, 即将容器导出为文件

2. 将导出的文件添加为新镜像

   ```bash
   docker import outfile/path/outfile.tar new-image-name
   ```

3. 查看镜像

   ```bash
   [root@localhost ~]# docker images
   REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
   export-test-temp    latest              42c12cbe83f0        4 seconds ago       521MB
   ```

4. 使用该镜像运行新的容器, 并添加挂载目录

   ```bash
   docker run -itd -v /host/folder:/container/folder image-name
   
   docker run -itd -v /host/folder:/container/folder mount-test-temp
   ```

5. 如需将新容器名称修改为与旧容器相同

   - 停止并删除旧容器

     ```bash
     docker stop old-container-id; docker rm old-container-id
     ```

   - 重命名新容器

     ```bash
     docker rename new-container-id old-container-name
     ```

## 参考文档
[docker-修改容器的挂载目录三种方式](https://blog.csdn.net/zedelei/article/details/90208183)
