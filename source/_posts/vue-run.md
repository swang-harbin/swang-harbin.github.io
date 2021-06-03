---
title: 运行vue项目
date: '2019-11-21 00:00:00'
updated: '2019-11-21 00:00:00'
tags:
- VUE
categories:
- VUE
---
# 运行vue项目

## 下载安装node.js
[node.js官方下载地址](https://nodejs.org/en/)

- node.js是JavaScript的一个运行环境, 类似于Java的JVM

- npm是Node.js的包管理工具(package manager)

### 测试安装结果
以管理员身份运行cmd, 输入 ```node -v```, 出现版本号, 即证明安装成功

npm是集成在node中, 可以使用```npm -v```查看版本

## 安装cnpm或修改npm仓库位置

### 安装cnpm
- cnpm是淘宝团队做的国内镜像, 由于npm的服务器位于国外, 速度较慢, 因此可以使用cnpm

以管理员身份运行cmd, 输入
```bash
npm install -g cnpm --registry=http://registry.npm.taobao.org
```

### 修改npm仓库位置

搜索[修改npm镜像]()

## 启动项目

以管理员身份运行cmd

在项目目录下使用```cnpm install``` 或 ```npm install```(速度较慢)安装依赖包, 会生成node_modules文件夹

安装完成后使用```npm run dev```命令启动项目
