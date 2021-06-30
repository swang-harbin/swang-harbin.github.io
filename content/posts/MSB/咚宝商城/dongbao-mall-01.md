---
title: 咚宝商城第一节课
date: '2021-01-31 00:00:00'
tags:
- MSB
- Project
- Java
---

# 咚宝商城第一节课

## 项目模块介绍

```shell
msb-dongbao-mall-parent        	父项目
	msb-dongbao-common 公共包
		msb-dongbao-common-base 公共基础类
		msb-dongbao-common-util 工具类
	msb-dongbao-api 业务模块接口层
		msb-dongbao-oms-api 订单中心接口
		msb-dongbao-pms-api 商品中心接口
		msb-dongbao-ums-api 用户中心接口
		msb-dongbao-pay-api 支付中心接口
		msb-dongbao-cart-api 购物车接口
		msb-dongbao-dictionary-api 基础字典接口
		msb-dongbao-sms-api 优惠中心接口
		msb-dongbao-cms-api 内容中心接口
	msb-dongbao-service 业务模块实现层
		msb-dongbao-oms 订单中心模块实现
		msb-dongbao-pms 商品中心模块实现
		msb-dongbao-ums 用户中心模块实现
		msb-dongbao-pay 支付中心模块实现
		msb-dongbao-cart 购物车模块实现
		msb-dongbao-dictionary 基础字典模块实现
		msb-dongbao-sms 优惠中心模块实现
		msb-dongbao-cms 内容中心模块实现
	msb-dongbao-application web 应用模块
	    msb-dongbao-manager-web 后台管理应用
		msb-dongbao-portal-web 商城门户网站
	msb-dongbao-job 定时任务模块
	msb-dongbao-generator 代码生成器
```

## maven 镜像

```xml
<mirror>
    <id>aliyunmaven</id>
    <mirrorOf>*</mirrorOf>
    <name>阿里云公共仓库</name>
    <url>https://maven.aliyun.com/repository/public</url>
</mirror>
<mirror>
    <id>aliyunmaven</id>
    <mirrorOf>*</mirrorOf>
    <name>阿里云谷歌仓库</name>
    <url>https://maven.aliyun.com/repository/google</url>
</mirror>
<mirror>
    <id>aliyunmaven</id>
    <mirrorOf>*</mirrorOf>
    <name>阿里云阿帕奇仓库</name>
    <url>https://maven.aliyun.com/repository/apache-snapshots</url>
</mirror>
<mirror>
    <id>aliyunmaven</id>
    <mirrorOf>*</mirrorOf>
    <name>阿里云 spring 仓库</name>
    <url>https://maven.aliyun.com/repository/spring</url>
</mirror>
<mirror>
    <id>aliyunmaven</id>
    <mirrorOf>*</mirrorOf>
    <name>阿里云 spring 插件仓库</name>
    <url>https://maven.aliyun.com/repository/spring-plugin</url>
</mirror>
```

## Docker 安装 MySQL

```shell
docker run \
--name mysql57 \
-p 3306:3306 \
-v /home/wangshuo/Data/docker/mysql57/conf:/etc/mysql/conf.d \
-v /home/wangshuo/Data/docker/mysql57/data:/var/lib/mysql \
-v /home/wangshuo/Data/docker/mysql57/log:/var/log/mysql \
-e MYSQL_ROOT_PASSWORD=root -d mysql:5.7
```

## lombok

1. 安装插件

2. 引入 jar 包

   ```xml
   <dependency>
       <groupId>org.projectlombok</groupId>
       <artifactId>lombok</artifactId>
   </dependency>
   ```

## SpringBoot 整合 Mybatis

1. 引入依赖

   ```xml
   <dependency>
       <groupId>org.mybatis.spring.boot</groupId>
       <artifactId>mybatis-spring-boot-starter</artifactId>
   </dependency>
   ```

2. 使用 `@MapperScan` 扫描指定包下所有 Mapper，或者使用 `@Mapper` 注解标注所有 Mapper 接口

3. 配置文件中添加 mapper.xml 的路径配置

   ```yaml
   mybatis:
     mapper-locations:
       - classpath:/com/example/dongbaoums/mapper/xml/*.xml
     # 设置开启自动驼峰命名规则映射（将表字段中的下划线自动映射为实体类中的驼峰格式）
     configuration:
       map-underscore-to-camel-case: true
   ```

