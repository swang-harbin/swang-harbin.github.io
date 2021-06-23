---
title: 将已有的 R 项目打包
date: '2020-09-09 00:00:00'
tags:
- R
---
# 将已有的 R 项目打包

## 目录介绍
- R：存放源码（.R 文件）的文件夹
- man：存放方法说明文档 .Rd 文件（类似于 JavaDoc），每个 .Rd 文件对应一个方法的文档注释
- DESCRIPTION：描述信息，主要包含 Package：包名，Author：作者，Description：描述信息，Imports：依赖包，Suggests：不是必须依赖的包，License：协议等
- NAMESPACE：命名空间
- xx.Rproj：当前项目的配置信息

## 打包

### 首先安装 `devtools`

```R
install.packages("devtools", dependencies = TRUE)
```

### 使用 `devtools` 生成 .Rd 文档

```R
devtools::document()
```

### 使用 RStadio 重新将项目打包


Build → Clean and Rebuild 等
