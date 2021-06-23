---
title: Maven 的 SNAPSHOT 和 RELEASE 的区别
date: '2021-06-21 17:50:09'
tags:
- Java
- Maven
---

# Maven 的 SNAPSHOT 和 RELEASE 的区别

`SNAPSHOT` 是快照的意思，代表开发分支上的最新代码，并不能保证代码的稳定性和不可变性。相反的, `RELEASE `代表正式版本，保证了代码的稳定性和不可变性，项目每到一个阶段后，就需要发布一个正式版本。

对于版本以 `-SNAPSHOT` 结尾的 jar 包，Maven 每次构建时都会从远程仓库拉取，即使本地仓库已经包含了该 jar 包。而对于非 `-SNAPSHOT` 结尾的 jar，Maven 每次构建时都会从本地仓库进行获取，只有当本地仓库不存在该 jar 的时候，才会从远程仓库拉取。

通过 Maven 提供的 [release ](https://maven.apache.org/maven-release/maven-release-plugin/)程序，可以将 **x.y-SNAPSHOT** 修改为 **x.y**。同时该程序也提供了对开发版本的增量更新。例如将 **1.0-SNAPSHOT** 发布为 **1.0** 版本后，将开发分支的版本更新为 **1.1-SNAPSHOT**

官方文档：[What_is_a_SNAPSHOT_version](https://maven.apache.org/guides/getting-started/index.html#What_is_a_SNAPSHOT_version)

## 什么时候用 SNAPSHOT

假如两个小组 A，B 分别负责开发两个模块 `service` 和 `common`，版本都是 `1.0`，其中 `service` 模块依赖于 `common `模块。此时如果对 `common` 模块进行了修改并发布到了 Nexus 上，则必须通知 A 组的同事，删除本地的 jar，然后重新进行构建。

如果使用了 `SNAPSHOT`，即可解决沟通的问题。只需将 `common` 的版本设置为 `1.0-SNAPSHOT`，`service` 模块依赖于该版本的 `common`，则每次对 `common` 进行修改发布到 Nexus 后，`service `在进行构建时，都会自动去 Nexus 拉取最新的 jar 包，并进行构建。

所以，开发的时候使用 `SNAPSHOT` 版本的 jar，可以减少因为版本更新造成的大量沟通问题。发布正式版本的时候使用 `RELEASE` 版本的 jar，可以防止对未上线的代码进行发布后，对正式版本造成影响。

## 调整 SNAPSHOT 的更新频率

如果使用了 `SNAPSHOT`，每次构建都从远程仓库拉取新的 jar 包，那么 maven 的本地缓存机制就没有用了，所以我们可以调整对 `SNAPSHOT` 版本的包的拉取频率，可以修改为 always（每次构建都拉取），daily（每天拉取），interval（每分钟拉取），never（从不拉取）

### 在 IDEA 中配置

IDEA 默认是不会更新 SNAPSHOT 的，需要在设置中勾选 **Always update snapshots**，然后点击 Maven 的刷新按钮

![image-20210621173222321](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210621173222.png)

### 在 settings.xml 中配置

参考官方配置文件示例：[settings](http://maven.apache.org/ref/3.8.1/maven-settings/settings.html)，添加如下配置

```xml
<snapshots>
    <enabled>true</enabled>
    <updatePolicy>always</updatePolicy>
</snapshots>
```

### 在 pom.xml 中配置

```xml
<repositories>
    <repository>
        <id>nexus-public</id>
        <name>nexus-release</name>
        <url>http://XXXXXXX/repository/maven-public/</url>
        <releases>
            <enabled>true</enabled>
        </releases>
        <snapshots>
            <enabled>true</enabled>
            <updatePolicy>always</updatePolicy>
        </snapshots>
    </repository>
</repositories>
```

### 使用 `-U` 参数强制使用最新快照构建

可以在任何 Maven 命令中添加 `-U` 参数强制 Maven 下载最新的快照进行构建

```bash
mvn clean package -U
```
