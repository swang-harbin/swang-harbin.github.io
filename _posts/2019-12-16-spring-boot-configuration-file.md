---
layout: post
title: Spring Boot配置文件
subheading:
author: swang-harbin
categories: java
banner:
tags: spring-boot java
---

# 二. Spring Boot配置文件

## 2.1 配置文件

Spring Boot使用一个全局的配置文件, 配置文件名是固定的;

- application.properties
- application.yml

配置文件的作用 : 修改SpringBoot自动配置的默认值;

YAML(YAML Ain't Markup Language)

- YAML A Markup Language : 是一种标记语言
- YAML isn't Markup Language : 不是标记语言

标记语言 :

- 以前的配置文件, 大多都是用xxx.xml文件
- YAML : 以数据为中心, 比json, xml等更适合做配置文件

```yaml
# YAML配置例子
server:
  port: 8081
# 注意: port:与8081之间需要有一个空格

# XML配置的例子
#<server>
#    <port>8081</port>
#</server>
```

## 2.2 YAML语法:

### 2.2.1 基本语法

k:(空格)v : 表示一堆键值对(空格必须有)

以**空格**的缩进来控制层级关系; 只要左对齐的一列数据, 都是同一层级的

```yaml
server: 
  port: 8081
  path: /hello
```

属性和值也是大小写敏感的

### 2.2.2 值的写法

#### 字面量 : 普通的值(数字, 字符串, 布尔)

`k: v `: 字面量直接来写, 字符串默认不用加上单双引号

`""`(双引号) : 不会转义字符串里面的特殊字符, 特殊字符会作为本身想表示的意思

```yaml
# 输出: zhangsan 换行 lisi
name: "zhangsan \n lisi"
```

`''`(单引号) : 会转义特殊字符, 特殊字符最终只是一个普通的字符串数据

```yaml
# 输出: zhangsan \n lisi
name: 'zhangsan \n lisi'
```

#### 对象(属性和值), Map(键值对) :

`k: v` : 在下一行来写对象的属性和值的关系, 注意缩进

```yaml
# 对象还是k: v的方式
friends:
  lastName: zhangsan
  age: 20
```

行内写法:

```yaml
friends: {lastName: zhangsan,age: 10}
```

#### 数组(List, Set) :

用`-`值表示数组中的一个元素

```yaml
pets:
  - cat
  - dog
  - pig
```

行内写法

```yaml
pets: {cat,dog,pig}
```

### 2.2.3 配置文件值注入

配置文件

```yaml
person:
  lastName: zhangsan
  age: 20
  boss: false
  birth: 2019/11/27
  maps: {k1: v1, k2: 12}
  lists:
    - lisi
    - zhaoliu
  dog:
    name: 小狗
    age: 2
```

javaBean

```java
/**
 * 将配置文件中配置的每一个属性的值, 映射到这个组件中
 * @ConfigurationProperties 告诉SpringBoot将本类中的所有属性和配置文件中相关的配置进行绑定
 * prefix = "person" : 和配置文件中哪个下面的所有属性进行一一映射
 *
 * 只有这个组件是容器中的组件, 才能使用容器提供的@ConfigurationProperties功能
 */
@Component
@ConfigurationProperties(prefix = "person")
public class Person {
    private String lastName;
    private Integer age;
    private Boolean boss;
    private Date birth;

    private Map<String, String> maps;
    private List<Object> lists;
    private Dog dog;
```

我们可以导入配置文件处理器, 以后编写配置就有提示了

```xml
<!--导入配置文件处理器, 配置文件进行绑定就会有提示-->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-configuration-processor</artifactId>
    <optional>true</optional>
</dependency>
```

`lastName: 张三` 和 `last-name: 张三` 是一样的

#### 2.2.3.1 properties配置乱码问题

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222005022.png)

#### 2.2.3.2 @Value获取值和@ConfigurationProperties获取值比较

| -                  | @ConfigurationProperties | @Value     |
| ------------------ | ------------------------ | ---------- |
| 功能               | 批量注入配置文件中的属性 | 一个个指定 |
| 松散绑定(松散语法) | 支持                     | 不支持     |
| SpEL               | 不支持                   | 支持       |
| JSR303数据校验     | 支持                     | 不支持     |
| 复杂类型封装       | 支持                     | 不支持     |

