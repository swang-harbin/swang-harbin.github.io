---
title: Spring Boot与数据访问
date: '2019-12-18 00:00:00'
updated: '2019-12-18 00:00:00'
tags:
- Spring Boot
- Java
categories:
- [Java, SpringBoot基础系列]
---

# Spring Boot与数据访问

[SpringBoot基础系列目录](spring-boot-table.md)

## 简介

对于数据访问层, 无论是SQL还是NOSQL, SpringBoot默认采用整合Spring Data的方式进行统一处理, 添加大量自动配置, 屏蔽了很多设置. 引入各种xxxTemplate, xxxRepository来简化我们对数据访问层的操作. 对我们来说只需要进行简单的设置即可. 我们将在数据访问章节测试使用SQL相关, NOSQL在缓存, 消息, 检索等章节测试

- JDBC
- MyBatis
- JPA

spring-boot-starter-data-xxx

## 整合基本JDBC与数据源

### JDBC

pom.xml

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-jdbc</artifactId>
</dependency>

<dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
    <scope>runtime</scope>
</dependency>
```

application.yml

```yaml
spring:
  datasource:
    username: root
    password: Root1234
    url: jdbc:mysql://39.105.30.251:3306/jdbc
    driver-class-name: com.mysql.jdbc.Driver
```

Controller

```java
@Controller
public class HelloController {

    @Autowired
    JdbcTemplate jdbcTemplate;

