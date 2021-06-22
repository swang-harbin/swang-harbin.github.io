---
title: IDEA/DataGrip添加自定义数据源
date: '2021-06-22 14:02:00'
updated: '2021-06-22 14:02:00'
tags:
- Java
- IDEA
- DataGrip
categories:
- Java
---

# IDEA/DataGrip添加自定义数据源

## 添加自定义的数据库驱动

![image-20210622133610341](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210622133610.png)



![image-20210622134626702](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210622134626.png)

人大金仓(kingbase8)的URL templates

```sql
default jdbc:kingbase8://{host::localhost}?[:{port::54321}][/{database}?]
default jdbc:kingbase8://{host::localhost}?[:{port::54321}][/DMSERVER?schema={database}]
```

达梦(DM)的URL templates

```sql
default jdbc:dm://{host::localhost}?[:{port::5236}][/{database}?]
default jdbc:dm://{host::localhost}?[:{port::5236}][/DMSERVER?schema={database}]
```

## 添加数据源

![image-20210622135317126](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210622135317.png)

