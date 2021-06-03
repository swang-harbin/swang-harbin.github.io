---
title: Spring Boot与Web开发
date: '2019-12-17 00:00:00'
updated: '2019-12-17 00:00:00'
tags:
- Spring Boot
- Java
categories:
- [Java, SpringBoot基础系列]
---
# Spring Boot与Web开发

[SpringBoot基础系列目录](spring-boot-table.md)

## 简介

**使用SpringBoot:**

1. 创建SpringBoot应用, 选中需要的模块
2. SpringBoot已经默认将这些场景配置好了, 只需要在配置文件中指定少量配置就可以运行起来
3. 自己编写业务代码

**自动配置原理?**

这个场景SpringBoot帮我们配置了什么? 能不能修改? 能修改哪些配置? 能不能扩展? ...

- **xxxAutoConfiguration**: 帮我们给容器中自动配置组件
- **xxxProperties**: 配置类来封装配置文件的内容

## SpringBoot对静态资源的映射规则

SpringBoot跟Web相关的配置都在**WebMvcAutoConfiguration**里

```java
@ConfigurationProperties(prefix = "spring.resources", ignoreUnknownFields = false)
public class ResourceProperties {
    // 可以设置和资源有关的参数, 缓存时间等
    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        if (!this.resourceProperties.isAddMappings()) {
            logger.debug("Default resource handling disabled");
            return;
        }
        Duration cachePeriod = this.resourceProperties.getCache().getPeriod();
        CacheControl cacheControl = this.resourceProperties.getCache().getCachecontrol().toHttpCacheControl();
        if (!registry.hasMappingForPattern("/webjars/**")) {
            customizeResourceHandlerRegistration(registry.addResourceHandler("/webjars/**")
                                                 .addResourceLocations("classpath:/META-INF/resources/webjars/")
                                                 .setCachePeriod(getSeconds(cachePeriod)).setCacheControl(cacheControl));
        }
        String staticPathPattern = this.mvcProperties.getStaticPathPattern();
        if (!registry.hasMappingForPattern(staticPathPattern)) {
            customizeResourceHandlerRegistration(registry.addResourceHandler(staticPathPattern)
                                                 .addResourceLocations(getResourceLocations(this.resourceProperties.getStaticLocations()))
                                                 .setCachePeriod(getSeconds(cachePeriod)).setCacheControl(cacheControl));
        }
    }

    // 配置欢迎页映射
    @Bean
    public WelcomePageHandlerMapping welcomePageHandlerMapping(ApplicationContext applicationContext,
                                                               FormattingConversionService mvcConversionService, ResourceUrlProvider mvcResourceUrlProvider) {
        WelcomePageHandlerMapping welcomePageHandlerMapping = new WelcomePageHandlerMapping(
            new TemplateAvailabilityProviders(applicationContext), applicationContext, getWelcomePage(),
            this.mvcProperties.getStaticPathPattern());
        welcomePageHandlerMapping.setInterceptors(getInterceptors(mvcConversionService, mvcResourceUrlProvider));
        return welcomePageHandlerMapping;
    }
```

1. 所有/webjars/**, 都去/META-INF/resources/webjars/找资源;

   - webjars : 以jar包的方式引入静态资源

   - [webjars官网](https://www.webjars.org/): 可以将常用的前端框架以Maven依赖的方式引入到项目中 ![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210607235730.png)

     测试访问: http://localhost:8080/webjars/jquery/3.4.1/jquery.js

     ```xml
     <!-- 引入jquery-webjars -->
     <!-- 在访问时只需要写webjars下面的资源名称即可 -->
     <dependency>
         <groupId>org.webjars</groupId>
         <artifactId>jquery</artifactId>
         <version>3.4.1</version>
     </dependency>
     ```

2. /**, 访问当前项目的任何资源, 静态资源的文件夹

   > "classpath:/META-INF/resources/",
   > "classpath:/resources/", 
   > "classpath:/static/", 
   > "classpath:/public/",
   > "/"

   localhost:8080/abc ==> 去静态资源文件夹里面找abc

3. 欢迎页: 静态资源文件夹下的所有index.html页面; 被"/**"映射

   localhost:8080/ ==> 找index.html页面

4. 所有的`**/favicon.ico`都是在静态资源文件夹下找

5. 可以通过`spring.resources.static-locations`属性自定义静态文件夹数组, 会使默认配置失效

## 模板引擎

JSP, Velocity, Freemarker, Thymeleaf

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222012731.png)

SpringBoot推荐的Thymeleaf;

语法简单, 功能更强大.

### 引入Thymeleaf

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-thymeleaf</artifactId>
</dependency>
```

如果thymeleaf版本过低, 使用下列方式替换

```xml
<properties>
    <thymeleaf.version>3.0.2.RELEASE</thymeleaf.version>
    <!-- 布局功能的支持程序 thymeleaf3主程序使用layout2以上版本 -->
    <thymeleaf-layout-dialect.version>2.1.1</thymeleaf-layout-dialect.version>
</properties>
```

### Thymeleaf使用&语法

```java
@ConfigurationProperties(prefix = "spring.thymeleaf")
public class ThymeleafProperties {

	private static final Charset DEFAULT_ENCODING = StandardCharsets.UTF_8;

	public static final String DEFAULT_PREFIX = "classpath:/templates/";

	public static final String DEFAULT_SUFFIX = ".html";
```

