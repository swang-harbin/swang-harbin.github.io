---
title: IDEA 中 maven 的使用
date: '2019-09-05 00:00:00'
tags:
- IDEA
- Java
---

# IDEA 中 maven 的使用

## 重新向工作空间导入仓库中的 jar 包

- 法 1：右键单击项目 → Maven → Reimport
- 法 2：先点击右侧 Maven 弹出窗口，点击 Reimport All Maven Projects 图标

## 下载 jar 包的源文件（Sources）和文档（Documentation）

- 法 1：右键单击项目 → Maven → Download Sources/Download Documentation/Download Sources and Documentation
- 法 2：先点击右侧 Maven 弹出窗口，点击 Download Sources and/or Documentation

## 重新下载未下载完成的 jar 包到本地仓库

1. 点击右侧 Maven 弹出窗口
2. 点击 Execute Maven Goal
3. 在弹出窗口中输入 `mvn -U idea:idea`
4. 点击 Execute

## 查看工作空间导入的 jar 包状态

1. 点击菜单栏 File → Project Structure...【<kbd>Ctrl</kbd>+<kbd>Alt</kbd>+<kbd>Shift</kbd>+<kbd>s</kbd>】
2. 点击 Libraries 即可查看当前工作空间的 jar 包状态

## 使用 tomcat7 插件运行项目

1. 点击右侧 Maven 弹出窗口
2. 单击需要运行的项目弹出选项 Lifecycle&Plugins&Dependencies
3. 单击 Plugins
4. 单击 tomcat7
5. 右键单击 tomcat7:run 选择 Run 项目名或 Debug 项目名即可
