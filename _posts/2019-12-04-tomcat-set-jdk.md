---
layout: post
title: 指定tomcat使用的JDK
subheading: 
author: swang-harbin
categories: java
banner: 
tags: tomcat java
---

# 指定Tomcat使用的JDK

修改bin目录下的setclasspath.sh, 在上方添加

```shell
export JAVA_HOME=/home/wangshuo/java/jdk1.8.0_231
export JRE_HOME=/home/wangshuo/java/jdk1.8.0_231/jre
# -----------------------------------------------------------------------------
#  Set JAVA_HOME or JRE_HOME if not already set, ensure any provided settings
#  are valid and consistent with the selected start-up options and set up the
#  endorsed directory.
# -----------------------------------------------------------------------------
```