只需要把html页面存放在**classpath:/templates/**, thymeleaf就能自动渲染;

**使用:**

1. 导入thymeleaf的名称空间

```xml
<html xmlns:th="http://www.thymeleaf.org">
```

1. 使用thymeleaf语法

```xml
<!-- th:text将div里面的文本内容设置为${hello} -->
<div th:text="${hello}">这是显示欢迎信息</div>
```

### Thymeleaf语法规则

1. th:text : 改变当前元素里面的文本内容

   - th : 任意html属性; 替换原生属性的值

   ![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222012834.png)

2. 表达式 [官方文档](https://www.thymeleaf.org/doc/tutorials/3.0/usingthymeleaf.html#standard-expression-syntax)

   ```html
   Simple expressions: (表达式语法)
       Variable Expressions: ${...} : 获取变量值, OGNL
           1. 获取对象的属性, 调用方法
           2. 使用内置的基本对象
               #ctx: the context object.
               #vars: the context variables.
               #locale: the context locale.
               #request: (only in Web Contexts) the HttpServletRequest object.
               #response: (only in Web Contexts) the HttpServletResponse object.
               #session: (only in Web Contexts) the HttpSession object.
               #servletContext: (only in Web Contexts) the ServletContext object.
           3. 内置的一些工具对象
               #execInfo: information about the template being processed.
               #messages: methods for obtaining externalized messages inside variables expressions, in the same way as they would be obtained using #{…} syntax.
               #uris: methods for escaping parts of URLs/URIs
               #conversions: methods for executing the configured conversion service (if any).
               #dates: methods for java.util.Date objects: formatting, component extraction, etc.
               #calendars: analogous to #dates, but for java.util.Calendar objects.
               #numbers: methods for formatting numeric objects.
               #strings: methods for String objects: contains, startsWith, prepending/appending, etc.
               #objects: methods for objects in general.
               #bools: methods for boolean evaluation.
               #arrays: methods for arrays.
               #lists: methods for lists.
               #sets: methods for sets.
               #maps: methods for maps.
               #aggregates: methods for creating aggregates on arrays or collections.
               #ids: methods for dealing with id attributes that might be repeated (for example, as a result of an iteration).
       Selection Variable Expressions: *{...} : 选择表达式, 和${...}在功能上是相同的
           补充: 配合th:object="${session.user}"来使用 
               <div th:object="${session.user}">
                   <p>Name: <span th:text="*{firstName}">Sebastian</span>.</p>
                   <p>Surname: <span th:text="*{lastName}">Pepper</span>.</p>
                   <p>Nationality: <span th:text="*{nationality}">Saturn</span>.</p>
               </div>
       Message Expressions: #{...} : 获取国际化内容
       Link URL Expressions: @{...} : 定义URL
           @{/order/process(execId=${execId},execType='FAST')}
       Fragment Expressions: ~{...} : 片段引用的表达式
           <div th:insert="~{commons :: main}">...</div>
   Literals(字面量)
       Text literals: 'one text', 'Another one!',…
       Number literals: 0, 34, 3.0, 12.3,…
       Boolean literals: true, false
       Null literal: null
       Literal tokens: one, sometext, main,…
   Text operations(文本操作):
       String concatenation: +
       Literal substitutions: |The name is ${name}|
   Arithmetic operations(数学运算):
       Binary operators: +, -, *, /, %
       Minus sign (unary operator): -
   Boolean operations(布尔运算):
       Binary operators: and, or
       Boolean negation (unary operator): !, not
   Comparisons and equality(比较运算):
       Comparators: >, <, >=, <= (gt, lt, ge, le)
       Equality operators: ==, != (eq, ne)
   Conditional operators(条件运算):
       If-then: (if) ? (then)
       If-then-else: (if) ? (then) : (else)
       Default: (value) ?: (defaultvalue)
   Special tokens(特殊操作):
       No-Operation: _
   ```

## SpringMVC自动配置

[Developing Web Applications](https://docs.spring.io/spring-boot/docs/2.2.2.RELEASE/reference/html/spring-boot-features.html#boot-features-developing-web-applications)

### Spring MVC auto-configuration

Spring Boot自动配置好了SpringMVC

以下是SpringBoot对SpringMVC的默认配置:

- Inclusion of `ContentNegotiatingViewResolver` and `BeanNameViewResolver` beans.

  - 自动配置了ViewResolver(视图解析器: 根据方法的返回值得到试图对象(View), 视图对象决定如何渲染(转发?重定向?))
  - ContentNegotiatingViewResolver : 用来组合所有视图解析器的;
  - 如何定制: 我们可以自己给容器中添加一个视图解析器; ContentNegotiatingViewResolver会自动的将其组合起来, 使其生效

- Static `index.html` support. 静态首页访问

- Support for serving static resources, including support for WebJars (covered later in this document)).静态资源文件夹路径, webjars

- Custom Favicon support (covered later in this document). 设置favicon.ico

- Automatic registration of `Converter`, `GenericConverter`, and `Formatter` beans.

  - Converter: 转换器, public String hello(String user): 类型转换使用

  - Formatter: 格式化器, 2019-12-14 ===> Date

    ```java
    @Bean
    @Override
    public FormattingConversionService mvcConversionService() {
        WebConversionService conversionService = new WebConversionService(this.mvcProperties.getDateFormat());
        addFormatters(conversionService);
        return conversionService;
    }
    ```

    自己添加的格式化器和转换器, 只需要将其添加到容器中即可

- Support for `HttpMessageConverters` (covered later in this document).

  - HttpMessageConverters: 消息转换器, 用来转换Http请求和响应的; User --> json
  - HttpMessageConverters是从容器中确定的, 获取容器中所有的HttpMessageConverters. 自己给容器中添加HttpMessageConverter, 只需要将自己的组件注册到容器中(@Bean, @Component)

- Automatic registration of `MessageCodesResolver` (covered later in this document). 定义错误代码生成规则

- Automatic use of a `ConfigurableWebBindingInitializer` bean (covered later in this document).

  - 我们可以配置一个ConfigurableWebBindingInitializer来替换默认的, (需要添加到容器)

  - 用来初始化WebDataBinder

    > 请求数据 === JavaBean

**[org.springframework.boot.autoconfigure.web](http://org.springframework.boot.autoconfigure.web/) : web的所有自动配置场景**

### 扩展SpringMVC

> If you want to keep Spring Boot MVC features and you want to add additional MVC configuration (interceptors, formatters, view controllers, and other features), you can add your own @Configuration class of type WebMvcConfigurer but without @EnableWebMvc. If you wish to provide custom instances of RequestMappingHandlerMapping, RequestMappingHandlerAdapter, or ExceptionHandlerExceptionResolver, you can declare a WebMvcRegistrationsAdapter instance to provide such components.

```xml
<mvc:view-controller path="/hello" view-name="success" />
<mvc:interceptors>
    <mvc:interceptor>
        <mvc:mapping path="/hello"/>
        <bean></bean>
    </mvc:interceptor>
</mvc:interceptors>
```

**编写一个配置类(标注@Configuration), 是WebMvcConfigurer(boot1.x版本是WebMvcConfigurerAdapter)类型, 不能标注@EnableWebMvc**

既保留了所有的自动配置, 也能用我们的扩展配置

```java
// 使用WebMvcConfigurer可以来扩展SpringMVC的功能
@Configuration
public class MyMvcConfig implements WebMvcConfigurer {

    @Override
    public void addViewControllers(ViewControllerRegistry registry) {
        // 浏览器发送/intelli请求, 也来到success页面
        registry.addViewController("/intelli").setViewName("success");
    }
}
```

**原理 :**

1. WebMvcAutoConfiguration
2. 在做其他自动配置时, 会导入@Import(EnableWebMvcConfiguration.class)

```java
@Configuration(proxyBeanMethods = false)
public static class EnableWebMvcConfiguration extends DelegatingWebMvcConfiguration implements ResourceLoaderAware {

    @Configuration(proxyBeanMethods = false)
    public class DelegatingWebMvcConfiguration extends WebMvcConfigurationSupport {

        private final WebMvcConfigurerComposite configurers = new WebMvcConfigurerComposite();

        // 从容器中获取所有的WebMvcConfigurer
        @Autowired(required = false)
        public void setConfigurers(List<WebMvcConfigurer> configurers) {
            if (!CollectionUtils.isEmpty(configurers)) {
                this.configurers.addWebMvcConfigurers(configurers);
            }

            // 一个参考实现, 将所有的WebMvcConfigurer相关的配置都来一起调用
            /*
    @Override
	public void addViewControllers(ViewControllerRegistry registry) {
		for (WebMvcConfigurer delegate : this.delegates) {
			delegate.addViewControllers(registry);
		}
	}
	*/
        }
