---
title: dns解析过程抓包分析
date: 2018-10-15 21:26:47
tags: [DNS, 抓包]
categories: [Work]
---

## dig +trace抓包分析：

dig +trace [hostname]命令从根服务器开始追踪一个域名的解析过程,下面结合命令输出以及wireshark抓包分析执行dig +trace命令后究竟发生了哪些事情。

dig +trace www.baidu.com 抓包结果：

以www.baidu.com为例：

```shell
-> dig +trace www.baidu.com

; <<>> DiG 9.9.5-3-Ubuntu <<>> +trace www.baidu.com

;; global options: +cmd

.			156084	IN	NS	l.root-servers.net.

.			156084	IN	NS	j.root-servers.net.

.			156084	IN	NS	f.root-servers.net.

.			156084	IN	NS	c.root-servers.net.

.			156084	IN	NS	d.root-servers.net.

.			156084	IN	NS	h.root-servers.net.

.			156084	IN	NS	b.root-servers.net.

.			156084	IN	NS	a.root-servers.net.

.			156084	IN	NS	k.root-servers.net.

.			156084	IN	NS	e.root-servers.net.

.			156084	IN	NS	m.root-servers.net.

.			156084	IN	NS	g.root-servers.net.

.			156084	IN	NS	i.root-servers.net.

.			85383	IN	RRSIG	NS 8 0 518400 20181007220000 20180924210000 41656 . V7zlNRZHj4pGVdIoAWXtaF3K8JflOlAY/2XRcaKFgrwNSrpOM9q8E2kX fJg3wNvdlE8Ebkboi5fTe31u6W/WGeKLY8QiHoDbco9jwy3U/af3mfFq UMZq2Zvs8ekUutUSCNenxUD2OTGsweA8VP5+qjcuuWEonEYm2ITRtiWv eFH0GFYeiB+5PBQL27XtwNUEN2EYKTRw22sADXUy/UCkawpyY+YKjKCf iIe/7wrF8bgbfA6oS7k9xORVA8/wZpTTYc5Q0VwsLbX5Ifz3NzbrjBCT 29oKepzR8R6VFmgaAdMwKVod5k2lGsB6nrTwn4PBFfwRTkK4xgu0e+Xn hxxh8w==

;; Received 1111 bytes from 127.0.1.1#53(127.0.1.1) in 88 ms

com.			172800	IN	NS	a.gtld-servers.net.

com.			172800	IN	NS	b.gtld-servers.net.

com.			172800	IN	NS	c.gtld-servers.net.

com.			172800	IN	NS	d.gtld-servers.net.

com.			172800	IN	NS	e.gtld-servers.net.

com.			172800	IN	NS	f.gtld-servers.net.

com.			172800	IN	NS	g.gtld-servers.net.

com.			172800	IN	NS	h.gtld-servers.net.

com.			172800	IN	NS	i.gtld-servers.net.

com.			172800	IN	NS	j.gtld-servers.net.

com.			172800	IN	NS	k.gtld-servers.net.

com.			172800	IN	NS	l.gtld-servers.net.

com.			172800	IN	NS	m.gtld-servers.net.

com.			86400	IN	DS	30909 8 2 E2D3C916F6DEEAC73294E8268FB5885044A833FC5459588F4A9184CF C41A5766

com.			86400	IN	RRSIG	DS 8 1 86400 20181008050000 20180925040000 41656 . 6dL3cyu8gI6F4PhxK+M2n1Yltj8ojeBpRFTqALwjcajEu4rRURBdvDYU M2WjdBitsXxXuHt081G69i7yzshhs+z29EHGPXG/NM681FVaV/WKm7r3 Kse2w3REQQS2jLeoFT/C0LT72djwHSNRYxGq3H0dJ1kuLbbjnEg144KN CS1tqbHNRXGQNjVsvGAopZwOKSRHXcI1ypenr58tPwxe8uBr1mWu5C9x O+UC7GR9VWhokCFm1QqgHX4Y3OnIvgB1+Ih2uCdjBt/t6cUTnPD9VOof A0kWd7AUE6Ac9dwARse2UqywbOqPM/7r1LI3d4YXqnF/gUAni3x8tHvh IWhxtg==

;; Received 1173 bytes from 198.41.0.4#53(a.root-servers.net) in 263 ms

baidu.com.		172800	IN	NS	dns.baidu.com.

baidu.com.		172800	IN	NS	ns2.baidu.com.

baidu.com.		172800	IN	NS	ns3.baidu.com.

baidu.com.		172800	IN	NS	ns4.baidu.com.

baidu.com.		172800	IN	NS	ns7.baidu.com.

CK0POJMG874LJREF7EFN8430QVIT8BSM.com. 86400 IN NSEC3 1 1 0 - CK0Q1GIN43N1ARRC9OSM6QPQR81H5M9A NS SOA RRSIG DNSKEY NSEC3PARAM

CK0POJMG874LJREF7EFN8430QVIT8BSM.com. 86400 IN RRSIG NSEC3 8 2 86400 20180929044218 20180922033218 46475 com. KFoD2muDMMl8m5+W8I2hXz7JhFlPdju7sxXLsHT5FNNX2EHVxB3WE8aq CbSSg8Uw6PJ5+bfjU7OcMDaw5um0QBhsJzaom03jqDtsUTYbpg4+NE4l NyieExXWz8EToYtBsyHFEWWYyrBbejHHoBw2Ubn3xTrV+rQ4YDE2x3Zy aRY=

HPVV2B5N85O7HJJRB7690IB5UVF9O9UA.com. 86400 IN NSEC3 1 1 0 - HPVVP23QUO0FP9R0A04URSICJPESKO9J NS DS RRSIG

HPVV2B5N85O7HJJRB7690IB5UVF9O9UA.com. 86400 IN RRSIG NSEC3 8 2 86400 20180930150114 20180923135114 46475 com. 1i+9CFd2kIT+a9/qIQLqdvIiunU3fY+FXuwoqqCzIsyN6T+OBjFj19/i rgbD5R0s+3yY9t3pcZeNx1dyAhJPpOvN6S/48+1BupOYyS4HzhRSPQj9 SrbCQxght6VBBF19B0gXgT5pX95QiqNq1Ai5o2FVQBuwufP6I1odnEKd kXQ=

;; Received 697 bytes from 192.55.83.30#53(m.gtld-servers.net) in 235 ms

www.baidu.com.		1200	IN	CNAME	www.a.shifen.com.

a.shifen.com.		1200	IN	NS	ns2.a.shifen.com.

a.shifen.com.		1200	IN	NS	ns5.a.shifen.com.

a.shifen.com.		1200	IN	NS	ns3.a.shifen.com.

a.shifen.com.		1200	IN	NS	ns4.a.shifen.com.

a.shifen.com.		1200	IN	NS	ns1.a.shifen.com.

;; Received 239 bytes from 220.181.37.10#53(ns3.baidu.com) in 67 ms

```

