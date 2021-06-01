---
title: MySQL密码策略
date: '2019-12-03 00:00:00'
updated: '2019-12-03 00:00:00'
tags:
- MySQL
categories:
- database
---

# 错误-Your password does not satisfy the current policy requirements

## 出错原因

由于MySQL数据库对密码的验证策略较为严格造成.

## 解决方法

### 1. 查看MySQL密码策略

```mysql
SHOW VARIABLES LIKE 'validate_password%';
```

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222190745.png)

### 2. 修改验证强度等级

将validate_password_policy设置为LOW, 则只验证密码长度

```mysql
set global validate_password_policy=LOW; 
```

### 3. 修改密码长度验证

可将validate_password_length设置为4, 最小值为4

```mysql
set global validate_password_length=4;
```

## 密码策略参数说明

1. `validate_password_length`  固定密码的总长度
2. `validate_password_dictionary_file` 指定密码验证的文件路径
3. `validate_password_mixed_case_count`  整个密码中至少要包含大/小写字母的总个数
4. `validate_password_number_count`  整个密码中至少要包含阿拉伯数字的个数
5. `validate_password_policy` 指定密码的强度验证等级，默认为 MEDIUM

> 关于 validate_password_policy 的取值：
>
> 1. 0/LOW：只验证长度；
> 2. 1/MEDIUM：验证长度、数字、大小写、特殊字符；
> 3. 2/STRONG：验证长度、数字、大小写、特殊字符、字典文件；

1. validate_password_special_char_count 整个密码中至少要包含特殊字符的个数；

## 参考文档

[ERROR 1819 (HY000): Your password does not satisfy the current policy requirements](https://blog.csdn.net/hello_world_qwp/article/details/79551789)
