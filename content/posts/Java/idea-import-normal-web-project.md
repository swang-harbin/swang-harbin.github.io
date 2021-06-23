---
title: IDEA 导入普通 Web 项目
date: '2020-04-22 00:00:00'
tags:
- IDEA
- Java
---

# IDEA 导入普通 Web 项目

IDEA 版本：IntelliJ IDEA 2020.1(Ultimate Edition)

## 普通 Web 项目目录结构介绍

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

**project**：项目目录

- **src**：用来存放 Java 类
- **web**：web 项目的根目录，eclipse 中为 WebRoot
  - **classes**：src 目录中的 .java 文件编译为 .class 文件后会放入到这里，src 目录中的配置文件等也会放入到这里
  - **WEB-INF**：Java 的 WEB 应用的安全目录。里面的内容只有服务端可以访问，客户端不能访问。
    - **lib**：存放项目依赖的 jar 包
    - **web.xml**：Web 应用程序配置文件
  - **index.jsp**：主页文件

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

## IDEA 引入普通 WEB 项目

以如下项目结构为例

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222152733.png)

1. 指定存放 Java 类的目录

   File -> Project Structure...【<kbd>Ctrl</kbd>+<kbd>Alt</kbd>+<kbd>Shift</kbd>+<kbd>s</kbd>】

   ![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222152753.png)

2. 指定 Java 文件编译后的目录

   此处，将其指定为 WEB-INF 下的 classes 目录

   ![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222152809.png)

3. 设置使用 tomcat 运行项目时，项目文件的输出位置

   此处设置为项目目录下的 out 文件夹

   ![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222152859.png)

4. 设置项目依赖的 jar 包位置

   ![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222152932.png)

5. 选择当前项目 WEB-INF 下的 lib 文件夹，并选择将该 lib 添加到哪个模块下

   ![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222152951.png)

6. 指定 web.xml 和 web 根目录的位置

   ![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222153004.png)

7. 选择需要添加 Web 部分的模块

   ![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222153019.png)

8. 指定 web.xml 位置和 web 根目录位置

   ![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222153033.png)

9. 预览项目结构效果图

   ![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222153047.png)

## 使用 tomcat 运行项目，并导出 war 包

注意：此处需确保前两步没有问题

1. 创建 IDEA 嵌入式 tomcat 可以运行的 Artifacts

   ![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222153104.png)

2. 选择为哪个模块创建 war exploded（这个 exploded 是可以运行在嵌入到 IDEA 中的 tomcat 的文件，相当于将 war 包解压后的目录，关于如何打 war 包，请继续向后看）

   ![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222153119.png)

   此处可以看到输出文件夹在之前 Project 中设置的 /project/out/ 目录下

3. 创建可打成 war 包的 Artifacts

   ![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222153146.png)

4. 效果图如下

   ![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222153207.png)

5. 配置 IDEA 使用嵌入式的 tomcat

   ![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222153221.png)

6. 添加一个本地的 tomcat

   ![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222153234.png)

   ![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222153247.png)

   ![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222153301.png)

7. 为该 tomcat 添加第二步中配置的 `war exploded`

   ![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222153315.png)

8. 选择`war exploded`

   ![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222153332.png)

9. 保存后即可运行

## 导出 war 包

1. Build -> Build Artifacts...

   ![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222153350.png)

2. 结果预览

   ![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222153404.png)
