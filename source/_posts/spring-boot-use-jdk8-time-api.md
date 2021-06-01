---
title: Spring Boot自动序列化/反序列化JDK8的时间API
date: '2020-11-24 00:00:00'
updated: '2020-11-24 00:00:00'
tags:
- spring-boot
- java
categories:
- java
---

# Spring Boot自动序列化/反序列化JDK8的时间API

## Jdk8TimeConfig.class

```java
import com.fasterxml.jackson.datatype.jsr310.deser.LocalDateDeserializer;
import com.fasterxml.jackson.datatype.jsr310.deser.LocalDateTimeDeserializer;
import com.fasterxml.jackson.datatype.jsr310.deser.LocalTimeDeserializer;
import com.fasterxml.jackson.datatype.jsr310.ser.LocalDateSerializer;
import com.fasterxml.jackson.datatype.jsr310.ser.LocalDateTimeSerializer;
import com.fasterxml.jackson.datatype.jsr310.ser.LocalTimeSerializer;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.jackson.Jackson2ObjectMapperBuilderCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;

/**
 * JDK8时间序列化/反序列化支持, 仅对Controller层序列化返回以及@RequestBody反序列化生效,
 * 对GET请求不生效, 参照{@link converter.jdk8time.Jdk8TimeConverter}
 *
 * @author wangshuo
 * @date 2020/10/27
 */
@Configuration
public class Jdk8TimeConfig {

    @Value("${spring.jackson.jdk8-date-time-format:yyyy-MM-dd HH:mm:ss}")
    private String dateTimeFormat;
    @Value("${spring.jackson.jdk8-date-format:yyyy-MM-dd}")
    private String dateFormat;
    @Value("${spring.jackson.jdk8-time-format:HH:mm:ss}")
    private String timeFormat;
    @Value("${spring.jackson.jdk8-time-zone:UTC}")
    private String timeZone;

    @Bean
    public Jackson2ObjectMapperBuilderCustomizer jackson2ObjectMapperBuilderCustomizer() {
        return builder -> builder
            .serializerByType(LocalDateTime.class, new LocalDateTimeSerializer(DateTimeFormatter.ofPattern(dateTimeFormat).withZone(ZoneId.of(timeZone))))
            .serializerByType(LocalDate.class, new LocalDateSerializer(DateTimeFormatter.ofPattern(dateFormat).withZone(ZoneId.of(timeZone))))
            .serializerByType(LocalTime.class, new LocalTimeSerializer(DateTimeFormatter.ofPattern(timeFormat).withZone(ZoneId.of(timeZone))))
            .deserializerByType(LocalDateTime.class, new LocalDateTimeDeserializer(DateTimeFormatter.ofPattern(dateTimeFormat).withZone(ZoneId.of(timeZone))))
            .deserializerByType(LocalDate.class, new LocalDateDeserializer(DateTimeFormatter.ofPattern(dateFormat).withZone(ZoneId.of(timeZone))))
            .deserializerByType(LocalTime.class, new LocalTimeDeserializer(DateTimeFormatter.ofPattern(timeFormat).withZone(ZoneId.of(timeZone))));
    }
}
```

## Jdk8TimeConverter.class

```java
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.core.convert.converter.Converter;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;

/**
 * JDK8时间格式转换器, 用于GET请求时, 将URL中的时间字符串反序列化为时间对象
 *
 * @author wangshuo
 * @date 2020/10/28
 */
@Component
public class Jdk8TimeConverter {

    private static final Logger logger = LoggerFactory.getLogger(Jdk8TimeConverter.class);

    @Value("${spring.jackson.jdk8-date-time-format:yyyy-MM-dd HH:mm:ss}")
    private String dateTimeFormat;
    @Value("${spring.jackson.jdk8-date-format:yyyy-MM-dd}")
    private String dateFormat;
    @Value("${spring.jackson.jdk8-time-format:HH:mm:ss}")
    private String timeFormat;
    @Value("${spring.jackson.jdk8-time-zone:UTC}")
    private String timeZone;

    @Bean
    public Converter<String, LocalDateTime> localDateTimeConverter() {
        DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern(dateTimeFormat).withZone(ZoneId.of(timeZone));
        return new Converter<String, LocalDateTime>() {
            @Override
            public LocalDateTime convert(String source) {
                LocalDateTime target = null;
                try {
                    target = LocalDateTime.parse(source, dateTimeFormatter);
                } catch (Exception e) {
                    logger.error("source [{}] can not converted to java.time.LocalDateTime, please use [{}] format.", source, dateTimeFormat, e);
                }
                return target;
            }
        };
    }

    @Bean
    public Converter<String, LocalDate> localDateConverter() {
        DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern(dateFormat).withZone(ZoneId.of(timeZone));
        return new Converter<String, LocalDate>() {
            @Override
            public LocalDate convert(String source) {
                LocalDate target = null;
                try {
                    target = LocalDate.parse(source, dateFormatter);
                } catch (Exception e) {
                    logger.error("source [{}] can not converted to java.time.LocalDate, please use [{}] format.", source, dateFormat, e);
                }
                return target;
            }
        };
    }

    @Bean
    public Converter<String, LocalTime> localTimeConverter() {
        DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern(timeFormat).withZone(ZoneId.of(timeZone));
        return new Converter<String, LocalTime>() {
            @Override
            public LocalTime convert(String source) {
                LocalTime target = null;
                try {
                    target = LocalTime.parse(source, timeFormatter);
                } catch (Exception e) {
                    logger.error("source [{}] can not converted to java.time.LocalTime, please use [{}] format.", source, timeFormat, e);
                }
                return target;
            }
        };
    }
}
```