配置文件yml还是properties他们都能获取到值

如果, 只是在某个业务逻辑中需要获取一下某个属性的值, 用`@Value`

如果, 专门编写了一个JavaBean来和配置文件进行映射, 我们就直接使用`@ConfigurationProperties`

#### 2.2.3.3 配置文件注入值数据校验

```java
@Component
@ConfigurationProperties(prefix = "person")
@Validated
public class Person {

    /**
     * <bean class="Person"
     *      <property name="lastName" value="字面量/${key}从环境变量,配置文件中获取值/#{SpEL}"></property>
     */
    // @Value("${person.lastName}")
    // lastName必须为邮箱格式
    @Email
    private String lastName;
    @Value("#{11 * 2}")
    private Integer age;
    @Value("true")
    private Boolean boss;
```

#### 2.2.3.4 @PropertySource和@ImportResource

`@ConfigurationProperties`注解默认从全局配置文件中获取值

**@PropertySource** : 加载指定的配置文件

```java
@Component
@ConfigurationProperties(prefix = "person")
@PropertySource(value = {"classpath:person.properties"})
public class Person {
```

**@ImportResource** : 导入Spring的配置文件, 让配置文件里面的内容生效

Spring Boot里面如果没有Spring的配置文件(application.yml/application.properties), 我们自己编写的配置文件, 也不能自动识别, 想让Spring的配置生效, 加载进来, 把`@ImportResource`标注在一个配置类上

```java
// 导入Spring的配置文件让其生效
@ImportResource(value = {"classpath:beans.xml"})
```

SpringBoot推荐使用全注解的方式给容器中添加组件:

- 原始xml方式

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd">

    <bean id="helloService" class="cc.ccue.springboot.bean.HelloService"></bean>
</beans>
```

1. 配置类就相当于Spring配置文件
2. 使用`@Bean`给容器中添加组件

```java
/**
 * @Configuration 指明当前类是一个配置类, 就是来替代之前的Spring配置文件
 */
@Configuration
public class MyAppConfig {

    // 将方法的返回值添加到容器中, 容器中这个组件默认的id就是方法名
    @Bean
    public HelloService helloService(){
        System.out.println("配置类给容器中添加组件了...");
        return new HelloService();
    }
}
```

## 2.4 配置文件占位符

### 2.4.1 随机数

```properties
$(random.value), $(random.int), $(random.long)
$(random.int(10)), $(random.int[1024, 65536])
```

### 2.4.2 占位符获取之前配置的值, 如果没有可以使用:获取默认值

```properties
person.last-name=张三${random.uuid}
person.age=${random.int}
person.birth=2017/12/15
person.boss=false
person.maps.k1=v1
person.maps.k2=v2
person.lists=a,b,c
person.dog.name=${person.hello:hello}_dog
person.dog.age=15
```

## 2.5 Profile

Profile是Spring对不同环境提供不同配置功能的支持, 可以通过激活, 指定参数等方式快速切换环境

### 2.5.1 多Profile文件

在主配置文件编写的时候, 文件名可以是application-{profile}.properties/yml

默认使用application.properties/yml的配置

### 2.5.2 yml支持多文档块方式

```yaml
server:
  port: 8081
spring:
  profiles:
    active: dev
---
server:
  port: 8083
spring:
  profiles: dev
---
server:
  port: 8084
spring:
  # 指定属于哪个环境
  profiles: prod
```

### 2.5.3 激活指定profile

1. 在配置文件中指定`spring.profiles.active=dev`
2. 命令行:

```shell
java -jar spring-boot-02-config-0.0.1-SNAPSHOT.jar --spring.profiles.active=dev
```

1. 虚拟机参数

```shell
-Dspring.profiles.active=dev
```

在IDEA中配置参数 

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222010736.png)

### 2.5.3 在一个yml中引入其他yml

SpringBoot只支持加载**application-xx.yml**格式的yml文件, 如果需要加载多个yml, 可使用如下方式

```yaml
spring:
  profiles:
    include:
      login,datasource,dubbo
