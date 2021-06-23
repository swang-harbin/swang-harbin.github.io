---
title: Nginx 代理解决跨域请求问题
date: '2020-04-22 00:00:00'
tags:
- Nginx
---
# Nginx 代理解决跨域请求问题

```nginx
user  root;
worker_processes  1;


events {
    worker_connections  1024;
}


http {

    include mime.types;
    default_type application/octet-stream;

    server {
        listen       8100;
        server_name  localhost;
        location / {
            root /root/software/nginx/html/dist;
            try_files $uri $uri/ /index.html
                add_header 'Access-Controller-Allow-Origin' '*';
            index index.html index.htm;
        }
        location /api/ {
            proxy_pass   http://127.0.0.1:8110/; 
            add_header 'Access-Control-Allow-Origin' '*';
            add_header 'Access-Control-Allow-Methods' '*';
            add_header 'Access-Control-Allow-Headers' 'DNT,X-Mx-ReqToken,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Authorization,token';
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


[ngx_http_headers_module](https://nginx.org/en/docs/http/ngx_http_headers_module.html)
