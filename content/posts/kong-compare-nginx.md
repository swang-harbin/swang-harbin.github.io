---
title: Kong对比Nginx负载均衡
date: '2019-12-11 00:00:00'
tags:
- Kong
- Nginx
categories:
- Kong
---
# Kong对比Nginx负载均衡
## 介绍和准备环境

由于Kong是基于Openresty的, 而Openresty又是对Niginx的二次封装, 所以有很多配置与Nginx类似.

举一个典型的Nginx负载均衡配置的例子
```nginx
# 这里包含着上游服务的位置信息
upstream upstream-name {
    server 10.1.3.15:8080 weight=100;
    server 10.1.3.16:8081 weight=50
}

# 这是Nginx的反向代理服务
server {
    listen 80;
    location /hello {
        proxy_pass http://upstream-name;
    }
}
```
nginx监听来自本地80端口的请求, 如果路径与/hello匹配, 便将请求原封不动的转发到名称为upstream-name的upstream, 而该upstream配置了一个负载均衡器, 可以路由到10.1.3.15:8080和10.1.3.16:8081

// todo 示例

在10.1.3.15:8080和10.1.3.16:8081上部署两个项目, 访问路径为/hello/hi, 分别返回"10.1.3.15:8080"和"10.1.3.16:8081". 

对于Kong的安装和启动此处不做介绍

## 对比Kong和Nginx的upstream和target

### Kong

创建一个叫upstream-name 的 upstream
```bash
curl -i -X POST http://kong:8001/upstreams \
    -- data "name=upstream-name"
```

添加两个负载均衡节点, 即两个真实的服务
```bash
curl -i -X POST http://kong:8081/upstreams/upstreams-name/targets \
    --data "target=10.1.3.15:8080" \
    --data "weight=100"
    
curl -i -X POST http://kong:8081/upstreams/upstreams-name/targets \
    --data "10.1.3.16:8081" \
    --data "weight=50"
```
### Nginx

```nginx
upstream upstream-name {
    server 10.1.3.15:8080 weight=100;
    server 10.1.3.16:8081 weight=50
}
```

## 对比Kong和Nginx的service和route

### Kong

配置一个service(反向代理服务), host对应upstream-name

```bash
curl -i -X POST http://kong:8001/services \
    --data "name=service-name" \
    --data "host=upstream-name"
```

为上面的service配置route信息
```bash
curl -X POST http://localhost:8001/services/service-name/routes/ \
    --data "hosts[]=route's IP or domain" \
    --data "path[]=/hello"
```

请求路径以**/hello**开头的请求都会被路由到对应的代理服务进行处理, 该代理服务使用负载均衡算法选择并调用一个真实服务. 

### Nginx

```nginx
location /hello {
    proxy_pass http://upstream-name;
}
```

## 测试Kong负载均衡

```bash
curl http://route's IP or domain:8000/hello/hi
```

2/3概率返回10.1.3.15:8080, 1/3概率返回10.1.3.16:8081. 

## 遇到的问题

通过上述方式访问, 我遇到过返回404的问题, 通过对真实服务添加Filter调试发现, 
使用浏览器访问`http://route's IP or domain:8000/hello/hi`, 后台真实访问的是`http://route's IP or domain:8000/hi`, 缺少了**/hello**路径, 具体原因暂未探讨, 请注意, 使用的kong版本为1.4.0.


## 参考文档
[初识 Kong 之负载均衡](https://blog.csdn.net/zy_281870667/article/details/79966649)
