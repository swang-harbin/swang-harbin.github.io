---
title: Nginx新手入门
date: '2019-12-01 00:00:00'
updated: '2019-12-01 00:00:00'
tags:
- Nginx
categories:
- Nginx
---
# Nginx新手入门

## Nginx简介

Nginx有一个主进程和几个工作进程, 主进程负责读取配置和维护工作进程. 工作进程对请求作出实际的处理. Nginx通过基本事件模块及操作系统来高效的对工作进程进行任务的分配. 所有的工作进程都是在配置文件中定义的, 这些配置文件可能在一个固定的位置, 也可能是根据可用的CPU内核数自动调整的.

Nginx和其模块的工作方式是在配置文件中确定的. 配置文件的默认名称是```nginx.conf```, 存放位置在```/usr/local/nginx/conf``` 或 ```/etc/nginx``` 或 ```/usr/local/etc/nginx```.

## 启动, 停止及重载配置
通过可执行文件启动nginx, 启动后可通过以下命令来控制nginx
```bash
nginx -s signal
```
其中```signal```可被下列参数替换
- stop : 立即停止
- quit : 优雅的停止
- reload : 重新加载配置文件
- reopen : 重启日志文件

当执行reload命令后, 如果执行成功, 主进程启动新的工作进程, 并要求旧的工作进程自动结束. 否则, 主进程会回滚改变并使旧的配置继续运行, 旧的工作进程会接收到停止的命令, 将当前所有正在处理的请求完成后自动停止这些工作进程.

signal也能在Unix工具的帮助下发送到nginx进程, 例如`kill`命令. nginx的主进程PID默认是记录在`nginx.pid`文件中的, 位置在`/usr/localnginx/logs`或`/var/run`目录下. 执行如下命令, 优雅的退出nginx.
```bash
kill -s QUIT PID
```

## 配置文件
nginx的模块和控制指令都是在配置文件中定义的. 指令分为简单指令和指令快. 简单指令是格式为
```nginx
key val;
```
块指令的格式为
```nginx
name {
    key1 val1; 
    key2 val2;
}
```
如果块指令被()包围, 则他被称为上下文
```nginx
(
    events {
        key1 val1;
    }
    
    http {
        key2 val2;
        
        server {
            key3 val3;
        }
    }
    
)
```

指令放在除配置文件以外的任何地方, 都被认为是主上下文. ```events```和```http```命令在主上下文, ```server```在```http```中, ```location```在```server```中.

## 通过nginx服务访问静态内容

创建两个目录```/data/www```(里面放html页面), ```/data/images```(里面放一些图片). 这时就需要在**http块**的**server块**中添加两个**location块**. 通常, server块中包含多个location块, 他们通过监听的端口和服务名称区分, 一旦nginx决定哪个服务解决请求, 他会检验location中定义URI

```nginx
# 配置文件中需要包含该标签, 不然会报错
events {

}

http {
    server {
        # 这里指定了使用"/"前缀与请求的URI进行比对
        location / {
            # root后是本地的文件路径
            # 查找文件时, 会将前缀/拼接到该文件路径后方, /data/www/
            root /data/www;
        }
        location /images/ {
            # /data/images/
            root /data;
        }
    }
}
```
如果请求匹配, 那么该URI会被添加root指令指定的路径下. 匹配会优先匹配长的前缀, 如果多个前缀均可以匹配, 会使用最长的前缀.

重启nginx, 默认监听80端口的请求.如果请求以```/images/```开头, 例如```http://localhost/images/example.png```, nginx会返回```/data/images/example.png```, 如果文件不存在, 返回404; 如果请求不以```/images/```开头, 将会映射到```/data/www```目录, 例如```http://localhost/some/example.html```, 将会返回```/data/www/some/example.html```.

如果一些事情没有按照预期的方式发生, 可以查看```access.log``` 和 ```error.log```文件, 位于```/usr/local/nginx/logs``` 或 ```/var/log/nginx```目录下.

## 建立一个简单的代理服务

将nginx作为代理服务器是一个频繁的情形, 就是说服务器将请求发送到代理服务器, 然后检索相应它, 并将相应发送给客户端.

配置一个基本的代理服务器, 服务请求通过代理服务器请求一个图片, 然后代理服务器将本地的图片响应给客户端. 在这个例子中, 两个服务将会定义在各自的nginx实例中. 

### 创建一个被代理的服务

重新解压一份新的nginx, 在nginx.conf中使用如下配置, 并在**/data/up1**文件夹中创建一个**example.json**, 内容随意.
```nginx
events {

}
http {
    server {
        listen 8080;
        root /data/up1;

        location / {

        }
    }
}
```
这会创建一个普通的服务, 监听8080端口, 并将所有的请求映射到本地的/data/up1目录. 此时root指令是在```server```的上下文中, 如果使用location块来相应请求, 并且其内部没有指定root指令, 那么会使用上下文中的root指令来作为它的root指令

### 创建代理服务器
重新解压一份新的nginx, 在nginx.conf中使用如下配置, 并在**/data/images**创建一个**example.png**
```nginx
events {

}
http {
    server {
        location / {
            proxy_pass http://localhost:8080/;
        }

        location ~\.(gif|jpg|png)$ {
            root /data/images;
        }
    }
}
```

指定**代理服务器**的**协议**, **服务名**和**端口**作为**proxy_pass指令**的参数

第二个location块使用了正则表达式, 此时会匹配所有以```.gif```, ```.jpg``` 或 ```.png```结尾的URI. 正则表达式需要有一个~符号在前面, 符合的请求会被映射到```/data/images```目录, 而其他的请求都会被映射到上面的代理服务器. 

当nginx选择了一个```location```块去服务请求, 它第一次会检查详细的```location```指令, 记住其中最长的那个前缀, 然后再去匹配正则表达式, 如果正则匹配成功, 就使用匹配成功的, 否则, 使用之前记录的最长的那个前缀

## 测试访问
此时被代理的服务器端口为8080, 代理服务器的端口为80, 通过访问代理服务器```http://localhost:80/example.json``` 或 ```http://localhost:80/example.png```进行测试.

## 建立一个FastCGI代理

可以使用Nginx将请求路由到一个FastCGI(Fast Common Gateway Interface)服务器, 最基本的配置方式为:
```nginx
http{
    server {
        location / {
            # 被代理的服务器协议+名称+端口
            fastcgi_pass  localhost:9000;
            # 设置通过FaseCGI服务器的参数
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            fastcgi_param QUERY_STRING    $query_string;
        }

        location ~\.(gif|jpg|png)$ {
            root /data/images;
        }
    }
}
```

以上除了符合改正则```~\.(gif|jpg|png)$```的请求会被映射到```/data/images```目录下, 其余的请求都会被代理服务器路由到FastCGI服务器.

## 参考文档
[官方文档 Beginner’s Guide](http://nginx.org/en/docs/beginners_guide.html)
