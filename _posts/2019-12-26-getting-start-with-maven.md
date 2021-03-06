---
layout: post
title: 项目管理工具Maven快速入门
subheading: 
author: swang-harbin
categories: java
banner: 
tags: maven java
---
# 项目管理工具Maven快速入门

## 一. 简介

服务于基于Java平台的项目构建, 依赖管理和项目信息管理.

项目构建 : 编译, 运行单元测试, 生成文档, 打包和部署等就是构建.

推荐书籍 : &lt;Maven实战&gt; 许晓斌

POM : project object model

## 二. Maven优势

1. 跨平台
2. 服务于构建, 它是一个异常强大的构建工具, 能自动化构建过程, 从清理, 编译, 测试到生成报告, 再到打包和部署.
3. 标准化, 能够标准化构建过程. 在Maven之前, 十个项目可能有十种构建方式, 有了maven后所有项目的构建命令都是简单一致的, 这极大地避免了不必要的学习成本, 而且有利于促进项目团队的的标准化.
4. 封装构建过程, 我们一直在不停地寻找避免重复的方法. Maven最大化清除了构建的重复, 抽象了够贱的生命周期, 并且为绝大部分的构建任务提供已实现的插件, 我们不需要定义过程.
5. 依赖管理, 在这个开源的年代里, 几乎任何java应用都会借用一些第三方的开源类库, 这些类库都可以通过依赖的方式引入到项目中来. 随着依赖的增多, 版本不一致, 版本冲突, 依赖臃肿等问题都会接踵而至. 手工解决这些问题是十分枯燥的, Maven提供了一个优秀的解决方案, 它通过一个坐标系统准确的定位每一个组件, 让他们变得有秩序, 因此我们可以借助它有序的管理依赖, 轻松的解决繁杂的依赖问题. Maven为Java提供了一个免费的中央仓库, 在其中可以知道任何流行的开源类库.
6. 项目规范化: maven对于项目目录结构, 测试用例命名方式等都有既定的规则, 只要遵循了这些成熟的规则, 用户在项目间切换的时候就免去了额外的学习成本, 可以说是 约定优于配置.

## 三. 手动构建一个maven项目

### 3.1 创建一个pom.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">

<!--GAV用来确定项目的唯一坐标-->
<!--groupId : 组织名称, 通常使用公司域名倒叙-->
<!--artifactId : 项目名称-->
<!--version : 版本-->
<groupId>com.example</groupId>
<artifactId>project-name</artifactId>
<version>V0.1</version>

<!--引入依赖-->
<dependencies>
        <dependency>
        <groupId>junit</groupId>
        <artifactId>junit</artifactId>
        <version>4.11</version>
        <!--设置只在测试时使用, 不会被打包到发布的war/jar包中-->
        <scope>test</scope>
    </dependency>
</dependencies>

</project>
```

### 3.2 创建一套目录结构

| 目录                          | 目的                          |
| ----------------------------- | ----------------------------- |
| ${basedir}                    | 存放pom.xml和所有的子目录     |
| ${basedir}/src/main/java      | 项目的java源代码              |
| ${basedir}/src/main/resources | 项目的资源, 例如property文件  |
| ${basedir}/src/test/java      | 项目的测试类, 比如说JUnit代码 |
| ${basedir}/src/test/resources | 测试使用的资源                |

```shell
mkdir -p maven-demo/src/main/java maven-demo/src/resources
mkdir -p maven-demo/src/test/java maven-demo/src/test/resources
```

### 3.3 Hello Maven

在maven-demo/src/main/java目录下创建HelloMaven.java

```java
public class HelloMaven {

    public static void main(String[] agrs){
        System.out.println("Hello Maven!!");
    }
}
```