---
layout: post
title: 'Cannot start compilation: the output path is not specified for module "..." Specify the output path'
subheading: 
author: swang-harbin
categories: java
banner: 
tags: idea exception java
---

## 报错:Cannot start compilation: the output path is not specified for module "..." Specify the output path

### 原因:

项目中此时没有指定class文件生成的路径，若单纯指定module的output路径会导致后续出现无法找到类的Error。

### 解决方法:

1. 打开project structure->project, 在右侧project compiler output目标路径文件夹，通常是"\Workspace Intelij\project_name\out"；
2. 打开（project structure->）module, 在paths栏中选择Inherit project compiler output path；
3. 确定