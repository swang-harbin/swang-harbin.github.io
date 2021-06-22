---
title: Maven多模块版本升级
date: '2021-06-21 12:47:37'
tags:
- Java
- Maven
---

# Maven多模块版本升级

## 项目结构

![项目结构](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210621095001.png)

最上层mall模块是下面所有子模块的顶级父类, 现在要实现更改mall的版本, 所有子模块的版本也要同步更改

## Maven的版本管理机制

子模块中可以不指定`<version>`标签, 则子模块使用其父模块的版本. 但是必须在子模块中指定`parent.version`

1. 顶级父模块mall的pom

   ```xml
   <groupId>icu.intelli</groupId>
   <artifactId>mall</artifactId>
   <!-- 顶级父模块中指定版本号 -->
   <version>1.0-SNAPSHOT</version>
   <packaging>pom</packaging>
   <modules>
       <module>api</module>
   </modules>
   ```

2. 父模块api的pom

   ```xml
   <parent>
       <artifactId>mall</artifactId>
       <groupId>icu.intelli</groupId>
       <!-- 但是必须指定parent.version -->
       <version>1.0-SNAPSHOT</version>
   </parent>
   <!-- 作为mall的子模块, 其不需要指定groupId和version, 会自动使用mall的 -->
   <artifactId>api</artifactId>
   <packaging>pom</packaging>
   <modules>
       <module>cart-api</module>
   </modules>
   ```

3. 子模块cart-api的pom

   ```xml
   <parent>
       <artifactId>api</artifactId>
       <groupId>icu.intelli</groupId>
       <!-- 但是必须指定parent.version -->
       <version>1.0-SNAPSHOT</version>
   </parent>
   <!-- 作为api的子模块, 其不需要指定groupId和version, 会自动使用api的 -->
   <artifactId>cart-api</artifactId>
   <packaging>jar</packaging>
   ```

## 出现的问题

虽然在子模块中不用指定自己的`<version>`了, 但是当版本升级的时候, 还是需要修改所有子模块中的`parent.verison`

## 批量更新POM中的版本

### 方式一

1. 在顶级父模块的pom中添加version插件

   ```xml
   <build>
       <plugins>
           <plugin>
               <groupId>org.codehaus.mojo</groupId>
               <artifactId>versions-maven-plugin</artifactId>
               <version>2.8.1</version>
               <configuration>
                   <generateBackupPoms>false</generateBackupPoms>
               </configuration>
           </plugin>
       </plugins>
   </build>
   ```

2. 在顶级父模块根目录执行如下命令修改版本号

   ```bash
   # 将所有模块的版本都修改为1.0.RELEASE
   mvn versions:set -DnewVersion=1.0-RELEASE
   ```

3. 以上命令会将mall/pom.xml以及其所有子模块的`parent.verison`都修改为1.0-RELEASE

#### 结论

顶级父模块的pom中维护`<version>`标签, 子模块的pom中不用指定自己的`<version>`和`<groupId>`. 子模块的pom中包含父模块的`<groupId>`, `<artifactId>`, `<version>`. 当版本需要更新的时候, 使用maven插件中的命令实现父子模块pom递归修改: `mvn versions:set -DnewVersion=1.0-RELEASE`

### 方式二

**注意** : 该方式只支持升级`SNAPSHOT`版本, 不支持对`RELEASE`版本的操作. 高级操作搜索: Maven最佳实践: 版本管理

官方文档 [update-versions](https://maven.apache.org/maven-release/maven-release-plugin/examples/update-versions.html)

在顶级父模块根目录执行下方命令, maven会给出输入框, 对每个模块的版本进行修改

```bash
mvn release:update-versions
```

如果确定每个子模块的版本都是和其父模块版本相同的, 可以添加`autoVersionSubmodules`选项, 此时只需要输入一次版本

```bash
mvn release:update-versions -DautoVersionSubmodules=true
```

还可以将版本直接放在命令行中, 此时就不需要再手动输入版本号了

```bash
mvn --batch-mode release:update-versions -DdevelopmentVersion=1.2.0-SNAPSHOT
```

