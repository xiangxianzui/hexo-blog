---
title: cache和db的一致性问题
date: 2018-12-04 22:46:19
tags: [cache, 一致性]
categories: [Work]
---
cache和db的一致性问题：https://www.jianshu.com/p/496ea8bc9aa1

读多写少的场景：

读：读cache，有就返回；没有，读db，更新cache，返回

写：写db，删除cache



写多读少的场景：





cache和db操作放在一个事务里的时候，要注意cache和db的更新顺序，因为rollback是针对db而言的

如果先cache后db























