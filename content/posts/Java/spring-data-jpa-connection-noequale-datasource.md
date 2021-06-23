---
title: Spring Data JPA 连接不同类型的多源数据库
date: '2020-03-12 00:00:00'
tags:
- Spring Data JPA
- Java
---

# Spring Data JPA 连接不同类型的多源数据库

## 环境说明

- Spring Boot：1.5.X
- Spring Data JPA：1.11.16

## 编写配置类

### 数据源配置

DataSourceConfig.java，**确保该类会被添加到 IOC 容器中**

```java
import com.alibaba.druid.pool.DruidDataSource;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

import javax.sql.DataSource;

// 表示是 Spring 的配置类
@Configuration
public class DataSourceConfig {

    // 第一个数据源
    // 创建一个名为 primaryDataSource 的对象，放到容器中
    @Bean(name = "primaryDataSource")
    // 指定读取配置文件的前缀
    @ConfigurationProperties(prefix = "spring.datasource.primary")
    // 作为主数据库
    @Primary
    public DataSource primaryDataSource() {
        /**
         * 使用 DataSourceBuilder.create().build();会按照如下顺序选择数据源, 
         * 因当前项目使用 Druid 数据源，因此返回 DruidDataSource 对象
         *
         * private static final String[] DATA_SOURCE_TYPE_NAMES = new String[] {
         * 			"org.apache.tomcat.jdbc.pool.DataSource",
         * 			"com.zaxxer.hikari.HikariDataSource",
         * 			"org.apache.commons.dbcp.BasicDataSource", // deprecated
         * 			"org.apache.commons.dbcp2.BasicDataSource" };
         */
        // return DataSourceBuilder.create().build();
        return new DruidDataSource();
    }

    // 第二个数据源
    @Bean(name = "secondaryDataSource")
    @ConfigurationProperties(prefix = "spring.datasource.secondary")
    public DataSource secondaryDataSource() {
        return new DruidDataSource();
    }
}
```

### 第一个数据源的 JPA 配置

注意修改 Repository 所在位置和实体类所在位置，该配置类需被添加到 IOC 容器

```java
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.orm.jpa.JpaProperties;
import org.springframework.boot.orm.jpa.EntityManagerFactoryBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.orm.jpa.JpaTransactionManager;
import org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.EnableTransactionManagement;

import javax.persistence.EntityManager;
import javax.sql.DataSource;
import java.util.HashMap;
import java.util.Map;

/**
 * 第一个数据源的 JPA 相关配置
 */
@Configuration
@EnableTransactionManagement
@EnableJpaRepositories(
        entityManagerFactoryRef = "entityManagerFactoryPrimary",
        transactionManagerRef = "transactionManagerPrimary",
        basePackages = {"icu.intelli.dao.primary"})
public class PrimaryDataSourceJpaConfig {


    /**
     * 注入第一个数据源
     */
    @Autowired
    @Qualifier("primaryDataSource")
    private DataSource primaryDataSource;

    /**
     * 实体管理
     * @param builder
     * @return
     */
    @Primary
    @Bean(name = "entityManagerPrimary")
    public EntityManager entityManager(EntityManagerFactoryBuilder builder) {
        return entityManagerFactoryPrimary(builder).getObject().createEntityManager();
    }

    @Primary
    @Bean(name = "entityManagerFactoryPrimary")
    public LocalContainerEntityManagerFactoryBean entityManagerFactoryPrimary(EntityManagerFactoryBuilder builder) {
        return builder
                .dataSource(primaryDataSource)
                .properties(getVendorProperties(primaryDataSource))
                // 设置实体类所在位置
                .packages("icu.intelli.po.primary")
                .persistenceUnit("primaryPersistenceUnit")
                .build();
    }

    /**
     * 注入 Jpa 属性对象
     */
    @Autowired
    private JpaProperties jpaProperties;

    /**
     * 从配置文件中读取方言
     */
    @Value("${spring.jpa.primary.dialect}")
    private String primaryDialect;
    /**
     * JPA 属性设置
     *
     * @param dataSource
     * @return
     */
    private Map<String, String> getVendorProperties(DataSource dataSource) {
        // 存放自定义的 jpa 属性
        Map<String, String> prop = new HashMap<>();
        prop.put("hibernate.dialect", primaryDialect);
        jpaProperties.setProperties(prop);
        return jpaProperties.getHibernateProperties(dataSource);
    }

    /**
     * JPA 事务管理设置
     *
     * @param builder
     * @return
     */
    @Primary
    @Bean(name = "transactionManagerPrimary")
    public PlatformTransactionManager transactionManagerPrimary(EntityManagerFactoryBuilder builder) {
        return new JpaTransactionManager(entityManagerFactoryPrimary(builder).getObject());
    }
}
```

