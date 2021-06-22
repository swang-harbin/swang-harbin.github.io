---
title: IDEA导入普通Web项目
date: '2020-04-22 00:00:00'
updated: '2020-04-22 00:00:00'
tags:
- IDEA
- Java
categories:
- Java
---

# IDEA导入普通Web项目

IDEA版本: IntelliJ IDEA 2020.1(Ultimate Edition)

## 普通Web项目目录结构介绍

```bash
project/
├── src
└── web
    ├── classes
    ├── index.jsp
    └── WEB-INF
        ├── lib
        └── web.xml
```

**project**: 项目目录

- **src**: 用来存放Java类
- **web**: web项目的根目录, eclipse中为WebRoot
  - **classes**: src目录中的.java文件编译为.class文件后会放入到这里, src目录中的配置文件等也会放入到这里
  - **WEB-INF**: Java的WEB应用的安全目录. 里面的内容只有服务端可以访问, 客户端不能访问.
    - **lib**: 存放项目依赖的jar包
    - **web.xml**: Web应用程序配置文件
  - **index.jsp**: 主页文件

推荐常用的目录结构

```bash
project/
├── src
│   └── com
│       └── domain
│           ├── controller
│           ├── dao
│           ├── entity
│           └── service
└── web
    ├── index.jsp
    ├── static
    │   ├── css
    │   ├── img
    │   └── js
    └── WEB-INF
        ├── classes
        ├── config
        │   ├── config.properties
        │   ├── mybatis
        │   └── spring
        ├── jsp
        ├── lib
        └── web.xml
```

## IDEA引入普通WEB项目

以如下项目结构为例

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222152733.png)

### 指定存放Java类的目录

File -> Project Structure...(Ctrl+Alt+Shift+s)

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222152753.png)

### 指定Java文件编译后的目录

此处, 将其指定为WEB-INF下的classes目录

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222152809.png)

### 设置使用tomcat运行项目时, 项目文件的输出位置

此处设置为项目目录下的out文件夹

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222152859.png)

### 设置项目依赖的jar包位置

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222152932.png)

选择当前项目WEB-INF下的lib文件夹, 并选择将该lib添加到哪个模块下

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222152951.png)

### 指定web.xml和web根目录的位置

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222153004.png)

选择需要添加Web部分的模块

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222153019.png)

指定web.xml位置和web根目录位置

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222153033.png)

### 预览项目结构效果图

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222153047.png)

## 使用tomcat运行项目, 并导出war包

注意: 此处需确保前两步没有问题

### 创建IDEA嵌入式tomcat可以运行的Artifacts

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222153104.png)

选择为哪个模块创建 war exploded(这个exploded是可以运行在嵌入到IDEA中的tomcat的文件, 相当于将war包解压后的目录, 关于如何打war包, 请继续向后看)

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222153119.png)

此处可以看到输出文件夹在之前Project中设置的/project/out/目录下

### 创建可打成war包的Artifacts

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222153146.png)

效果图如下

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222153207.png)

### 配置IDEA使用嵌入式的tomcat

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222153221.png)

添加一个本地的tomcat

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222153234.png)

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222153247.png)

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222153301.png)

为该tomcat添加第二步中配置的`war exploded`

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222153315.png)

选择`war exploded`

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222153332.png)

保存后即可运行

## 导出war包

Build -> Build Artifacts...

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222153350.png)

结果预览

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222153404.png)
