---
title: 'LeetCode: Delete Node in a Linked List'
date: 2017-01-12 11:27:07
tags: [Linked List]
categories: [LeetCode]
---

## Problem

Write a function to delete a node (except the tail) in a singly linked list, given only access to that node.

Supposed the linked list is `1 -> 2 -> 3 -> 4` and you are given the third node with value `3`, the linked list should become `1 -> 2 -> 4` after calling your function.

## Solution

The solution is a little tricky. Normally, when we delete a node from a linked list, we should know the previous node of the one we want to delete. However, at this time, we only have access to the node to be deleted. So, we have to "**sacrifice**" the next node! Here is the java code:

```
public class Solution {
    public void deleteNode(ListNode node) {
        if(node!=null){
            node.val = node.next.val;
            node.next = node.next.next;
        }
    }
}
```

This problem is quite easy, but tricky. I just want to record this trick to guarantee I won't forget it someday :)

> Written with [StackEdit](https://stackedit.io/).