4. 如果 mapper.xml 不在 resources 目录下，需要将 mapper.xml 文件添加到编译路径

   ```xml
   <!-- 如果 mapper.xml 不是在 resources 目录下，而是在 src/main/java 下，需要添加该配置，否则编译的时候找不到该 xml，会报错 -->
   <build>
       <resources>
           <resource>
               <directory>src/main/resources</directory>
           </resource>
           <resource>
               <directory>src/main/java</directory>
               <includes>
                   <include>**/*.xml</include>
               </includes>
           </resource>
       </resources>
   </build>
   ```

4. 如果使用了 mybatis-plus 生成的代码，还需要添加如下依赖

   ```xml
   <dependency>
       <groupId>com.baomidou</groupId>
       <artifactId>mybatis-plus-boot-starter</artifactId>
   </dependency>
   
   <dependency>
       <groupId>com.baomidou</groupId>
       <artifactId>mybatis-plus-extension</artifactId>
       <scope>compile</scope>
   </dependency>
   ```
   
6. 如果使用了 mybatis-plus，调用 mapper 的方法时报 `Invalid bound statement (not found)` 错误，还需要添加如下配置

   ```yaml
   mybatis-plus:
     configuration:
       log-impl: org.apache.ibatis.logging.stdout.StdOutImpl
     global-config:
       db-config:
         logic-delete-value: 1
         logic-not-delete-value: 0
     mapper-locations:
       - classpath:/com/example/dongbao/ums/mapper/xml/*.xml
   ```

## mybatis-plus 代码生成器

1. 添加依赖

   ```xml
   <!--代码生成器配置 https://mybatis.plus/guide/generator.html#%E4%BD%BF%E7%94%A8%E6%95%99%E7%A8%8B-->
   <!-- mybatis plus -->
   <dependency>
       <groupId>com.baomidou</groupId>
       <artifactId>mybatis-plus-boot-starter</artifactId>
       <version>${mybatis-plus-boot-starter.version}</version>
   </dependency>
   <!-- 代码生成器 -->
   <dependency>
       <groupId>com.baomidou</groupId>
       <artifactId>mybatis-plus-generator</artifactId>
       <version>${mybatis-plus-generator.version}</version>
   </dependency>
   <!-- 模板引擎 -->
   <dependency>
       <groupId>org.apache.velocity</groupId>
       <artifactId>velocity-engine-core</artifactId>
       <version>${velocity-engine-core.version}</version>
   </dependency>
   ```

