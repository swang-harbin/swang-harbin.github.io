---
title: logback配置文件介绍
date: '2019-12-13 00:00:00'
tags:
- Logback
- Java
---

# logback配置文件介绍

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!-- scan : 默认为true, 配置文件发生改变, 会被重新加载-->
<!-- scanPeriod : 检查配置文件是否发生更改的时间间隔, 默认6000毫秒-->
<!-- debug : 如果为true, 实时打印logback框架的日志信息-->
<configuration scan="true" scanPeriod="60 seconds" debug="false">
    <!--定义参数常量-->

    <!--日志级别TRACE<DEBUG<INFO<WARN<ERROR-->
    <property name="log.level" value="DEBUG"/>
    <!-- 最大保存时间(天) -->
    <property name="log.maxHistory" value="30"/>
    <!-- 文件输出路径 -->
    <property name="log.filePath" value="D:/log"/>
    <!-- 输出格式 -->
    <property name="log.pattern"
              value="%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] %-5level %logger{50} - %msg%n"/>


    <!--控制台设置-->
    <appender name="consoleAppender" class="ch.qos.logback.core.ConsoleAppender">
        <!--layout将event事件转为字符串-->
        <!--encoder除了将event事件转为字节数组, 还会将日志输出到文件-->
        <encoder>
            <pattern>${log.pattern}</pattern>
        </encoder>
    </appender>

    <!--DEBUG-->
    <appender name="debugAppender" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <!--文件路径-->
        <file>${log.filePath}/debug.log</file>
        <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <!--文件名称-->
            <fileNamePattern>${log.filePath}/debug/debug.%d{yyyy-MM-dd}.log.gz</fileNamePattern>
            <!--文件最大保存历史时间-->
            <maxHistory>${log.maxHistory}</maxHistory>
        </rollingPolicy>
        <encoder>
            <pattern>${log.pattern}</pattern>
        </encoder>
        <!--仅接受DEBUG级别的信息-->
        <filter class="ch.qos.logback.classic.filter.LevelFilter">
            <level>DEBUG</level>
            <onMatch>ACCEPT</onMatch>
            <onMismatch>DENY</onMismatch>
        </filter>
    </appender>

    <!--INFO-->
    <appender name="infoAppender" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <!--文件路径-->
        <file>${log.filePath}/info.log</file>
        <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <!--文件名称-->
            <fileNamePattern>${log.filePath}/info/info.%d{yyyy-MM-dd}.log.gz</fileNamePattern>
            <!--文件最大保存历史时间-->
            <maxHistory>${log.maxHistory}</maxHistory>
        </rollingPolicy>
        <encoder>
            <pattern>${log.pattern}</pattern>
        </encoder>
        <!--仅接受INFO级别的信息-->
        <filter class="ch.qos.logback.classic.filter.LevelFilter">
            <level>INFO</level>
            <onMatch>ACCEPT</onMatch>
            <onMismatch>DENY</onMismatch>
        </filter>
    </appender>

    <!--ERROR-->
    <appender name="errorAppender" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <!--文件路径-->
        <file>${log.filePath}/error.log</file>
        <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <!--文件名称-->
            <fileNamePattern>${log.filePath}/error/error.%d{yyyy-MM-dd}.log.gz</fileNamePattern>
            <!--文件最大保存历史时间-->
            <maxHistory>${log.maxHistory}</maxHistory>
        </rollingPolicy>
        <encoder>
            <pattern>${log.pattern}</pattern>
        </encoder>
        <!--仅接受ERROR级别的信息-->
        <filter class="ch.qos.logback.classic.filter.LevelFilter">
            <level>ERROR</level>
            <onMatch>ACCEPT</onMatch>
            <onMismatch>DENY</onMismatch>
        </filter>
    </appender>

    <!--记录哪个包下的信息, 一个类/包只能对应一个logger-->
    <!--additivity: 默认true, 按logger中的日志级别, 将日志输出到它父级(root)的位置(console)-->
    <logger name="icu.intelli" level="${log.level}" additivity="true">
        <appender-ref ref="debugAppender"/>
        <appender-ref ref="infoAppender"/>
        <appender-ref ref="errorAppender"/>
    </logger>

    <!-- 根级别 -->
    <root level="info">
        <appender-ref ref="consoleAppender"/>
    </root>
</configuration>
```
