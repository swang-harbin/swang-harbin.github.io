---
title: Nginx负载均衡
date: '2019-12-01 00:00:00'
tags:
- Nginx
---

# Nginx负载均衡
跨多个应用实例的负载均衡技术, 可以优化资源利用率, 最大化吞吐量, 减少延迟, 并确保容错配置.

可以使用Nginx作为非常有效的HTTP负载均衡器, 将流量分发给几个应用程序服务器, 提高web服务器的性能,及可伸缩性, 可扩展性.

## Nginx支持的负载均衡方法

- 轮询: 对应用程序的请求以循环的方式发布
- 最少连接: 将连接分配给活跃连接数最少的服务器
- ip哈希: 基于客户机的IP地址进行哈希运算, 来确定将请求分配给哪个服务器

## 配置负载均衡

在nginx.conf中配置相关信息

### 轮询方式

```nginx
http {
    # 定义一组均运行了相同应用的服务器, 组名称为myapp1
    upstream myapp1 {
        # 使用域名方式或IP:port
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
Nginx的负载均衡包含对HTTP, HTTPS, FastCGI, uwsgi, SCGI, memcached, and gRPC的反向代理.

### 最少连接的负载平衡

该分配方式对应用程序实例更公平些, 同时请求需要更长的时间来完成. nginx将新的请求分配给不太繁忙的服务器.

```nginx
upstream myapp1 {
    # 使用最少连接的负载平衡
    least_conn;
        server srv1.example.com;
    server srv2.example.com;
    server srv3.example.com;
}
```

### ip-hash负载平衡
ip-hash负载平衡, 会将客户端和服务器绑定, 即, 一个客户端的请求始终会被同一个服务器处理, 除非该服务器不可用.

```nginx
upstream myapp1 {
    ip_hash;
    server srv1.example.com;
    server srv2.example.com;
    server srv3.example.com;
}
```
### 加权的负载平衡
在上面例子中, 没有配置权重, 意味着所有的服务器具有相同的权重. 

使用weight在设置权重

```nginx
upstream myapp1 {
    server srv1.example.com weight=3;
    server srv2.example.com;
    server srv3.example.com;
}
```

如果有5个请求, 3个会分配到srv1, 1个分配给srv2, 1个分配给srv3.

也可以使用在最少连接和ip-hash负载均衡

## 健康检查
nginx默认实现健康检查, 如果一个服务器请求出错, nginx将会标记这个错误的服务器, 并且避免将之后的请求分配到该服务器

max_fails参数定义请求出错几次将该服务器标记为错误, 默认值为1, 如果设置为0, 健康检查将会对该服务器失效. fail_timeout定义多长时间解除服务器失败的标记.

## 参考文档
[官方文档 Using nginx as HTTP load balancer](http://nginx.org/en/docs/http/load_balancing.html)

[使用Nginx实现负载均衡](https://blog.csdn.net/gu_wen_jie/article/details/82149003)
