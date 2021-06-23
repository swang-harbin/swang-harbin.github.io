---
title: 'Cannot start compilation: the output path is not specified for module "..."
  Specify the output path'
date: '2019-09-05 00:00:00'
tags:
- IDEA
- Exception
- Java
---

# Cannot start compilation: the output path is not specified for module "..." Specify the output path

## 原因

项目中此时没有指定 class 文件生成的路径，若单纯指定 module 的 output 路径会导致后续出现无法找到类的 Error。

## 解决方法

1. 打开 project structure → project，在右侧 project compiler output 目标路径文件夹，通常是"\Workspace Intelij\project_name\out"
2. 打开（project structure →）module，在 paths 栏中选择 Inherit project compiler output path
3. 确定
