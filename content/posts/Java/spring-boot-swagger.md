---
title: Spring Boot添加swagger
date: '2020-09-11 00:00:00'
tags:
- Swagger
- Spring Boot
- Java
---

# Spring Boot添加swagger

maven导包

```xml
<properties>
    <swagger.version>2.9.2</swagger.version>
</properties>

<dependencies>
    <!-- swagger2-->
    <dependency>
        <groupId>io.springfox</groupId>
        <artifactId>springfox-swagger2</artifactId>
        <version>${swagger.version}</version>
    </dependency>

    <!-- swagger2-UI-->
    <dependency>
        <groupId>io.springfox</groupId>
        <artifactId>springfox-swagger-ui</artifactId>
        <version>${swagger.version}</version>
    </dependency>
</dependencies>
```

配置文件

```java
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import springfox.documentation.builders.ApiInfoBuilder;
import springfox.documentation.builders.PathSelectors;
import springfox.documentation.builders.RequestHandlerSelectors;
import springfox.documentation.service.ApiInfo;
import springfox.documentation.service.Contact;
import springfox.documentation.spi.DocumentationType;
import springfox.documentation.spring.web.plugins.Docket;
import springfox.documentation.swagger2.annotations.EnableSwagger2;

/**
 * Swagger2的接口配置
 *
 * @author wangshuo
 */
@Configuration
@EnableSwagger2
public class SwaggerConfig {
    /**
     * 系统基础配置
     */
    @Autowired
    private ProjectMetaConfig projectMetaConfig;

    /**
     * 是否开启swagger
     */
    @Value("${swagger.enabled}")
    private boolean enabled;

    /**
     * 设置请求的统一前缀
     */
    @Value("${swagger.pathMapping}")
    private String pathMapping;

    /**
     * 创建API
     */
    @Bean
    public Docket createRestApi() {
        return new Docket(DocumentationType.SWAGGER_2)
                // 是否启用Swagger
                .enable(enabled)
                // 用来创建该API的基本信息，展示在文档的页面中（自定义展示的信息）
                .apiInfo(apiInfo())
                // 设置哪些接口暴露给Swagger展示
                .select()
                // 扫描所有有注解的api，用这种方式更灵活
                .apis(RequestHandlerSelectors.withMethodAnnotation(ApiOperation.class))
                // 扫描指定包中的swagger注解
//                 .apis(RequestHandlerSelectors.basePackage("cn.piesat.controller"))
                // 扫描所有
                .apis(RequestHandlerSelectors.any())
                .paths(PathSelectors.any())
                .build()
                /* 设置安全模式，swagger可以设置访问token */
//                .securitySchemes(securitySchemes())
//                .securityContexts(securityContexts())
                .pathMapping(pathMapping);
    }
//
//    /**
//     * 安全模式，这里指定token通过Authorization头请求头传递
//     */
//    private List<ApiKey> securitySchemes() {
//        List<ApiKey> apiKeyList = new ArrayList<>();
//        apiKeyList.add(new ApiKey("Authorization", "Authorization", "header"));
//        return apiKeyList;
//    }
//
//    /**
//     * 安全上下文
//     */
//    private List<SecurityContext> securityContexts() {
//        List<SecurityContext> securityContexts = new ArrayList<>();
//        securityContexts.add(
//                SecurityContext.builder()
//                        .securityReferences(defaultAuth())
//                        .forPaths(PathSelectors.regex("^(?!auth).*$"))
//                        .build());
//        return securityContexts;
//    }
//
//    /**
//     * 默认的安全上引用
//     */
//    private List<SecurityReference> defaultAuth() {
//        AuthorizationScope authorizationScope = new AuthorizationScope("global", "accessEverything");
//        AuthorizationScope[] authorizationScopes = new AuthorizationScope[1];
//        authorizationScopes[0] = authorizationScope;
//        List<SecurityReference> securityReferences = new ArrayList<>();
//        securityReferences.add(new SecurityReference("Authorization", authorizationScopes));
//        return securityReferences;
//    }

    /**
     * 添加摘要信息
     */
    private ApiInfo apiInfo() {
        // 用ApiInfoBuilder进行定制
        return new ApiInfoBuilder()
                // 设置标题
                .title("标题: " + projectMetaConfig.getTitle())
                // 描述
                .description("描述:" + projectMetaConfig.getDescription())
                // 作者信息
                .contact(new Contact(projectMetaConfig.getContactName(), projectMetaConfig.getContactUrl(),
                        projectMetaConfig.getContactEmail()))
                // 版本
                .version("版本号:" + projectMetaConfig.getVersion())
                .build();
    }
}
```

```java
package cn.piesat.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

/**
 * 项目源信息
 *
 * @author wangshuo
 * @date 2020/09/10
 */
@Configuration
@ConfigurationProperties(prefix = "proj.meta")
public class ProjectMetaConfig {

    /**
     * 标题
     */
    private String title;
    /**
     * 作者姓名
     */
    private String contactName;
    /**
     * 作者主页
     */
    private String contactUrl;

    /**
     * 作者邮箱
     */
    private String contactEmail;

    /**
     * 项目版本
     */
    private String version;

    /**
     * 项目描述信息
     */
    private String description;
    /**
     * 版权年限
     */
    private String copyrightYear;


    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getContactName() {
        return contactName;
    }

    public void setContactName(String contactName) {
        this.contactName = contactName;
    }

    public String getContactUrl() {
        return contactUrl;
    }

    public void setContactUrl(String contactUrl) {
        this.contactUrl = contactUrl;
    }

    public String getContactEmail() {
        return contactEmail;
    }

    public void setContactEmail(String contactEmail) {
        this.contactEmail = contactEmail;
    }

    public String getVersion() {
        return version;
    }

    public void setVersion(String version) {
        this.version = version;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getCopyrightYear() {
        return copyrightYear;
    }

    public void setCopyrightYear(String copyrightYear) {
        this.copyrightYear = copyrightYear;
    }
}
```

