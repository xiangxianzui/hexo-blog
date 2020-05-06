---
title: CDN经典算法初探
date: 2019-11-01 11:02:35
tags: [CDN]
categories: [Work]
---

## CDN经典算法初探

Overview





Global Load Balancing

全局负载均衡是指将客户端的请求映射到CDN某个集群的过程，是集群粒度的调度。客户端的请求可以用一个二元组来表示：`<ip address prefix, traffic class>`，第一项是一组ip地址，组内的ip地址在地域上是相近的，或者说将它们调度到某个集群所获效益是相似的；第二项代表流量类型，可以是音视频、网页、应用数据等。



Local Load Balancing



Caching





> 参考：<http://www.sigcomm.org/sites/default/files/ccr/papers/2015/July/0000000-0000009.pdf>