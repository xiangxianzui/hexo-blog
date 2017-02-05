---
title: 'LeetCode: Coin Change'
date: 2017-02-05 11:58:29
tags: [algorithm, Dynamic Programming]
categories: [LeetCode]
---

## Problem

You are given coins of different denominations and a total amount of money amount. Write a function to compute the fewest number of coins that you need to make up that amount. If that amount of money cannot be made up by any combination of the coins, return `-1`.

**Example 1**:

```
coins = [1, 2, 5], amount = 11
return 3 (11 = 5 + 5 + 1)
```

**Example 2**:

```
coins = [2], amount = 3
return -1.
```

**Note**: You may assume that you have an infinite number of each kind of coin.

## Solution

This is a classic Dynamic Programming problem. Let's take an example as usual. Given 3 types of coins with value `1`, `2`, `5` respectively, and the total money amount is `11`, try to select minimal number of coins to make up that amount.

We denote that given money amount `s`, the number of coins being selected is `N(s)`. So the problem is to solve `N(11)`.

At the beginning, it is easy to find that `N(0)=0`. Then,  if `s=1`, we can only select coin with value `1`, and we get `N(1)=1`. Then go to `s=2`. We can select coin with value `1` and value `2`. If select value `1`, the remaining amount is `1`, since we already know `N(1)=1`, so `N(2)=N(2-1)+1=2`; if select value `2`, the remaining amount is `0`, so `N(2)=N(2-2)+1=1`. The final `N(2)=min(2,1)=1`. Then we move on to `s=3`. We still can only select value `1` and value `2`. If select value `1`, `N(3)=N(3-1)+1=2`; if select value `2`, `N(3)=N(3-2)+1=2`. So the final `N(3)=min(2,2)=2`. We do this similarly until we reach `s=11`, and the answer is `N(11)=3`.

From the above example, we can analyse this problem in a more general way. Given several types of coins with values `[V1, V2, ..., Vn]`, money amount `s`, and number of selected coins `N(s)`. If we already know `N(0), N(1), ..., N(s-1)`, we determine `N(s)` as `min{N(s-Vi)+1}`, where `1<= i <=n` and `Vi <= s`. 

The java code could be like this:

```
public class Solution {
    public int coinChange(int[] coins, int amount) {
        Map<Integer,Integer> map = new HashMap();
        map.put(0, 0);
        
        int a = 1;
        while(a<=amount){
            int min = Integer.MAX_VALUE;
            boolean notPossible = true;
            for(int i=0; i<coins.length; i++){
                if(a>=coins[i]){
                    if(map.get(a-coins[i])!=-1){
                        int temp = map.get(a-coins[i])+1;
                        if(temp<min)    min = temp;
                        notPossible = false;
                    }
                    
                }
            }
            if(notPossible==true)   map.put(a,-1);
            else{
                map.put(a,min);
            }
            a++;
        }
        return map.get(amount);
        
    }
}
```
> Written with [StackEdit](https://stackedit.io/).
