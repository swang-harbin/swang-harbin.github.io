---
title: PowerDesigner16.5导入MySQL数据
date: '2019-11-21 00:00:00'
updated: '2019-11-21 00:00:00'
tags:
- PowerDesigner
categories:
- PowerDesigner
---
# PowerDesigner16.5导入MySQL数据

## 下载MySQL的ODBC连接工具
[MySQL ODBC官方下载](https://dev.mysql.com/downloads/connector/odbc/)

注 : 需要检验PowerDisigner使用的ODBC数据源是32位还是64位, 具体操作如下

#### **以管理员身份运行**PowerDesigner16.5新建一个空白项目
![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609143011.png)
![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609143012.png)
![image](https://note.youdao.com/yws/res/42585/F05EC918A2E54BEE9C04776D73D258B2)

#### 如下图所示, 则下载安装32位的ODBC

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609143013.png)

## 导入MySQL数据

安装完成ODBC后, 重新**以管理员身份运行**新的PowerDesigner

依次点击**File** -> **Reverse Engineer** -> **Database**

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609143015.png)

输入**Model Name**并选择**DBMS**, **Model Name**和项目名称相同即可, **DBMS**此处选择**MySQL5.0**

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609143017.png)

选择**Using a data source:**, 如下图依次点击, 最后选择**系统数据源(只用于当前机器)(S)**  
注 : 如果不是**以管理员身份运行**的PowerDesigner,此选项不可选

![image](https://note.youdao.com/yws/res/42607/658B54F2238F4A5298D9BE92C400518C)

下一步后选择**MySQL ODBC 5.3 Unicode Driver**, 依次点击完成

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609143019.png)

依次输入**数据源名称**, **IP地址和端口号**, **用户和密码**, **使用的数据库**, 数据源名称自定义,可以与项目名称相同, 使用的数据库是否选择都没有问题.

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609143020.png)

依次点击确定后,到达如下页面后, 选择刚才新建的数据库, 点击**Connect**

![image](https://note.youdao.com/yws/res/42637/72343078A56C4F61B94FD068A9FF6629)

首先, 选择**<All users>**, 点击如下图标, 取消对数据库中所有数据库所有数据表的全部选中

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609143021.png)

然后, 选择需要使用的数据库, 点击如下图标, 选中所用数据库中的所有表, 此处可按需求选择

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609143022.png)

点击**OK**后, 该数据库中的信息自动加载到当前工作空间, 如下图所示

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609143023.png)
