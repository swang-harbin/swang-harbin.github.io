---
title: Maven 仓库
date: '2019-12-25 00:00:00'
tags:
- Maven
- Java
---

# Maven 仓库

Maven 允许通过 settings.xml 配置文件，以及项目中的 pom.xml 文件修改仓库位置

maven 仓库分类

1. 本地仓库
2. 远程仓库
   1. 中央仓库
   2. 私服
   3. 其他公共库

maven 项目中依赖的搜索顺序，由先到后

1. 本地仓库：setting.xml 中通过 `<localRepository>` 设置
2. 全局 profile 仓库：settings.xml 中通过 `<profiles><repositories></repository></profile>` 设置
3. 项目 profile 仓库：在项目的 pom.xml 中
4. 项目仓库
5. 镜像仓库：settings.xml 中通过 `<mirrors></mirror>` 设置
6. 中央仓库

## 本地仓库

默认是在 `${user.home}/.m2/repository`，可以通过修改 `${user.home}/.m2/setting.xml` 修改指定用户的 maven 本地仓库设置。

也可以直接修改 `${MAVEN_HOME}/conf/setting.xml` 修改全局的本地仓库设置。

```xml
<localRepository>/path/to/local/repository</localRepository>
```

## 远程仓库

### 中央仓库

所有 pom 都会继承超级 pom，在超级 pom 中配置了 maven 官方的中央仓库

```xml
<repositories>  
    <repository>  
      <id>central</id>  
      <name>Central Repository</name>  
      <url>http://repo.maven.apache.org/maven2</url>  
      <layout>default</layout>  
      <snapshots>  
        <enabled>false</enabled>  
      </snapshots>  
    </repository>  
</repositories>
```

可以在 settings.xml 中配置中央仓库

```xml
<profile>  
    <id>central</id>  
    <repositories>
        <repository>
        <id>Central</id>
        <name>Central</name>
        <url>http://repo1.maven.org/maven2/</url>
        <releases>
            <enabled>true</enabled>
        </releases>
        <snapshots>
            <enabled>true</enabled>
        </snapshots>
        </repository>
    </repositories>
</profile>
```

并且需要激活

```xml
<activeProfile>central</activeProfile>
```

### 私服

私服是假设在局域网内的仓库服务，私服代理广域网上的远程仓库，供局域网内的 Maven 用户使用。当 maven 需要下载构件时，他从私服请求该构件，如果私服中不存在该构件，则从外部的远程仓库缓存到私服后，再为 maven 提供下载服务，还可以把一些无法从外部仓库下载到的构件上传到私服上。

1. 私服仓库需要在 setting.xml 文件中配置

   ```xml
   <profile>
       <id>localRepository</id>
       <repositories>
           <repository>
               <id>myRepository</id>
               <name>myRepository</name>
               <url>http://127.0.0.1:8081/nexus/content/repositories/myRepository/</url>
               <releases>
                   <enabled>true</enabled>
               </releases>
               <snapshots>
                   <enabled>true</enabled>
               </snapshots>
           </repository>
       </repositories>
   </profile>
   ```

2. 并且需要激活

   ```xml
   <activeProfile>localRepository</activeProfile>
   ```

3. 如果有验证信息

   ```xml
   <server>
       <id>myRepo</id>
       <username>admin</username>
       <password>admin123</password>
   </server>
   ```

### 其他公共库

## 镜像仓库

由于网络或访问流量过大等问题，造成访问远程仓库很慢，因此将远程仓库镜像到多个地方，提升访问速度

配置阿里云镜像仓库：在 `<mirrors>` 标签中可以添加多个 `<mirror>` 镜像标签，其中 id 是不可重复的，mirrorOf 中的 central 表示所有可以从中央仓库获取的构件，均可以从该仓库获取

```xml
<mirror>
    <id>alimaven</id>
    <name>aliyun maven</name>
    <url>http://maven.aliyun.com/nexus/content/groups/public/</url>
    <mirrorOf>central</mirrorOf>
</mirror>
```

配置私服镜像

```xml
<mirror>  
    <id>nexus</id>
    <name>internal nexus repository</name>
    <url>http://183.238.2.182:8081/nexus/content/groups/public/</url>
    <mirrorOf>*</mirrorOf>
</mirror>
```

在 maven 项目的 pom.xml 里面修改

```xml
<repositories>
    <repository>
        <id>maven-ali</id>
        <url>http://maven.aliyun.com/nexus/content/groups/public//</url>
        <releases>
            <enabled>true</enabled>
        </releases>
        <snapshots>
            <enabled>true</enabled>
            <updatePolicy>always</updatePolicy>
            <checksumPolicy>fail</checksumPolicy>
        </snapshots>
    </repository>
</repositories>
```
