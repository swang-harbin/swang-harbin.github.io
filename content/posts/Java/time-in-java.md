---
title: Java 中时间相关的类
date: '2020-05-22 00:00:00'
tags:
- Java
---

# Java 中时间相关的类

## 部分时间系统

**格林尼治标准时（GMT）**/**世界时（UT）**：Greenwich Mean Time/Universal Time，以地球自转为基础的时间计量系统，指当太阳横穿格林尼治本初子午线时的时间，由于地球自转速度变化的影响，这个时刻可能和真太阳时相差 16 分钟。

**太阳时**：太阳时是指以太阳日为标准来计算的时间。可以分为真太阳时和平（均）太阳时。

- 真太阳时：以真太阳日为标准来计算的叫真太阳时，日晷所表示的时间就是真太阳时。
- 平太阳时（MT）：mean solar time，以平太阳日为标准来计算的叫平太阳时，钟表所表示的时间就是平太阳时。

**原子时（IAT）**：international atomic time，以物质的原子内部发射的电磁振荡频率为基准的时间计量系统。秒长定义为 铯-133 原子基态的两个超精细能级间在零磁场下跃迁辐射 9192631770 周所持续的时间。这是一种均匀的时间计量系统。初始历元规定为 1958 年 1 月 1 日世界时 0 时，但事后发现，在该瞬间原子时与世界时的时刻之差为 0.0039 秒，这一差值就作为历史事实而保留下来。

**协调世界时（UTC）**：Universal Time Coordinated，原子时与地球自转没有直接联系，由于地球自转速度长期变慢的趋势，原子时与世界时的差异将逐渐变大。为了保证时间与季节的协调一致，便于日常使用，建立了以原子时秒长为计量单位，在时刻上与"平均太阳时"之差小于 0.9 秒的时间系统，称为世界协调时。

在不需要精确到秒的情况下，通常将 GMT 和 UTC 视作等同

## Java 中时间相关的类

epoch：时代，代表 1970-01-01 00:00:00

### java.util.Date

**构造方法**

- `public Date(){}`

  ```java
  public Date() {
      // `System.currentTimeMillis()`：返回将当前系统时间转为 UTC 时间后距离 1970-01-01 00:00:00 的毫秒数，均按 UTC 时间计算
      this(System.currentTimeMillis());
  }
  ```

- `public Date(long date)`

  ```java
  public Date(long date) {
      fastTime = date;
  }
  ```

Date 类中保存的是以 UTC 时间计算距离 epoch 的毫秒数，该毫秒数是按 UTC 时间系统计算的，是时区无关的。他的 zoneid 属性保存了时区信息，就是当前系统的时区，不能直接改变。

**常用方法**

- `public static Date from(Instant instant) {}`：将 Instant 对象转为 Date 对象
- `public Instant toInstant() {}`：将 Date 对象转为 Instance 对象
- `public long getTime() {}`：获取当前时间距离 epoch 的 UTC 毫秒数
- `public boolean equals/before/after(Date when) {}`：时间比较

### java.util.Calendar

日历类，注意 Month 是从 0 开始

**获取实例方法**

- `public static Calendar getInstance(){}`：其中时区和地区信息均是系统默认的
- `public static Calendar getInstance(TimeZone zone){}`：指定时区，地区信息是系统默认
- `public static Calendar getInstance(Locale aLocale){}`：指定地区，时区信息是系统默认
- `public static Calendar getInstance(TimeZone zone, Locale aLocale){}`：指定时区和地区

**其他常用方法**

- `public long getTimeInMillis() {}`：获取当前时间距离 epoch 的 UTC 毫秒数
- `public void setTimeInMillis(long millis) {}`：使用 UTC 毫秒数修改时间
- `public void set(int field, int value) {}`：为指定字段设置值，field 可使用`Calendar.属性`方式传入
- `public int get(int field) {}`：获取去某一字段的值，field 可使用`Calendar.属性`方式传入
- `public final void setTime(Date date) {}`：使用 Date 类型对象设置时间
- `public void setTimeZone(TimeZone value) {}`：设置时区
- `public final Instant toInstant() {}`：转换为 Instant 类型对象
- `public final void set(int year, int month, int date, int hourOfDay, int minute, int second) {}`：设置年月日时分秒的值

### java.util.TimeZone

表示时区，通常 java.util.Date 和 java.util.Calendar 类会使用到

**获取系统默认时区对象**

- `public static TimeZone getDefault() {}`

**其他方法**

- `public static synchronized String[] getAvailableIDs() {}`：获取所有受支持的时区 ID，主要包括两种格式：`Asia/Shanghai`和`CST`
- `public static synchronized String[] getAvailableIDs(int rawOffset) {}`：根据给定偏移量，获取受支持的时区 ID，偏移量为毫秒
- `public static synchronized TimeZone getTimeZone(String ID) {}`：根据字符串类型的时区 ID 获取 TimeZone 类型对象，受支持的 ID 可使用前两个方法获取
- `public static TimeZone getTimeZone(ZoneId zoneId) {}`：根据 ZoneId 类型的时区 ID 获取 TimeZone 类型对象，ZoneId 是 jdk1.8 之后才有的

## java.text.SimpleDateFormat

## java.time.LocalDateTime

不包含任何时区信息

**方法**

- `public static LocalDateTime now() {}`：使用系统时钟和系统默认时区的当前时间
- `public static LocalDateTime parse(CharSequence text) {}`：将字符串根据本地时间格式转换为 LocalDateTime 对象，该对象是不包含时区信息的
- `public static LocalDateTime parse(CharSequence text, DateTimeFormatter formatter) {}`：按指定格式将字符串转为 LocalDateTime 对象，该对象是不包含时区信息的

java.time.LocalDate

java.time.LocalTime

java.time.Instant

java.time.ZonedDateTime
