---
title: Eclipse使用git提交项目
date: '2019-07-03 00:00:00'
updated: '2019-07-03 00:00:00'
tags:
- eclipse
- java
categories:
- java
---
# Eclipse使用git提交项目

1. Team->Fetch from UpStream：从git服务器将代码拉取到本地服务器
2. Team->Pull：将本地服务器的代码拉取到工作空间
3. Team->Commit：将工作空间中的代码提交到本地服务器，这里要选择需要提交的文件，将Unstaged Changes中需要提交的代码 添加到 Staged Changes中然后点击Commit
4. Team->Push Branch "xxxxx"：将本地服务器的代码提交到git服务器
