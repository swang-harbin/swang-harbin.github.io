---
layout: post
title: Java中时间相关的类
subheading: 
author: swang-harbin
categories: java
banner: 
tags: java
---

# Java中时间相关的类

## 一. 部分时间系统

**格林尼治标准时(GMT)**/**世界时(UT)**: Greenwich Mean Time/Universal Time, 以地球自转为基础的时间计量系统, 指当太阳横穿格林尼治本初子午线时的时间, 由于地球自转速度变化的影响, 这个时刻可能和真太阳时相差16分钟.

**太阳时**: 太阳时是指以太阳日为标准来计算的时间. 可以分为真太阳时和平(均)太阳时. - 真太阳时: 以真太阳日为标准来计算的叫真太阳时, 日晷所表示的时间就是真太阳时. - 平太阳时(MT): mean solar time, 以平太阳日为标准来计算的叫平太阳时，钟表所表示的时间就是平太阳时.

**原子时(IAT)**: international atomic time, 以物质的原子内部发射的电磁振荡频率为基准的时间计量系统. 秒长定义为铯-133原子基态的两个超精细能级间在零磁场下跃迁辐射9192631770周所持续的时间. 这是一种均匀的时间计量系统. 初始历元规定为1958年1月1日世界时0时, 但事后发现, 在该瞬间原子时与世界时的时刻之差为0.0039秒, 这一差值就作为历史事实而保留下来.

**协调世界时(UTC)**: Universal Time Coordinated, 原子时与地球自转没有直接联系, 由于地球自转速度长期变慢的趋势, 原子时与世界时的差异将逐渐变大. 为了保证时间与季节的协调一致, 便于日常使用, 建立了以原子时秒长为计量单位, 在时刻上与"平均太阳时"之差小于0.9秒的时间系统, 称为世界协调时.

在不需要精确到秒的情况下，通常将GMT和UTC视作等同

## 二. Java中时间相关的类

epoch: 时代, 代表1970-01-01 00:00:00

### 2.1 java.util.Date

**构造方法**

- public Date(){}:

```java
public Date() {
    // `System.currentTimeMillis()`: 返回将当前系统时间转为UTC时间后距离1970-01-01 00:00:00的毫秒数, 均按UTC时间计算
    this(System.currentTimeMillis());
}
```

- public Date(long date)

```java
public Date(long date) {
    fastTime = date;
}
```

Date类中保存的是以UTC时间计算距离epoch的毫秒数, 该毫秒数是按UTC时间系统计算的, 是时区无关的. 他的zoneid属性保存了时区信息, 就是当前系统的时区, 不能直接改变.

**常用方法**

- public static Date from(Instant instant) {}: 将Instant对象转为Date对象
- public Instant toInstant() {}: 将Date对象转为Instance对象
- public long getTime() {}: 获取当前时间距离epoch的UTC毫秒数
- public boolean equals/before/after(Date when) {}: 时间比较

### 2.2 java.util.Calendar

日历类, 注意Month是从0开始

**实例方法**

- public static Calendar getInstance(){}: 其中时区和地区信息均是系统默认的
- public static Calendar getInstance(TimeZone zone){}: 指定时区, 地区信息是系统默认
- public static Calendar getInstance(Locale aLocale){}: 指定地区, 时区信息是系统默认
- public static Calendar getInstance(TimeZone zone, Locale aLocale){}: 指定时区和地区

**其他常用方法**

- public long getTimeInMillis() {}: 获取当前时间距离epoch的UTC毫秒数
- public void setTimeInMillis(long millis) {}: 使用UTC毫秒数修改时间
- public void set(int field, int value) {}: 为指定字段设置值, field可使用`Calendar.属性`方式传入
- public int get(int field) {}: 获取去某一字段的值, field可使用`Calendar.属性`方式传入
- public final void setTime(Date date) {}: 使用Date类型对象设置时间
- public void setTimeZone(TimeZone value) {}: 设置时区
- public final Instant toInstant() {}: 转换为Instant类型对象
- public final void set(int year, int month, int date, int hourOfDay, int minute, int second) {} : 设置年月日时分秒的值

### 2.3 java.util.TimeZone

表示时区, 通常java.util.Date和java.util.Calendar类会使用到

**获取系统默认时区对象**

- public static TimeZone getDefault() {}

**其他方法**

- public static synchronized String[] getAvailableIDs() {}: 获取所有受支持的时区ID, 主要包括两种格式: `Asia/Shanghai`和`CST`
- public static synchronized String[] getAvailableIDs(int rawOffset) {}: 根据给定偏移量, 获取受支持的时区ID, 偏移量为毫秒
- public static synchronized TimeZone getTimeZone(String ID) {}: 根据字符串类型的时区ID获取TimeZone类型对象, 受支持的ID可使用前两个方法获取
- public static TimeZone getTimeZone(ZoneId zoneId) {}: 根据ZoneId类型的时区ID获取TimeZone类型对象, ZoneId是jdk1.8之后才有的

## 2.4 java.text.SimpleDateFormat

## 2.5 java.time.LocalDateTime

不包含任何时区信息

**方法**

- public static LocalDateTime now() {}: 使用系统时钟和系统默认时区的当前时间
- public static LocalDateTime parse(CharSequence text) {}: 将字符串根据本地时间格式转换为LocalDateTime对象, 该对象是不包含时区信息的.
- public static LocalDateTime parse(CharSequence text, DateTimeFormatter formatter) {}: 按指定格式将字符串转为LocalDateTime对象, 该对象是不包含时区信息的

java.time.LocalDate

java.time.LocalTime

java.time.Instant

java.time.ZonedDateTime