### 第二个数据源的 JPA 配置

注意修改 Repository 所在位置和实体类所在位置，该配置类需被添加到 IOC 容器

```java
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.orm.jpa.JpaProperties;
import org.springframework.boot.orm.jpa.EntityManagerFactoryBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.orm.jpa.JpaTransactionManager;
import org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.EnableTransactionManagement;

import javax.persistence.EntityManager;
import javax.sql.DataSource;
import java.util.HashMap;
import java.util.Map;

/**
 * 第二数据源的 Jpa 相关配置
 */
@Configuration
@EnableTransactionManagement
@EnableJpaRepositories(
        entityManagerFactoryRef = "entityManagerFactorySecondary",
        transactionManagerRef = "transactionManagerSecondary",
        basePackages = {"icu.intelli.dao.secondary"})
public class SecondaryDataSourceJpaConfig {

    @Autowired
    @Qualifier("secondaryDataSource")
    private DataSource secondaryDataSource;

    @Bean(name = "entityManagerSecondary")
    public EntityManager entityManager(EntityManagerFactoryBuilder builder) {
        return entityManagerFactorySecondary(builder).getObject().createEntityManager();
    }

    @Bean(name = "entityManagerFactorySecondary")
    public LocalContainerEntityManagerFactoryBean entityManagerFactorySecondary (EntityManagerFactoryBuilder builder) {
        return builder
                .dataSource(secondaryDataSource)
                .properties(getVendorProperties(secondaryDataSource))
                // 设置实体类所在位置
                .packages("icu.intelli.po.secondary")
                .persistenceUnit("secondaryPersistenceUnit")
                .build();
    }

    @Autowired
    private JpaProperties jpaProperties;

    @Value("${spring.jpa.secondary.dialect}")
    private String secondaryDialect;

    private Map<String, String> getVendorProperties(DataSource dataSource) {
        Map<String, String> prop = new HashMap<>();
        prop.put("hibernate.dialect", secondaryDialect);
        jpaProperties.setProperties(prop);
        return jpaProperties.getHibernateProperties(dataSource);
    }

    @Bean(name = "transactionManagerSecondary")
    PlatformTransactionManager transactionManagerSecondary(EntityManagerFactoryBuilder builder) {
        return new JpaTransactionManager(entityManagerFactorySecondary(builder).getObject());
    }
}
```

## 编写配置文件

该配置文件需要被添加到 Spring 容器中，可以在 SpringBoot 启动类上使用 `@PropertySource("classpath:jdbc.properties")` 添加

