---
title: NIO编程学习笔记(三)
date: 2017-10-24 21:39:54
tags: [NIO, 网络编程]
categories: [学习笔记]
---

## Java NIO Buffer

### 概述
Java NIO Buffer通常被用来与Channel交互，我们知道，数据从channel被读到buffer，从buffer被写入channel。
一个buffer是一个内存块，让我们写入数据，写完之后从中读取数据。这块内存被封装成NIO Buffer对象，并提供了一些方法让我们方便地操作这块内存。

### Buffer基本用法
Buffer读取和写入数据通常分以下4个过程：
- 向buffer写入数据
- 调用buffer.flip()
- 从buffer读数据
- 调用buffer.clear()或者buffer.compact()

当我们向buffer写数据时，buffer会自动跟踪写了多少数据。当我们需要从buffer读数据时，需要将buffer从"writing mode"切换到"reading mode"，也就是要调用flip()方法。在reading mode下我们可以读取所有被写入buffer的数据。

当我们已经读取完所有数据时，我们需要清空buffer，好让buffer可以重新被写入。有两种方法做到这点：clear()和compact()。clear()方法清空整个buffer；compact()方法只清空我们已经读过的数据，所有尚未读到的数据都会被移动到buffer的起始位置，接下来数据将会被写入到未读数据之后。

下面是一个例子：
``` java
RandomAccessFile aFile = new RandomAccessFile("data/nio-data.txt", "rw");
FileChannel inChannel = aFile.getChannel();

//create buffer with capacity of 48 bytes
ByteBuffer buf = ByteBuffer.allocate(48);

int bytesRead = inChannel.read(buf); //read into buffer.
while (bytesRead != -1) {

  buf.flip();  //make buffer ready for read

  while(buf.hasRemaining()){
      System.out.print((char) buf.get()); // read 1 byte at a time
  }

  buf.clear(); //make buffer ready for writing
  bytesRead = inChannel.read(buf);
}
aFile.close();
```

### Buffer中的Capacity,Position和Limit
Buffer类有三个重要的属性，分别是：
- capacity
- position
- limit

position和limit的含义在reading mode和writing mode下有所不同，但是capacity的含义无论哪种mode都是相同的。

![Buffer capacity, position and limit in write and read mode](buffers-modes.png "Buffer capacity, position and limit in write and read mode")

#### capacity
作为一个内存块，Buffer有固定的大小，即capacity。一旦Buffer满了，我们必须先清理它(read the data, or clear it)，才能再次写入数据。

#### position
向Buffer写入数据是从一个特定的position开始的，最初position等于0。当不断地向Buffer写数据时，position就不断地向前移动。position最大等于capacity-1

从Buffer读数据也是从一个给定的position开始的。调用flip()方法从writing mode切换到reading mode时，position的值被重置为0，随着我们不断地读数据，position的值也会不断地向前移动。

#### limit
writing mode下，limit是我们能够写入Buffer的最大数据数，和capacity相等。

reading mode下，limit是我们能够从Buffer读取的最大数据数。用flip()方法切换到reading mode时，limit被设置成writing mode下的position(见上图)。换言之，我们之前写入多少数据就可以读多少数据。

### Buffer的实现类
Buffer主要有以下8种实现类：
- ByteBuffer
- MappedByteBuffer
- CharBuffer
- DoubleBuffer
- FloatBuffer
- IntBuffer
- LongBuffer
- ShortBuffer

### 向Buffer写数据
有两类向Buffer写入数据的方法：
- 从Channel写入
- 用put()方法写入

``` java
int bytesRead = inChannel.read(buf); //read into buffer.

buf.put(127);
```
更多put()方法的api可参考JavaDoc

### flip()方法
``` java
public final Buffer flip() {
    limit = position;
    position = 0;
    mark = -1;
    return this;
}
```

flip()方法将Buffer从writing mode切换到reading mode。切换完成后，position标记着读的起始位置，limit标记着最多有多少数据可读。

### 从Buffer读数据
有两类从Buffer读取数据的方法：
- 从Channel读取
- 用get()方法读取

``` java
int bytesWritten = inChannel.write(buf); //read from buffer into channel.

byte aByte = buf.get(); 
```
更多get()方法的api可参考JavaDoc

### rewind()方法
``` java
public final Buffer rewind() {
    position = 0;
    mark = -1;
    return this;
}
```

注意rewind()与flip()的唯一区别就是不改变limit

