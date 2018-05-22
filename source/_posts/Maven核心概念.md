---
title: Maven核心概念
date: 2018-02-08 21:24:03
tags: [Maven]
categories: [学习笔记]
---

### Maven是什么
- Apache基金会出品
- 开源
- java写的
- Maven是一个项目构建和依赖管理的工具

### 为什么选择Maven
- 基于约定优先于配置的原则：默认限定了项目的目录结构，项目之间迁移的学习成本低
- 提供三方依赖包的管理：提供远程仓库，解决了依赖维护
- 提供一致的项目构建管理方式：将项目构建过程的操作抽象成生命周期，减少构建工作量
- 插件式的架构，大量的可重用的插件
- 方便地集成IDE

### pom.xml
- POM: Project Object Model
- groupId:组织
- artifactId:项目标识符
- version:版本　　X.Y.Z-SNAPSHOT, X.Y.Z-RELEASE, X.Y.Z
- groupId,artifactId,version三个字段构成了一个项目的唯一坐标
- packaging:打包类型　有war,jar,pom三种
- dependencies:依赖的项目

### Maven基本命令
- `mvn archetype:generate`  使用模板生成项目
例子： 
`mvn archetype:generate -DgroupId=com.netease.restaurant -DartifactId=Kitchen -Dpackage=com.netease -Dversion=1.0.0-SNAPSHOT -DarchetypeArtifactId=maven-archetype-webapp`
archetypeArtifactId指定了项目类型
web项目模板：maven-archetype-webapp
java项目模板：maven-archetype-quickstart
- `mvn compile`  编译源代码
- `mvn test`  一般用来跑单元测试
- `mvn package`  打包
- `mvn deploy`  部署
- `mvn site`  生成项目相关的站点和在线文档等
- `mvn clean`  清理
- `mvn install`  把包安装到本地仓库，从而让其他项目引用

### Tomcat插件
- Tomcat官方提供的，实现了在Maven中内嵌一个Tomcat，方便开发调试
- `mvn help:describe -Dplugin=tomcat7`  获得插件的详细帮助
- `mvn tomcat7:run`  启动一个Tomcat实例
- 还有`mvn tomcat7:deploy`  `mvn tomcat7:undeploy`等命令

### 父pom与子pom
- 子pom从父pom中继承，也可以覆盖父pom中的配置
- 可继承项目：
坐标，如groupId
依赖配置
插件配置
一般性信息，如开发者信息、开源协议等

### Super POM
- 所有Maven项目的POM都继承自Super POM
- 是Maven的组成部分
- 定义了一组被所有项目共享的默认设置
如：默认的文件结构
统一的插件配置
默认的中央仓库配置

### 多模块构建
- parent项目，packaging类型是pom，定义多个modules
- 子模块module配置通过`<parent></parent>`属性指定parent项目，继承自parent

### 依赖配置
```
<dependencies>
  <dependency>
    <groupId>javax.servlet</groupId>
    <artifactId>servlet-api</artifactId>
    <version>3.0.1</version>
    <scope>provided</scope>
  </dependency>
</dependencies>
```
scope指的是依赖范围，有两种：compile和provided
不配置scope时默认是compile，指所依赖的包在编译的时候用，在打包的时候也会把这个依赖包打包进去；provided就是在依赖包在只在编译的时候用，在打包的时候不把依赖包打包进去，因为在部署的时候一般容器都会提供这个依赖包，所以不需要再打包进去了

### 仓库
- 用于统一存储所有Maven项目共享的构件的空间
- 仓库分为本地仓库和远程仓库。本地仓库相当于缓存，在查找依赖包时，首先在本地仓库找，找不到再从远程仓库下载，下载到本地仓库以便下次使用。
- 本地仓库目录为`${usr.home}/.m2/repository`
- 远程仓库有中央仓库、其他公共仓库、私服三种。中央仓库由maven官方提供和维护，其他公共仓库提供国内镜像等，私服由公司内部搭建
- maven项目在远程仓库的存放路径为：`/<groupId>/<artifactId>/<version>/<artifactId>-<version>.<packaging>`

### 构建的生命周期
- 一个构建生命周期是一组精心组织的有序的阶段
- 每个阶段执行预先定义的“动作”：编译、打包、部署等等
- 这些“动作”会根据项目的类型进行选择
#### clean生命周期：pre-clean -> clean -> post-clean
#### default生命周期：... -> process-resources -> compile -> ... -> test -> package -> install -> deploy
举几个阶段的例子：
- validate：验证项目是否正确，以及检查为了完成完整构建过程所必要的信息是否有缺少
- process-resources：将资源文件复制目标目录下
- compile：编译源代码
- test：跑单元测试
- package：打包
- install：将包安装到本地仓库，供其他项目进行依赖
- deploy：将包上传到远程仓库
#### site生命周期：pre-site -> site -> post-site -> site-deploy

### 插件(Plugin)和目标(Goal)
- Maven是插件式架构，可以看成是由一个引擎和多个插件构成的，所有的插件本身也是一个Maven构件，由Maven仓库管理
- 每个Plugin提供多个Goal
- 调用目标的格式：`mvn <Plugin>:<Goal>`

### 插件和目标绑定构建生命周期
- 生命周期的阶段与目标是绑定的，用户指定生命周期阶段实际上是隐式地调用了某个插件执行任务
- 生命周期的各个阶段绑定的目标如表所示：
|    生命周期阶段    | 目标 |
| ---------- | --- |
| process-resources |  resources:resources |
| compile       |  compiler:compile |
| test          |  surefire:test |
| install       |  install:install |
| deploy        |  deploy:deploy |
比如`mvn compile`实际上就是执行了compiler插件的compile目标，相当于执行了`mvn compiler:compile`
对于package阶段，会根据项目类型不同，绑定到不同的目标

### 插件配置
在pom.xml中经常会配置某个插件的参数，如果不知道怎么配，可以用下面命令查看帮助文档：
`mvn help:describe -Dplugin=<plugin_name> -Dgoal=<goal_name> -Ddetail`
比如查看compiler插件中compile目标的配置参数帮助文档：
`mvn help:describe -Dplugin=compiler -Dgoal=compile -Ddetail`








