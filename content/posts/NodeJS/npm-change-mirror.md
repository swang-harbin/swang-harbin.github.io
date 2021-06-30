---
title: 修改 npm 镜像
date: '2019-10-20 00:00:00'
tags:
- NodeJS
---
# 修改 npm 镜像

## 国内优秀 npm 镜像
### 淘宝 npm 镜像
- 搜索地址：http://npm.taobao.org/
- registry 地址：http://registry.npm.taobao.org/

### cnpmjs 镜像
- 搜索地址：http://cnpmjs.org/
- registry 地址：http://r.cnpmjs.org/

## 使用方式

### 临时使用
```bash
npm --registry https://registry.npm.taobao.org install express
```

### 持久使用
```bash
npm config set registry https://registry.npm.taobao.org
 
// 配置后可通过下面方式来验证是否成功
npm config get registry
// 或
npm info express
```

### 使用 cnpm
```bash
npm install -g cnpm --registry=https://registry.npm.taobao.org

// 使用
cnpm install expresstall express
```

## 参考文档


https://blog.csdn.net/p358278505/article/details/78094542