    @ResponseBody
    @GetMapping("/query")
    public Map<String, Object> map(){
        List<Map<String, Object>> list = jdbcTemplate.queryForList("select * from department");
        return list.get(0);
    }
}
```

1.x版本默认使用org.apache.tomcat.jdbc.pool.DataSource数据源, 2.x版本默认使用com.zaxxer.hikari.HikariDataSource数据源

数据源的相关配置都在DataSourceProperties类中

**1.x自动配置原理 :**

org.springframework.boot.autoconfigure.jdbc

1. 参考DataSourceConfiguration, 根据配置创建数据源, 默认使用Tomcat连接池, 可以使用spring.datasource.type指定自定义的数据源类型

2. SpringBoot默认可以支持 :

   ```java
   org.apache.tomcat.jdbc.pool.DataSource, HikariDataSource, BasicDataSource
   ```

3. 自定义数据源类型

   ```java
   /**
    * Generic DataSource configuration.
    */
   @Configuration(proxyBeanMethods = false)
   @ConditionalOnMissingBean(DataSource.class)
   @ConditionalOnProperty(name = "spring.datasource.type")
   static class Generic {
   
       @Bean
       DataSource dataSource(DataSourceProperties properties) {
           // 使用DataSourceBuilder创建数据源, 利用反射创建相应type的数据源, 并且绑定相关属性
           return properties.initializeDataSourceBuilder().build();
       }
   
   }
   ```

4. DataSourceInitializer : ApplicationListener

   - 作用:
     1. runSchemaScripts()运行建表语句;
     2. runDataScripts()运行插入数据的sql语句;

   ```yaml
   # 默认只需要将文件命名为 : 
   schema-*.sql(建表), data-*.sql(插入数据)
   
   # 默认规则 : schema.sql, schema-all.sql
   
   # 可以使用
   spring:
     datasource:
       username: root
       password: Root1234
       url: jdbc:mysql://39.105.30.251:3306/jdbc
       driver-class-name: com.mysql.jdbc.Driver
       schema:
         - classpath: department.sql
   
   # 指定配sql的位置
   
   # SpringBoot2.x版本需要添加
   spring: 
       datasource: 
           initialization-mode: always
   ```

5. 操作数据库 : 自动配置了jdbcTemplate操作数据库

### 使用druid

使用http://localhost:8080/druid登录druid控制台

#### 方式一: 使用com.alibaba.druid

**环境 :**

SpringBoot1.5.9
druid1.1.8

1. 引入druid数据源

   ```xml
   <dependency>
       <groupId>com.alibaba</groupId>
       <artifactId>druid</artifactId>
       <version>1.1.8</version>
   </dependency>
   ```

2. 配置druid数据源

   **application.yml :**

   ```yaml
   spring:
     datasource:
       username: root
       password: 123456
       url: jdbc:mysql://192.168.15.22:3306/jdbc
       driver-class-name: com.mysql.jdbc.Driver
       type: com.alibaba.druid.pool.DruidDataSource
   
       initialSize: 5
       minIdle: 5
       maxActive: 20
       maxWait: 60000
       timeBetweenEvictionRunsMillis: 60000
       minEvictableIdleTimeMillis: 300000
       validationQuery: SELECT 1 FROM DUAL
       testWhileIdle: true
       testOnBorrow: false
       testOnReturn: false
       poolPreparedStatements: true
   #   配置监控统计拦截的filters，去掉后监控界面sql无法统计，'wall'用于防火墙
       filters: stat,wall,log4j
       maxPoolPreparedStatementPerConnectionSize: 20
       useGlobalDataSourceStat: true
       connectionProperties: druid.stat.mergeSql=true;druid.stat.slowSqlMillis=500
   ```

   此时, 配置是不生效的 需要添加配置类

   **DruidConfig.java :**

   ```java
   @Configuration
   public class DruidConfig {
   
       @ConfigurationProperties(prefix = "spring.datasource")
       @Bean
       public DataSource druid(){
           return  new DruidDataSource();
       }
   
       //配置Druid的监控
       //1、配置一个管理后台的Servlet
       @Bean
       public ServletRegistrationBean statViewServlet(){
           ServletRegistrationBean bean = new ServletRegistrationBean(new StatViewServlet(), "/druid/*");
           Map<String,String> initParams = new HashMap<>();
   
           initParams.put("loginUsername","admin");
           initParams.put("loginPassword","123456");
           initParams.put("allow","");//默认就是允许所有访问
           initParams.put("deny","192.168.15.21");
   
           bean.setInitParameters(initParams);
           return bean;
       }
   
   
       //2、配置一个web监控的filter
       @Bean
       public FilterRegistrationBean webStatFilter(){
           FilterRegistrationBean bean = new FilterRegistrationBean();
           bean.setFilter(new WebStatFilter());
   
           Map<String,String> initParams = new HashMap<>();
           initParams.put("exclusions","*.js,*.css,/druid/*");
   
           bean.setInitParameters(initParams);
   
           bean.setUrlPatterns(Arrays.asList("/*"));
   
           return  bean;
       }
   }
   ```

#### 方式二: 使用druid-spring-boot-starter

SpringBoot 2.2.2
druid-spring-boot-starter 1.1.10

1. 添加依赖

   ```xml
   <dependency>
       <groupId>com.alibaba</groupId>
       <artifactId>druid-spring-boot-starter</artifactId>
       <version>1.1.10</version>
   </dependency>
   ```

2. 配置application.yml

   ```yaml
   spring:
       application:
           name: springboot-test-exam1
       datasource:
           # 使用阿里的Druid连接池
           type: com.alibaba.druid.pool.DruidDataSource
           driver-class-name: com.mysql.jdbc.Driver
           # 填写你数据库的url、登录名、密码和数据库名
           url: jdbc:mysql://localhost:3306/databaseName?useSSL=false&characterEncoding=utf8
           username: root
           password: root
           druid:
             # 连接池的配置信息
             # 初始化大小，最小，最大
             initial-size: 5
             min-idle: 5
             maxActive: 20
             # 配置获取连接等待超时的时间
             maxWait: 60000
             # 配置间隔多久才进行一次检测，检测需要关闭的空闲连接，单位是毫秒
             timeBetweenEvictionRunsMillis: 60000
             # 配置一个连接在池中最小生存的时间，单位是毫秒
             minEvictableIdleTimeMillis: 300000
             validationQuery: SELECT 1
             testWhileIdle: true
             testOnBorrow: false
             testOnReturn: false
             # 打开PSCache，并且指定每个连接上PSCache的大小
             poolPreparedStatements: true
             maxPoolPreparedStatementPerConnectionSize: 20
             # 配置监控统计拦截的filters，去掉后监控界面sql无法统计，'wall'用于防火墙
             filters: stat,wall,slf4j
             # 通过connectProperties属性来打开mergeSql功能；慢SQL记录
             connectionProperties: druid.stat.mergeSql\=true;druid.stat.slowSqlMillis\=5000
             # 配置DruidStatFilter
             web-stat-filter:
               enabled: true
               url-pattern: "/*"
               exclusions: "*.js,*.gif,*.jpg,*.bmp,*.png,*.css,*.ico,/druid/*"
             # 配置DruidStatViewServlet
             stat-view-servlet:
               url-pattern: "/druid/*"
               # IP白名单(没有配置或者为空，则允许所有访问)
               allow: 127.0.0.1,192.168.163.1
               # IP黑名单 (存在共同时，deny优先于allow)
               deny: 192.168.1.73
               #  禁用HTML页面上的“Reset All”功能
               reset-enable: false
               # 登录名
               login-username: admin
               # 登录密码
               login-password: 123456
   ```

   更多版本查看, 见[Maven仓库](http://mvnrepository.com/artifact/com.alibaba/druid-spring-boot-starter)

   更多参数说明, 见[官方文档](https://github.com/alibaba/druid/tree/master/druid-spring-boot-starter)

## 整合MyBatis

1. 添加mybatis依赖

   ```xml
   <dependency>
       <groupId>org.mybatis.spring.boot</groupId>
       <artifactId>mybatis-spring-boot-starter</artifactId>
       <version>2.1.1</version>
   </dependency>
   ```

   ![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222134235.png)

2. 配置druid数据源及配置文件

   详情参照[6.2.1 使用druid](http:)

3. 建立数据表

   ```yaml
   spring:
     datasource:
       schema:
         - classpath:sql/department.sql
         - classpath:sql/employee.sql
       # SpringBoot2.x版本需要添加下面配置
       initialization-mode: always
   ```

4. 创建java bean 略

## Mybatis注解版

```java
// 指定这是一个操作数据库的mapper
@Mapper
public interface DepartmentMapper {

