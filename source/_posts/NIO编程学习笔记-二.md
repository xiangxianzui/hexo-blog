---
title: NIO编程学习笔记(二)
date: 2017-10-24 16:46:42
tags: [NIO, 网络编程]
categories: [Learning]
---

## Java NIO Channel

### 概述
Java NIO Channel与流(stream)的概念相似，但有以下几点不同：
- 我们可以同时对channel进行读写操作，而stream是单向的，读和写不能同时进行
- Channel可以异步地进行读写
- Channel总是向buffer读数据，或者从buffer写数据

![Java NIO: Channels read data into Buffers, and Buffers write data into Channels](overview-channels-buffers.png "Java NIO: Channels read data into Buffers, and Buffers write data into Channels")

前面提到过Channel主要有以下四种实现类：
- FileChannel
- DatagramChannel
- SocketChannel
- ServerSocketChannel

FileChannel向文件读写数据
DatagramChannel通过UDP读写数据
SocketChannel通过TCP读写数据
ServerSocketChannel监听即将到来的TCP连接，就像Web服务器所做的那样。对每一个到来的TCP连接，都会创建一个SocketChannel

### 简单的关于Channel的例子
这个例子用了FileChannel将数据读到buffer中

``` java
RandomAccessFile aFile = new RandomAccessFile(System.getProperty("user.dir")+"/data/nio-data.txt", "rw");
FileChannel inChannel = aFile.getChannel();

ByteBuffer buf = ByteBuffer.allocate(48);

int bytesRead = inChannel.read(buf);
while (bytesRead != -1) {

    System.out.println("Read " + bytesRead);
    buf.flip();

    int i = 0;
    while(buf.hasRemaining()){
        System.out.println(i + " "+(char) buf.get());
        i++;
    }

    buf.clear();
    bytesRead = inChannel.read(buf);
}
aFile.close();
```

### Channel的Scattering read和Gathering write

#### Scatter(扩散)
Scattering read是指将1个channel的数据读到多个buffer中去，如图：
![Java NIO: Scattering Read](scatter.png "Java NIO: Scattering Read")

下面是一个简单的Scattering read的例子
``` java
ByteBuffer header = ByteBuffer.allocate(128);
ByteBuffer body   = ByteBuffer.allocate(1024);

ByteBuffer[] bufferArray = { header, body };

channel.read(bufferArray);
```

read()方法首先填充header，header满了之后再填充body
Scattering read只有在填满1个buffer之后才会去填充下一个，这意味着它不适合用在大小动态变化的场景。比如，我们有1个header和1个body，header的大小是固定的(e.g. 128 bytes)，那么使用Scattering read是可行的；如果header大小是可变的(e.g. 这次128 bytes，下次64 bytes了)，那么用Scattering read读到第一个buffer中的数据可能不是我们想要的。

#### Gather(聚集)
Gathering write是指将多个buffer中的数据写入到1个channel中，如图：
![Java NIO: Gathering Write](gather.png "Java NIO: Gathering Write")

下面是一个简单的Gathering write的例子
``` java
ByteBuffer header = ByteBuffer.allocate(128);
ByteBuffer body   = ByteBuffer.allocate(1024);

//write data into buffers

ByteBuffer[] bufferArray = { header, body };

channel.write(bufferArray);
```

与前面的read()方法类似，write()方法按顺序将buffer依次写入到channel中，当然，只写入buffer在position和limit之间的数据，比如buffer的capacity是128字节，但是position和limit之间只有58字节，那么只写入58字节。因此，Gathering write不存在像Scattering read那样不适合用在大小动态变化场景的问题。

### Channel和Channel之间传输数据
Java NIO允许我们直接在两个channel之间传输数据，当然这样做的前提是其中一个channel是FileChannel类，因为FileChannel类提供了transferFrom()和transferTo()

#### transferFrom()
FileChannel.transferFrom()将数据从源channel传输到FileChannel中。

``` java
RandomAccessFile fromFile = new RandomAccessFile("fromFile.txt", "rw");
FileChannel      fromChannel = fromFile.getChannel();

RandomAccessFile toFile = new RandomAccessFile("toFile.txt", "rw");
FileChannel      toChannel = toFile.getChannel();

long position = 0;
long count    = fromChannel.size();

toChannel.transferFrom(fromChannel, position, count);
```

参数position和count，告诉我们从目的文件的何处(position)开始写入数据，以及最多写入多少(count)字节的数据。如果源channel的字节数小于count，则有多少写入多少。
除此之外，如果源channel是SocketChannel的话，transferFrom()方法只会传输SocketChannel当前的数据，即使未来SocketChannel中还会有新的数据到来。因此，如果调用该方法时SocketChannel中的字节数少于count，传输的字节也少于count，即使未来SocketChannel中字节数多于count。

