---
title: 服务注册与发现
date: '2019-12-09 00:00:00'
tags:
- Kong
---
# 服务注册与发现

## 使用 Admin API 添加服务

使用 cUrl 命令添加服务

```shell
curl -i -X POST \
--url http://localhost:8001/services/ \
--data 'name=log-service' \
--data 'url=http://localhost:18081'
```

**说明**

- `--url http://localhost:8001/services/`

  向该 url 发送请求，因为 kong 装在本机，所以 IP 使用 localhost

- `--data 'name=log-service'`

  该次请求提交的数据，name 是指定当前的服务名称

- `--data 'url=http://localhost:18081'`

  该次请求提交的数据，url 是被添加服务的 url，因为测试的服务在本机，所以 IP 使用 localhost

关于该接口的详细参数，见官方文档 [Service Object](https://docs.konghq.com/1.4.x/admin-api/#service-object)

## 为服务添加路由

```shell
curl -i -X POST \
--url http://localhost:8001/services/log-service/routes \
--data 'name=log-route' \
--data 'hosts[]=10.1.100.152'
```

**说明**

- `--url http://localhost:8001/services/log-service/routes`

  url 请求格式：/services/{service name or id}/routes，为 name=log-service 的服务添加一个路由

- `--data 'name=log-route'`

  设置路由名称为 log-route

- `--data 'hosts[]=10.1.100.152'`

  设置请求头中的 Host 为 10.1.100.152，也可以设置为 example.com 格式

完成上述两步后，Kong 将会反向代理所有向指定主机（host[]指定的主机）发送的请求，并将这些请求路由到与其关联的上游 URL（upstream URL，第一步中通过 `--data 'url=xx'` 指定的 url）

关于该接口的详细参数，见官方文档 [Route Object](https://docs.konghq.com/1.4.x/admin-api/#route-object)

## 通过 kong 访问服务

```shell
curl -i -X GET \
--url http://10.1.100.152:8000/logController/login \
--header 'Host:10.1.100.152'
```

**说明**

- `--url http://10.1.100.152:8000/logController/login`

  使用 Kong 的 IP 和端口，访问被添加服务的 /logController/login 接口

- `--header 'Host:10.1.100.152'`

  指定请求头中的 Host，与上一步中的 host[] 对应


也可以使用浏览器直接访问
```http
http://10.1.100.152:8000/logController/login
```

## 参考文档

[Configuring a Service](https://docs.konghq.com/1.4.x/getting-started/configuring-a-service/)
