---
title: Enable TLSv1.2 in JDK7
date: 2019-04-09 15:19:30
tags: [https]
categories: [Work]
---

最近发现我们线上服务器向用户服务器发送https请求被拒绝的现象，原因是用户服务器设置的https协议是只支持TLSv1.2的请求，而我们使用JDK7的服务器发送https请求时默认使用的是TLSv1，用户服务器拒绝握手，出现connection reset错误，在不升级到JDK8的前提下需要支持发送TLSv1.2的https请求。

使用apache的httpClient代码如下：

```java
CloseableHttpClient httpClient = HttpClientBuilder
                .create()
                .setSSLSocketFactory(new SSLConnectionSocketFactory((SSLSocketFactory)SSLSocketFactory.getDefault(),
                        new String[] {"TLSv1", "TLSv1.1", "TLSv1.2"},
                        null,
                        SSLConnectionSocketFactory.getDefaultHostnameVerifier()))
                .build();
```

详细原因见SSLSocketFactory类，在JDK7和JDK8中有不同的实现。

默认情况下，JDK7使用TLSv1作为加密协议，JDK8使用TLSv1.2作为加密协议，除了上面代码那样做之外，也可以`-Dhttps.protocols=TLSv1,TLSv1.1,TLSv1.2`，表示3种协议都可以。

另外，可以用`-Djavax.net.debug=all`，这样会打印https握手详细过程。



> 参考：
>
> <https://docs.oracle.com/javase/7/docs/technotes/guides/security/SunProviders.html#tlsprotonote>
>
> <https://superuser.com/questions/747377/enable-tls-1-1-and-1-2-for-clients-on-java-7>
>
> <https://stackoverflow.com/questions/43772426/java-apache-httpclient-tlsv1-2-openjdk-7>