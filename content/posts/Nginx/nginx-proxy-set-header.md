---
title: Nginx 中 proxy_set_header 的作用
date: '2019-12-12 00:00:00'
tags:
- Nginx
---
# Nginx 中 proxy_set_header 的作用

参考文档：[nginx 中 proxy_set_header Host $host 的作用](https://www.cnblogs.com/yanghj010/p/5980974.html)

ginx 为了实现反向代理的需求而增加了一个 ngx_http_proxy_module 模块。其中 proxy_set_header 指令就是该模块需要读取的配置文件。在这里，所有设置的值的含义和 http 请求同中的含义完全相同，除了 Host 外还有 X-Forward-For。
Host 的含义是表明请求的主机名，因为 nginx 作为反向代理使用，而如果后端真是的服务器设置有类似防盗链或者根据 http 请求头中的 host 字段来进行路由或判断功能的话，如果反向代理层的 nginx 不重写请求头中的 host 字段，将会导致请求失败【默认反向代理服务器会向后端真实服务器发送请求，并且请求头中的 host 字段应为 proxy_pass 指令设置的服务器】。
  同理，X_Forward_For 字段表示该条 http 请求是有谁发起的？如果反向代理服务器不重写该请求头的话，那么后端真实服务器在处理时会认为所有的请求都来在反向代理服务器，如果后端有防攻击策略的话，那么机器就被封掉了。因此，在配置用作反向代理的 nginx 中一般会增加两条配置，修改 http 的请求头：
proxy_set_header Host $http_host;
proxy_set_header X-Forward-For $remote_addr;
这里的$http_host 和$remote_addr 都是 nginx 的导出变量，可以再配置文件中直接使用。如果 Host 请求头部没有出现在请求头中，则$http_host 值为空，但是$host 值为主域名。因此，一般而言，会用$host 代替$http_host 变量，从而避免 http 请求中丢失 Host 头部的情况下 Host 不被重写的失误。


X-Forwarded-For:简称 XFF 头，它代表客户端，也就是 HTTP 的请求端真实的 IP，只有在通过了 HTTP 代理或者负载均衡服务器时才会添加该项。它不是 RFC 中定义的标准请求头信息，在 squid 缓存代理服务器开发文档中可以找到该项的详细介绍。标准格式如下：X-Forwarded-For: client1, proxy1, proxy2。


这一 HTTP 头一般格式如下:
X-Forwarded-For: client1, proxy1, proxy2
其中的值通过一个 逗号+空格 把多个 IP 地址区分开，最左边(client1)是最原始客户端的 IP 地址，代理服务器每成功收到一个请求，就把请求来源 IP 地址添加到右边。在上面这个例子中，这个请求成功通过了三台代理服务器：proxy1, proxy2 及 proxy3。请求由 client1 发出，到达了 proxy3(proxy3 可能是请求的终点)。请求刚从 client1 中发出时，XFF 是空的，请求被发往 proxy1；通过 proxy1 的时候，client1 被添加到 XFF 中，之后请求被发往 proxy2;通过 proxy2 的时候，proxy1 被添加到 XFF 中，之后请求被发往 proxy3；通过 proxy3 时，proxy2 被添加到 XFF 中，之后请求的的去向不明，如果 proxy3 不是请求终点，请求会被继续转发。
鉴于伪造这一字段非常容易，应该谨慎使用 X-Forwarded-For 字段。正常情况下 XFF 中最后一个 IP 地址是最后一个代理服务器的 IP 地址，这通常是一个比较可靠的信息来源。
