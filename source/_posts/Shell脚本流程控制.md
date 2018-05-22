---
title: Shell脚本流程控制
date: 2017-10-19 18:52:50
tags: [Linux, Shell]
categories: [Work]
---


### if-else
``` sh
#! /bin/sh
a=1
if [ $1=$a ]
then
 echo "you input 1"
elif [ $1=2 ]
then
 echo "you input 2"
else
 #do nothing
 echo " you input $1"
fi
```
如果某个条件下的执行体为空, 就不能写这个条件，否则会报错；
 [ ] 两边一定要加空格, 否则会报错；
注意: 实际上这里的[]是test命令的一种形式, [是系统的一个内置命令,存在路径是/bin/[,它是调用test命令的标识, 右中括号是关闭条件判断的标识。

### case
``` sh
#! /bin/sh
input=$1
case $input in
        1 | 0)
        str="一or零";;
        2)
        str="二";;
        3)
        str="三";;
        *)
        str=$input;;
esac
```
case 1 | 0代表逻辑或;
;;相当于其它语言中的break;
每个pattern之后记得加)

### for
``` sh
for file in *.txt
do
 open $file
done
```
[]括起来的 in list, 为可选部分, 如果省略in list则默认为in "$@", 即你执行此命令时传入的参数列表；

### while
``` sh
#! /bin/sh
i=0
while ((i<5));
do
 ((i++))
 echo "i=$i"
done
```

### until
``` sh
#! /bin/sh
i=5
until ((i==0))
do
 ((i--))
 echo "i=$i"
done
```

### 函数
``` sh
function funcname()
{
 do something
}
```
或者
``` sh
funcname ()
{
 do something
}
```

``` sh
#! /bin/sh
# ad.sh 计算sum
add()
{
 let "sum=$1+$2"
 return $sum
}
 
add $1 $2
echo "sum=$?"
```

\$?保存的是上一条命令的返回值，\$@代表所有参数的内容, \$#代表所有参数的个数, \$0代表脚本的名称, \$1代表第一个参数的值.
函数必须先定义后使用；
如果在函数中使用exit会退出脚本, 如果想退回到原本函数调用的地方, 则可使用return；

---
> Written with [StackEdit](https://stackedit.io/).
