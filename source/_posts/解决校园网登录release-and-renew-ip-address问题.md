---
title: 解决校园网登录release and renew ip address问题
date: 2017-11-09 13:39:52
tags: [network]
categories: [Work]
---

今天在登录校园网时出现了"Invalid ip address, please release and renew it"的错误，无法正常上网，记录一下解决办法。

### Windows系统
Windows系统下，在cmd中输入
<code>ipconfig release</code>
<code>ipconfig renew</code>

### Linux系统
Linux系统下，<code>ip a</code>查看所有网卡：
![所有网卡](网卡.png "所有网卡")
在我机器上wlan0是连接校园网的无线网卡

接着执行以下2条命令：
<code>sudo dhclient -v -r wlan0</code>
<code>sudo dhclient -v wlan0</code>
第一条命令相当于释放当前已分配的ip地址，第二条命令从DHCP server重新获得一个ip

重新登录校园网即可。

> 参考https://www.cnblogs.com/Leo_wl/p/5484108.html