```

1. 容器中所有的WebMvcConfigurer都会一起起作用
2. 我们的配置类也会被调用

**效果: **SpringMvc的配置和我们的扩展配置都会起作用

### 全面接管SpringMVC

If you want to take complete control of Spring MVC, you can add your own @Configuration annotated with @EnableWebMvc.

**效果 :** SpringBoot对SpringMVC的自动配置不需要了, 所有都是我们自己配, 所有的SpringMVC的自动配置都失效

**在我们自己的配置类中添加@EnableWebMvc即可.**

```java
// 禁用SpringMVC的自动配置, 全都由我们自己来配置
@EnableWebMvc
@Configuration
public class MyMvcConfig implements WebMvcConfigurer {
```

**原理 :**

为什么加上@EnableWebMvc自动配置就失效了?

```java
@Import(DelegatingWebMvcConfiguration.class)
public @interface EnableWebMvc {
}
```

```java
@Configuration(proxyBeanMethods = false)
public class DelegatingWebMvcConfiguration extends WebMvcConfigurationSupport {
```

```java
@Configuration(proxyBeanMethods = false)
@ConditionalOnWebApplication(type = Type.SERVLET)
@ConditionalOnClass({ Servlet.class, DispatcherServlet.class, WebMvcConfigurer.class })

// 容器中没有这个组件的时候, 这个配置类才生效
@ConditionalOnMissingBean(WebMvcConfigurationSupport.class)
@AutoConfigureOrder(Ordered.HIGHEST_PRECEDENCE + 10)
@AutoConfigureAfter({ DispatcherServletAutoConfiguration.class, TaskExecutionAutoConfiguration.class,
		ValidationAutoConfiguration.class })
public class WebMvcAutoConfiguration {
```

1. `@EnableWebMvc`将`WebMvcConfigurationSupport`组件导入进来了;
2. 导入的`WebMvcConfigurationSupport`只是SpringMVC最基本的功能.

## 如何修改SpringBoot的默认配置

**SpringBoot自动配置的模式 :**

1. SpringBoot在自动配置很多组件的时候, 先看容器中有没有用户自己配置的(@Bean, @Component), 如果有就用用户配置的, 如果没有, 才自动配置; 如果有些组件可以有多个(eg.ViewResolver), 将用户配置的和自己默认的组合起来.
2. 在SpringBoot中会有非常多的xxxConfigurer, 帮助我们进行扩展配置
3. 在SpringBoot中会有很多的xxx.Customizer帮助我们进行定制配置

## RestfulCRUD

### 默认访问首页

```java
@Configuration
public class MyMvcConfiguarer implements WebMvcConfigurer {
    @Override
    public void addViewControllers(ViewControllerRegistry registry) {
        registry.addViewController("/").setViewName("login");
        registry.addViewController("/index.html").setViewName("login");
    }
}
```

### 国际化

**1. 编写国际化配置文件**

1. 使用`ResourceBundleMessageSource`管理国际化资源文件
2. 在页面使用`fmt:message`取出国际化内容

步骤:

1. 编写国际化配置文件, 抽取页面需要显示的国际化消息

   ![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222013644.png)

2. Spring Boot自动配置好了管理国际化资源文件的组件

```java
@Configuration(proxyBeanMethods = false)
@ConditionalOnMissingBean(name = AbstractApplicationContext.MESSAGE_SOURCE_BEAN_NAME, search = SearchStrategy.CURRENT)
@AutoConfigureOrder(Ordered.HIGHEST_PRECEDENCE)
@Conditional(ResourceBundleCondition.class)
@EnableConfigurationProperties
public class MessageSourceAutoConfiguration {

    private static final Resource[] NO_RESOURCES = {};

    @Bean
    @ConfigurationProperties(prefix = "spring.messages")
    public MessageSourceProperties messageSourceProperties() {
        return new MessageSourceProperties();
    }

    @Bean
    public MessageSource messageSource(MessageSourceProperties properties) {
        ResourceBundleMessageSource messageSource = new ResourceBundleMessagimgeSource();
        if (StringUtils.hasText(properties.getBasename())) {
            // 设置国际化资源文件的基础名(去掉语言国家代码的)
            messageSource.setBasenames(StringUtils
                                       .commaDelimitedListToStringArray(StringUtils.trimAllWhitespace(properties.getBasename())));
        }
        if (properties.getEncoding() != null) {
            messageSource.setDefaultEncoding(properties.getEncoding().name());
        }/**
 * 可以在连接上携带区域信息
 */
public class MyLocaleResolver implements LocaleResolver {
    @Override
    public Locale resolveLocale(HttpServletRequest request) {
        String l = reqimguest.getParameter("l");
        Locale locale = Locale.getDefault();
        if (!StringUtils.isEmpty(l)) {
            String[] split = l.split("_");
            locale = new Locale(split[0], split[1]);
        }
        return locale;
    }

    @Override
    public void setLocale(HttpServletRequest request, HttpServletResponse response, Locale locale) {

    }
}


// MyMvcConfigurer中将自定义的组件添加到容器中
@Bean
public LocaleResolver localeResolver(){
    return new MyLocaleResolver();
}
        messageSource.setFallbackToSystemLocale(properties.isFallbackToSystemLocale());
        Duration cacheDuration = properties.getCacheDuration();
        if (cacheDuration != null) {
            messageSource.setCacheMillis(cacheDuration.toMillis());
        }
        messageSource.setAlwaysUseMessageFormat(properties.isAlwaysUseMessageFormat());
        messageSource.setUseCodeAsDefaultMessage(properties.isUseCodeAsDefaultMessage());
        return messageSource;
    }


