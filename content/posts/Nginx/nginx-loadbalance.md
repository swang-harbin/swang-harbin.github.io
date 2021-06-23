---
title: Nginx 负载均衡
date: '2019-12-01 00:00:00'
tags:
- Nginx
---

# Nginx 负载均衡
跨多个应用实例的负载均衡技术，可以优化资源利用率，最大化吞吐量，减少延迟，并确保容错配置。

可以使用 Nginx 作为非常有效的 HTTP 负载均衡器，将流量分发给几个应用程序服务器，提高 web 服务器的性能，及可伸缩性，可扩展性。

## Nginx 支持的负载均衡方法

- 轮询：对应用程序的请求以循环的方式发布
- 最少连接：将连接分配给活跃连接数最少的服务器
- ip 哈希：基于客户机的 IP 地址进行哈希运算，来确定将请求分配给哪个服务器

## 配置负载均衡

在 nginx.conf 中配置相关信息

### 轮询方式

```nginx
http {
    # 定义一组均运行了相同应用的服务器，组名称为 myapp1
    upstream myapp1 {
        # 使用域名方式或 IP:port
        server srv1.example.com:;
        server srv2.example.com;
        server 192.168.12.25:3349;
    }

    server {
        listen 80;

        location / {
            # 此处使用了组名称
            proxy_pass http://myapp1;
        }
    }
}
```
Nginx 的负载均衡包含对 HTTP、HTTPS、FastCGI、uwsgi、SCGI、memcached and gRPC 的反向代理。

### 最少连接的负载平衡

该分配方式对应用程序实例更公平些，同时请求需要更长的时间来完成。nginx 将新的请求分配给不太繁忙的服务器。

```nginx
upstream myapp1 {
    # 使用最少连接的负载平衡
    least_conn;
        server srv1.example.com;
    server srv2.example.com;
    server srv3.example.com;
}
```

### ip-hash 负载平衡
ip-hash 负载平衡，会将客户端和服务器绑定，即，一个客户端的请求始终会被同一个服务器处理，除非该服务器不可用。

```nginx
upstream myapp1 {
    ip_hash;
    server srv1.example.com;
    server srv2.example.com;
    server srv3.example.com;
}
```
### 加权的负载平衡
在上面例子中，没有配置权重，意味着所有的服务器具有相同的权重。

使用 weight 在设置权重

```nginx
upstream myapp1 {
    server srv1.example.com weight=3;
    server srv2.example.com;
    server srv3.example.com;
}
```

如果有 5 个请求，3 个会分配到 srv1，1 个分配给 srv2，1 个分配给 srv3。

也可以使用在最少连接和 ip-hash 负载均衡

## 健康检查
nginx 默认实现健康检查，如果一个服务器请求出错，nginx 将会标记这个错误的服务器，并且避免将之后的请求分配到该服务器

max_fails 参数定义请求出错几次将该服务器标记为错误，默认值为 1，如果设置为 0，健康检查将会对该服务器失效。fail_timeout 定义多长时间解除服务器失败的标记。

## 参考文档
[官方文档 Using nginx as HTTP load balancer](http://nginx.org/en/docs/http/load_balancing.html)

[使用 Nginx 实现负载均衡](https://blog.csdn.net/gu_wen_jie/article/details/82149003)
