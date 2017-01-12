---
title: 'LeetCode: Move Zeroes'
date: 2017-01-12 10:14:39
tags: [algorithm, java, Array]
categories: [LeetCode]
---

## Problem

Given an array nums, write a function to move all 0's to the end of it while maintaining the relative order of the non-zero elements.

For example, given `nums = [0, 1, 0, 3, 12]`, after calling your function, `nums` should be `[1, 3, 12, 0, 0]`.

**Note**:
You must do this in-place without making a copy of the array.
Minimize the total number of operations.

## Solution 1 -- 59ms

Go through the array. If `ith` element is 0, then move all elements within [i+1,nums,length-1] one place ahead, and set the last element of the array to 0. To prevent endless loop when `nums=[0,0,...,0]`, set a variable `reapeatCount`.

```
public void moveZeroes(int[] nums) {
    int repeatCount = 0;
    for(int i=0; i<nums.length; i++){
        if(nums[i]==0){
            for(int j=i; j<nums.length-1; j++){
                nums[j] = nums[j+1];
            }
            nums[nums.length-1] = 0;
            i--;
            repeatCount++;
        }
        if(repeatCount==nums.length)    break;
            
    }
}
```

## Solution 2 -- 19ms

Go through the array. If `ith` element is 0, then find the first non-zero element within range [i+1,nums.length-1] and swap it with current element; if there is no such non-zero element, it means all non-zero elements are before zeroes -- done! If current element is non-zero, just go on to the next.

```
public void moveZeroes(int[] nums) {
    if(nums != null){
        for(int i=0; i<nums.length; i++){
            if(nums[i]==0){
                //find the first non-zero element within range [i+1,nums.length-1]
                int firstNonZeroIdx = -1;
                for(int j=i+1; j<nums.length; j++){
                    if(nums[j]!=0){
                        firstNonZeroIdx = j;
                        break;
                    }
                }
                if(firstNonZeroIdx==-1) break;
                else{
                    int temp = nums[i];
                    nums[i] = nums[firstNonZeroIdx];
                    nums[firstNonZeroIdx] = temp;
                }
            }
        }
    }
}
```


Solution 2 is better than Solution 1. This is because in Solution 1, it is unnecessary to move all elements after a non-zero element one place ahead. 



> Written with [StackEdit](https://stackedit.io/).