    public class MessageSourceProperties {
        // 我们的配置文件可以直接放在类路径下叫messages.properties
        private String basename = "messages";
```

在application.properties中配置`spring.messages.basename=i18n/login`, 即可指定国家化配置文件的位置i18n/login从跟路径下查找基础名为login的国际化配置文件

1. 去页面获取国际化的值

themeleaf使用#{...}获取国际化值

```html
<label class="sr-only" th:text="#{login.username}">Username</label>
```

```html
<!-- 行内表达式 -->
<input type="checkbox" value="remember-me"/> [[#{login.remember}]]
```

效果: 根据浏览器语言设置的信息, 切换国际化

**SpringMVC国际化原理 :**

国际化 Locale(区域信息对象) : LocaleResolver(获取区域信息对象)

```java
@Bean
@ConditionalOnMissingBean
@ConditionalOnProperty(prefix = "spring.mvc", name = "locale")
public LocaleResolver localeResolver() {
    if (this.mvcProperties.getLocaleResolver() == WebMvcProperties.LocaleResolver.FIXED) {
        return new FixedLocaleResolver(this.mvcProperties.getLocale());
    }
    AcceptHeaderLocaleResolver localeResolver = new AcceptHeaderLocaleResolver();
    localeResolver.setDefaultLocale(this.mvcProperties.getLocale());
    return localeResolver;
}
@Override
public Locale resolveLocale(HttpServletRequest request) {
    Locale defaultLocale = getDefaultLocale();
    if (defaultLocale != null && request.getHeader("Accept-Language") == null) {
        return defaultLocale;
    }
    Locale requestLocale = request.getLocale();
    List<Locale> supportedLocales = getSupportedLocales();
    if (supportedLocales.isEmpty() || supportedLocales.contains(requestLocale)) {
        return requestLocale;
    }
    Locale supportedLocale = findSupportedLocale(request, supportedLocales);
    if (supportedLocale != null) {
        return supportedLocale;
    }
    return (defaultLocale != null ? defaultLocale : requestLocale);
}
```

SpringBoot默认配置的是根据请求头中带来的区域信息获取Locale进行国际化

1. 点击连接切换国际化

```java
/**
 * 可以在连接上携带区域信息
 */
public class MyLocaleResolver implements LocaleResolver {
    @Override
    public Locale resolveLocale(HttpServletRequest request) {
        String l = request.getParameter("l");
        Locale locale = Locale.getDefault();
        if (!StringUtils.isEmpty(l)) {
            String[] split = l.split("_");
            locale = new Locale(split[0], split[1]);
        }
        return locale;
    }

    @Override
    public void setLocale(HttpServletRequest request, HttpServletResponse response, Locale locale) {

    }
}


// MyMvcConfigurer中将自定义的组件添加到容器中
@Bean
public LocaleResolver localeResolver(){
    return new MyLocaleResolver();
}
```

### 登录

开发期间模板引擎页面修改后, 要实时生效 :

1. 禁用模板引擎的缓存

```properties
# 禁用模板引擎缓存
spring.thymeleaf.cache=false
```

1. 页面修改完成以后, idea使用Ctrl+F9, 重新编译

登录错误消息的显示

```html
<!-- 判断 -->
<p style="color: red" th:text="${msg}" th:if="${not #strings.isEmpty(msg)}"></p>
```

登录成功, 防止表单重复提交, 可以重定向到主页

```java
// 在自定义的视图解析器中添加
registry.addViewController("/main.html").setViewName("dashboard");

// 登录成功, 将请求重定向到main.html再经过解析器返回dashboard.html页面
return "redirect:/main.html";
```

### 拦截器进行登录验证

1. 创建登录拦截器类

```java
/**
 * 登录检查,
 */
public class LoginHandlerInterceptor implements HandlerInterceptor {
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        Object user = request.getSession().getAttribute("loginUser");
        if (user == null) {
            // 未登录, 返回登录页面
            request.getRequestDispatcher("/index.html").forward(request, response);
            request.setAttribute("msg", "没有权限, 请先登录.");
            return false;
        } else {
            // 已登录,放行请求
            return true;
        }
    }
}
```

1. 注册拦截器

设置拦截所有请求, 放心登录相关请求

```java
@Configuration
public class MyMvcConfigurer implements WebMvcConfigurer {
    // 注册拦截器
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        // 静态资源: *.css, *.js
        // SpringBoot已经做好了静态资源映射
        registry.addInterceptor(new LoginHandlerInterceptor()).addPathPatterns("/**")
            .excludePathPatterns("/index.html", "/", "/user/login");
    }
}
```

### CRUD-员工列表

实验要求 :

1. RestfulCRUD : CRUD要满足Rest风格 URI : /资源名称/资源标识 HTTP请求方式区分对资源的CRUD操作

| -    | 普通CRUD(uri来区分操作) | RestfulCRUD       |
| ---- | ----------------------- | ----------------- |
| 查询 | getEmp                  | emp---GET         |
| 添加 | addEmp?xxx              | emp---POST        |
| 修改 | updateEmp?id=x&xxx=xx   | emp/(id)---PUT    |
| 删除 | deleteEmp?id=x          | emp/(id)---DELETE |

1. 实验的请求架构 :

| -                                  | 请求URI  | 请求方式 |
| ---------------------------------- | -------- | -------- |
| 查询所有员工                       | emps     | GET      |
| 查询某个员工                       | emp/(id) | GET      |
| 来到添加页面                       | emp      | GET      |
| 添加员工                           | emp      | POST     |
| 来到修改页面(查出员工进行信息回显) | emp/(id) | GET      |
| 修改员工                           | emp      | PUT      |
| 删除员工                           | emp/(id) | DELETE   |

1. 员工列表

```html
1. 抽取公共片段
<div th:fragment="copy">
      &copy; 2011 The Good Thymes Virtual Grocery
</div>

2. 引入公共片段
<div th:insert="~{footer :: copy}"></div>
<div th:insert="footer :: copy"></div>

~{templatename::selector} : 模板名::选择器
~{templatename::fragmentname} : 模板名::片段名

3. 默认效果
insert的功能片段在div标签中
如果使用th:insert等属性进行引入, 可以不用写~{};
行内写法可以加上 : [[~{}]], [(~{})]
```

三种引入公共片段的th属性:

**th:insert** 将公共片段整个插入到声明引入元素中

**th:replace** 将声明引入的元素替换为公共片段

**th:include** 将被引入的片段的内容包含进这个标签中

```html
<footer th:fragment="copy">
  &copy; 2011 The Good Thymes Virtual Grocery
</footer>

<!-- 引入方式 -->
<div th:insert="footer :: copy"></div>
<div th:replace="footer :: copy"></div>
<div th:include="footer :: copy"></div>

<!-- 效果 -->
<div>
<footer>
  &copy; 2011 The Good Thymes Virtual Grocery
</footer>
</div>

<footer>
&copy; 2011 The Good Thymes Virtual Grocery
</footer>

<div>
&copy; 2011 The Good Thymes Virtual Grocery
</div>
```

### CRUD-员工添加

最常遇到的问题是, 提交的数据格式不对 : 特别是生日

2019-12-12; 2019/12/12; 2019.12.12;

日期格式化: SpringMVC将页面提交的值需要转换为指定的类型;

默认是按照2019-12-12类型进行格式化

通过application.properties修改默认时间格式

```properties
spring.mvc.date-format=
```

### CRUD-员工修改

form表单只支持POST和GET请求, 此时需要使用PUT请求方式:

1. SpringMVC中配置HiddenHttpMethodFilter, 将请求转成我们指定的方式
2. 页面创建一个post表单
3. 创建一个input项, name="_method"; 值就是我们指定的请求方式

### CRUD-员工删除

使用DELETE请求方式, 参考员工修改

使用@PathVariable("id")获取uri中的变量值

thymeleaf设置自定义属性

```html
<form action="xxx" th:attr="key1=val1, key2=val2"
```

### 错误处理机制

#### SpringBoot默认的错误处理机制

**默认效果 :**

1. 如果是浏览器, 返回一个默认的错误页面

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222014721.png)

浏览器发送请求的请求头 :

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222015133.png)

2. 如果是其他客户端, 默认相应一个json数据

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222015016.png)

客户端发送请求的请求头 :

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222015154.png)

**原理 :**

可以参照ErrorMvcAutoConfiguration, 错误处理的自动配置

给容器中添加了如下组件

- DefaultErrorAttributes :

```java
// 帮我们在页面共享信息
public Map<String, Object> getErrorAttributes(WebRequest webRequest, boolean includeStackTrace) {
    Map<String, Object> errorAttributes = new LinkedHashMap();
    errorAttributes.put("timestamp", new Date());
    this.addStatus(errorAttributes, webRequest);
    this.addErrorDetails(errorAttributes, webRequest, includeStackTrace);
    this.addPath(errorAttributes, webRequest);
    return errorAttributes;
}
```

- BasicErrorController : 处理默认的/error请求

```java
@Controller
@RequestMapping("${server.error.path:${error.path:/error}}")
public class BasicErrorController extends AbstractErrorController {