```

## 2.6 配置文件加载位置

SpringBoot启动会扫描以下位置的application.properties或者application.yml文件作为SpringBoot的默认配置文件

- `src:./config/`
- `src:./`
- `classpath:/config/`
- `classpath:/`

以上是按照**优先级从高到低**的顺序, 所有位置的文件都会被加载, **高优先级**配置会**覆盖低优先级**配置, **互补配置**

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222011006.png)

我们还可以通过配置`spring.config.location`来改变默认的配置

> 项目打包好后, 我们可以使用命令行参数的形式, 在启动项目的时候指定配置文件的新位置, 指定的配置文件和默认加载的这些配置文件会共同起作用, 形成互补配置, 此处指定的配置文件优先级最高

## 2.7 外部配置加载顺序

Spring Boot支持多种外部配置方式, 如下常用配置优先级从高到低, 高优先级的配置会覆盖低优先级配置, 所有配置形成互补配置

1. 命令行参数

```shell
# 此时则使用8082端口, 多个参数按空格分开; 格式 : --配置项=值
java -jar spring-boot-xx-SNAPSHOT.jar --server.port=8082
```

1. 来自java:comp/env的JNDI属性
2. java系统属性
3. 操作系统环境变量
4. RandomValuePropertySource配置的random.*属性值

**由jar包外向jar包内进行寻找**

**优先加载带profile**

1. jar包外部的application-{profile}.properties或application.yml(带spring.profile)配置文件
2. jar包内部的application-{profile}.properties或application.yml(带spring.profile)配置文件

**再加载不带profile**

1. jar包外部的application.properties或application.yml(不带spring.profile)配置文件
2. jar包外部的application.properties或application.yml(不带spring.profile)配置文件
3. @Configuration注解类上的@PropertySource
4. 通过SpringApplication.setDefaultProperties指定的默认属性

更多配置详见 [官方文档](https://docs.spring.io/spring-boot/docs/2.2.2.BUILD-SNAPSHOT/reference/html/spring-boot-features.html#boot-features-external-config)

## 2.8 自动配置原理

配置文件能配置的属性, 参照[官方 Common Application properties](https://docs.spring.io/spring-boot/docs/2.2.2.BUILD-SNAPSHOT/reference/html/appendix-application-properties.html#common-application-properties)

### 2.8.1 自动配置原理:

1. SpringBoot在启动时加载主配置类, 开启了自动配置功能==@EnableAutoConfiguration==

2. @EnableAutoConfiguration作用:

   - 利用AutoConfigurationImportSelector给容器中导入一些组件?

   - 可以查看selectImports()方法的内容;

   - List\<String\> configurations = getCandidateConfigurations(annotationMetadata, attributes); 获取候选的配置

     > SpringFactoriesLoader.loadFactoryNames()
     > 扫描所有jar包类路径(META-INF)下的spring.factories文件
     > 把扫描到的这些文件的内容包装成Properties对象
     > 从properties中获取到EnableAutoConfiguration.class类(类名)对应的值, 然后添加在容器中

   **将类路径下META-INF/spring.factories里面配置的所有EnableAutoConfiguration的值加入到容器中**

   ```properties
   # Auto Configure
   org.springframework.boot.autoconfigure.EnableAutoConfiguration=\
   org.springframework.boot.autoconfigure.admin.SpringApplicationAdminJmxAutoConfiguration,\
   org.springframework.boot.autoconfigure.aop.AopAutoConfiguration,\
   org.springframework.boot.autoconfigure.amqp.RabbitAutoConfiguration,\
   org.springframework.boot.autoconfigure.batch.BatchAutoConfiguration,\
   org.springframework.boot.autoconfigure.cache.CacheAutoConfiguration,\
   org.springframework.boot.autoconfigure.cassandra.CassandraAutoConfiguration,\
   org.springframework.boot.autoconfigure.cloud.CloudServiceConnectorsAutoConfiguration,\
   org.springframework.boot.autoconfigure.context.ConfigurationPropertiesAutoConfiguration,\
   org.springframework.boot.autoconfigure.context.MessageSourceAutoConfiguration,\
   org.springframework.boot.autoconfigure.context.PropertyPlaceholderAutoConfiguration,\
   org.springframework.boot.autoconfigure.couchbase.CouchbaseAutoConfiguration,\
   org.springframework.boot.autoconfigure.dao.PersistenceExceptionTranslationAutoConfiguration,\
   org.springframework.boot.autoconfigure.data.cassandra.CassandraDataAutoConfiguration,\
   org.springframework.boot.autoconfigure.data.cassandra.CassandraReactiveDataAutoConfiguration,\
   org.springframework.boot.autoconfigure.data.cassandra.CassandraReactiveRepositoriesAutoConfiguration,\
   org.springframework.boot.autoconfigure.data.cassandra.CassandraRepositoriesAutoConfiguration,\
   org.springframework.boot.autoconfigure.data.couchbase.CouchbaseDataAutoConfiguration,\
   org.springframework.boot.autoconfigure.data.couchbase.CouchbaseReactiveDataAutoConfiguration,\
   org.springframework.boot.autoconfigure.data.couchbase.CouchbaseReactiveRepositoriesAutoConfiguration,\
   org.springframework.boot.autoconfigure.data.couchbase.CouchbaseRepositoriesAutoConfiguration,\
   org.springframework.boot.autoconfigure.data.elasticsearch.ElasticsearchAutoConfiguration,\
   org.springframework.boot.autoconfigure.data.elasticsearch.ElasticsearchDataAutoConfiguration,\
   org.springframework.boot.autoconfigure.data.elasticsearch.ElasticsearchRepositoriesAutoConfiguration,\
   org.springframework.boot.autoconfigure.data.elasticsearch.ReactiveElasticsearchRepositoriesAutoConfiguration,\
   org.springframework.boot.autoconfigure.data.elasticsearch.ReactiveRestClientAutoConfiguration,\
   org.springframework.boot.autoconfigure.data.jdbc.JdbcRepositoriesAutoConfiguration,\
   org.springframework.boot.autoconfigure.data.jpa.JpaRepositoriesAutoConfiguration,\
   org.springframework.boot.autoconfigure.data.ldap.LdapRepositoriesAutoConfiguration,\
   org.springframework.boot.autoconfigure.data.mongo.MongoDataAutoConfiguration,\
   org.springframework.boot.autoconfigure.data.mongo.MongoReactiveDataAutoConfiguration,\
   org.springframework.boot.autoconfigure.data.mongo.MongoReactiveRepositoriesAutoConfiguration,\
   org.springframework.boot.autoconfigure.data.mongo.MongoRepositoriesAutoConfiguration,\
   org.springframework.boot.autoconfigure.data.neo4j.Neo4jDataAutoConfiguration,\
   org.springframework.boot.autoconfigure.data.neo4j.Neo4jRepositoriesAutoConfiguration,\
   org.springframework.boot.autoconfigure.data.solr.SolrRepositoriesAutoConfiguration,\
   org.springframework.boot.autoconfigure.data.redis.RedisAutoConfiguration,\
   org.springframework.boot.autoconfigure.data.redis.RedisReactiveAutoConfiguration,\
   org.springframework.boot.autoconfigure.data.redis.RedisRepositoriesAutoConfiguration,\
   org.springframework.boot.autoconfigure.data.rest.RepositoryRestMvcAutoConfiguration,\
   org.springframework.boot.autoconfigure.data.web.SpringDataWebAutoConfiguration,\
   org.springframework.boot.autoconfigure.elasticsearch.jest.JestAutoConfiguration,\
   org.springframework.boot.autoconfigure.elasticsearch.rest.RestClientAutoConfiguration,\
   org.springframework.boot.autoconfigure.flyway.FlywayAutoConfiguration,\
   org.springframework.boot.autoconfigure.freemarker.FreeMarkerAutoConfiguration,\
   org.springframework.boot.autoconfigure.gson.GsonAutoConfiguration,\
   org.springframework.boot.autoconfigure.h2.H2ConsoleAutoConfiguration,\
   org.springframework.boot.autoconfigure.hateoas.HypermediaAutoConfiguration,\
   org.springframework.boot.autoconfigure.hazelcast.HazelcastAutoConfiguration,\
   org.springframework.boot.autoconfigure.hazelcast.HazelcastJpaDependencyAutoConfiguration,\
   org.springframework.boot.autoconfigure.http.HttpMessageConvertersAutoConfiguration,\
   org.springframework.boot.autoconfigure.http.codec.CodecsAutoConfiguration,\
   org.springframework.boot.autoconfigure.influx.InfluxDbAutoConfiguration,\
   org.springframework.boot.autoconfigure.info.ProjectInfoAutoConfiguration,\
   org.springframework.boot.autoconfigure.integration.IntegrationAutoConfiguration,\
   org.springframework.boot.autoconfigure.jackson.JacksonAutoConfiguration,\
   org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration,\
   org.springframework.boot.autoconfigure.jdbc.JdbcTemplateAutoConfiguration,\
   org.springframework.boot.autoconfigure.jdbc.JndiDataSourceAutoConfiguration,\
   org.springframework.boot.autoconfigure.jdbc.XADataSourceAutoConfiguration,\
   org.springframework.boot.autoconfigure.jdbc.DataSourceTransactionManagerAutoConfiguration,\
   org.springframework.boot.autoconfigure.jms.JmsAutoConfiguration,\
   org.springframework.boot.autoconfigure.jmx.JmxAutoConfiguration,\
   org.springframework.boot.autoconfigure.jms.JndiConnectionFactoryAutoConfiguration,\
   org.springframework.boot.autoconfigure.jms.activemq.ActiveMQAutoConfiguration,\
   org.springframework.boot.autoconfigure.jms.artemis.ArtemisAutoConfiguration,\
   org.springframework.boot.autoconfigure.groovy.template.GroovyTemplateAutoConfiguration,\
   org.springframework.boot.autoconfigure.jersey.JerseyAutoConfiguration,\
   org.springframework.boot.autoconfigure.jooq.JooqAutoConfiguration,\
   org.springframework.boot.autoconfigure.jsonb.JsonbAutoConfiguration,\
   org.springframework.boot.autoconfigure.kafka.KafkaAutoConfiguration,\
   org.springframework.boot.autoconfigure.ldap.embedded.EmbeddedLdapAutoConfiguration,\
   org.springframework.boot.autoconfigure.ldap.LdapAutoConfiguration,\
   org.springframework.boot.autoconfigure.liquibase.LiquibaseAutoConfiguration,\
   org.springframework.boot.autoconfigure.mail.MailSenderAutoConfiguration,\
   org.springframework.boot.autoconfigure.mail.MailSenderValidatorAutoConfiguration,\
   org.springframework.boot.autoconfigure.mongo.embedded.EmbeddedMongoAutoConfiguration,\
   org.springframework.boot.autoconfigure.mongo.MongoAutoConfiguration,\
   org.springframework.boot.autoconfigure.mongo.MongoReactiveAutoConfiguration,\
   org.springframework.boot.autoconfigure.mustache.MustacheAutoConfiguration,\
   org.springframework.boot.autoconfigure.orm.jpa.HibernateJpaAutoConfiguration,\
   org.springframework.boot.autoconfigure.quartz.QuartzAutoConfiguration,\
   org.springframework.boot.autoconfigure.rsocket.RSocketMessagingAutoConfiguration,\
   org.springframework.boot.autoconfigure.rsocket.RSocketRequesterAutoConfiguration,\
   org.springframework.boot.autoconfigure.rsocket.RSocketServerAutoConfiguration,\
   org.springframework.boot.autoconfigure.rsocket.RSocketStrategiesAutoConfiguration,\
   org.springframework.boot.autoconfigure.security.servlet.SecurityAutoConfiguration,\
   org.springframework.boot.autoconfigure.security.servlet.UserDetailsServiceAutoConfiguration,\
   org.springframework.boot.autoconfigure.security.servlet.SecurityFilterAutoConfiguration,\
   org.springframework.boot.autoconfigure.security.reactive.ReactiveSecurityAutoConfiguration,\
   org.springframework.boot.autoconfigure.security.reactive.ReactiveUserDetailsServiceAutoConfiguration,\
   org.springframework.boot.autoconfigure.security.rsocket.RSocketSecurityAutoConfiguration,\
   org.springframework.boot.autoconfigure.security.saml2.Saml2RelyingPartyAutoConfiguration,\
   org.springframework.boot.autoconfigure.sendgrid.SendGridAutoConfiguration,\
   org.springframework.boot.autoconfigure.session.SessionAutoConfiguration,\
   org.springframework.boot.autoconfigure.security.oauth2.client.servlet.OAuth2ClientAutoConfiguration,\
   org.springframework.boot.autoconfigure.security.oauth2.client.reactive.ReactiveOAuth2ClientAutoConfiguration,\
   org.springframework.boot.autoconfigure.security.oauth2.resource.servlet.OAuth2ResourceServerAutoConfiguration,\
   org.springframework.boot.autoconfigure.security.oauth2.resource.reactive.ReactiveOAuth2ResourceServerAutoConfiguration,\
   org.springframework.boot.autoconfigure.solr.SolrAutoConfiguration,\
   org.springframework.boot.autoconfigure.task.TaskExecutionAutoConfiguration,\
   org.springframework.boot.autoconfigure.task.TaskSchedulingAutoConfiguration,\
   org.springframework.boot.autoconfigure.thymeleaf.ThymeleafAutoConfiguration,\
   org.springframework.boot.autoconfigure.transaction.TransactionAutoConfiguration,\
   org.springframework.boot.autoconfigure.transaction.jta.JtaAutoConfiguration,\
   org.springframework.boot.autoconfigure.validation.ValidationAutoConfiguration,\
   org.springframework.boot.autoconfigure.web.client.RestTemplateAutoConfiguration,\
   org.springframework.boot.autoconfigure.web.embedded.EmbeddedWebServerFactoryCustomizerAutoConfiguration,\
   org.springframework.boot.autoconfigure.web.reactive.HttpHandlerAutoConfiguration,\
   org.springframework.boot.autoconfigure.web.reactive.ReactiveWebServerFactoryAutoConfiguration,\
   org.springframework.boot.autoconfigure.web.reactive.WebFluxAutoConfiguration,\
   org.springframework.boot.autoconfigure.web.reactive.error.ErrorWebFluxAutoConfiguration,\
   org.springframework.boot.autoconfigure.web.reactive.function.client.ClientHttpConnectorAutoConfiguration,\
   org.springframework.boot.autoconfigure.web.reactive.function.client.WebClientAutoConfiguration,\
   org.springframework.boot.autoconfigure.web.servlet.DispatcherServletAutoConfiguration,\
   org.springframework.boot.autoconfigure.web.servlet.ServletWebServerFactoryAutoConfiguration,\
   org.springframework.boot.autoconfigure.web.servlet.error.ErrorMvcAutoConfiguration,\
   org.springframework.boot.autoconfigure.web.servlet.HttpEncodingAutoConfiguration,\
   org.springframework.boot.autoconfigure.web.servlet.MultipartAutoConfiguration,\
   org.springframework.boot.autoconfigure.web.servlet.WebMvcAutoConfiguration,\
   org.springframework.boot.autoconfigure.websocket.reactive.WebSocketReactiveAutoConfiguration,\
   org.springframework.boot.autoconfigure.websocket.servlet.WebSocketServletAutoConfiguration,\
   org.springframework.boot.autoconfigure.websocket.servlet.WebSocketMessagingAutoConfiguration,\
   org.springframework.boot.autoconfigure.webservices.WebServicesAutoConfiguration,\
   org.springframework.boot.autoconfigure.webservices.client.WebServiceTemplateAutoConfiguration
   ```

   每一个`xxxAutoConfiguration`类都是容器中的一个组件, 都加入到容器中; 用它们来做自动配置;

3. 每一个自动配置类进行自动配置功能

4. 以**HttpEncodingAutoConfiguration**为例, 解释自动配置原理

   ```java
   @Configuration(proxyBeanMethods = false) // 表示这是一个配置类, 以前编写的配置文件一样, 也可以给容器中添加组件
   @EnableConfigurationProperties(HttpProperties.class) // 启动指定类的ConfigurationProperties功能, 将配置文件中对应的值和HttpProperties绑定起来, 并把HttpProperties加入到IOC容器中
   @ConditionalOnWebApplication(type = ConditionalOnWebApplication.Type.SERVLET)// spring底层@Conditional注解, 根据不同的条件, 如果满足指定的条件, 整个配置类里面的配置就会生效; 判断当前应用是否是SERVLET应用, 如果是, 当前配置类生效
   @ConditionalOnClass(CharacterEncodingFilter.class) // 判断当前项目有无CharacterEncodingFilter类; SpringMVC中解决乱码的过滤器
   @ConditionalOnProperty(prefix = "spring.http.encoding", value = "enabled", matchIfMissing = true) // 判断配置文件中是否存在某个配置spring.http.encoding.enabled; 如果不存在, 判断也是成立的.
   public class HttpEncodingAutoConfiguration {
       
       // 已经和SpringBoot的配置文件映射了
       private final HttpProperties.Encoding properties;
       
       // 只有一个有参构造器的情况下, 参数的值就会从容器中拿
       public HttpEncodingAutoConfiguration(HttpProperties properties) {
   	    this.properties = properties.getEncoding();
       }
       
   	@Bean // 给容器中添加一个组件, 这个组件的某些值需要从properties中获取
   	@ConditionalOnMissingBean
   	public CharacterEncodingFilter characterEncodingFilter() {
   		CharacterEncodingFilter filter = new OrderedCharacterEncodingFilter();
   		filter.setEncoding(this.properties.getCharset().name());
   		filter.setForceRequestEncoding(this.properties.shouldForce(Type.REQUEST));
   		filter.setForceResponseEncoding(this.properties.shouldForce(Type.RESPONSE));
   		return filter;
   }
   ```

   根据当前不同的条件判断, 决定这个配置类是否生效.

   一旦这个配置类生效: 这个配置类就会给容器中添加各种组件, 这些组件的属性是从对应的properties类中获取的, 而这些类中的每一个属性又是和配置文件绑定的

5. 所有在配置文件中能配置的属性都是在xxxProperties类中封装着, 配置文件能配置什么就可以参照某个功能对应的这个属性类

   ```java
   // 从配置文件中获取指定的值和bean的属性进行绑定
   @ConfigurationProperties(prefix = "spring.http")
   public class HttpProperties {
   ```

**SpringBoot的精髓:**

**1. SpringBoot启动会加载大量的自动配置类;**

**2. 我们看我们需要的功能有没有SpringBoot默认写好的配置类;**

**3. 再看这个配置类中到底配置来了哪些组件;(只要有需要用的组件, 就不需要再来配置了)**

**4. 给容器中自动配置类添加组件的时候, 会从properties类中获取某些属性. 我们就可以在配置文件中指定这些属性的值;**

### 2.8.2 细节

1. @Conditional派生注解(Spring注解版原生的@Conditional作用) 作用: 必须是@Conditional指定的条件成立, 才给容器中添加组件, 配置类里的内容才生效

   [boot-features-condition-annotations](https://docs.spring.io/spring-boot/docs/2.2.2.RELEASE/reference/html/spring-boot-features.html#boot-features-condition-annotations)

   | @Conditional扩展注解            | 作用                                             |
   | ------------------------------- | ------------------------------------------------ |
   | @ConditionalOnJava              | 系统Java版本是否符合要求                         |
   | @ConditionalOnBean              | 容器中存在指定的Bean                             |
   | @ConditionalMissingBean         | 容器中不存在指定的Bean                           |
   | @ConditionalOnExpression        | 满足SpEL表达式指定                               |
   | @ConditionalOnClass             | 系统中有指定类                                   |
   | @ConditionalMissingClass        | 系统中没有指定类                                 |
   | @ConditionalOnSingleCandidate   | 容器中只有一个指定的Bean, 或者这个Bean是首选Bean |
   | @ConditionalOnProperty          | 系统中指定的属性是否有指定的值                   |
   | @ConditionalOnWebApplication    | 当前是web环境                                    |
   | @ConditionalOnNotWebApplication | 当前不是web环境                                  |
   | @ConditionalOnJndi              | JNDI存在指定项                                   |

   **自动配置类必须在一定的条件下才能生效**

   我们怎么知道哪些自动配置类生效了? 可以通过在配置文件中配置`debug=true`, 将自动配置报告打印到控制台, 这样我们就可以很方便的知道哪些自动配置类生效.

   ```
   ============================
   CONDITIONS EVALUATION REPORT
   ============================
   
   
   Positive matches:
   -----------------
   
      AopAutoConfiguration matched:
         - @ConditionalOnProperty (spring.aop.auto=true) matched (OnPropertyCondition)
      ......
       
   Negative matches:
   -----------------
   
      ActiveMQAutoConfiguration:
         Did not match:
            - @ConditionalOnClass did not find required class 'javax.jms.ConnectionFactory' (OnClassCondition)
      ......
   ```