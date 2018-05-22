---
title: tomcat相关问题解决
date: 2017-12-01 13:41:11
tags: [tomcat]
categories: [Work]
---

### 解决tomcat启动过慢
http://blog.csdn.net/benyuxy/article/details/7570244
http://blog.csdn.net/u011627980/article/details/54024974
http://blog.csdn.net/changyinling520/article/details/71036515

### 远程部署war包过程中，tomcat报错java.util.zip.ZipException: error in opening zip file。
![server.xml配置](tomcat配置.png "server.xml配置")
tomcat会自动解压webapps目录下的war包，当用scp把war包部署到远程tomcat上的时候，如果这个war包比较大，那么tomcat在war包还没有传输完成的时候就尝试解压，这样就会导致zipException


另：
### tomcat下部署war包的两种方法
http://blog.csdn.net/wy818/article/details/7240294
