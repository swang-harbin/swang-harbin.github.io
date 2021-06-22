---
title: IDEA中maven的使用
date: '2019-09-05 00:00:00'
tags:
- IDEA
- Java
---

# IDEA中maven的使用

## 重新向工作空间导入仓库中的jar包

- 法1:右键单击项目>Maven>Reimport
- 法2:先点击右侧Maven弹出窗口,点击Reimport All Maven Projects图标

## 下载jar包的源文件(Sources)和文档(Documentation)

- 法1:右键单击项目>Maven>Download Sources/Download Documentation/Download Sources and Documentation
- 法2:先点击右侧Maven弹出窗口,点击Download Sources and/or Documentation

## 重新下载未下载完成的jar包到本地仓库

1. 点击右侧Maven弹出窗口
2. 点击Execute Maven Goal
3. 在弹出窗口中输入`mvn -U idea:idea`
4. 点击Execute

## 查看工作空间导入的jar包状态

1. 点击菜单栏File>Project Structure...(Ctrl+Alt+Shift+S)
2. 点击Libraries即可查看当前工作空间的jar包状态

## 使用tomcat7插件运行项目

1. 点击右侧Maven弹出窗口
2. 单击需要运行的项目弹出选项Lifecycle&Plugins&Dependencies
3. 单击Plugins
4. 单击tomcat7
5. 右键单击tomcat7:run选择Run 项目名或Debug 项目名即可
