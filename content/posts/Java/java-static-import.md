---
title: Java静态导入
date: '2020-01-03 00:00:00'
tags:
- Java
---

# Java静态导入

`import static`是JDK1.5中的新特性. 该功能是向当前类导入指定类中的静态方法, 使得在当前类中可以直接通过方法名调用这些静态方法, 而不用使用`类名.方法名()`的格式调用. 例如: `import static java.lang.Math.*;`. 也可以导入指定的方法, `import static java.lang.Math.abs;`

这种方法建议在有很多重复调用的时候使用，如果仅有一到两次调用，不如直接写来的方便

```java
import static java.lang.Math.*;
```

## 参考文档

[import static和import的区别](https://www.cnblogs.com/heiming/p/7416444.html)