    @RequestMapping(produces = MediaType.TEXT_HTML_VALUE) // 产生html类型的数据, 浏览器发出的请求, 来这个方法处理
    public ModelAndView errorHtml(HttpServletRequest request, HttpServletResponse response) {
        HttpStatus status = getStatus(request);
        Map<String, Object> model = Collections
            .unmodifiableMap(getErrorAttributes(request, isIncludeStackTrace(request, MediaType.TEXT_HTML)));
        response.setStatus(status.value());

        // 去哪个页面作为错误页面, 包含页面地址和页面内容
        ModelAndView modelAndView = resolveErrorView(request, response, status, model);
        return (modelAndView != null) ? modelAndView : new ModelAndView("error", model);
    }

    @RequestMapping // 产生json数据, 其他客户端的请求, 来到这里处理
    public ResponseEntity<Map<String, Object>> error(HttpServletRequest request) {
        HttpStatus status = getStatus(request);
        if (status == HttpStatus.NO_CONTENT) {
            return new ResponseEntity<>(status);
        }
        Map<String, Object> body = getErrorAttributes(request, isIncludeStackTrace(request, MediaType.ALL));
        return new ResponseEntity<>(body, status);
    }
```

- ErrorPageCustomizer

```java
// 系统出现错误以后来到error请求进行处理, 相当于SSM在web.xml注册的错误页面规则
@Value("${error.path:/error}")
private String path = "/error";
```

- DefaultErrorViewResolver

```java
@Override
public ModelAndView resolveErrorView(HttpServletRequest request, HttpStatus status, Map<String, Object> model) {
    ModelAndView modelAndView = resolve(String.valueOf(status.value()), model);
    if (modelAndView == null && SERIES_VIEWS.containsKey(status.series())) {
        modelAndView = resolve(SERIES_VIEWS.get(status.series()), model);
    }
    return modelAndView;
}

private ModelAndView resolve(String viewName, Map<String, Object> model) {
    //默认SpringBoot可以找到一个页面 : error/404
    String errorViewName = "error/" + viewName;

    // 模板引擎可以解析这个页面地址就用模板引擎解析
    TemplateAvailabilityProvider provider = this.templateAvailabilityProviders.getProvider(errorViewName,
                                                                                           this.applicationContext);
    if (provider != null) {
        // 模板引擎可用的情况下返回errorViewName指定的视图地址
        return new ModelAndView(errorViewName, model);
    }
    // 模板引擎不可用, 就在静态资源文件夹下找errorViewName对应的页面 : error/404.html
    return resolveResource(errorViewName, model);
}
```

**步骤 :** 一旦系统出现4xx或者5xx之类的错误, ErrorPageCustomizer就会生效(定制错误的响应规则); 就会来到/error请求; 就会被**BasicErrorController**处理;

1. 响应页面 : 去哪个页面是由

   DefaultErrorViewResolver

   解析得到的

   ```java
   protected ModelAndView resolveErrorView(HttpServletRequest request, HttpServletResponse response, HttpStatus status,
                                           Map<String, Object> model) {
       // 所有的ErrorViewResolver得到ModelAndView
       for (ErrorViewResolver resolver : this.errorViewResolvers) {
           ModelAndView modelAndView = resolver.resolveErrorView(request, status, model);
           if (modelAndView != null) {
               return modelAndView;
           }
       }
       return null;
   }
   ```

#### 如何定制错误响应

- 如何定制错误的页面

  1. 有模板引擎的情况下 : error/状态码, 将错误页面命名为 错误状态码.html, 放在模板引擎文件夹里面的error文件夹下, 发生此状态码的错误, 就会来到对应的页面;

     可以使用4xx和5xx作为错误页面的文件名来匹配这种类型的所有错误, 精确优先(优先寻找精确地 状态码.html)

     页面能获取的信息:

     ```
     timestamp : 时间戳
     status : 状态码
     error : 错误提示
     exception : 异常对象
     message : 异常消息
     errors : jsr303数据校验的错误都在这
     ```

  2. 没有模板引擎(或模板引擎不能按上述找到这个错误页面), 从静态资源文件夹下找

  3. 以上都没有错误页面, 默认来到SpringBoot默认的错误提示页面

- 如何定制错误的json数据

  1. 自定义异常处理&返回定制json数据

     ```java
     @ControllerAdvice // 自定义异常需要添加
     public class MyExceptionHandler {
     
         // 浏览器和客户端返回的都是json
         @ResponseBody
         // 产生MyException时, 使用该方法
         @ExceptionHandler(MyException.class)
         public Map<String, Object> handleException(Exception e) {
             Map<String, Object> map = new HashMap<>();
             map.put("code", "user.myexception");
             map.put("message", e.getMessage());
             return map;
         }
     }
     ```

  2. 转发到/error进行自适应相应效果

     ```java
     @ControllerAdvice
     public class MyExceptionHandler {
     
