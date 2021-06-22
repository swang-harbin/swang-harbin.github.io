---
title: Windows配置自动启动批处理任务
date: '2019-11-19 00:00:00'
updated: '2019-11-19 00:00:00'
tags:
- Windows
categories:
- Windows
---
# Windows开机自动挂载挂载盘
## 创建批处理文件
新建文本文档,将格式修改为.bat,得到nfs_auto.bat
```bash
mount \\172.168.13.119\home X:
```
![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609143026.png)
## 创建计划任务

1. 在Windows的**管理工具**中,打开**任务计划程序**
2. 选择**操作**->**创建任务**

   ![创建任务](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210619223943.png)

3. 选择**常规**,设置任务计划**名称**,选择**不管用户是否登录都要运行、使用最高权限运行(I)**

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609143027.png)

4. 选择**触发器**->**新建**,弹出**编辑触发器**,**开始任务**选择**登录时**,**高级设置**中选择**已启用**,单击**确定**.

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609143028.png)

5. 选择**操作**->**新建**,弹出**新建操作**,**操作**选择**启动程序**,**程序或脚本**选择**nfs_auto.bat**文件,单击**确定**

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609143029.png)

6. 选择**条件**,**网络**选择**任何连接**.

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210619224015.png)

7.选择**设置**,选择**如果请求后任务还在运行，强行将其停止(F)**、**请勿启动新实例**.

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609143030.png)

8. 单击**确定**,保存退出

## 常见问题
### 任务计划程序无法应用你的更改。用户账户未知、密码错误或用户账户没有修改此任务的权限。
![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609143031.png)

**解决方法:**

可选择**常规**,选择**只在用户登录时运行(R)**
![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609143032.png)

### 可能的原因包括不允许空密码,登录时间限制,或强制的策略限制

**解决方法:**

1. 按**Win+R**输入gpedit.msc打开**本地组策略编辑器**

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609143033.png)

2. 找到**账户:使用空密码的本地账户只允许进行控制台登录**

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609143034.png)

3. 双击,将其禁用

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609143035.png)

## 参考文档
- [Windows系统实现自动挂载NAS](https://help.aliyun.com/knowledge_detail/71869.html)
- [解决：登录失败，用户账号限制。可能的原因包括不允许空密码，登录时间限制，或强制的策略限制](https://blog.csdn.net/xuhui_liu/article/details/73832743)
