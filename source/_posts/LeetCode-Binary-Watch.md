---
title: 'LeetCode: Binary Watch'
date: 2017-01-12 13:43:05
tags: [Backtracking]
categories: [LeetCode]
---

## Problem

A binary watch has 4 LEDs on the top which represent the **hours (0-11)**, and the 6 LEDs on the bottom represent the **minutes (0-59)**.

Each LED represents a zero or one, with the least significant bit on the right.

![Binary Watch](Binary_clock_samui_moon.jpg)

For example, the above binary watch reads "3:25".

Given a non-negative integer n which represents the number of LEDs that are currently on, return all possible times the watch could represent.

**Example**:

```
Input: n = 1
Return: ["1:00", "2:00", "4:00", "8:00", "0:01", "0:02", "0:04", "0:08", "0:16", "0:32"]
```

**Note**:

 - The order of output does not matter.
 - The hour must not contain a leading zero, for example "01:00" is not
   valid, it should be "1:00".
 - The minute must be consist of two digits and may contain a leading
   zero, for example "10:2" is not valid, it should be "10:02".

## Solution 1

The following code goes through all possible times, and checks if the time has correct number of one-bit.

```
public List<String> readBinaryWatch(int num) {
        List<String> result = new ArrayList();
        for(int h=0; h<12; h++){
            for(int m=0; m<60; m++){
                if(Integer.bitCount(h) + Integer.bitCount(m) == num){
                    result.add(String.format("%d:%02d", h, m));
                }
            }
        }
        return result;
    }
```

**Note**:
`Integer.bitCount(N)` returns the number of one-bits in the two's complement binary representation of the specified int value N.

## Solution 2

The following code describes the framework of the solution:

```
int[] hours = new int[] {8,4,2,1};
int[] minutes = new int[] {32,16,8,4,2,1};
for(int i=0; i<=nums; i++){
	//select i elements from hours, add them to get the hour
	//select (nums-i) elements from minutes, add them to get the minute
	//then construct one possible time
}
```

Thus, the first thing we need to solve is **how to select r elements from an array with n elements?**

My idea is to permutate the array, and select the first r elements.

**Example**

```bash
array = [1,2,3]
All permutations of the array are: [1,2,3], [1,3,2], [2,1,3], [2,3,1], [3,1,2], [3,2,1].
If we select the first 2 elements, we will get [1,2], [1,3], [2,1], [2,3], [3,1], [3,2].
[1,2] and [2,1] are same, so we need to remove duplicates.
```

The following code calculates all permutations of an array, select the first r elements of each permutation, and removes duplicates with the help of `HashSet`.

```
public void permute(int[] nums, int start, int end, int r, Set<List<Integer>> results){
    if(start==end){
	    //do something with a permutation here
	    List<Integer> result = new ArrayList();
        for(int i=0; i<r; i++){
	        result.add(nums[i]);
        }
        results.add(result);
    }
        
    for(int i=start; i<=end; i++){
	    //swap the current element with start element
        int temp = nums[i];
        nums[i] = nums[start];
        nums[start] = temp;
        //recursively permute all latter elements
        permute(nums, start+1, end, r);
        //after one permutation, swap back
        temp = nums[i];
        nums[i] = nums[start];
        nums[start] = temp;   
    }
}
```

The above code is an important framework of **permutation problems**. It could be explained as: 

```
Let {a,b,c} denote all permutations of [a,b,c]
then, {a,b,c} = a{b,c} + b{a,c} + c{a,b}
and permute {b,c}, {a,c}, {a,b} recursively.
```

After solving **selecting r elements from an array with n elements**, we can move on to construct the time with the hour and minute we get.

The complete code is as follows:

```
public class Solution {
    public List<String> readBinaryWatch(int num) {
        List<String> result = new ArrayList();
        int[] hours = new int[] {8,4,2,1};
        int[] minutes = new int[] {32,16,8,4,2,1};
        Set<Integer> selectedHours = new HashSet();
        Set<Integer> selectedMinutes = new HashSet();
        for(int i=0; i<=num; i++){
            if(i<=4 && num-i<=6){
                selectFromHours(hours, 0, hours.length-1, i, selectedHours);
                selectFromMinutes(minutes, 0, minutes.length-1, num-i, selectedMinutes);
                for(int h : selectedHours){
                    for(int m : selectedMinutes){
                        String m_str = (m<10) ? ("0"+m) : (""+m);
                        result.add(h+":"+m_str);
                    }
                }
                selectedHours.clear();
                selectedMinutes.clear();
            }
        }
        
        return result;
    }
    
    public void selectFromHours(int[] hours, int start, int end, int r, Set<Integer> selectedHours){
        if(r==0){
            selectedHours.add(0);
            return;
        }
        if(start==end){
            int sum = 0;
            for(int j=0; j<r; j++){
                sum += hours[j];
            }
            if(sum<=11){
                selectedHours.add(sum);
            }
        }
        
        for(int i=start; i<=end; i++){
            int temp = hours[i];
            hours[i] = hours[start];
            hours[start] = temp;
            selectFromHours(hours, start+1, end, r, selectedHours);
            temp = hours[i];
            hours[i] = hours[start];
            hours[start] = temp;
        }
    }
    
    public void selectFromMinutes(int[] minutes, int start, int end, int r, Set<Integer> selectedMinutes){
        if(r==0){
            selectedMinutes.add(0);
            return;
        }
        if(start==end){
            int sum = 0;
            for(int j=0; j<r; j++){
                sum += minutes[j];
            }
            if(sum<=59){
                selectedMinutes.add(sum);
            }
        }
        
        for(int i=start; i<=end; i++){
            int temp = minutes[i];
            minutes[i] = minutes[start];
            minutes[start] = temp;
            selectFromMinutes(minutes, start+1, end, r, selectedMinutes);
            temp = minutes[i];
            minutes[i] = minutes[start];
            minutes[start] = temp;
        }
    }
}
```

> Written with [StackEdit](https://stackedit.io/).
