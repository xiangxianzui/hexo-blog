---
title: nginx配置样例
date: 2017-10-19 16:54:57
tags: [nginx, 需要密码才能看]
categories: [Work]
password: wh0606
---

nginx配置样例，详情请阅读全文。

<!-- more -->

```
upstream twell {
        server 127.0.0.1:8888;
        server l-tw1.f.dev.cn6.qunar.com:8888;
        server l-tw2.f.dev.cn6.qunar.com:8888;
        server l-tw4.f.dev.cn6.qunar.com:8888;
        healthcheck_enabled;
        healthcheck_delay 3000;
        healthcheck_timeout 1000;
        healthcheck_failcount 2;
        healthcheck_send 'GET /healthcheck.html HTTP/1.0' 'Host: qunar.com' 'Connection: close';
    }
     server {
        listen       80;
        server_name  flightlcf.qunar.com;
        gzip                    on;
        gzip_disable            "MSIE [1-6]";
        gzip_http_version       1.1;
        gzip_buffers            256 64k;
        gzip_comp_level         5;
        gzip_min_length         1000;
        gzip_types              text/csv text/xml text/css text/plain text/javascript application/javascript application/x-javascript application/json application/xml;
        error_page   500 502 503 504  /50x.html;
        location / {
            proxy_pass http://twell;
            proxy_set_header Host $host;
            proxy_next_upstream http_502 http_500 http_503 http_404;
            proxy_set_header X-Real-IP $remote_addr;
            root   html;
            index  index.html index.htm;
            client_max_body_size    70m;
        }
    }
```

配置完成后reload：
sudo /home/q/nginx/sbin/nginx -s reload

