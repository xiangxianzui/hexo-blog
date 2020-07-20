---
title: HBase入门手册
date: 2020-05-03 16:47:08
tags: [HBase]
categories: [Work]
---

# HBase入门手册

最近工作中遇到与HBase相关的问题，于是买了本《HBase不睡觉书》，这是一本关于HBase的入门级别的书，我快速翻阅后找出我认为比较重要的部分摘抄和总结出来，作为HBase的入门手册。

## 初识HBase

### HBase项目的起源

2006年Google发表文章*Bigtable: A Distributed Storage System for Structured Data*，描述了一个具有高扩展性、高可用性、高性能的用来存储结构化数据的分布式存储系统。2007年，作为基于Bigtable研发的Java开源版本，HBase问世了，起初作为Hadoop项目的一部分，后来在2008年成为Apache的顶级项目。经过不断迭代，HBase几乎实现了Bigtable的所有特性，成为开源非关系型数据库中的翘楚。

### 与关系型数据库的对比

关系型数据库的范式决定了每一行都是不可分割的，也就是不同的列必须要存储在同一台服务器上。

![](/home/wanghao/hexo/source/_posts/HBase入门手册/关系型数据库表结构.png)

与关系型数据库按行存储不同，HBase是列式数据库，同一行的不同列可以存在不同的服务器上，而"行"则被弱化成为一个逻辑概念，不同的列被认为是属于同一行数据的依据是具有相同的rowkey

![](/home/wanghao/hexo/source/_posts/HBase入门手册/Hbase表结构.png)

### 优势与不足

列式存储带来的优势就是把不同的列分散到不同的服务器，充分分散了负载压力，但是这种“并不直观”的存储方式带来的代价就是：即使存储少量的数据，HBase也不会很快。因此只有当数据量很大时，使用HBase才能体现出它的优势。

另外，NoSQL数据库的通病之一就是不支持表的关联查询，所以当我们想用HBase做数据分析、实现group by或者order by这样的操作时会很痛苦，通常需要写很多MapReduce代码。

所以总结下来就是：

- 何时使用HBase：
  - 单表数据量超过千万，高并发操作
  - 数据分析需要较弱，或者不需要那么灵活或者实时

- 何时不要使用HBase：
  - 主要需求是做数据分析和报表
  - 单表数据量不超过千万

## HBase内部探险

### 数据模型

#### Namespace（表命名空间）

表命名空间的作用是把多个属于相同业务领域的表分成一组来统一管理，可以把属于不同业务的表分到不同的命名空间，对不同的命名空间进行不同的环境设定，比如配额管理、安全管理等。

HBase有两个保留的命名空间，分别是

- Hbase：系统表空间，用于HBase内部表

- default：没有显式地定义命名空间的表都被自动分配到default表空间下

#### Table（表）

一个表由一个或多个列族组成。数据属性，比如过期时间（TTL）、压缩算法（COMPRESSION）等都是在列族上定义。定义完列族后表是空的，只有添加了行之后表里才有数据。

#### Row（行）

一个行包含了多个列，这些列通过列族来分类，一个行中的数据可以分布在不同的服务器上。每一行都有一个不重复的字符串，称为行键（rowkey），用来标识属于同一行。rowkey的生成规则完全由用户指定，且严格按照字典序排序，比如row11会排在row1和row2之间。

#### Column Family（列族）

列族是多个列的集合。其实列式数据库只需要列就可以了，为什么还需要列族？因为HBase会尽量把同一列族的列放在同一服务器上，这样可以提高存取性能，并且可以批量管理有关联的多个列。表的很多属性，比如过期时间、数据块缓存以及是否压缩等都是定义在列族上而不是在表或列上，同一个表里的不同列族可以有完全不同的属性配置，但是同一个列族内的所有列都有相同的属性，可以说列族是HBase中最重要的概念。

#### Column Qualifier（列）

多个列组成一个行。列族和列经常用Column Family: Column Qualifier来一起表示。列是可以随意定义的，一个行中的列不限名字、不限数量，只限定列族。建表的时候是不需要指定列的，比如下面这个建表语句，声明了命名空间为ns，表名为table，定义了一个列族为cf，并没有定义列。

```sql
create 'ns:table', {NAME => 'cf', TTL => '2678400', COMPRESSION => 'SNAPPY', BLOOMFILTER => 'ROW'}, SPLITS => ['1','2','3','4','5','6','7','8','9','a','b','c','d','e','f']
```

#### Cell（单元格）

一个列可以存储多个版本的数据，而每个版本就称为一个单元格，单元格就是数据存储的最小单元。关系型数据库中一行和一列唯一确定一个单元格，但在HBase中的数据粒度比关系型数据库更细一级，同一个位置的数据还细分成多个版本。

#### Timestamp（时间戳/版本号）

单元格中的版本号。一行和一列确定数据可能有多个版本，如果不手动指定版本号的时候，系统会自动采用当前时间戳作为版本号，如果手动指定一个数字当做版本号的时候，会以你手动指定的为准。

### 存储结构

#### 宏观架构

