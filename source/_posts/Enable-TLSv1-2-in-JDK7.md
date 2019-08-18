---
title: Enable TLSv1.2 in JDK7
date: 2019-04-09 15:19:30
tags: [https]
categories: [Work]
---

最近发现我们线上服务器向用户服务器发送https请求被拒绝的现象，原因是用户服务器设置的https协议是只支持TLSv1.2的请求，而我们服务器发送https请求使用的是TLSv1，用户服务器拒绝握手。