         @ExceptionHandler(MyException.class)
         public String handleException(Exception e, HttpServletRequest request) {
             Map<String, Object> map = new HashMap<>();
             // 传入我们自己的错误状态码, 否则就不会进入定制错误页面的解析流程
             /**
             Integer status = (Integer)this.getAttribute(requestAttributes, "javax.servlet.error.status_code");
             */
             request.setAttribute("javax.servlet.error.status_code", "400");
             map.put("code", "user.myexception");
             map.put("message", e.getMessage());
             // 转发到/error, 让BasicErrorController自适应处理
             return "forward:/error";
         }
     }
     ```

  3. 将我们的定制数据携带出去

     出现错误以后, 会来到/error请求, 会被BasicErrorController处理, 响应出去的可以获取的数据是由getErrorAttributes得到的(是AbstractErrorController规定的方法)

     - 完全来编写一个ErrorController的实现类(或者编写AbstractErrorController的子类)
     - 页面上能用的数据, 或者是json返回能用的数据, 是从errorAttributes.getErrorAttributes得到的,
       容器中的DefaultErrorAttributes默认进行数据处理的, 可以写一个DefaultErrorAttributes的子类, 覆盖他的getErrorAttribute方法, 可以通过requestAttributes.getAttribute()获取到自定义异常中使用request.setAttributes()设置的值

**最终的效果 :** 响应是自适应的, 可以通过定制ErrorAttribute改变需要定制的内容

### 配置嵌入式Servlet容器

SpringBoot默认用的是嵌入式Servlet容器(Tomcat);

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222015309.png)

#### 如何定制和修改Servlet容器的相关配置

1. 修改和server有关的配置(ServerProperties)

```properties
server.port=8080
server.servlet.context-path=/crud

# 通用的servlet容器设置
server.xxx
# Tomcat的设置
server.tomcat.xxx
```

1. 编写一个EmbeddedServletContainerCustomizer : 嵌入式的Servlet容器的定制器, springboot2.x使用WebServerFactoryCustomizer, 来修改Servlet的配置

```java
// SpringBoot 1.x
@Bean
public EmbeddedServletContainerCustomizer embeddedServletContainerCustomizer(){
    return new EmbeddedServletContainerCustomizer(){
    
        // 定制嵌入式的Servlet容器相关规则
        @Override
        public void customize(ConfigurableEmbeddedServletContainer container) {
            container.setPort(8083);
        }
    }
}
// SpringBoot2.x
@Bean
public WebServerFactoryCustomizer<ConfigurableWebServerFactory> webServerFactoryCustomizer() {
    return new WebServerFactoryCustomizer<ConfigurableWebServerFactory>() {
        @Override
        public void customize(ConfigurableWebServerFactory factory) {
            factory.setPort(8081);
        }
    };
}
```

#### 注册Servlet三大组件[Servlet, Filter, Listener]

由于SpringBoot默认是以jar包的方式启动嵌入式的Servlet容器来启动SpringBoot的web应用, 没有web.xml文件.

所以要注册三大组件用以下方式:

- Servlet:

```java
@Bean
public ServletRegistrationBean myServlet() {
    return new ServletRegistrationBean<>(new MyServlet(), "/myServlet");
}
```

- Filter:

```java
@Bean
public FilterRegistrationBean myFilter() {
    FilterRegistrationBean<Filter> filterFilterRegistrationBean = new FilterRegistrationBean<>();
    filterFilterRegistrationBean.setFilter(new MyFilter());
    filterFilterRegistrationBean.setUrlPatterns(Arrays.asList("/hello", "/myServlet"));
    return filterFilterRegistrationBean;
}
```

- Listener:

```java
@Bean
public ServletListenerRegistrationBean myListener(){
    return new ServletListenerRegistrationBean(new MyListener());
}
```

SpringBoot帮我们自动配置SpringMVC的时候, 自动注册了SpringMVC的前端控制器(DispatcherServlet), 通过DispatcherServletAutoConfiguration类

默认拦截 / 所有请求, 包括静态资源, 但是不拦截jsp请求

/*会拦截jsp

可通过server.servletPath(springboot2.x使用spring.mvc.servlet.path)来修改SpringMVC前端控制器默认拦截的请求路径

#### 使用其他Servlet容器

SpringBoot 1.5.9默认支持:

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222015406.png)

SpringBoot2.2.2默认支持:

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222015445.png)

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
    <!-- 排除tomcat servlet容器 -->
    <exclusions>
        <exclusion>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-tomcat</artifactId>
        </exclusion>
    </exclusions>
</dependency>

<!--引入其他的Servlet容器-->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-jetty</artifactId>
</dependency>
```

#### 嵌入式Servlet容器自动配置原理

```java
//SpringBoot 1.5.9
@AutoConfigureOrder(Ordered.HIGHEST_PRECEDENCE)
@Configuration
@ConditionalOnWebApplication
@Import(BeanPostProcessorsRegistrar.class)
// Spring注解版, 给容器中导入一些组件
// 导入了EmbeddedServletContainerCustomizerBeanPostProcessor
// 后置处理器: bean初始化前后(创建完对象, 还没属性赋值)执行初始化工作
public class EmbeddedServletContainerAutoConfiguration {

	@Configuration
	@ConditionalOnClass({ Servlet.class, Tomcat.class }) // 当前是否引入了Tomcat依赖
	@ConditionalOnMissingBean(value = EmbeddedServletContainerFactory.class, search = SearchStrategy.CURRENT) //判断当前容器中没有用户自己定义的EmbeddedServletContainerFactory(嵌入式的容器工厂, 作用: 创建嵌入式的Servlet容器)
	public static class EmbeddedTomcat {

		@Bean
		public TomcatEmbeddedServletContainerFactory tomcatEmbeddedServletContainerFactory() {
			return new TomcatEmbeddedServletContainerFactory();
		}

	}

// SpringBoot 2.2.2
@Configuration(proxyBeanMethods = false)
@AutoConfigureOrder(Ordered.HIGHEST_PRECEDENCE)
@ConditionalOnClass(ServletRequest.class)
@ConditionalOnWebApplication(type = Type.SERVLET)
@EnableConfigurationProperties(ServerProperties.class)
@Import({ ServletWebServerFactoryAutoConfiguration.BeanPostProcessorsRegistrar.class,
		ServletWebServerFactoryConfiguration.EmbeddedTomcat.class,
		ServletWebServerFactoryConfiguration.EmbeddedJetty.class,
		ServletWebServerFactoryConfiguration.EmbeddedUndertow.class })
public class ServletWebServerFactoryAutoConfiguration {

	@Bean
	@ConditionalOnClass(name = "org.apache.catalina.startup.Tomcat")
	public TomcatServletWebServerFactoryCustomizer tomcatServletWebServerFactoryCustomizer(
			ServerProperties serverProperties) {
		return new TomcatServletWebServerFactoryCustomizer(serverProperties);
	}
```

1. EmbeddedServletContainerFactory(嵌入式Servlet容器工厂)

   ```java
   public interface EmbeddedServletContainerFactory {
       
       // 嵌入式的Servlet容器
   	EmbeddedServletContainer getEmbeddedServletContainer(
   			ServletContextInitializer... initializers);
   
   }
   ```

   ![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222132151.png)

2. EmbeddedServletContainer : 嵌入式的Servlet容器

   ```java
   /**
    * Nested configuration if Tomcat is being used.
    */
   @Configuration
   @ConditionalOnClass({ Servlet.class, Tomcat.class })
   @ConditionalOnMissingBean(value = EmbeddedServletContainerFactory.class, search = SearchStrategy.CURRENT)
   public static class EmbeddedTomcat {
   
       @Bean
       public TomcatEmbeddedServletContainerFactory tomcatEmbeddedServletContainerFactory() {
           return new TomcatEmbeddedServletContainerFactory();
       }
   
   }
   
   /**
    * Nested configuration if Jetty is being used.
    */
   @Configuration
   @ConditionalOnClass({ Servlet.class, Server.class, Loader.class,
                        WebAppContext.class })
   @ConditionalOnMissingBean(value = EmbeddedServletContainerFactory.class, search = SearchStrategy.CURRENT)
   public static class EmbeddedJetty {
   
       @Bean
       public JettyEmbeddedServletContainerFactory jettyEmbeddedServletContainerFactory() {
           return new JettyEmbeddedServletContainerFactory();
       }
   
   }
   
   /**
    * Nested configuration if Undertow is being used.
    */
   @Configuration
   @ConditionalOnClass({ Servlet.class, Undertow.class, SslClientAuthMode.class })
   @ConditionalOnMissingBean(value = EmbeddedServletContainerFactory.class, search = SearchStrategy.CURRENT)
   public static class EmbeddedUndertow {
   
       @Bean
       public UndertowEmbeddedServletContainerFactory undertowEmbeddedServletContainerFactory() {
           return new UndertowEmbeddedServletContainerFactory();
       }
   
   }
   ```

