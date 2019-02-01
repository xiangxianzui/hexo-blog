---
title: cache和db的一致性问题
date: 2018-12-04 22:46:19
tags: [cache, 一致性]
categories: [Work]
---
#### 更新cache/db的原则

##### 读多写少的场景

读：读cache，有就返回；没有，读db，更新cache，返回

写：写db，删除cache

##### 写多读少的场景



> 参考：https://www.jianshu.com/p/496ea8bc9aa1



#### 在事务中的顺序

cache和db操作放在一个事务里的时候，要注意cache和db的更新顺序，因为rollback是针对db而言的。

##### 先cache后db

![](先cache后db.png)

- 写cache成功 -> 写db成功 -> success
- 写cache成功 -> 写db失败 -> db回滚 -> cache改变了，db不变，造成不一致
- 写cache失败 -> db回滚 -> cache不变，db也不变，一致

##### 先db后cache

![](先db后cache.png)

- 写db成功 -> 写cache成功 -> success
- 写db成功 -> 写cache失败 -> db回滚 -> cache和db都不变，一致
- 写db失败 -> db回滚 -> cache和db都不变，一致



解决不一致问题的常用方法：

事务

悲观锁

乐观锁：version

分布式锁