### clear()和compact()
一旦读完Buffer中的数据，需要让Buffer准备好再次被写入。可以通过clear()和compact()方法来完成。

如果调用clear()方法，position将被设为0，limit被设置成capacity的值。换句话说，Buffer被清空了，但是Buffer中的数据并未清除，只是这些标记告诉我们可以从哪里开始往Buffer里写数据。如果Buffer中有一些未读的数据，调用clear()方法，这些数据将“被遗忘”，意味着不再有任何标记会告诉你哪些数据被读过，哪些还没有。

如果Buffer中仍有未读的数据，且后续还需要这些数据，但是此时想要先写些数据，那么使用compact()方法。compact()方法将所有未读的数据拷贝到Buffer起始处，然后将position设为最后一个未读元素后面。limit属性依然像clear()方法一样，设置成capacity。现在Buffer准备好写数据了，但是不会覆盖未读的数据。

### mark()和reset()
我们可以用mark()方法记住某个position，然后用reset()方法将position重置为刚刚mark的标记。
``` java
buffer.mark();

//call buffer.get() a couple of times, e.g. during parsing.

buffer.reset();  //set position back to mark.
```

## Java NIO Selector
Selector可以监控一个或多个channel，查看哪些channel有感兴趣的事件就绪，这样的话单线程就可以管理多个channel，即多个网络连接。
![Java NIO: A Thread uses a Selector to handle 3 Channels](overview-selectors.png "Java NIO: A Thread uses a Selector to handle 3 Channels")

### 创建Selector
``` java
Selector selector = Selector.open();
```

### 把Channel注册到Selector上
为了让Selector能够监听Channel，我们必须把Channel注册到Selector上去。
``` java
channel.configureBlocking(false);

SelectionKey key = channel.register(selector, SelectionKey.OP_READ);
```

为了与Selector配合使用，Channel必须配置成non-blocking mode。这就意味着我们不能将FileChannel和Selector配合使用，因为FileChannel不能被配置成non-blocking mode。不过其它Channel可以。

注意register()方法的第二个参数，这是"interest set"，也就是我们把Channel注册到Selector上面，让Selector时刻注意我们感兴趣的event。我们可以监听4种event：
- Connect
- Accept
- Read
- Write

Channel触发了一个event说明该event已经就绪。一个Channel成功连接上另一台服务器称为"connect ready"；一个ServerSocketChannel准备好接受一个连接称为"accept ready"；一个有数据可读的Channel称为"read ready"；一个准备接受写入数据的Channel称为"write ready"。

上面4中event可以用4个常量表示：
- SelectionKey.OP_CONNECT
- SelectionKey.OP_ACCEPT
- SelectionKey.OP_READ
- SelectionKey.OP_WRITE

如果我们对不止一种event感兴趣，可以用**OR运算符**连接起来：
``` java
int interestSet = SelectionKey.OP_READ | SelectionKey.OP_WRITE;
```

### SelectionKey
register()方法返回一个SelectionKey对象，SelectionKey对象有下面几个property：
- The interest set
- The ready set
- The Channel
- The Selector
- An attached object (optional)

下面分别详细说明这些property

#### Interest Set
Interest Set是我们感兴趣的事件的集合，我们可以通过SelectionKey读写Interest Set，看下例：
``` java
int interestSet = selectionKey.interestOps();

boolean isInterestedInAccept  = interestSet & SelectionKey.OP_ACCEPT;
boolean isInterestedInConnect = interestSet & SelectionKey.OP_CONNECT;
boolean isInterestedInRead    = interestSet & SelectionKey.OP_READ;
boolean isInterestedInWrite   = interestSet & SelectionKey.OP_WRITE;
```

可以看到，用**AND**操作Interest Set和给定的SelectionKey常量，可以确定某个确定的事件是否在Interest Set中。

#### Ready Set
Ready Set是Channel已经准备就绪的操作的集合。在一次选择(Selection)之后，我们会得到这个Ready Set
``` java
int readySet = selectionKey.readyOps();
```

我们可以通过与Interest Set类似的方法判断某个event是否在Ready Set中，也可以用下面的方法：
``` java
boolean isAcceptReady = selectionKey.isAcceptable();
boolean isConnectReady = selectionKey.isConnectable();
boolean isReadReady = selectionKey.isReadable();
boolean isWriteReady = selectionKey.isWritable();
```

#### Channel和Selector
通过SelectionKey得到Channel和Selector是很简单的：
``` java
Channel  channel  = selectionKey.channel();

Selector selector = selectionKey.selector();
```