   ![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222132444.png)

3. 以TomcatEmbeddedServletContainerFactory为例

   ```java
   @Override
   public EmbeddedServletContainer getEmbeddedServletContainer(
       ServletContextInitializer... initializers) {
       // 创建一个Tomcat
       Tomcat tomcat = new Tomcat();
   
       // 配置tomcat的基本环节
       File baseDir = (this.baseDirectory != null ? this.baseDirectory
                       : createTempDir("tomcat"));
       tomcat.setBaseDir(baseDir.getAbsolutePath());
       Connector connector = new Connector(this.protocol);
       tomcat.getService().addConnector(connector);
       customizeConnector(connector);
       tomcat.setConnector(connector);
       tomcat.getHost().setAutoDeploy(false);
       configureEngine(tomcat.getEngine());
       for (Connector additionalConnector : this.additionalTomcatConnectors) {
           tomcat.getService().addConnector(additionalConnector);
       }
       prepareContext(tomcat.getHost(), initializers);
       // 将配置好的tomcat传入进去, 返回一个EmbeddedServletContainer, 并且启动Tomcat服务器
       return getTomcatEmbeddedServletContainer(tomcat);
   }
   ```

4. 我们对嵌入式容器的配置修改是怎么生效的

   ```java
   ServerProperties, EmbeddedServletContainerCustomizer(2.x版本不一样)
   ```

**EmbeddedServletContainerCustomizer :** 定制器帮我们修改了Servlet容器的配置

怎么修改的?

```java
// EmbeddedServletContainerCustomizerBeanPostProcessor

// 初始化之前
@Override
public Object postProcessBeforeInitialization(Object bean, String beanName)
    throws BeansException {
    // 如果当前初始化的是一个ConfigurableEmbeddedServletContainer类型的组件
    if (bean instanceof ConfigurableEmbeddedServletContainer) {
        postProcessBeforeInitialization((ConfigurableEmbeddedServletContainer) bean);
    }
    return bean;
}


private void postProcessBeforeInitialization(
    ConfigurableEmbeddedServletContainer bean) {
    // 获取所有的定制器, 调用每一个定制器的customize方法给Servlet容器进行属性赋值
    for (EmbeddedServletContainerCustomizer customizer : getCustomizers()) {
        customizer.customize(bean);
    }
}


private Collection<EmbeddedServletContainerCustomizer> getCustomizers() {
    if (this.customizers == null) {
        // Look up does not include the parent context
        this.customizers = new ArrayList<EmbeddedServletContainerCustomizer>(
            this.beanFactory
            // 从容器中获取到所有这个类型的组件 : EmbeddedServletContainerCustomizer
            // 定制Servlet容器, 给容器中可以添加一个EmbeddedServletContainerCustomizer类型的组件
            .getBeansOfType(EmbeddedServletContainerCustomizer.class,
                            false, false)
            .values());
        Collections.sort(this.customizers, AnnotationAwareOrderComparator.INSTANCE);
        this.customizers = Collections.unmodifiableList(this.customizers);
    }
    return this.customizers;
}

// serverProperties也是定制器(2.x版本不同)
```

总流程:

1. SpringBoot根据导入的依赖情况, 给容器中添加相应的嵌入式容器工厂 : EmbeddedServletContainerFactory

2. 容器中某个组件要创建组件就毁惊动后置处理器 : EmbeddedServletContainerCustomizerBeanPostProcessor

   只要是嵌入式的Servlet容器工厂, 后置处理器就工作

3. 后置处理器从容器中获取所有的EmbeddedServletContainerCustomizer, 调用定制器的定制方法

#### 嵌入式Servlet容器启动原理

什么时候创建嵌入式的Servlet容器工厂? 什么时候获取嵌入式的Servlet容器并启动Tomcat?

获取嵌入式的Servlet容器工厂

1. SpringBoot应用启动运行run方法

2. refreshContext(context) : SpringBoot刷新IOC容器, 创建并初始化容器, 创建容器中的每个组件, 如果是web应用创建AnnotationConfigEmbeddedWebApplicationContext(2.x是AnnotationConfigServletWebServerApplicationContext), 否则AnnotationConfigApplicationContext(2.x还有一种REACTIVE对应的AnnotationConfigReactiveWebServerApplicationContext)

3. refresh(context)

   ```java
   public void refresh() throws BeansException, IllegalStateException {
       synchronized (this.startupShutdownMonitor) {
           // Prepare this context for refreshing.
           prepareRefresh();
   
           // Tell the subclass to refresh the internal bean factory.
           ConfigurableListableBeanFactory beanFactory = obtainFreshBeanFactory();
   
           // Prepare the bean factory for use in this context.
           prepareBeanFactory(beanFactory);
   
           try {
               // Allows post-processing of the bean factory in context subclasses.
               postProcessBeanFactory(beanFactory);
   
               // Invoke factory processors registered as beans in the context.
               invokeBeanFactoryPostProcessors(beanFactory);
   
               // Register bean processors that intercept bean creation.
               registerBeanPostProcessors(beanFactory);
   
               // Initialize message source for this context.
               initMessageSource();
   
               // Initialize event multicaster for this context.
               initApplicationEventMulticaster();
   
               // Initialize other special beans in specific context subclasses.
               onRefresh();
   
               // Check for listener beans and register them.
               registerListeners();
   
               // Instantiate all remaining (non-lazy-init) singletons.
               finishBeanFactoryInitialization(beanFactory);
   
               // Last step: publish corresponding event.
               finishRefresh();
           }
   ```

4. onRefresh() : web的ioc容器重写了onRefresh方法

5. webioc容器会创建嵌入式的Servlet容器:createembeddedServletContainer() (2.x是createWebServer)

6. 获取嵌入式的Servlet容器工厂EmbeddedServletContainerFactory containerFactory = getEmbeddedServletContainerFactory();(2.x是ServletWebServerFactory factory = getWebServerFactory();)

