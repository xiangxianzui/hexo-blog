---
title: Spring如何处理循环依赖
date: 2020-02-29 20:51:47
tags: [Spring]
categories: [Work]
---
理解bean和对象的区别：

- bean是指经过spring完整生命周期、由spring容器管理的对象

- 对象就是单纯的指java对象，未经过spring完整生命周期的对象只能算是“未成熟的“bean


GoodService.java

```java
package com.test.ioc

@Service
public class GoodService {
    @Autowired
    private OrderService orderService;
    
    public void testGood() {
        ...
    }
}
```

OrderService.java

```java
package com.test.ioc

@Service
public class OrderService {
    @Autowired
    private GoodService goodService;
    
    public void testOrder() {
        ...
    }
}
```

Bootstrap.java

```java
public class Bootstrap {
    public static void main(String[] args) {
        AbstractApplicationContext ac = new AnnotationConfigApplicationContext("com.test.ioc");
    }
}
```

GoodService和OrderService循环引用了彼此，Spring在创建这两个bean的时候都做了哪些事情呢？

debug路线：refresh -> finishBeanFactoryInitialization -> preInstantiateSingletons -> getBean -> doGetBean -> createBean -> doCreateBean

创建GoodService的bean -> 

单例池：singletonObjects，存放“成熟的”单例bean

单例工厂池：singletonFactories，存放生产单例的工厂对象

单例工厂生产单例池：earlySingletonObjects，存放





Target Object目标对象

Proxy代理对象



何时创建代理？

- 有循环依赖
- 无循环依赖



AOP基础概念：

Aspect切面

PointCut切点

JointPoint连接点

Advice通知



Spring AOP和AspectJ的区别：

Spring AOP和AspectJ都是AOP框架，但是实现AOP的原理不同。

Spring AOP：

基于动态代理，在运行时生成代理对象来实现AOP。默认情况下，如果目标类实现了接口，用JDK动态代理生成代理对象，否则用CGLIB生成目标类的子类对象作为代理对象；当然也可以设置强制使用CGLIB来做代理。

Spring AOP需要依赖IOC容器来管理，代理对象的生成其实是在bean的生命周期内的。

由于在Spring容器启动时需要生成代理对象，而代理的使用势必会增加调用方法栈的深度，所以在性能上不如AspectJ.



AspectJ：

基于字节码增强，属于静态织入，通过修改代码来实现，在运行前就已经织入完成。

有3个织入时机：

编译期织入（Compile-time weaving）：未生成.class文件时织入

编译后织入（Post-compile weaving）：已生成.class文件时织入

加载时织入（Load-time weaving）：类加载器在加载.class文件过程中织入。(1)可以通过自定义类加载器来实现，(2)或者在JVM启动的时候指定javaagent：`-javaagent:xxx/xxx/xxx.jar`，可以自己实现一个javaagent或者使用AspectJ提供的aspectjweaver





jackson：static inner class, inner class, anonymous inner class

<http://www.cowtowncoder.com/blog/archives/2010/08/entry_411.html#disqus_thread>



<https://www.cnkirito.moe/dubbo-gracefully-startup/>