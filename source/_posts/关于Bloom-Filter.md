---
title: 关于Bloom Filter
date: 2017-10-20 13:53:00
tags: [Bloom Filter, 转载]
categories: [Work]
---

Bloom Filter是一种空间效率很高的随机数据结构，用来表示一个集合，主要的应用是判断一个元素是否属于这个集合，适用于能容忍一定错误率的场合下，比如网络爬虫里的url去重。

最近看到了一个写的非常好的关于Bloom Filter的文章系列，读完之后受益匪浅，写篇博文记录之。

### Bloom Filter概念和原理
http://blog.csdn.net/jiaomeng/article/details/1495500

### 从哈希存储到Bloom Filter
http://blog.csdn.net/jiaomeng/article/details/1496329

### 应用Bloom Filter的几个技巧
http://blog.csdn.net/jiaomeng/article/details/1497361

### Counting Bloom Filter
http://blog.csdn.net/jiaomeng/article/details/1498283

### Partial Bloom Filter
http://blog.csdn.net/jiaomeng/article/details/1502910

### Compressed Bloom Filter
http://blog.csdn.net/jiaomeng/article/details/1505299

### Perfect Hashing VS. Bloom Filter
http://blog.csdn.net/jiaomeng/article/details/1519383

### Bloom Filter应用之Web Cache Sharing
http://blog.csdn.net/jiaomeng/article/details/1531423

### Bloom Filter, Counting Bloom Filter和Dynamic Count Filter源码下载
http://blog.csdn.net/jiaomeng/article/details/1619321


> 注：该文章系列的作者为[焦萌](http://blog.csdn.net/jiaomeng)