```properties
# 第一个数据源配置（MySQL）
spring.datasource.primary.url=jdbc:mysql://127.0.0.1:3306/database1?autoReconnect=true&autoReconnectForPools=true&useUnicode=true&characterEncoding=utf8
spring.datasource.primary.username=root
spring.datasource.primary.password=root
spring.datasource.primary.driver-class-name=com.mysql.jdbc.Driver
# 第一个数据源其他初始化配置
spring.datasource.primary.type=com.alibaba.druid.pool.DruidDataSource
spring.datasource.primary.initial-size=10
spring.datasource.primary.min-idle=10
spring.datasource.primary.max-active=50
spring.datasource.primary.max-wait=60000
spring.datasource.primary.time-between-eviction-runs-millis=60000
spring.datasource.primary.min-evictable-idle-time-millis=300000
spring.datasource.primary.validationQuery=SELECT 'x'
spring.datasource.primary.validation-query-timeout=30
spring.datasource.primary.test-while-idle=true
spring.datasource.primary.test-on-borrow=true
spring.datasource.primary.test-on-return=true
spring.datasource.primary.pool-prepared-statements=false
spring.datasource.primary.max-open-prepared-statements=100
spring.datasource.primary.max-pool-prepared-statement-per-connection-size=20
spring.datasource.primary.filters=wall,stat
spring.datasource.primary.connection-properties=druid.stat.mergeSql=true;druid.stat.slowSqlMillis=5000
# 第二个数据源配置（PostgreSQL）
spring.datasource.secondary.url=jdbc:postgresql://127.0.0.1:5432/database2
spring.datasource.secondary.username=root
spring.datasource.secondary.password=root
spring.datasource.secondary.driver-class-name=org.postgresql.Driver
# 第二个数据源其他初始化配置
spring.datasource.secondary.type=com.alibaba.druid.pool.DruidDataSource
spring.datasource.secondary.initial-size=10
spring.datasource.secondary.min-idle=10
spring.datasource.secondary.max-active=50
spring.datasource.secondary.max-wait=60000
spring.datasource.secondary.time-between-eviction-runs-millis=60000
spring.datasource.secondary.min-evictable-idle-time-millis=300000
spring.datasource.secondary.validationQuery=SELECT version()
spring.datasource.secondary.validation-query-timeout=30
spring.datasource.secondary.test-while-idle=true
spring.datasource.secondary.test-on-borrow=true
spring.datasource.secondary.test-on-return=true
spring.datasource.secondary.pool-prepared-statements=false
spring.datasource.secondary.max-open-prepared-statements=100
spring.datasource.secondary.max-pool-prepared-statement-per-connection-size=20
spring.datasource.secondary.filters=wall,stat
spring.datasource.secondary.connection-properties=druid.stat.mergeSql=true;druid.stat.slowSqlMillis=5000

# JPA 公共配置
spring.jpa.show-sql=true
spring.jpa.generate-ddl=true
spring.jpa.hibernate.ddl-auto=update
# JPA 指定配置
# 第一数据源相关配置（MySQL）
spring.jpa.primary.dialect=org.hibernate.dialect.MySQL5Dialect
# 第二数据源相关配置（Postgis）
spring.jpa.secondary.dialect=org.hibernate.spatial.dialect.postgis.PostgisDialect
```

## 测试

```java
import icu.intelli.Application;
import icu.intelli.dao.productfileinfo.ProductFileInfoDao;
import icu.intellidao2.DecodingTypeRepository;
import icu.intelli.entity2.DecodingType;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;
import javax.sql.DataSource;
import java.util.List;

@RunWith(SpringRunner.class)
@SpringBootTest(classes = Application.class)
public class myTest {

    @Autowired
    private ProductFileInfoDao productFileInfoDao;

    @Autowired
    private DecodingTypeRepository decodingTypeRepository;

    @Autowired
    @Qualifier("primaryDataSource")
    DataSource primaryDataSource;

    @Autowired
    @Qualifier("secondaryDataSource")
    DataSource secondaryDataSource;

    @Test
    public void testDao1() {
        List list = productFileInfoDao.findByproductInfoId("33789241244d466fb2427283f8b24619");
        System.out.println(list);
    }

    @Test
    public void testDao2() {
        DecodingType one = decodingTypeRepository.findOne("A");
        System.out.println(one);
    }
    
}
```

## 参考文档

[SpringBoot 1.5.XX 多数据源配置](https://blog.csdn.net/u011751078/article/details/79784228)