从dig +trace的输出结果来看，整个过程可以被分成四个部分：

(1)从本地服务dnsmasq(127.0.1.1:53)得到13台根域名服务器的地址，耗时88ms

(2)从其中一台根域名服务器(a.root-servers.net)得到13台通用顶级域名.com服务器的地址，耗时263ms

(3)从其中一台.com域名服务器(m.gtld-servers.net)得到5台二级域名baidu.com服务器地址，耗时235ms

(4)从其中一台baidu.com域名服务器(ns3.baidu.com)得知所查域名www.baidu.com的别名为www.a.shifen.com，进而得知5台三级域名a.shifen.com服务器的地址，耗时67ms

下面通过wireshark对上述过程的抓包结果，来分析究竟发生了什么。

首先看第一阶段：

dnsmasq是linux本地的一个提供dns服务的进程，即local dns。如果ps -ef | grep dnsmasq的话会看到--listen-address=127.0.1.1，再用netstat查看端口会看到53端口，这说明dnsmasq进程监听本地回环地址127.0.1.1的53号端口

![img](dnsmasq.png)

如下图所示，10.242.52.179是本机ip。为了得到www.baidu.com的ip地址，我们首先需要知道根域名服务器的地址，因此dnsmasq进程对外询问局域网内的DNS服务器，在这里是10.246.3.3[1-4]；我们分别向四台DNS服务器发送了一条DNS query，询问<Root>跟域名服务器的ip地址；可以看到，我们接受了10.246.3.33的DNS response，与此同时拒绝了其他三台DNS服务器的应答；10.246.3.33这台机器它说它有13台根域名服务器，你想用哪台都行，丢给我们13台服务器的域名；我们拿到一堆域名一脸懵逼，因为我们并不知道它们的ip地址，于是不得不再向DNS服务器询问，老兄你刚才给我的13个根域名的ip地址都是啥啊？DNS服务器对我们有求必应，不仅告诉我们ipv4地址(A记录)，还告诉我们ipv6地址(AAAA记录)。

