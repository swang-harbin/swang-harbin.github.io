---
title: 运行 vue 项目
date: '2019-11-21 00:00:00'
tags:
- VUE
---
# 运行 vue 项目

## 下载安装 node.js
[node.js 官方下载地址](https://nodejs.org/en/)

- node.js 是 JavaScript 的一个运行环境，类似于 Java 的 JVM

- npm 是 Node.js 的包管理工具（package manager）

### 测试安装结果
以管理员身份运行 cmd，输入 `node -v`, 出现版本号，即证明安装成功

npm 是集成在 node 中，可以使用 `npm -v` 查看版本

## 安装 cnpm 或修改 npm 仓库位置

### 安装 cnpm
- cnpm 是淘宝团队做的国内镜像，由于 npm 的服务器位于国外，速度较慢，因此可以使用 cnpm

  以管理员身份运行 cmd，输入

  ```bash
  npm install -g cnpm --registry=http://registry.npm.taobao.org
  ```

### 修改 npm 仓库位置

搜索 [修改 npm 镜像]()

## 启动项目

以管理员身份运行 cmd

在项目目录下使用 `cnpm install` 或 `npm install`（速度较慢）安装依赖包，会生成 node_modules 文件夹

安装完成后使用 `npm run dev` 命令启动项目