#### transferTo()
transferTo()方法将数据从FileChannel传输到目的channel。

``` java
RandomAccessFile fromFile = new RandomAccessFile("fromFile.txt", "rw");
FileChannel      fromChannel = fromFile.getChannel();

RandomAccessFile toFile = new RandomAccessFile("toFile.txt", "rw");
FileChannel      toChannel = toFile.getChannel();

long position = 0;
long count    = fromChannel.size();

fromChannel.transferTo(position, count, toChannel);
```

此例与上面的例子相似。与此同时，上面提到的SocketChannel的问题在这里依然存在。

### SocketChannel
Java NIO SocketChannel是连接到TCP网络套接字的通道，有两种方法可以创建它。
- 我们打开SocketChannel并连接到互联网某服务器
- 当有新的连接到达ServerSocketChannel时，一个SocketChannel会被创建

#### 打开一个SocketChannel
``` java
SocketChannel socketChannel = SocketChannel.open();
socketChannel.connect(new InetSocketAddress("http://jenkov.com", 80));
```

#### 关闭一个SocketChannel
``` java
socketChannel.close();
```

#### 从SocketChannel读数据
``` java
ByteBuffer buf = ByteBuffer.allocate(48);

int bytesRead = socketChannel.read(buf);
```
read()方法将数据从SocketChannel读到buffer中，方法返回的int值为读到数据的字节数，如果返回为-1，说明读到了流的末尾(连接关闭了)。

#### 向SocketChannel写数据
``` java
String newData = "New String to write to file..." + System.currentTimeMillis();

ByteBuffer buf = ByteBuffer.allocate(48);
buf.clear();
buf.put(newData.getBytes());

buf.flip();

while(buf.hasRemaining()) {
    channel.write(buf);
}
```
注意SocketChannel.write()方法的调用是在一个while循环中的。write()方法无法保证能写多少字节到SocketChannel，所以重复调用write()直到Buffer没有要写的字节为止。

#### 非阻塞模式(Non-blocking Mode)
我们可以把SocketChannel设置为非阻塞模式，这样我们就可以在异步模式下调用connect(),read(),write()

connect()：
如果SocketChannel处于非阻塞模式，然后调用connect()方法，方法可能在连接建立完成之前就返回了。为了确定连接是否建立完成了，我们可以用finishConnect方法进行判断，如下例：
``` java
socketChannel.configureBlocking(false);
socketChannel.connect(new InetSocketAddress("http://jenkov.com", 80));

while(! socketChannel.finishConnect() ){
    //wait, or do something else...
}
```

write()：
非阻塞模式下write()方法可能在尚未写入任何数据时就返回了，因此需要在循环中调用write()方法。

read()：
非阻塞模式下read()方法可能在尚未读取任何数据时就返回了，因此需要时刻关注read()方法的返回值，看读了多少字节。

#### 非阻塞模式与Selector配合使用
非阻塞模式与Selector搭配会工作的更好，通过将一或多个SocketChannel注册到Selector，可以询问选择器哪个通道已经准备好了读取，写入等。后面会详细说明。

### ServerSocketChannel
ServerSocketChannel可以监听即将到达的TCP连接，就像Java标准IO中的ServerSocket。
下面是一个例子：
``` java
ServerSocketChannel serverSocketChannel = ServerSocketChannel.open();

serverSocketChannel.socket().bind(new InetSocketAddress(9999));

while(true){
    SocketChannel socketChannel = serverSocketChannel.accept();

    //do something with socketChannel...
}
```

#### 打开和关闭ServerSocketChannel
``` java
ServerSocketChannel serverSocketChannel = ServerSocketChannel.open();

serverSocketChannel.close();
```

#### 监听新到来的TCP连接
通过ServerSocketChannel.accept()方法监听新进来的连接。当accept()方法返回的时候,它返回一个包含新进来的连接的SocketChannel。因此,accept()方法会一直阻塞到有新连接到达。
我们通常不会仅仅监听一个连接，因此通常像下例这么做：Se
``` java
while(true){
    SocketChannel socketChannel = serverSocketChannel.accept();

    //do something with socketChannel...
}
```

#### 非阻塞模式
ServerSocketChannel也可以被设置成非阻塞模式。在非阻塞模式下，ServerSocketChannel的accep()不论有没有连接到达都会立即返回，因此可能返回为null。看下例：
``` java
ServerSocketChannel serverSocketChannel = ServerSocketChannel.open();

serverSocketChannel.socket().bind(new InetSocketAddress(9999));
serverSocketChannel.configureBlocking(false);

while(true){
    SocketChannel socketChannel = serverSocketChannel.accept();

    if(socketChannel != null){
        //do something with socketChannel...
    }
}
```