![HBase集群架构](/home/wanghao/hexo/source/_posts/HBase入门手册/集群架构.png)

HBase集群由Master节点、多个RegionServer、ZooKeeper集群组成。

##### Master

负责在HBase集群启动的时候分配Region到具体的RegionServer，执行各种管理操作，比如Region的分割和合并。在HBase中Master节点的作用不是那么重要，数据的读取和写入都跟它没什么关系，它挂掉之后系统照样运行，不影响数据的读写，因为客户端从ZooKeeper获取了RegionServer的地址后，会直接在RegionServer进行获取、插入、删除数据等操作，而不需要经过Master。当然Master也不能宕机太久，有很多必要的操作，比如创建表、修改列族配置、以及更重要的分割和合并都需要它的操作。另外，Master可以做成单点也可以配置HA。

##### RegionServer

RegionServer就是存放Region的容器。

Region就是一段数据的集合，存储了表的一部分数据；每一个Region都有起始rowkey和结束rowkey，代表了它所存储的row范围。HBase中的表一般拥有一个或多个Region。Region有以下特性：

- Region不能跨服务器，一个Region只能存在于一个RegionServer上，但一个RegionServer可以有一个或多个Region
- 数据量小的时候，一个Region足以存储所有数据，但是当数据量变大的时候，HBase会拆分Region
- 当HBase在进行负载均衡的时候，也有可能会从一个RegionServer上把Region移动到另一台RegionServer上
- Region是基于HDFS的，它的所有数据操作都是调用了HDFS的客户端接口来实现的

##### ZooKeeper

ZooKeeper在HBase中的重要性甚至超过了Master，因为Master宕机后业务系统照样跑，能读能写，但是ZooKeeper不可用之后就不能读取数据了，因为读取数据所需要的元数据表hbase:meta的位置存储在ZooKeeper上。

#### RegionServer&Region内部结构

下面我们将深入到RegionServer和Region内部来看看HBase是怎样存储数据的。

![RegionServer结构图](/home/wanghao/hexo/source/_posts/HBase入门手册/RegionServer结构.png)

RegionServer中存储一个或多个Region，一个Region内部包含一个或多个Store实例，一个Store存储一个列族的数据，而Store内部又包含MemStore和HFile两部分。

举个实际的例子，比如表ns:table中有2个列族cf1和cf2，表中数据的rowkey从101到1000，假设只有一台RegionServer服务器，每100条数据分到1个Region，那么101~200的数据分到Region1，...，901~1000的数据分到Region9，每个Region内有2个Store，分别存放cf1和cf2的数据。存储结构见下图：

![](/home/wanghao/hexo/source/_posts/HBase入门手册/RegionServer内多Region.png)

##### WAL（预写日志）

WAL是Write-Ahead Log的缩写。当数据到达Region的时候，HBase会先把把数据写到基于内存实现的MemStore里，等数据到达一定的数量时才刷写（flush）到HFile里。如果在这个过程中服务器宕机或断电了，那么数据就会丢失，WAL是一个保险机制，数据在写到MemStore之前先把操作写到WAL，由于WAL的数据是存储在HDFS上的，宕机后数据不会丢失，所以当故障恢复的时候就可以从WAL中恢复数据。

WAL机制是默认开启的，当然也可以设置为关闭：

```java
Mutation.setDurability(Durability.SKIP_WAL);
```

**同步写入WAL**

默认情况下，写入WAL是一个同步操作，对数据的每一次写操作（Put/Delete/Append）都会被同步记录到WAL，记录的方式是调用HDFS客户端来写入HDFS，也就是说即使只有一个改动，也会调用HDFS接口来同步数据，写入WAL后再写入内存MemStore。这样的话在写入并发很高时会影响写速度，于是HBase提供了异步写入WAL的机制。

**异步写入WAL**

异步写入WAL是指操作记录先保存在内存，等到条件满足的时候才把操作持久化到WAL。这里的条件主要指的是时间间隔`hbase.regionserver.optionallogflushinterval`，意思是HBase间隔多久会把操作从内存写入WAL，默认1秒。

开启异步写入WAL：

```java
Mutation.setDurability(Durability.ASYNC_WAL);
```

如果异步写入的时候出错的话，是没有任何事务保证的。因此如果对系统性能要求很高、对故障恢复时数据一致性要求不高，可以考虑使用异步WAL，否则使用默认的配置即可。

##### MemStore

每个Store有一个基于内存的MemStore，数据写入WAL之后会被放入MemStore，MemStore的大小增加到超过一定阈值的时候会被写到HDFS上，以HFile的形式被持久起来。

为什么数据在进入HFile之前要先写入到内存MemStore中，而不是直接写入HFile呢？因为HDFS文件只能创建、追加、删除，但是不能修改。对于一个随机读写的数据库HBase来说，按顺序存放数据是非常重要的，这是性能的保障，所以我们不能按照数据到来的顺序写入硬盘。于是可以在持久化之前写入MemStore，在内存中把数据整理成顺序存放，再一起写入磁盘，这就是MemStore存在的意义。

