---
title: 给已运行的容器添加端口映射
date: '2020-03-09 00:00:00'
tags:
- Docker
categories:
- Docker
---
# 给已运行的容器添加端口映射

**注 :** 该方法需要重启docker服务

## 查看正在运行中的容器

```bash
[root@localhost ~]$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                    NAMES
b19505cec84d        tomcat              "catalina.sh run"        4 minutes ago       Up 2 seconds        0.0.0.0:8888->8080/tcp   affectionate_driscoll
```

当前容器将容器的8080端口与宿主机的8888端口进行了映射


## 停止需要修改端口映射的容器

```bash
[root@localhost ~]$ docker stop b195
b195
```

## 修改相应容器的配置文件

配置文件在`/var/lib/docker/containers/{container id}`目录下

### 修改hostconfig.json

在PortBindings中添加/删除新的端口映射关系, 此处添加容器的9080与宿主机的9999端口映射关系
```json
{
    "Binds":null,
    "ContainerIDFile":"",
    "LogConfig":{
        "Type":"json-file",
        "Config":{

        }
    },
    "NetworkMode":"default",
    "PortBindings":{
        "8080/tcp":[
            {
                "HostIp":"",
                "HostPort":"8888"
            }
        ],
        "9080/tcp":[
            {
                "HostIp":"",
                "HostPort":"9999"
            }
        ]
    },
    "RestartPolicy":{
        "Name":"no",
        "MaximumRetryCount":0
    },
    ...
}
```

### 修改config.v2.json

修改Config->ExposedPorts中的信息

```json
{
    "StreamConfig":{

    },
    "State":{
        "Running":false,
        "Paused":false,
        "Restarting":false,
        "OOMKilled":false,
        "RemovalInProgress":false,
        "Dead":false,
        "Pid":0,
        "ExitCode":143,
        "Error":"",
        "StartedAt":"2020-03-09T07:46:49.757023507Z",
        "FinishedAt":"2020-03-09T07:48:41.124615166Z",
        "Health":null
    },
    "ID":"b19505cec84d0e0a10a1583e1c5fa71c385e6fde21478e3bf90428169390598f",
    "Created":"2020-03-09T07:42:49.197745561Z",
    "Managed":false,
    "Path":"catalina.sh",
    "Args":[
        "run"
    ],
    "Config":{
        "Hostname":"b19505cec84d",
        "Domainname":"",
        "User":"",
        "AttachStdin":false,
        "AttachStdout":false,
        "AttachStderr":false,
        "ExposedPorts":{
            "8080/tcp":{

            },
            "9080/tcp":{

            }
        },
        "Tty":false,
        "OpenStdin":false,
        "StdinOnce":false,
       
    },
    ...
}
```

## 重启docker服务
```bash
systemctl restart docker
```
## 启动相应容器
```bash
docker start b19505cec84d
```
