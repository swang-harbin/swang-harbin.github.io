---
title: maven使用profile
date: '2020-01-08 00:00:00'
updated: '2020-01-08 00:00:00'
tags:
- maven
- java
categories:
- java
---

# Maven使用Profile

## 一. Profile简介

在开发过程中，我们的软件会面对不同的运行环境，比如开发环境、测试环境、生产环境，而我们的软件在不同的环境中，有的配置可能会不一样，比如数据源配置、日志文件配置、以及一些软件运行过程中的基本配置，那每次我们将软件部署到不同的环境时，都需要修改相应的配置文件，这样来回修改，很容易出错，而且浪费劳动力。

maven提供了一种方便的解决这种问题的方案，就是profile功能。

profile可以让我们定义一系列的配置信息，然后指定其激活条件。这样我们就可以定义多个profile，然后每个profile对应不同的激活条件和配置信息，从而达到不同环境使用不同配置信息的效果。

### profile定义的位置

1. 针对于特定项目的profile配置我们可以定义在该项目的pom.xml中。
2. 针对于特定用户的profile配置，我们可以在用户的settings.xml文件中定义profile。该文件在用户家目录下的“.m2”目录下。
3. 全局的profile配置。全局的profile是定义在Maven安装目录下的“conf/settings.xml”文件中的。

## 二. pom.xml方式的使用

在项目的pom.xml的`project`标签下添加

```xml
<profiles>
    <!-- 开发环境 -->
    <profile>
        <!-- 设置profile的id, 可自定义配置 -->
        <id>dev</id>
        <activation>
            <!-- 默认选中 -->
            <activeByDefault>true</activeByDefault>
        </activation>
    </profile>
    <!-- 测试环境 -->
    <profile>
        <id>test</id>
    </profile>
    <!-- 生产环境 -->
    <profile>
        <id>prod</id>
    </profile>
</profiles>
```

该代码添加了三个profile选项, 默认使用dev环境。

从IDEA中可以看到:

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222155502.png)

### profile中的标签

在每个`<profile>`标签中可以添加以下标签 :

![image-20210222155937714](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222155938.png)

在`<project>`标签中可以添加以下标签 :

![image-20210222160115504](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222160115.png)

两者做对比, 会发现有部分重复的标签, 这些标签都可以定义在`<profile>`标签中, 根据不同的运行环境, 使得某些属性生效.

## 二. Profile的用处

### 2.1 结合SpringBoot的profile功能优化配置方式

#### SpringBoot配置文件的目录结构

在resources目录下创建了3个文件夹dev, prod, test, 并在每个文件夹中创建对应的application.properties和application-{profile}.properties文件, 在每个application.properties中都包含spring.profiles.active={profile}

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222155544.png)

#### 在pom.xml中添加

```xml
<build>
    <plugins>
        <plugin>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-maven-plugin</artifactId>
            <executions>
                <execution>
                    <goals>
                        <goal>repackage</goal>
                    </goals>
                </execution>
            </executions>
            <configuration>
                <executable>true</executable>
            </configuration>
        </plugin>
    </plugins>

    <resources>
        <resource>
            <directory>src/main/resources/</directory>
            <!--打包时先排除掉三个文件夹-->
            <excludes>
                <exclude>dev/*</exclude>
                <exclude>prod/*</exclude>
                <exclude>test/*</exclude>
            </excludes>
            <includes>
                <!--如果有其他定义通用文件，需要包含进来-->
                <!--<include>messages/*</include>-->
            </includes>
        </resource>
        <resource>
            <!--这里是关键! 根据不同的环境，把对应文件夹里的配置文件打包-->
            <directory>src/main/resources/${profiles.active}</directory>
        </resource>
    </resources>
</build>

<profiles>
    <!-- 开发环境 -->
    <profile>
        <id>dev</id>
        <activation>
            <!-- 默认选中 -->
            <activeByDefault>true</activeByDefault>
        </activation>
        <properties>
            <!-- 添加了一个自定义的属性, 用来根据不同的环境使用不同文件夹中的配置文件 -->
            <profiles.active>dev</profiles.active>
        </properties>
    </profile>
    <!-- 测试环境 -->
    <profile>
        <id>test</id>
        <properties>
            <profiles.active>test</profiles.active>
        </properties>
    </profile>
    <!-- 生产环境 -->
    <profile>
        <id>prod</id>
        <properties>
            <profiles.active>prod</profiles.active>
        </properties>
    </profile>
</profiles>
```

此时, 根据不同的运行环境, maven会将对应的配置文件打到包中, 不需要对配置文件进行任何修改.

#### 打包

选中`prod`, 执行package， 可见打包了prod文件夹下的application.properties和application-prod.properties配置文件.

# 参考文档

- [maven（三）最详细的profile的使用](https://blog.csdn.net/java_collect/article/details/83870215)
- [maven profile动态选择配置文件](https://www.cnblogs.com/0201zcr/p/6262762.html)
