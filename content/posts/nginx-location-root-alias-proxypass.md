---
title: Nginx中location与root, alias, proxy_pass的使用
date: '2020-05-18 00:00:00'
tags:
- Nginx
categories:
- Nginx
---
# Nginx中location与root, alias, proxy_pass的使用


## location与root

root后的文件路径是否有`/`效果是相同的, **会将location后面的xxx拼接到root配置的路径后**
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

`/xxx/index.html`均可以访问到`/path/to/static/xxx/index.html`资源


## location与alias

按如方式配置, alias配置的路径后必须包含`/`, **不会将location后面的xxx拼接到root配置的路径后**

```nginx
location /xxx/ {
    alias /path/to/static/;
}
```
使用`/xxx/index.html`访问, 可访问到`/path/to/static/index.html`文件

## location与proxy_pass

对`proxy_pass`的配置包含如下两种情况

1. backend后面没有`/`: 

   ```nginx
   location /xxx/ {
       proxy_pass http://192.168.1.1:8080;
   }
   ```

2. backend后面有`/`: 

   ```nginx
   location /xxx/ {
       proxy_pass http://192.168.1.1:8080/;
   }
   ```

如果此时有一个请求为Url为`/xxx/endpoint`
- 第1种向backend发送的请求为`http://192.168.1.1:8080/xxx/endpoint`, 包含location中的配置
- 第2种向backend发送的请求为`http://192.168.1.1:8080/endpoint`， 不包含location中的配置