    @Select("SELECT * FROM department WHERE id=#{id}")
    Department getDeptById(Integer id);

    @Delete("DELETE FROM department WHERE id=#{id}")
    int deleteDeptById(Integer id);

    // 插入后返回主键
    @Options(useGeneratedKeys = true, keyProperty = "id")
    @Insert("INSERT INTO department(departmentName) VALUES(#{departmentName})")
    int insertDept(Department department);

    @Update("UPDATE department SET departmentName=#{departmentName} WHERE id=#{id}")
    int updateDept(Department department);
}
```

自定义MyBatis的配置规则, 给容器中添加一个ConfigurationCustomizer

```java
@Configuration
public class MyBatisConfig {

    @Bean
    public ConfigurationCustomizer configurationCustomizer() {
        return new ConfigurationCustomizer() {
            @Override
            public void customize(Configuration configuration) {
                // 自动将数据库中dept_name映射为bean中的deptName
                configuration.setMapUnderscoreToCamelCase(true);
            }
        };
    }
}
```

使用@MapperScan扫描指定包下的所有Mapper, 就不用在每个xxxMapper接口上标注@Mapper注解了

```java
// 标注在SpringBoot主程序上
@MapperScan(value = "icu.intelli.springboot.mapper")
@SpringBootApplication
public class Application {

// 或者MyBatis的自定义配置类上
@MapperScan(value = "icu.intelli.springboot.mapper")
@org.springframework.context.annotation.Configuration
public class MyBatisConfig {
```

## Mybatis配置文件版

**mapper.java**

```java
//无论是注解还是配置文件方式, 都要使用@Mapper或者@MapperScan将接口扫描装配到容器中
public interface EmployeeMapper {

