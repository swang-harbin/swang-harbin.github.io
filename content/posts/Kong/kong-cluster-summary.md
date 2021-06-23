---
title: Kong 集群部署总结
date: '2019-12-12 00:00:00'
tags:
- Kong
---
# Kong 集群部署总结

## 准备工作
本次使用的各个软件版本为
- CentOS 7
- Windows 10
- PostgreSQL：v10.11
- Kong v1.4.2
- npm v8.11.3
- Nginx: v1.16.1
- Konga v-

## 整体介绍

### 架构图

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142953.png)

其中，Konga、Request-Nginx、AdminAPI-Nginx 和其中一个 Kong 安装在 Windows，另一个 Kong，2 个 logController 和 1 个 testController 部署在 CentOS。

CentOS 系统 IP：10.1.100.152

Windows 系统 IP：10.1.7.187

Kong 均使用 8000 作为调用服务的端口，使用 8001 作为访问 Admin API 端口。

Request-Nginx 代理客户的请求，对请求进行负载均衡，并监听 9000 端口。

AdminAPI 在 Konga 和 Kong 集群之间传输数据，对 Konga 的请求进行负载均衡，并监听 9001 端口。

log-upstream 的反向代理路由只处理 /logRoute 开头的请求，test-upstream 的反向代理路由只处理 /testRoute 开头的请求。

logController 中方法的访问路径为 /logController/login，使用 18081 和 18082 端口

testController 中方法的访问路径为 /testController/test，使用 18083 端口


## 部署及配置说明

### kong 的配置介绍

1. CentOS 中的 kong.conf

   ```bash
   # 设置任意 IP 均可以通过反向代理监听的端口
   proxy_listen=0.0.0.0:8000,0.0.0.0:8443 ssl
   # 设置任意 IP 均可以通过 Admin API 监听的端口
   admin_listen=0.0.0.0:8001,0.0.0.0:8444 ssl
   
   # 设置数据库信息，需提前创建数据库
   
   # 数据库类型，本次使用 PostgresSQL
   database=postgres
   # 数据库 IP
   pg_host=127.0.0.1
   # 数据库端口
   pg_port=5432
   # 数据库用户名
   pg_user=kong
   # 数据库密码
   pg_password=kong
   # 数据库名称
   pg_database=kong
   ```

2. Windows 使用了 docker 进行安装

   安装及启动命令

   ```bash
   docker run -d --name kong --network=kong-net 
   -e "KONG_DATABASE=postgres" 
   -e "KONG_PG_HOST=10.1.100.152" 
   -e "KONG_PROXY_ACCESS_LOG=/dev/stdout" 
   -e "KONG_ADMIN_ACCESS_LOG=/dev/stdout" 
   -e "KONG_PROXY_ERROR_LOG=/dev/stderr" 
   -e "KONG_ADMIN_ERROR_LOG=/dev/stderr" 
   -e "KONG_PROXY_LISTEN=0.0.0.0:8000, 0.0.0.0:8443 ssl" 
   -e "KONG_ADMIN_LISTEN=0.0.0.0:8001, 0.0.0.0:8444 ssl" 
   -p 8000:8000 
   -p 8443:8443 
   -p 8001:8001 
   -p 8444:8444 
   kong:1.4.2
   ```

   如果使用 linux 的 docker 需要在上述命令中添加 `--privileged=true`, 给 kong 应用授权

### 添加代理服务，负载均衡及路由

详解可参见 [Kong 对比 Nginx 负载均衡](./kong-compare-nginx.md)

1. logController

   ```java
   curl -X POST http://10.1.100.152:8001/upstreams \
   	--data 'name=log-upstream'
   	
   curl -X POST http://10.1.100.152:8001/upstreams/log-upstream/targets \
   	--data "target=10.1.100.152:18081" \
   	--data "weight=100"
   	
   curl -X POST http://10.1.100.152:8001/upstreams/log-upstream/targets \
   	--data "target=10.1.100.152:18082" \
   	--data "weight=50"
   	
   curl -X POST http://10.1.100.152:8001/services/ \
       --data "name=log-service" \
       --data "host=log-upstream"
   
   # 注意此处的 paths[] 参数
   # 当通过 paths 中的一个匹配到一个 Route 后，会将匹配到的前缀从发送给上游服务的请求中剔除掉
   # 可通过将 strip_path 设置为 false, 取消剔除，默认值为 true, 本文不做修改
   # 例如访问 http:10.1.7.187:8000/logRoute/logController/login
   # 到达上游服务的 url 实际可能 http:10.1.100.152:18081/logController/login
   curl -X POST http://10.1.100.152:8001/services/log-service/routes/ \
       --data "hosts[]=10.1.100.152&hosts[]=10.1.7.187" \
   	--data "paths[]=/logRoute"
   ```

2. 添加 testController

   ```java
   curl -X POST http://10.1.100.152:8001/upstreams \
   	--data 'name=test-upstream'
   	
   curl -X POST http://10.1.100.152:8001/upstreams/test-upstream/targets \
   	--data "target=10.1.100.152:18083" \
   	--data "weight=100"
   	
   curl -X POST http://10.1.100.152:8001/services/ \
       --data "name=test-service" \
       --data "host=test-upstream"
   	
   curl -X POST http://10.1.100.152:8001/services/test-service/routes/ \
       --data "hosts[]=10.1.100.152&hosts[]=10.1.7.187" \
   	--data "paths[]=/testRoute"
   ```

此时已对真实的服务做了反向代理和负载均衡。可通过 http://10.1.7.187:8000/logRoute/logController/login，http://10.1.100.152:8000/logRoute/logController/login，http://10.1.7.187:8000/testRoute/testController/test，http://10.1.100.152:8000/testRoute/testController/test 访问真实服务，并通过 http://10.1.7.187:8001/routes，http://10.1.100.152:8001/routes 访问 Admin API 接口获取所有 routes 信息。

### 对 Kong 的端口进行反向代理和负载均衡

#### 访问端口(8000)

nginx.conf

```nginx
events {
}
http {
	upstream kong {
	   server 10.1.100.152:8000;
	   server 10.1.7.187:8000;
	}
	server {
	   listen 9000;
	   location / {
	       # 一定要添加该条，否则会访问不同 kong 的 route 
		   proxy_set_header Host $http_host;
		   proxy_pass http://kong;
	   }
	}
}
```

此时可通过 http://10.1.7.187:9000/logRoute/logController/login 或 http://10.1.7.187:9000/testRoute/testController/test 访问真实服务

#### Admin API 端口(8001)

nginx.conf

```nginx
events {
}
http {
	upstream kong-admin {
        server 10.1.7.187:8001;
		server 10.1.100.152:8001;
    }
	server {
		listen 9001;
		location / {
			allow all;
			proxy_pass http://kong-admin;
		}
	}
}
```

此时可通过 http://10.1.7.187:9001/routes 访问 kong 的 Admin API，并获取所有的 route 信息。

## 安装 Konga

[GitHub 地址](https://github.com/pantsel/konga)

测试环境不需要做数据库，拉下代码，直接 npm install → npm start 即可。

生产环境需要使用到数据库，来存储账号等信息。

具体步骤参照 GitHub 下方说明即可。

