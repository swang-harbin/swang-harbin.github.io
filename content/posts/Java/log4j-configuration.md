---
title: log4j详细配置
date: '2019-12-12 00:00:00'
tags:
- Log4j
- Java
---

# log4j详细配置

## log4j根配置语法

```properties
log4j.rootLogger = [ level ], appenderName, appenderName, ...
```

把指定级别(level)的日志信息输出到指定的一个或多个位置(appenderName)

## 日志等级

log4j根据日志信息的重要程度, 由高到低否分为OFF、FATAL、ERROR、WARN、INFO、DEBUG、ALL, 可以输出等级大于等于level的日志信息. 例如: 配置为WARN可以输出FATAL、ERROR、WARN日志信息.

log4j官方建议实际开发时只是用4个级别, 优先级从高到低分别为ERROR, WARN, INFO, DEBUG

如果rootLogger的level设置为DEBUG, 则所有的信息都可以输出

## 输出位置

```properties
# DEBUG为level
# Console和File为appenderName, 可以自定义, 只要下方配置与其对应即可
log4j.rootLogger=DEBUG, Console, File

# Console
log4j.appender.Console = org.apache.log4j.ConsoleAppender
log4j.appender.Console.layout = org.apache.log4j.PatternLayout
log4j.appender.Console.layout.ConversionPattern = %d [%t] %-5p [%c] - %m%n

# File
log4j.appender.File = org.apache.log4j.FileAppender
log4j.appender.File.file = D:\\log\\log
log4j.appender.File.layout = org.apache.log4j.PatternLayout
log4j.appender.File.layout.ConversionPattern = %d [%t] %-5p [%c] - %m%n
```

**log4j官方提供的appender:**

1. `org.apache.log4j.ConsoleAppender`: 控制台
2. `org.apache.log4j.FileAppender`: 文件
3. `org.apache.log4j.DailyRollingFileAppender`: 每天产生一个日志文件
4. `org.apache.log4j.RollingFileAppender`: 文件大小到达指定尺寸产生一个新文件
5. `org.apache.log4j.WriterAppender`: 将日志信息以流的形式发送到任意指定的地方

**实际开发中使用1, 3, 4**

- 假如日志数据量不是很大, 可以使用DailyRollingFileAppender每天产生一个日志, 方便查看;
- 假如日志数据量很大, 可以使用RollingFileAppender, 固定尺寸的日志, 超过指定大小就产生一个新文件.

**示例**:

```properties
log4j.rootLogger=DEBUG, Console ,File ,DailyRollingFile ,RollingFile
   
#Console  
log4j.appender.Console=org.apache.log4j.ConsoleAppender  
log4j.appender.Console.layout=org.apache.log4j.PatternLayout  
log4j.appender.Console.layout.ConversionPattern=%d [%t] %-5p [%c] - %m%n
   
#File
log4j.appender.File = org.apache.log4j.FileAppender
log4j.appender.File.File = C://File
log4j.appender.File.layout = org.apache.log4j.PatternLayout
log4j.appender.File.layout.ConversionPattern =%d [%t] %-5p [%c] - %m%n

#DailyRollingFile
log4j.appender.DailyRollingFile = org.apache.log4j.DailyRollingFileAppender
log4j.appender.DailyRollingFile.File = C://DailyRoolingFile
log4j.appender.DailyRollingFile.layout = org.apache.log4j.PatternLayout
log4j.appender.DailyRollingFile.layout.ConversionPattern =%d [%t] %-5p [%c] - %m%n

#RollingFile
log4j.appender.RollingFile = org.apache.log4j.RollingFileAppender
log4j.appender.RollingFile.File = C://RoolingFile
log4j.appender.RollingFile.MaxFileSize=1KB
log4j.appender.RollingFile.MaxBackupIndex=3
log4j.appender.RollingFile.layout = org.apache.log4j.PatternLayout
log4j.appender.RollingFile.layout.ConversionPattern =%d [%t] %-5p [%c] - %m%n
```

`log4j.appender.RollingFile.MaxFileSize`: 日志文件的最大尺寸

`log4j.appender.RollingFile.MaxBackupIndex`: 日志文件的个数, 如果超过了则覆盖

## layout日志信息格式

1. `org.apache.log4j.HTMLLayout`: 以HTML表格形式布局
2. `org.apache.log4j.SimpleLayout`: 包含日志信息的级别和信息的字符串
3. `org.apache.log4j.TTCCLayout`: 包含日志产生的时间, 线程, 类别等信息
4. `org.apache.log4j.PatternLayout`: 可以灵活地指定布局模式

### HTMLLayout

```properties
log4j.appender.Console=org.apache.log4j.ConsoleAppender  
log4j.appender.Console.layout=org.apache.log4j.HTMLLayout
```

输出:

```html
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title>Log4J Log Messages</title>
<style type="text/css">
<!--
body, table {font-family: arial,sans-serif; font-size: x-small;}
th {background: #336699; color: #FFFFFF; text-align: left;}
-->
</style>
</head>
<body bgcolor="#FFFFFF" topmargin="6" leftmargin="6">
<hr size="1" noshade>
Log session start time Fri Dec 13 11:00:02 GMT+08:00 2019<br>
<br>
<table cellspacing="0" cellpadding="4" border="1" bordercolor="#224466" width="100%">
<tr>
<th>Time</th>
<th>Thread</th>
<th>Level</th>
<th>Category</th>
<th>Message</th>
</tr>

<tr>
<td>0</td>
<td title="main thread">main</td>
<td title="Level">INFO</td>
<td title="icu.intelli.HelloWorld category">icu.intelli.HelloWorld</td>
<td title="Message">普通info信息</td>
</tr>

<tr>
<td>2</td>
<td title="main thread">main</td>
<td title="Level"><font color="#339933">DEBUG</font></td>
<td title="icu.intelli.HelloWorld category">icu.intelli.HelloWorld</td>
<td title="Message">调试debug信息</td>
</tr>

<tr>
<td>2</td>
<td title="main thread">main</td>
<td title="Level"><font color="#993300"><strong>WARN</strong></font></td>
<td title="icu.intelli.HelloWorld category">icu.intelli.HelloWorld</td>
<td title="Message">警告warn信息</td>
</tr>

<tr>
<td>2</td>
<td title="main thread">main</td>
<td title="Level"><font color="#993300"><strong>ERROR</strong></font></td>
<td title="icu.intelli.HelloWorld category">icu.intelli.HelloWorld</td>
<td title="Message">报错error信息</td>
</tr>

<tr>
<td>2</td>
<td title="main thread">main</td>
<td title="Level"><font color="#993300"><strong>FATAL</strong></font></td>
<td title="icu.intelli.HelloWorld category">icu.intelli.HelloWorld</td>
<td title="Message">致命fatal信息</td>
</tr>
```

### SimpleLayout

输出:

```
INFO - 普通info信息
DEBUG - 调试debug信息
WARN - 警告warn信息
ERROR - 报错error信息
FATAL - 致命fatal信息
```

### TTCCLayout

输出:

```
[main] INFO icu.intelli.HelloWorld - 普通info信息
[main] DEBUG icu.intelli.HelloWorld - 调试debug信息
[main] WARN icu.intelli.HelloWorld - 警告warn信息
[main] ERROR icu.intelli.HelloWorld - 报错error信息
[main] FATAL icu.intelli.HelloWorld - 致命fatal信息
```

### PatternLayout

**实际开发应该使用的**

配置 :

```properties
log4j.appender.Console=org.apache.log4j.ConsoleAppender  
log4j.appender.Console.layout=org.apache.log4j.PatternLayout
log4j.appender.Console.layout.ConversionPattern=%d [%t] %-5p [%c] - %m%n
```

输出:

```
2019-12-13 11:03:46,985 [main] INFO  [icu.intelli.HelloWorld] - 普通info信息
2019-12-13 11:03:46,985 [main] DEBUG [icu.intelli.HelloWorld] - 调试debug信息
2019-12-13 11:03:46,985 [main] WARN  [icu.intelli.HelloWorld] - 警告warn信息
2019-12-13 11:03:46,985 [main] ERROR [icu.intelli.HelloWorld] - 报错error信息
2019-12-13 11:03:46,985 [main] FATAL [icu.intelli.HelloWorld] - 致命fatal信息
```

#### ConversionPattern配置说明

```
%m 输出代码中指定的消息;

%M 输出打印该条日志的方法名;

%p 输出日志等级，即DEBUG，INFO，WARN，ERROR，FATAL, %-5p表示需要输出5个字符, 不足5个字符用空格填补

%r 输出自应用启动到输出该log信息耗费的毫秒数;

%c 输出所属的类名，通常就是所在类的全名;

%t 输出产生该日志事件的线程名;

%n 输出一个回车换行符，Windows平台为"rn”，Unix平台为"n”;

%d 输出日志时间点的日期或时间，默认格式为ISO8601，也可以在其后指定格式，比如：%d{yyyy-MM-dd HH:mm:ss,SSS}，输出类似：2002-10-18 22:10:28,921;

%l 输出日志事件的发生位置，及在代码中的行数;
```

## Threshold属性指定输出等级

有时候我们需要把一些ERROR日志单独存到指定文件, 这时, 就需要用到Threshold属性

**示例** :

将Debug以上的所有信息保存到DebugFile, 其中的ERROR级别以上的信息, 单独再保存到ErrorFile一份.

```properties
log4j.rootLogger=DEBUG, DebugFile, ErrorFile

#DebugFile
log4j.appender.DebugFile = org.apache.log4j.FileAppender
log4j.appender.DebugFile.File = D:/log/DebugFile
log4j.appender.DebugFile.layout = org.apache.log4j.PatternLayout
log4j.appender.DebugFile.layout.ConversionPattern =%d [%t] %-5p [%c] - %m%n

#ErrorFile
log4j.appender.ErrorFile = org.apache.log4j.FileAppender
log4j.appender.ErrorFile.File = D:/log/ErrorFile
log4j.appender.ErrorFile.layout = org.apache.log4j.PatternLayout
log4j.appender.ErrorFile.layout.ConversionPattern =%d [%t] %-5p [%c] - %m%n
log4j.appender.ErrorFile.Threshold = ERROR
```

DebugFile:

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222151323.png)

ErrorFile:

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222151340.png)

## Append属性指定是否追加内容

默认是true, 追加.

设置为覆盖之前的信息:

```properties
log4j.appender.File.Append = false
```