    Employee getEmpById(Integer id);

    void insertEmp(Employee employee);
}
```

**mapper.xml**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="icu.intelli.springboot.mapper.EmployeeMapper">

    <select id="getEmpById" resultType="icu.intelli.springboot.bean.Employee">
        SELECT *
        FROM
            employee
        WHERE
        id = #{id}
    </select>

    <insert id="insertEmp">
        INSERT INTO
            employee(
            lastName, email, gender, d_id
            )
        Values(
            #{lastName},
            #{email},
            #{gender},
            #{dId}
        )
    </insert>
</mapper>
```

**mybatis-config.xml**

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE configuration
        PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
    <settings>
        <!-- 开启驼峰转换 -->
        <setting name="mapUnderscoreToCamelCase" value="true"/>
    </settings>
</configuration>
```

**application.yml**

```yaml
mybatis:
  config-location: classpath:mybatis/mybatis-config.xml
  mapper-locations: classpath:mybatis/mapper/*.xml
```

## 整合JPA

### Spring Data

#### 简介

SpringData项目的目的是为了简化构建基于Spring框架应用的数据访问技术, 包括非关系数据库, Map-Reduce框架, 云数据服务等等, 另外也包含对关系数据库的访问支持.

Spring Data包含多个子项目: 

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222134431.png)

Spring Data的结构:

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222134513.png)

1. Spring Data特点

SpringData为我们提供使用统一的API来对数据访问层进行操作; 这主要是Spring Data Commons项目来实现的. Spring Data Commons让我们在使用关系型或者非关系型数据库访问技术时基于Spring提供的统一标准, 标准包含了CRUD(创建, 获取, 更新, 删除), 查询, 排序和分页的相关操作.

1. 统一的Repository接口 

   ![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222134533.png)

   - Repository<T, ID extends Serializable> : 统一接口
   - RevisionRepository<T, ID extends Serializable, N extends Number & Comparable<N>> : 基于乐观锁机制
   - CrudRepository<T, ID extends Serializable> : 基于CRUD操作
   - PagingAndSortingRepository<T, ID extends Serializable> : 基于CRUD及分页

2. 提供数据访问模板类xxxTemplate 如: MongoTemplate, RedisTemplate等

3. JPA(Java Persistence API)与Spring Data

- JpaRepository基本功能

  编写接口继承JPARepository既有crud及分页等基本功能

- 定义符合规范的方法命名

  在接口中只需要声明符合规范的方法, 即拥有对应的功能

- @Query自定义查询, 定制查询SQL

- Specification查询(Spring Data JPA支持JPA2.0的Criteria查询)

### 整合JPA

JPA也是基于ORM(Object Relational Mapping)思想的

1. 编写一个实体类(bean)和数据表进行映射, 并且配置好映射关系

   ```java
   // 使用JPA注解配置映射关系
   @Entity // 告诉JPA这是一个实体类(和数据表映射的类)
   @Table(name = "tbl_user") // 指定和哪个数据表对应, 如果省略, 默认表名就是类名小写user
   public class User {
   
       @Id // 这是一个主键
       @GeneratedValue(strategy = GenerationType.IDENTITY) // 自增主键
       private Integer id;
   
       @Column(name = "last_name", length = 50) // 这是和数据表对应的一个列
       private String lastName;
   
       @Column // 可以省略, 默认列名就是属性名
       private String email;
   ```

2. 编写一个Dao接口来操作实体类对应的数据表(Repository)

   ```java
   // 继承JpaRepository来完成对数据库的操作
   // JpaRepository<T, ID>: T为对应的实体类型, ID为实体类的主键类型
   public interface UserRepository extends JpaRepository<User, Integer> {
   }
   ```

3. 基本的配置

   ```yaml
   spring:
       jpa:
           hibernate:
               # 更新或者创建数据表结构
               ddl-auto: update
           # 控制台显示SQL
           show-sql: true
   ```