#### Attaching Objects
可以将一个对象或者更多信息附加到SelectionKey上，这样就能方便地识别某个Channel。比如，可以附加与Channel一起使用的Buffer，或是包含聚集数据的某个对象。如下例：
``` java
selectionKey.attach(theObject);

Object attachedObj = selectionKey.attachment();
```

也可以在注册的时候直接附加一个对象到SelectionKey上：
``` java
SelectionKey key = channel.register(selector, SelectionKey.OP_READ, theObject);
```

### 通过Selector选择Channel
向一个Selector注册一个或多个Channel后，我们就可以使用select()方法了。该方法返回我们感兴趣的事件(connect, accept, read or write)且这些事件已经准备就绪的那些Channel。比如，我们对“读就绪”的Channel感兴趣，select()方法会返回读事件已经就绪的那些Channel。

有以下3种select()方法：
- int select()
- int select(long timeout)
- int selectNow()

select()在有就绪事件的Channel出现之前会一直阻塞
select(long timeout)与select()相似，只不过最多阻塞timeout微秒
selectNow()不会阻塞，它会立即返回，不论是否有Channel就绪

select()方法返回的int值表示有多少通道已经就绪，也就是自上次调用select()方法后有多少通道变成就绪状态。如果调用select()方法，这时有一个通道变成就绪状态，就会返回1，若再次调用select()方法，这时另一个通道就绪了，它会再次返回1。如果对第一个就绪的channel没有做任何操作，现在就有两个就绪的通道，但在每次select()方法调用之间，只有一个通道就绪了。

### selectedKeys()方法
调用了select()方法后，可以通过selectKeys()方法得到“selected key set”，进而得到就绪的Channel.
``` java
Set<SelectionKey> selectedKeys = selector.selectedKeys(); 
```

下面是一个比较完整的例子：
``` java
Set<SelectionKey> selectedKeys = selector.selectedKeys();

Iterator<SelectionKey> keyIterator = selectedKeys.iterator();

while(keyIterator.hasNext()) {
    
    SelectionKey key = keyIterator.next();

    if(key.isAcceptable()) {
        // a connection was accepted by a ServerSocketChannel.

    } else if (key.isConnectable()) {
        // a connection was established with a remote server.

    } else if (key.isReadable()) {
        // a channel is ready for reading

    } else if (key.isWritable()) {
        // a channel is ready for writing
    }

    keyIterator.remove();
}
```

遍历所有在selected key set中的key，对每一个key都判断是否有就绪的事件发生。
注意最后的keyIterator.remove()，Selector不会自己从selected key set中移除SelectionKey实例，必须在处理完通道时自己移除。下次该通道变成就绪时，Selector会再次将其放入selected key set中。

SelectionKey.channel()方法返回的通道需要转型成我们要处理的类型，比如ServerSocketChannel,SocketChannel等。

### wakeUp()方法
如果select()方法一直阻塞，也就是一直没有就绪的Channel，这时可以用wakeUp()方法让线程从select()方法返回。只要让其它线程在第一个线程调用select()方法的那个对象上调用Selector.wakeup()方法即可，阻塞在select()方法上的线程会立即返回。

如果有其它线程调用了wakeup()方法，但当前没有线程阻塞在select()方法上，下个调用select()方法的线程会立即wake up。

### close()方法
close()方法关闭一个Selector，并且使得所有注册到这个Selector上的SelectionKey实例全部失效，但是注册的Channel不会被关闭。

###　一个完整的例子
打开一个Selector，把Channel注册到这个Selector上，然后监控事件是否就绪。
``` java
Selector selector = Selector.open();

channel.configureBlocking(false);

SelectionKey key = channel.register(selector, SelectionKey.OP_READ);


while(true) {

  int readyChannels = selector.select();

  if(readyChannels == 0) continue;


  Set<SelectionKey> selectedKeys = selector.selectedKeys();

  Iterator<SelectionKey> keyIterator = selectedKeys.iterator();

  while(keyIterator.hasNext()) {

    SelectionKey key = keyIterator.next();

    if(key.isAcceptable()) {
        // a connection was accepted by a ServerSocketChannel.

    } else if (key.isConnectable()) {
        // a connection was established with a remote server.

    } else if (key.isReadable()) {
        // a channel is ready for reading

    } else if (key.isWritable()) {
        // a channel is ready for writing
    }

    keyIterator.remove();
  }
}
```