第一阶段结束。

![img](first period.png)

再看第二阶段：

拿到了13个根域名服务器的ip地址后，我们选择了其中一个：a.root-servers.net(192.55.83.30)，下面我们向这台服务器询问com顶级域名服务器的地址。

![img](second period.png)

再看第三阶段：

我们选择了m.gtld-servers.net顶级域名服务器，对应ip为192.55.83.30，向它询问baidu.com域名服务器的地址。

![img](third period.png)

最后看第四阶段：

我们选择了ns3.baidu.com域名服务器，对应ip为220.181.37.10，向他询问www.baidu.com的ip地址。然而，域名服务器在它的dns记录表中发现，www.baidu.com对应的记录是一条CNAME记录，其CNAME别名为www.a.shifen.com

![img](fourth period.png)

与此同时，ns3.baidu.com这台域名服务器还告诉我们a.shifen.com域名服务器有5个，分别是ns[1-5].a.shifen.com，这样就不用我们拿着www.a.shifen.com再从根域名服务器、.com服务器、.shifen.com费尽周折地查找了。

![img](fourth period%201.png)

最后，我们向ns[1-5].a.shifen.com中的任意一台机器询问www.a.shifen.com的ip地址，得到的也就是www.baidu.com的ip地址了。

## CNAME和A记录：

A(Address)记录把主机名或域名映射到IP地址，实现了域名到IP的关联

CNAME(Canonical NAME)是别名记录，就是将一个或多个主机名或域名映射到另一个域名

举个例子：有一台主机名为host.example.com的服务器，其对外ip为10.110.72.29；服务器提供了门户网站和邮箱两个服务，我们希望用户通过地址www.example.com和mail.example.com分别访问两个服务，那么DNS应该这样记录：

```shell
+------------------+-------+------------------+
| host.example.com | A     | 10.110.72.29     |
+------------------+-------+------------------+
| www.example.com  | CNAME | host.example.com |
+------------------+-------+------------------+
| mail.example.com | CNAME | host.example.com |
+------------------+-------+------------------+
```

这样的话，www和mail服务其实都是指向了同一个ip，当主机的ip地址变更时，只需更改A记录即可。

## jdk中DNS解析过程：

java的DNS解析过程在java.net包下的InetAddress类中完成，核心代码如下：

