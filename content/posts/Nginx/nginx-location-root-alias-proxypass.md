---
title: Nginx 中 location 与 root，alias，proxy_pass 的使用
date: '2020-05-18 00:00:00'
tags:
- Nginx
---
# Nginx 中 location 与 root，alias，proxy_pass 的使用


## location 与 root

root 后的文件路径是否有 `/` 效果是相同的，**会将 location 后面的 xxx 拼接到 root 配置的路径后**
```nginx
location /xxx/ {
    root /path/to/static;
}
```
```nginx
location /xxx/ {
    root /path/to/static/;
}
```

`/xxx/index.html` 均可以访问到 `/path/to/static/xxx/index.html` 资源


## location 与 alias

按如方式配置，alias 配置的路径后必须包含 `/`，**不会将 location 后面的 xxx 拼接到 root 配置的路径后**

```nginx
location /xxx/ {
    alias /path/to/static/;
}
```
使用 `/xxx/index.html` 访问，可访问到 `/path/to/static/index.html` 文件

## location 与 proxy_pass

对 `proxy_pass` 的配置包含如下两种情况

1. backend 后面没有 `/`

   ```nginx
   location /xxx/ {
       proxy_pass http://192.168.1.1:8080;
   }
   ```

2. backend 后面有 `/`

   ```nginx
   location /xxx/ {
       proxy_pass http://192.168.1.1:8080/;
   }
   ```

如果此时有一个请求为 Url 为 `/xxx/endpoint`
- 第 1 种向 backend 发送的请求为 `http://192.168.1.1:8080/xxx/endpoint`，包含 location 中的配置
- 第 2 种向 backend 发送的请求为 `http://192.168.1.1:8080/endpoint`，不包含 location 中的配置

