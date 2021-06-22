---
title: 将已有的R项目打包
date: '2020-09-09 00:00:00'
updated: '2020-09-09 00:00:00'
tags:
- R
categories:
- R
---
# 将已有的R项目打包

## 目录介绍
- R: 存放源码(.R文件)的文件夹
- man: 存放方法说明文档.Rd文件(类似于JavaDoc), 每个.Rd文件对应一个方法的文档注释
- DESCRIPTION: 描述信息, 主要包含Package: 包名, Author: 作者, Description: 描述信息, Imports: 依赖包, Suggests: 不是必须依赖的包, License: 协议等
- NAMESPACE: 命名空间
- xx.Rproj: 当前项目的配置信息

## 打包

### 首先安装`devtools`

```R
install.packages("devtools", dependencies = TRUE)
```

### 使用`devtools`生成.Rd文档

```R
devtools::document()
```

### 使用RStadio重新将项目打包


Build -> Clean and Rebuild 等