2. 代码生成器主类

   ```java
   package org.example.dongbaogenerator;
   
   import com.baomidou.mybatisplus.annotation.FieldFill;
   import com.baomidou.mybatisplus.annotation.IdType;
   import com.baomidou.mybatisplus.generator.AutoGenerator;
   import com.baomidou.mybatisplus.generator.config.DataSourceConfig;
   import com.baomidou.mybatisplus.generator.config.GlobalConfig;
   import com.baomidou.mybatisplus.generator.config.PackageConfig;
   import com.baomidou.mybatisplus.generator.config.StrategyConfig;
   import com.baomidou.mybatisplus.generator.config.po.TableFill;
   import com.baomidou.mybatisplus.generator.config.rules.DateType;
   import com.baomidou.mybatisplus.generator.config.rules.NamingStrategy;
   
   import java.util.ArrayList;
   
   /**
    * @author wangshuo
    * @date 2021/01/27
    */
   public class DongbaoGenerator {
   
       public static void main(String[] args) {
           // 代码生成器
           AutoGenerator mpg = new AutoGenerator();
   
           // 全局配置，设置生成文件的输出路径以及格式等信息
           GlobalConfig gc = new GlobalConfig();
           // 设置输出文件夹
           gc.setOutputDir("/home/wangshuo/Projects/mashibing/dongbao-mall/dongbao-mall-parent-v1/dongbao-service/dongbao-ums/src/main/java");
           gc.setAuthor("wangshuo");
           gc.setOpen(false);
           gc.setFileOverride(true);
           // 去掉 Service 的 I 前缀
           gc.setServiceName("%sService");
           gc.setIdType(IdType.ASSIGN_ID);
           gc.setDateType(DateType.ONLY_DATE);
           // 实体属性 Swagger2 注解
           gc.setSwagger2(false);
   
           mpg.setGlobalConfig(gc);
   
           // 数据源配置
           DataSourceConfig dsc = new DataSourceConfig();
           dsc.setUrl("jdbc:mysql://localhost:3306/dongbao_mall_v1?useUnicode=true&useSSL=false&characterEncoding=utf8");
           // dsc.setSchemaName("public");
           dsc.setDriverName("com.mysql.cj.jdbc.Driver");
           dsc.setUsername("root");
           dsc.setPassword("root");
           mpg.setDataSource(dsc);
   
           // 包配置
           PackageConfig pc = new PackageConfig();
   //        pc.setModuleName(scanner("模块名"));
           pc.setParent("com.example.dongbao.ums");
           pc.setEntity("entity");
           pc.setMapper("mapper");
           pc.setController("controller");
           mpg.setPackageInfo(pc);
   
           StrategyConfig sc = new StrategyConfig();
           // 表名
           sc.setInclude("ums_member");
           // 下划线转驼峰
           sc.setNaming(NamingStrategy.underline_to_camel);
           // 列 下划线转驼峰
           sc.setColumnNaming(NamingStrategy.underline_to_camel);
           // 开启 lombok
           sc.setEntityLombokModel(true);
           sc.setLogicDeleteFieldName("deleted");
   
           // 自动填充
           TableFill gmtCreate = new TableFill("gmt_create", FieldFill.INSERT);
           TableFill gmtModify = new TableFill("gmt_modified", FieldFill.INSERT_UPDATE);
           ArrayList<TableFill> tableFills = new ArrayList<TableFill>();
           tableFills.add(gmtCreate);
           tableFills.add(gmtModify);
   
           sc.setTableFillList(tableFills);
   
           // 乐观锁
           sc.setVersionFieldName("version");
   
           // restcontroller
           sc.setRestControllerStyle(true);
           // localhost:xxx/hello_2
           sc.setControllerMappingHyphenStyle(true);
   
           mpg.setStrategy(sc);
   
           mpg.execute();
       }
   
   }
   ```

   ## 创建数据库

   ```mysql
   CREATE TABLE `ums_member` (
       `id` bigint(20) NOT NULL AUTO_INCREMENT,
       `username` varchar(64) DEFAULT NULL,
       `password` varchar(64) DEFAULT NULL,
       `icon` varchar(500) DEFAULT NULL COMMENT '头像',
       `email` varchar(100) DEFAULT NULL COMMENT '邮箱',
       `nick_name` varchar(200) DEFAULT NULL COMMENT '昵称',
       `note` varchar(500) DEFAULT NULL COMMENT '备注信息',
       `gmt_create` datetime DEFAULT NULL COMMENT '创建时间',
       `gmt_modified` datetime DEFAULT NULL COMMENT '更新时间',
       `login_time` datetime DEFAULT NULL COMMENT '最后登录时间',
       `status` int(1) DEFAULT '1' COMMENT '帐号启用状态：0->禁用；1->启用',
       PRIMARY KEY (`id`),
       UNIQUE KEY `un_name` (`username`) USING BTREE COMMENT '用户名唯一'
   ) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8mb4 COMMENT='后台用户表';
   ```

   **注意事项**

   1. 表必备的三个字段：id，gmt_create，gmt_modified

   2. 更新时间的默认设置，不要让数据库来控制

   3. 创建时间和更新时间，用 Mybatis Plus 的 `MetaObjectHandler` 控制

      添加 Handler

      ```java
      package com.example.dongbao.ums.handler;
      
      import com.baomidou.mybatisplus.core.handlers.MetaObjectHandler;
      import org.apache.ibatis.reflection.MetaObject;
      import org.springframework.stereotype.Component;
      
      import java.util.Date;
      
      @Component
      public class MyMetaObjectHandler implements MetaObjectHandler {
      
          @Override
          public void insertFill(MetaObject metaObject) {
              System.out.println("insert 时，添加创建和更新时间");
              this.setFieldValByName("gmtCreate", new Date(), metaObject);
              this.setFieldValByName("gmtModified", new Date(), metaObject);
          }
      
          @Override
          public void updateFill(MetaObject metaObject) {
              System.out.println("update 的时候，添加更新时间");
              this.setFieldValByName("gmtModified", new Date(), metaObject);
      
          }
      }
      ```

      在实体类的创建和更新字段添加注解

      ```java
      /**
       * 创建时间
       */
      @TableField(fill = FieldFill.INSERT)
      private Date gmtCreate;
      
      /**
       * 更新时间
       */
      @TableField(fill = FieldFill.INSERT_UPDATE)
      private Date gmtModified;
      ```

   4. Mybatis Plus 更新数据的原理

      ```xml
      <if 字段!=null>
      字段=#{字段值}
      </if>
      ```

## maven 本地打包的时候跳过测试代码

```xml
<plugins>
    <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-surefire-plugin</artifactId>
        <configuration>
            <skip>true</skip>
        </configuration>
    </plugin>
</plugins>
```
