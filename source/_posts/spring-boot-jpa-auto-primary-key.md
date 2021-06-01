---
title: Spring Data JPA自动生成主键, 创建时间和更新时间
date: '2020-05-18 00:00:00'
updated: '2020-05-18 00:00:00'
tags:
- spring-data-jpa
- java
categories:
- java
---

# Spring JPA自动生成主键, 创建时间和更新时间

## 1.自定义的基本DO父类

```java
import org.hibernate.annotations.GenericGenerator;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import javax.persistence.*;
import java.io.Serializable;
import java.util.Date;

/**
 * 标识该类是一个父类
 * 不需要映射数据表, 但是该类中的属性会被子类继承, 并映射为数据表的列中
 * 不能在使用@Entity和@Table注解
 */
@MappedSuperclass
/**
 * 可标注在标注了@Entity或@MappedSuperclass的类上
 * 指定实体或超类的监听类
 AuditingEntityListener: 监听捕获实体类在持久化和更新时的审计信息
 */
@EntityListeners(AuditingEntityListener.class)
public class BaseDO implements Serializable {
    /**
     * 唯一ID
     * @GenericGenerator: Hibernate通用生成器, 此处使用uuid策略
     * @GeneratedValue: 指定主键生成策略
     */
    @Id
    @Column(length = 32)
    @GenericGenerator(name = "jpa-uuid", strategy = "uuid")
    @GeneratedValue(generator = "jpa-uuid")
    private String id;
    /**
     * 创建时间
     * @Temporal: 只能标注在java.util.Date和java.util.Calendar类型的属性上, 指定映射Data和Calendar的数据库字段类型
     * @CreatedDate: 声明该字段为一个创建日期字段
     */
    @Temporal(TemporalType.TIMESTAMP)
    @CreatedDate
    @Column(nullable = false)
    private Date createTime;
    /**
     * 更新时间
     * @LastModifiedDate: 声明该字段为一个更新日期字段
     */
    @Temporal(TemporalType.TIMESTAMP)
    @LastModifiedDate
    private Date updateTime;

    public String getId() {
        return id;
    }

    public BaseDO setId(String id) {
        this.id = id;
        return this;
    }

    public Date getCreateTime() {
        return createTime;
    }

    public BaseDO setCreateTime(Date createTime) {
        this.createTime = createTime;
        return this;
    }

    public Date getUpdateTime() {
        return updateTime;
    }

    public BaseDO setUpdateTime(Date updateTime) {
        this.updateTime = updateTime;
        return this;
    }
}
```

## 2. BaseDO的子类RegionDO

```java
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Table;

@Entity
@Table(name = "tb_region", schema = "lincao")
public class RegionDO extends BaseDO {
    /**
     * 行政区划名称
     */
    @Column
    private String region;
    /**
     * 行政区划ID, 12位
     */
    @Column(length = 12)
    private String regionCode;

    public String getRegion() {
        return region;
    }

    public RegionDO setRegion(String region) {
        this.region = region;
        return this;
    }

    public String getRegionCode() {
        return regionCode;
    }

    public RegionDO setRegionCode(String regionCode) {
        this.regionCode = regionCode;
        return this;
    }
}
```

## 3. 在Application.java上添加`@EnableJpaAuditing`注解, 启动JPA审核功能

```java
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@SpringBootApplication
/**
 * 注解方式启动JPA审核功能
 */
@EnableJpaAuditing
public class Application {

    public static void main(String[] args) {
        // Spring应用启动起来
        SpringApplication.run(Application.class, args);
    }
}
```

## 4. Repository(DAO)层

```java
import cc.ccue.dataobject.RegionDO;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface RegionDAO extends JpaRepository<RegionDO, String> {

}
```

只需要生成主键时可以不添加`@EntityListeners(AuditingEntityListener.class)`和`@EnableJpaAuditing`注解

还可以使用`@Version`注解, 自动生成版本号

