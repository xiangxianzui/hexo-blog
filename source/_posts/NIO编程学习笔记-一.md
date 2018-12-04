---
title: NIO编程学习笔记(一)
date: 2017-10-24 16:16:23
tags: [NIO, 网络编程]
categories: [Learning]
---

## 基本概念

### “伪异步”
JAVA socket I/O是阻塞型的，为每个请求开一个线程，并发请求过多时必然消耗大量资源，JDK1.5之前没有NIO，怎样解决高并发问题呢？可以采用线程池和阻塞队列实现一种“伪异步”的IO通信框架。

其实就是将客户端的socket封装成一个task任务(实现Runnable接口)然后投递到线程池中，线程池限制了系统为应用开辟的最大线程数，如果同时有大量的请求到来，超过了最大线程数，那么就会添加到阻塞队列中等待进入线程池。

这种方法实际上仅仅能够解决高并发引起的服务器宕机问题，但是并不能提高效率。

### 阻塞和非阻塞
BIO(Blocking I/O)和NIO(Non-Blocking I/O)的区别，其本质就是阻塞和非阻塞的区别。

阻塞：应用程序在获取网络数据的时候，如果网络传输数据很慢，那么程序就一直等着，直到传输完毕为止。

非阻塞：应用程序直接可以获取已经准备就绪好的数据，无需等待。

**BIO为同步阻塞形式，NIO为同步非阻塞形式，NIO并没有实现异步，在JDK1.7之后，升级了NIO库包，支持异步非阻塞通信模型，即NIO2.0(AIO)**

### 同步和异步
同步和异步：同步和异步一般是面向操作系统与应用程序对IO操作的层面上来区别的。

同步时，应用会直接参与IO读写操作，并且我们的应用程序会直接阻塞到某一个方法上，直到数据准备就绪；或者采用轮询的策略实时检查数据的就绪状态，如果就绪则获取数据。

异步时，所有的IO读写操作交给操作系统处理，与我们的应用程序没有直接关系，程序不需要关系IO读写，当操作系统完成了IO读写操作时，会给我们应用程序发送通知，应用程序直接拿走数据即可。

## NIO概述
> 从这里开始，后面所有关于NIO编程的内容均翻译自[java nio tutorial](http://tutorials.jenkov.com/java-nio/index.html)

在标准IO中我们使用字节流和字符流，在NIO中我们使用Channel和Buffer。数据总是从channel被读到buffer，或者从buffer被写入channel中。Java NIO可以让我们以非阻塞的形式进行IO操作。比如一个线程可以将数据从channel读到buffer，与此同时，线程可以做其他事情而不必阻塞于IO操作。一旦数据被读到了buffer，线程可以回过头来处理这些数据。向channel中写入数据也是类似。除了Channel和Buffer之外，Selector也是NIO中最重要的概念。一个selector可以通过轮询的方式监听多个channel中的事件(比如：打开连接，数据到来等)，因此，只需单个线程就可以监控多个channel了。

### Channels and Buffers
在NIO中，所有的IO操作都是从一个channel开始的。Channel有点像流(stream)，数据可以从channel读到buffer，也可以从buffer写入到channel，如下图：
![Java NIO: Channels read data into Buffers, and Buffers write data into Channels](overview-channels-buffers.png "Java NIO: Channels read data into Buffers, and Buffers write data into Channels")


Java NIO中主要有以下几种Channel的实现类：
- FileChannel
- DatagramChannel
- SocketChannel
- ServerSocketChannel

可以看到，这些实现类涵盖了UDP/TCP newwork IO和file IO

Java NIO中的Buffer实现类有以下几种：
- ByteBuffer
- CharBuffer
- DoubleBuffer
- FloatBuffer
- IntBuffer
- LongBuffer
- ShortBuffer

可以看到，Buffer针对Java中除了Boolean的所有基本数据类型都实现了相应的Buffer类。
除了以上7种之外，还有一个MappedByteBuffer类。

### Selector
Selector使得单线程就可以处理多个channel。当我们有许多连接(channel)同时打开，每个连接却只有少量的通信流量的时候(比如：聊天服务器)，这种特性是十分好用的。

下图描述了一个线程利用Selector处理3个channel
![Java NIO: A Thread uses a Selector to handle 3 Channel's](overview-selectors.png "Java NIO: A Thread uses a Selector to handle 3 Channel's")

使用Selector的时候必须把需要监听的channel注册到该Selector上，然后调用Selector的select()方法，该方法会一直阻塞，直到注册过的channels中有就绪的event发生，然后线程就会处理这些event。