   从IOC容器中获取EmbeddedServletContainerFactory组件, TomcatEmbeddedServletContainerFactory 创建对象, 后置处理器就获取所有的定制器来先定制Servlet容器的相关配置

7. 使用容器工厂获取嵌入式的Servlet容器: this.embeddedServletContainer = containerFactory.getEmbeddedServletContainer(getSelfInitializer());
8. 嵌入式的Servlet容器创建对象并启动.

**先启动嵌入式的Servlet容器, 再将IOC容器中剩下没有创建出的对象获取出来**

**IOC容器启动创建嵌入式的Servlet容器**

### 使用外置的Servlet容器

**嵌入式Servlet容器 :** 应用打成可执行的jar

- 优点: 简单, 便携
- 缺点: 默认不支持JSP, 优化定制比较复杂(解决方法见 : 配置嵌入式Servlet容器);

**外置的Servlet容器 :** 外面安装Tomcat---把应用打成war包

```properties
# 可指定SpringMVC视图解析器的前后缀
spring.mvc.view.prefix=/WEB-INF/
spring.mvc.view.suffix=.jsp
```

**步骤 :**

其实就是将SpringBoot工程修改为了Maven Web工程, 然后添加了一个SpringBootServletInitializer的子类, 在外置tomcat启动后, 自动启动SpringBoot工程.

1. 必须创建一个war项目: jar项目可以修改pom.xml中的`<packaging>war</packaging>`

   ```xml
   <groupId>icu.intelli</groupId>
   <artifactId>spring-boot-jpa-demo</artifactId>
   <version>1.0-SNAPSHOT</version>
   <packaging>war</packaging>
   ```

2. 创建好目录结构:

   - IDEA可通过Project Structure快速创建, 手动创建的也需要进入Project Structure将web根目录和web.xml设置好

   ![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222132803.png)

   ​	![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210222132825.png)

3. 将嵌入式的tomcat指定为provided

   ```xml
   <dependency>
       <groupId>org.springframework.boot</groupId>
       <artifactId>spring-boot-starter-tomcat</artifactId>
       <scope>provided</scope>
   </dependency>
   ```

4. 必须编写一个SpringBootServletInitializer的子类, 并调用configure方法

   ```java
   public class ServletInitializer extends SpringBootServletInitializer {
   
       @Override
       protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
           // 需要传入SpingBoot应用的主程序
           return application.sources(Application.class);
       }
   
   }
   ```

5. IDEA通过*Edit Configurations...*添加tomcat容器, 并将当前项目设置进去

6. 启动外置tomcat就可以使用(此处直接运行Application.java使用的还是嵌入式的tomcat)

### 原理

**jar包 :** 执行SpringBoot主类的main方法, 启动IOC容器, 创建嵌入式Servlet容器;

**war包 :** 启动服务器, **服务器来启动SpringBoot应用**[SpringBootServletInitializer], 然后启动IOC容器

servlet3.0 : 8.2.4 Shared libraries 65.79/ runtimes pluggability :

**规则 :**

1. 服务器启动(Web应用启动)会创建当前web应用里面每一个jar包里面的ServletContainerInitializer实例;
2. ServletContainerInitializer的实现放在jar包的META-INFO/service文件夹下, 里面必须有一个名为javax.servlet.ServletContainerInitializer的文件, 内容就是ServletContainerInitializer的实现类的全类名
3. 还可以使用@HandlerTypes, 在应用启动的时候加载我们感兴趣的类

**流程 :**

1. 启动Tomcat

2. org/springframework/spring-web/5.2.2.RELEASE/spring-web-5.2.2.RELEASE.jar!/META-INF/services/javax.servlet.ServletContainerInitializer

   SpringBoot的web模块里有这个文件: **javax.servlet.ServletContainerInitializer**

3. SpringServletContainerInitializer将@HandlesTypes(WebApplicationInitializer.class)标注的所有这个类型的类传入到onStartup方法的Set<Class<?>>, 为这些WebApplicationInitializer类型的类创建实例

4. 每一个WebApplicationInitializer都调用自己的onStartup方法

5. 相当于我们的SpringBootServletInitialize的类会被创建对象, 并执行onStartup方法 ![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210608000048.png)

6. SpringBootServletInitialize实例执行onStartup的时候会createRootApplicationContext, 创建容器

   ```java
   protected WebApplicationContext createRootApplicationContext(ServletContext servletContext) {
       SpringApplicationBuilder builder = createSpringApplicationBuilder();
       builder.main(getClass());
       ApplicationContext parent = getExistingRootWebApplicationContext(servletContext);
       if (parent != null) {
           this.logger.info("Root context already created (using as parent).");
           servletContext.setAttribute(WebApplicationContext.ROOT_WEB_APPLICATION_CONTEXT_ATTRIBUTE, null);
           builder.initializers(new ParentContextApplicationContextInitializer(parent));
       }
       builder.initializers(new ServletContextApplicationContextInitializer(servletContext));
       builder.contextClass(AnnotationConfigServletWebServerApplicationContext.class);
   
       // 调用configure方法, 子类重写了这个方法, 将SpringBoot的主程序类传入了进来
       builder = configure(builder);
   
       builder.listeners(new WebEnvironmentPropertySourceInitializer(servletContext));
   
       // 使用builder创建一个Spring应用
       SpringApplication application = builder.build();
       if (application.getAllSources().isEmpty()
           && MergedAnnotations.from(getClass(), SearchStrategy.TYPE_HIERARCHY).isPresent(Configuration.class)) {
           application.addPrimarySources(Collections.singleton(getClass()));
       }
       Assert.state(!application.getAllSources().isEmpty(),
                    "No SpringApplication sources have been defined. Either override the "
                    + "configure method or add an @Configuration annotation");
       // Ensure error pages are registered
       if (this.registerErrorPageFilter) {
           application.addPrimarySources(Collections.singleton(ErrorPageFilterConfiguration.class));
       }
       // 启动SpringBoot应用
       return run(application);
   }
   ```

7. Spring的应用就启动了, 并且创建IOC容器

   ```java
   public ConfigurableApplicationContext run(String... args) {
       StopWatch stopWatch = new StopWatch();
       stopWatch.start();
       ConfigurableApplicationContext context = null;
       Collection<SpringBootExceptionReporter> exceptionReporters = new ArrayList<>();
       configureHeadlessProperty();
       SpringApplicationRunListeners listeners = getRunListeners(args);
       listeners.starting();
       try {
           ApplicationArguments applicationArguments = new DefaultApplicationArguments(args);
           ConfigurableEnvironment environment = prepareEnvironment(listeners, applicationArguments);
           configureIgnoreBeanInfo(environment);
           Banner printedBanner = printBanner(environment);
           context = createApplicationContext();
           exceptionReporters = getSpringFactoriesInstances(SpringBootExceptionReporter.class,
                                                            new Class[] { ConfigurableApplicationContext.class }, context);
           prepareContext(context, environment, listeners, applicationArguments, printedBanner);
           refreshContext(context);
           afterRefresh(context, applicationArguments);
           stopWatch.stop();
           if (this.logStartupInfo) {
               new StartupInfoLogger(this.mainApplicationClass).logStarted(getApplicationLog(), stopWatch);
           }
           listeners.started(context);
           callRunners(context, applicationArguments);
       }
       catch (Throwable ex) {
           handleRunFailure(context, ex, exceptionReporters, listeners);
           throw new IllegalStateException(ex);
       }
   
       try {
           listeners.running(context);
       }
       catch (Throwable ex) {
           handleRunFailure(context, ex, exceptionReporters, null);
           throw new IllegalStateException(ex);
       }
       return context;
   }
   ```