```java
private static final HashMap<String, Void> lookupTable = new HashMap<>();

private static InetAddress[] getAddressesFromNameService(String host, InetAddress reqAddr)
        throws UnknownHostException
    {
        InetAddress[] addresses = null;
        boolean success = false;
        UnknownHostException ex = null;

        // Check whether the host is in the lookupTable.
        // 1) If the host isn't in the lookupTable when
        //    checkLookupTable() is called, checkLookupTable()
        //    would add the host in the lookupTable and
        //    return null. So we will do the lookup.
        // 2) If the host is in the lookupTable when
        //    checkLookupTable() is called, the current thread
        //    would be blocked until the host is removed
        //    from the lookupTable. Then this thread
        //    should try to look up the addressCache.
        //     i) if it found the addresses in the
        //        addressCache, checkLookupTable()  would
        //        return the addresses.
        //     ii) if it didn't find the addresses in the
        //         addressCache for any reason,
        //         it should add the host in the
        //         lookupTable and return null so the
        //         following code would do  a lookup itself.
        if ((addresses = checkLookupTable(host)) == null) {
            try {
                // This is the first thread which looks up the addresses
                // this host or the cache entry for this host has been
                // expired so this thread should do the lookup.
                for (NameService nameService : nameServices) {
                    try {
                        /*
                         * Do not put the call to lookup() inside the
                         * constructor.  if you do you will still be
                         * allocating space when the lookup fails.
                         */

                        addresses = nameService.lookupAllHostAddr(host);
                        success = true;
                        break;
                    } catch (UnknownHostException uhe) {
                        if (host.equalsIgnoreCase("localhost")) {
                            InetAddress[] local = new InetAddress[] { impl.loopbackAddress() };
                            addresses = local;
                            success = true;
                            break;
                        }
                        else {
                            addresses = unknown_array;
                            success = false;
                            ex = uhe;
                        }
                    }
                }

                // More to do?
                if (reqAddr != null && addresses.length > 1 && !addresses[0].equals(reqAddr)) {
                    // Find it?
                    int i = 1;
                    for (; i < addresses.length; i++) {
                        if (addresses[i].equals(reqAddr)) {
                            break;
                        }
                    }
                    // Rotate
                    if (i < addresses.length) {
                        InetAddress tmp, tmp2 = reqAddr;
                        for (int j = 0; j < i; j++) {
                            tmp = addresses[j];
                            addresses[j] = tmp2;
                            tmp2 = tmp;
                        }
                        addresses[i] = tmp2;
                    }
                }
                // Cache the address.
                cacheAddresses(host, addresses, success);

                if (!success && ex != null)
                    throw ex;

            } finally {
                // Delete host from the lookupTable and notify
                // all threads waiting on the lookupTable monitor.
                updateLookupTable(host);
            }
        }

        return addresses;
    }


    private static InetAddress[] checkLookupTable(String host) {
        synchronized (lookupTable) {
            // If the host isn't in the lookupTable, add it in the
            // lookuptable and return null. The caller should do
            // the lookup.
            if (lookupTable.containsKey(host) == false) {
                lookupTable.put(host, null);
                return null;
            }

            // If the host is in the lookupTable, it means that another
            // thread is trying to look up the addresses of this host.
            // This thread should wait.
            while (lookupTable.containsKey(host)) {
                try {
                    lookupTable.wait();
                } catch (InterruptedException e) {
                }
            }
        }

        // The other thread has finished looking up the addresses of
        // the host. This thread should retry to get the addresses
        // from the addressCache. If it doesn't get the addresses from
        // the cache, it will try to look up the addresses itself.
        InetAddress[] addresses = getCachedAddresses(host);
        if (addresses == null) {
            synchronized (lookupTable) {
                lookupTable.put(host, null);
                return null;
            }
        }

        return addresses;
    }

    private static void updateLookupTable(String host) {
        synchronized (lookupTable) {
            lookupTable.remove(host);
            lookupTable.notifyAll();
        }
    }
```

拿到一个host，首先会调用getCachedAddresses方法查缓存（缓存由LinkedHashMap实现），命中缓存则返回地址，未命中则调用getAddressesFromNameService方法查询name server。在查询name server之前，该方法会检查lookupTable（一个HashMap）。如果table中已经存在key为hostname的记录，说明此时另外一个线程正在对该host进行查询，那么当前线程就会等待，直到host记录被删除，也就是说另一个线程完成了对host的查询并更新了缓存，正常情况下此时缓存中已经有该条host的记录了，因此当前线程就没有必要自己查询name server，从缓存中取即可，但是特殊情况下无法命中缓存，那么当前线程需要将键值对<host, null>放入lookupTable，标志其正在进行查询，遍历所有已知的name server，找到host对应的地址后，更新缓存、删除lookupTable中的记录，最后返回查到的地址。

上面提到，java查询DNS后会有缓存，具体缓存多久的时间与jvm security policy的配置相关。通过下面两个参数可以控制DNS解析结果的缓存时间：

**networkaddress.cache.ttl**（default: -1）# 设置缓存解析成功的时间

> Specified in java.security to indicate the caching policy for successful name lookups from the name service. The value is specified as as integer to indicate the number of seconds to cache the successful lookup.
> A value of -1 indicates cache forever. The default behavior is to cache forever when a security manager is installed, and to cache for an implementation specific period of time, when a security manager is not installed.

**networkaddress.cache.negative.ttl** (default: 10) # 设置缓存解析失败的时间

> Indicates the caching policy for un-successful name lookups from the name service. The value is specified as as integer to indicate the number of seconds to cache the failure for un-successful lookups. A value of 0 indicates never cache. A value of -1 indicates cache forever.

以上两个参数可在`${java.home}/jre/lib/security/java.security`中配置，或者也可以在代码中进行配置：

```java
java.security.Security.setProperty(networkaddress.cache.ttl, 60);
```