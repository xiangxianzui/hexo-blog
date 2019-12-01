---
title: elastic-job分片策略
date: 2019-12-01 12:01:36
tags: [分布式, 作业调度, elastic-job]
categories: [Work]
---

## elastic-job分片策略

elastic-job在选举出主节点后，会由这个主节点进行作业分片，也就是要把每个作业的每个分片按照某种策略分配到各个作业执行节点上去。elastic-job默认提供了三种分片策略：

- AverageAllocationJobShardingStrategy：基于平均分配算法的分片策略
- OdevitySortByNameJobShardingStrategy：根据作业名的哈希值奇偶数决定IP升降序算法的分片策略
- RotateServerByNameJobShardingStrategy：根据作业名的哈希值对服务器列表进行轮转的分片策略

可以通过在配置作业的时候指定`job-sharding-strategy-class`来选择分片策略。

对于只有一个分片的作业，或者分片数小于作业执行节点数的作业，以上三种分片策略都会把分片分配到某一台或几台节点上去，会有固定的几台节点完全得不到分片，而elastic-job只有在节点变动（如加机器、节点崩溃退出）的时候才会重新分片，这就意味着如果初始分片不均匀的话，整个系统负载不均衡的情况就会一直存在。

为了解决这个问题，我设计了一个基于一致性哈希算法的分片策略`ConsistentHashJobShardingStrategy`，下面举例说明：

```
假设作业执行实例个数为3，作业分片数为2
* 首先将3个实例哈希到[0,N-1]，设定N=100，则分别映射到0、33、66
* 再计算2个作业分片的哈希值，如果在[0,32]之间则分配给实例1，[33,65]之间分配给实例2，[66,99]之间分配给实例3
```

这样可以尽量避免不同的作业映射到同一个执行实例上而导致实例间负载不均。

具体代码如下：

```java
public final class ConsistentHashJobShardingStrategy implements JobShardingStrategy {

    /**
     * 允许的最多执行实例的个数
     */
    private static final int N = 100;

    @Override
    public Map<JobInstance, List<Integer>> sharding(final List<JobInstance> jobInstances, final String jobName, final int shardingTotalCount) {
        if (jobInstances.isEmpty()) {
            return Collections.emptyMap();
        }
        int instanceNum = jobInstances.size();
        if (instanceNum > N) {
            // should not reach here
            return Collections.emptyMap();
        }

        int gap = N / instanceNum;
//        int pos = 0;
//        Map<JobInstance, Integer> instanceMap = new LinkedHashMap<>(instanceNum, 1);
//        for (JobInstance jobInstance : jobInstances) {
//            instanceMap.put(jobInstance, pos);
//            pos += gap;
//        }

        Map<JobInstance, List<Integer>> resultMap = new LinkedHashMap<>();
        for (int shardIdx = 0; shardIdx < shardingTotalCount; shardIdx++) {
            int shardHash = hash(jobName, shardIdx);
            int select = shardHash / gap;
            if (shardHash == N - 1) {
                select = select - 1;
            }
            JobInstance selectJobInstance = jobInstances.get(select);
            if (resultMap.containsKey(selectJobInstance)) {
                resultMap.get(selectJobInstance).add(shardIdx);
            } else {
                List<Integer> shardList = new ArrayList<>();
                shardList.add(shardIdx);
                resultMap.put(selectJobInstance, shardList);
            }
        }

        return resultMap;
    }


    /**
     * @param jobName 作业名
     * @param shardIdx 分片索引
     * @return 计算作业分片的hash值，范围[0,N-1]
     */
    private int hash(final String jobName, final int shardIdx) {
        String shardJobName = jobName + shardIdx;

        int hash = 0;
        for (int i = 0; i < shardJobName.length(); i++) {
            hash += Math.abs(shardJobName.charAt(i) - '0');
        }
        return hash % N;
    }
}
```