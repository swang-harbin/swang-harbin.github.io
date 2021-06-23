---
title: 指定 tomcat 使用的 JDK
date: '2019-12-04 00:00:00'
tags:
- Tomcat
- Java
---

# 指定 Tomcat 使用的 JDK

修改 bin 目录下的 setclasspath.sh，在上方添加

```shell
export JAVA_HOME=/home/wangshuo/java/jdk1.8.0_231
export JRE_HOME=/home/wangshuo/java/jdk1.8.0_231/jre
# -----------------------------------------------------------------------------
#  Set JAVA_HOME or JRE_HOME if not already set, ensure any provided settings
#  are valid and consistent with the selected start-up options and set up the
#  endorsed directory.
# -----------------------------------------------------------------------------
```

