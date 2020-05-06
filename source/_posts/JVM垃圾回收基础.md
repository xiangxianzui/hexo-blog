---
title: JVM垃圾回收基础
date: 2020-05-03 16:28:02
tags: [垃圾回收, JVM]
categories: [Work]
---

## 垃圾回收基础

### 什么是垃圾

没有任何引用指向的一个对象或多个对象（循环引用）叫做垃圾。

### 如何定位垃圾

**引用计数**：引用计数为0的对象标记为垃圾，无法解决循环依赖

**GC roots**：

JVM stack, native method stack, runtime constant pool, static references in method area, Clazz

从GC roots开始遍历所有对象，遍历不到的对象标记为垃圾

### 常见的垃圾回收算法

这里说垃圾回收算法，其实叫垃圾回收思想更合适，因为实际垃圾回收算法都是借鉴了这些思想。

**标记清除（Mark Sweep）**：找到所有垃圾后清除

优点是实现简单，缺点是容易产生内存碎片。

**拷贝（Copying）**：将内存一分为二，只使用其中一份，垃圾回收时，把非垃圾对象拷贝到另一份内存，然后把第一份内存清掉

优点是没有内存碎片，缺点是浪费空间。

**标记压缩（Mark Compact）**：找到所有垃圾后清除，然后把存活对象压缩到一起消除碎片

优点是没有内存碎片，缺点是效率偏低。

### JVM内存分代模型

jdk1.7：年轻代（Young）、老年代（Old）、永久代（Perm）

jdk1.8：年轻代（Young）、老年代（Old）、元数据区（MetaData）

元数据区可指定大小的下限，但不可指定上限，除非整个JVM用尽，否则不会溢出

\>jdk1.8：JVM内存不再是分代模型



永久代必须指定大小的上下限，也就是说有永久代溢出的可能性；元数据区可以设置也可以不设置，无上限（受限于物理内存）

字符串常量：1.7放在永久代，1.8放在堆

方法区：逻辑概念，1.7放在永久代，1.8放在元数据区



年轻代：

Eden + Suvivor0 + Suvivor1，空间比例8:1:1（年轻代总空间为10）

new的对象放在Eden区，如果Eden空间不够直接进入老年代

YGC后，Eden大多数对象都会被回收，存活的对象拷贝至S0

再次YGC后，Eden+S0中存活的对象被拷贝到S1

再次YGC后，Eden+S1中存活的对象被拷贝到S0

......

每次YGC后，存活的对象的“年龄”+1，年龄够了会升入老年代



老年代：

存放“顽固分子”，或者太大的对象

老年代满了会触发FGC，GC调优的目的就是减少FGC的次数，因为FGC可能会有较长时间的STW（Stop The World）

### 常见的垃圾回收器

![垃圾回收器](垃圾回收器.jpeg)

> 上图红色细虚线表示相互连接的2个垃圾回收器可以配合使用

**用于年轻代的垃圾回收器**：

Serial：单线程回收

Parallel Scavenge：多线程回收

ParNew：为了与CMS配合使用而从Parallel Scavenge改造而来的，多线程回收

**用于老年代的垃圾回收器**：

Serial Old：单线程回收

Parallel Old：多线程回收

CMS：ConcurrentMarkSweep，这里Concurrent是指垃圾回收线程与应用线程在某些阶段可以并行执行，从而减少STW时间（官方声称STW时间<=200ms）

**使用非分代模型的JVM的垃圾回收器**：

G1：STW<=10ms

ZGC：STW<=1ms

Shenandoah：Shenandoah与ZGC都是下一代JVM备选的垃圾回收器

**不用关注**：

Epsilon：jdk内部调试使用的回收器



### 常见参数

java -XX:+PrintFlagsFinal 打印出jvm所有配置的默认值和当前值

你会发现有=和:=，=就是默认值，:=就是你手动修改后的值，或者是jvm根据你当前系统智能设定的值

`:=` denotes that the flag value was overriden either by JVM ergonomics or manually via a command line option.



```
[-Djava.util.logging.config.file=/home/vcloud/vcloud-live/vcloud-live-xs/online/tomcat/conf/logging.properties, -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager, -Djdk.tls.ephemeralDHKeySize=2048, -Djava.protocol.handler.pkgs=org.apache.catalina.webresources, -Djava.awt.headless=true, -Xms10240m, -Xmx10240m, -XX:MaxPermSize=512m, -Dcom.netease.appname=vcloud_live_online, -verbose:gc, -XX:+PrintGCDetails, -Xloggc:/home/vcloud/vcloud-live/vcloud-live-xs/online/tomcat/logs/gc.log, -XX:+PrintGCTimeStamps, -Djava.library.path=/home/vcloud/lib/, -Dforeign.domain=true, -Dorg.apache.catalina.SESSION_COOKIE_NAME=NTESwebSI, -Dsun.rmi.transport.tcp.responseTimeout=20000, -Dsun.rmi.dgc.client.gcInterval=7200000, -Dsun.rmi.dgc.server.gcInterval=7200000, -Dcom.sun.management.jmxremote, -Dcom.sun.management.jmxremote.ssl=false, -Dcom.sun.management.jmxremote.authenticate=false, -Dlog.dir=/home/vcloud/vcloud-live/vcloud-live-xs/online/tomcat/logs, -Denv=PRO, -Dpro_meta=http://vcloud-nts.service.163.org, -javaagent:/home/vcloud/vcloud-live/vcloud-live-xs/online/webroot/WEB-INF/classes/sentry-javaagent-home/sentry-javaagent-premain-2.0.0.jar, -Dsentry_collector_libpath=/home/vcloud/vcloud-live/vcloud-live-xs/online/tomcat/lib/, -Djava.endorsed.dirs=/home/vcloud/vcloud-live/vcloud-live-xs/online/tomcat/endorsed, -Dcatalina.base=/home/vcloud/vcloud-live/vcloud-live-xs/online/tomcat, -Dcatalina.home=/home/vcloud/vcloud-live/vcloud-live-xs/online/tomcat, -Djava.io.tmpdir=/home/vcloud/vcloud-live/vcloud-live-xs/online/tomcat/tmp/]
```

-Xms10240m jvm初始内存

-Xmx10240m jvm最大内存

-XX:MaxPermSize=512m 永久代最大空间

-XX:+PrintGCDetails 在gc.log打印GC信息

-Xloggc:\<file-name\> gc.log日志地址

-XX:+PrintGCTimeStamps 打印gc时间信息



rmi远程控制gc，设置为固定2小时触发一次full gc

-Dsun.rmi.dgc.client.gcInterval=7200000

-Dsun.rmi.dgc.server.gcInterval=7200000

正常情况下是由jvm控制gc，但是如果开启rmi，则由rmi接管gc的控制