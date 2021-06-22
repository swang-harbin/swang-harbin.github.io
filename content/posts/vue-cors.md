---
title: VUE跨域问题
date: '2020-03-09 00:00:00'
tags:
- VUE
categories:
- VUE
---
# VUE跨域问题

## 使用Nginx结局

### 将打包后的文件放在nginx的html文件夹中

可以任意存放位置, 只需修改配置文件中对应配置即可

目录结构类似如下
```bash
html/
└── dist
    ├── index.html
    └── static
```

### 修改nginx配置文件

```nginx
user  root;
worker_processes  1;

events {
    worker_connections  1024;
}

http {

    # 解决浏览器控制台Resource interpreted as Stylesheet but transferred with MIME type text/plain错误
    # 主要影响为, 造成页面样式显示不正确
    include mime.types;
    default_type application/octet-stream;

    server {
        # nginx的端口和地址
        listen       8100;
        server_name  localhost;

        location / {
            # 指定vue项目打包后文件存放的位置
            root /root/software/nginx/html/dist;
            try_files $uri $uri/ /index.html
                add_header 'Access-Controller-Allow-Origin' '*';
            index index.html index.htm;
        }
        # 此处根据vue中的配置进行修改
        location /api/ {
            # 被代理的后端服务地址
            proxy_pass   http://127.0.0.1:8110/;
            # 解决跨域请求问题的主要代码
            add_header 'Access-Control-Allow-Origin' '*';
            add_header 'Access-Control-Allow-Methods' '*';
            add_header 'Access-Control-Allow-Headers' 'DNT,X-Mx-ReqToken,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Authorization,token';
            # 其他配置, 暂不清楚, 可查看nginx官方文档
            proxy_redirect     off;
            proxy_set_header   Host             $host;
            proxy_set_header   X-Real-IP        $remote_addr;
            proxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;
            proxy_set_header   Connection       close;
            proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
            proxy_max_temp_file_size 0;
            proxy_connect_timeout      90;
            proxy_send_timeout         90;
            proxy_read_timeout         90;
            proxy_buffer_size          4k;
            proxy_buffers              4 32k;
            proxy_busy_buffers_size    64k;
            proxy_temp_file_write_size 64k;
        }
    }
}
```

## SpringBoot项目解决跨域问题

```java
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurerAdapter;

/**
 * 解决跨域请求问题
 */
@Configuration
public class CorsConfig extends WebMvcConfigurerAdapter {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                .allowedOrigins("*")
                .allowCredentials(true)
                .allowedMethods("GET", "POST", "DELETE", "PUT")
                .maxAge(3600);
        super.addCorsMappings(registry);
    }
}
```