MemStore内部使用了LSM树结构来存储数据。在LSM树的实现中，必须要先对数据进行排序，MemStore就是将数据按照rowkey顺序排列的。LSM树是Google Bigtable和HBase的基本存储算法，是传统关系型数据库的B+树的改进，算法的关注重心是“如何在频繁的数据改动下保持系统读取速度的稳定性”，算法的核心在于尽量保证数据是顺序存储到磁盘上的，并且会有频率地对数据进行整理，确保其顺序性。

需要注意的是，HBase在读取数据的时候并不是先从MemStore中读再从HFile读，读取的时候有专门的缓存叫BlockCache，先读BlockCache，读不到再读HFile+MemStore

##### HFile

在Store中有多个HFile，当MemStore数据到达阈值之后会在HDFS上生成一个新的HFile并刷写到HFile，HFile是数据存储的实际载体。

![](/home/wanghao/hexo/source/_posts/HBase入门手册/HFile结构.png)

可以看到HFile是由一个一个的块组成的，在HBase中一个块的大小默认为64KB，由列族上的BLOCKSIZE属性定义。下面看Data数据块。

![](/home/wanghao/hexo/source/_posts/HBase入门手册/Data数据块结构.png)

Data数据块的第一位存储的是块的类型，后面存储的是多个KeyValue键值对，也就是单元格（Cell）的实现类。Cell是一个接口，KeyValue是它的实现类。下面就是KeyValue的结构。

![](/home/wanghao/hexo/source/_posts/HBase入门手册/KeyValue结构.png)

一个KeyValue里面最后一部分是数据的Value，而前面的部分都是存储跟该单元格相关的元数据信息。如果存储的Value很小，那么这个单元格的绝大部分空间就都是rowkey、column family、column等的元数据，所以列族和列的名字如果很长，大部分空间就被拿来存储这些数据了，这时可以选用数据块编码或压缩算法，后面会详细说明。

##### 总结

之前已经自上而下地剖析了RegionServer和Region的内部结构，下面用一张图总结一下RegionServer、Region、Store、MemStore、HFile之间的关系。

![](/home/wanghao/hexo/source/_posts/HBase入门手册/RegionServer内部数据结构.png)

归纳起来就是这样：

- 一个RegionServer包含多个Region，划分规则是：一个表的一段键值在一个RegionServer上会产生一个Region
- 一个Region包含多个Store，划分规则是：一个列族分为一个Store，如果一个表只有一个列族，那么这个表在这个机器上的每一个Region里面都只有一个Store
- 一个Store里面只有一个MemStore
- 一个Store里面有多个HFile，每次MemStore的刷写就会产生一个新的HFile出来

#### 单元格的写入、删除、读取

##### 写入

单元格的写入操作会第一时间被写入WAL，由于WAL只是一个暂存的日志，是不区分Store的，所以WAL是不能被直接读取的；接下来数据会立即进入MemStore按照LSM树进行排序整理；最后刷写到HFile中。至此，数据被真正有组织地被持久化了。

##### 删除

HBase是一个随机读写的数据库，但它所基于的持久化层HDFS却是要么新增、要么整个删除、不能修改的系统，那么HBase是如何实现删除的？真实的情况是HBase几乎总是在做新增操作：

- 当你新增一个单元格的时候，HBase在HDFS上新增一条数据

- 当你修改一个单元格的时候，HBase在HDFS上又新增一条数据，只是版本号比之前的大（或者自己定义）

- 当你删除一个单元格的时候，HBase还是新增一条数据，只是这条数据没有Value，类型为DELETE，这条数据叫墓碑标记（Tombstone）


HBase每隔一段时间都会进行一次合并（Compation），合并的对象是HFile文件，合并分为minor compaction和majar compaction两种。在进行majar compaction的时候，它会把多个HFile合并成1个HFile，在这个过程中，一旦检测到有被打上墓碑标记的记录，在合并的过程中就忽略这条记录，这样产生的新HFile中就没有这条记录了，数据就相当于被删除了。

##### 读取

读取一个单元格的顺序是先从BlockCache中找数据，找不到再去MemStore和HFile中查询数据。

#### 定位Region的过程

HBase客户端在读写数据的时候，如何定位数据在哪个Region呢？

![](/home/wanghao/hexo/source/_posts/HBase入门手册/定位Region.png)

总结为以下流程：

1. 客户端通过zookeeper的/hbase/meta-region-server节点查询到哪台RegionServer上有hbase:meta表
2. 客户端连接到含有hbase:meta表的RegionServer。hbase:meta表存储了所有Region的行健范围信息，通过这个表就可以查询出你要存取的rowkey属于哪个Region的范围里面，以及这个Region又是存在哪个RegionServer
3. 获取这些信息后，客户端就可以直连其中一台拥有你要存取的rowkey的RegionServer，并直接对其操作
4. 客户端会把meta信息缓存起来，下次操作就不需要进行以上加载hbase:meta的步骤了

### 数据块编码和压缩器





Bloom Filter



> 参考：《HBase不睡觉书》-- 杨曦 著

+