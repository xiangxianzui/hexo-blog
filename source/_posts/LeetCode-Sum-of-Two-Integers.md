---
title: 'LeetCode: Sum of Two Integers'
date: 2017-01-09 22:00:24
tags: [algorithm, Bit Manipulation]
categories: [LeetCode]
---

## Problem

```
Calculate the sum of two integers a and b, but you are not allowed to use the operator + and -.

Example:
Given a = 1 and b = 2, return 3.
```

## Solution

Think this problem with an example. 

Consider 15+9=24.

``` bash
#XOR holds the remaining part of the result
     00001111
XOR  00001001
-------------
     00000110
```

``` bash
#AND holds the carry part of the result
     00001111
AND  00001001
-------------
     00001001
```

``` bash
# shift the carry to left for 1 place, and add with the remaining
     00000110
 +   00010010
-------------
     00011000
```

Thus, for any integer `a` and `b`, `a + b = a^b + (a&b)<<1`. Because `+` operator is not allowed, we can regard `a^b` as new `a`, and `(a&b)<<1` as new `b`. Repeat this until current carry is `0`.

The java implementation is like this:

``` bash
# Java solution
public class Solution {
    public int getSum(int a, int b) {
        if(b==0)    return a;
        while(b!=0){
            int carry = (a&b)<<1;
            int remain = a^b;
            b = carry;
            a = remain;
        }
        return a;
    }
}
```



> Written with [StackEdit](https://stackedit.io/).