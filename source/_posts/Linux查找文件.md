---
title: Linux查找文件
date: 2017-10-19 15:42:24
tags: [Linux]
categories: [Work]
---

Linux下查找文件通常可以用which，whereis，locate和find命令，下面总结它们各自的用法和区别。

### which
which 用来查找可执行文件的绝对路径。which只能用来查找PATH环境变量中出现的路径下的可执行文件。当查找的文件在PATH变量中并没有时，就会报错。

### whereis 和 locate
whereis 通过预先生成的一个文件列表库去查找跟给出的文件名相关的文件。
locate 类似于whereis，也是通过查找预先生成的文件列表库来告诉用户要查找的文件在哪里。后边直接跟文件名。

### find
find 语法： find [路径] [参数]
常用的参数
-atime +n ：访问或执行时间大于n天的文件
-ctime +n ：写入、更改inode属性（例如更改所有者、权限或者连接）时间大于n天的文件
-mtime +n ：写入时间大于n天的文件
-name expression ：根据正则表达式查找文件     e.g.  find . -name "*p.java" 在当前目录查找以p结尾的java文件
-type type ：通过文件类型查找
文件的 Access time，atime 是在读取文件或者执行文件时更改的。
文件的 Modified time，mtime 是在写入文件时随文件内容的更改而更改的。
文件的 Create time，ctime 是在写入文件、更改所有者、权限或链接设置时随 Inode 的内容更改而更改的。 
因此，更改文件的内容即会更改 mtime 和 ctime，但是文件的ctime 可能会在 mtime 未发生任何变化时更改，例如，更改了文件的权限，但是文件内容没有变化。 
如何获得一个文件的atime mtime 以及ctime ？
ls -l 命令可用来列出文件的 atime、ctime 和 mtime。
ls -lc filename         列出文件的 ctime
ls -lu filename         列出文件的 atime
ls -l filename          列出文件的 mtime 
atime不一定在访问文件之后被修改，因为：使用ext3文件系统的时候，如果在mount的时候使用了noatime参数那么就不会更新atime的信息。而这是加了 noatime 取消了, 不代表真实情況。反正, 這三個 time stamp 都放在 inode 中。若 mtime, atime 修改inode 就一定會改, 既然 inode 改了, 那 ctime 也就跟着要改了。


---
> Written with [StackEdit](https://stackedit.io/).
