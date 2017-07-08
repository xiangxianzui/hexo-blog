---
title: Frequently-used commands in Linux
date: 2017-05-19 13:39:38
tags: [Linux]
categories: [Interview]
---

This post concludes frequently-used commands in Linux, which might be functioning like a handy manual page for Linux commands.

 - man

```
$ man [command] //manual page of [command]
```

 - ls

``` 
$ ls -a //display all files, including hidden files
$ ls -l //list detailed information
$ ls -r //list files according to name, in reversing order
$ ls -i //view inode number
```

 - cat

```
$ cat [filename] //print content of [filename]
$ cat -n [filename] //print content as well as line number
$ cat > [filename] //create a new file and enter content from standard inputstream
$ cat [file1] [file2] > [file3] //concat contents in [file1] and [file2], and then write to [file3]
$ cat [bigfile] | more //use pipeline and more to view [bigfile]
$ cat >> [filename] //add content to the end of [filename]
```

 - mv

```
$ mv [oldname] [newname] //change file name
$ mv [file] [directory] //move [file] to [directory]
```

 - rm

```
$ rm -i [file] //interactive mode, ask for confirmation before deleting
$ rm -f [file] //force to delete
$ rm -r [directory] //delete all sub-directories and files in [directory] recursively
```

 - grep (global regular expression print)

```
$ grep [options] [PATTERN] [filename] //print contents which satisfy regular expression [PATTERN] in file [filename]
```
```
[options] includes: -n (display line number); -i (ignore character case); -v (display contents which don't satisfy regular expression)
```
 
 - find

```
$ find [path] [options] [expression] //find files whose name satisfies regular expression [expression] in the specific path [path]
e.g.: find . -name file.* //find files satisfying file.* in current directory
e.g.: find ./dir -name *.txt //find txt files in sub-directory ./dir
```

 - chmod

```
$ chmod u+x [file] //grant the user with execution authority
$ chmod a+r [file] //grant all users with reading authority
$ chmod 777 [file] //grant u(user),g(group),o(other) with reading(1), writing(2) and executing(4) authority (7=1+2+4)
```

 - tar

```
$ tar -czvf some.tar.gz file1 file2 file3 //compress file1, file2 and file3 using gzip
$ tar -xzvf some.tar.gz //uncompress some.tar.gz to current directory
```
 
 - pwd: print current working directory

 - diff
 
```
$ diff [file1] [file2] //compare two files and print differences
```
 
 - file: print the type of the file

```
e.g.: file test.txt
e.g.: file [directory]

```

 - ps

```
$ ps -a //display all processes, including other users' processes
$ ps -u //display processes belonging to current user
$ ps -x //print complete information
$ ps -ef | grep tomcat //print all processes relevant to tomcat in standard way(more human-readable)
e.g.: ps -aux | grep "google" //print all processes relevant to "google" in BSD style
```

 - top: print processes in real time, similar to resources monitor in Windows

 - kill

```
$ kill -l //display all kill SIGNAL
$ kill -9 [PID] //force to kill process [PID]
$ kill -15 [PID] //kill process [PID] in a moderate way, which means reclaim resources of the process and then kill it
$ kill [PID] //same with kill -15 [PID]
```
 
 - more/less

In general, both more and less print contents of a file to the screen. But they offer different functions. This [article](http://www.cnblogs.com/aijianshi/p/5750911.html) is a good resource to understand them.

 - uname

```
$ uname -a //check kernel version and name of the OS
```

 - netstat

```
$ netstat -a //display all possible columns
$ netstat -t //display TCP-relevant only
$ netstat -u //display UDP-relevant only
$ netstat -n //display number rather than name
$ netstat -l //display items which are in LISTEN status
$ netstat -p //display program names and PID of the connection
$ netstat
 -r //display kernel routing table
$ netstat -i //display kernel interface table
often used with grep:
netstat -anp | grep python //view connections relevant to python
netstat -anp | grep 8080 //view connections relevant to port 8080
```

- touch

Update the access and modification times of each FILE to the current time. But it is used to create a new file frequently.

```
$ touch [OPTION] [FILE] //change file timestamps.  
```


To be continued...
- - - 
> Written with [StackEdit](https://stackedit.io/).
