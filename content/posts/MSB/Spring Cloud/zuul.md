---
title: Zuul
date: '2021-01-14 23:46:00'
tags:
- MSB
- Spring Cloud
- Zuul
- Java
---
# Zuul

服务治理和注册发现（Eureka），服务调用（RestTemplate/Feign），负载均衡（Ribbon），熔断（Hystrix）等微服务基本模块已经有了，就可以做微服务了。微服务一般都在内网，相互之间不用做安全验证。

网关是介于客户端（外部调用方，比如 H5，app 等）和微服务的中间层

## 网关分类

### 普通网关和 DR 网关对比

![image-20210114104210141](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210114104211.png)

![image-20210114104221661](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210114104222.png)

- 普通网关：对数据包的接收和响应都需要经过它进行处理，此时如果服务端数量较多，网关会成为瓶颈，同时因为所有数据包都经过它，所以可以做一些额外处理

- DR 网关：只接收请求的数据包，然后把数据包进行修改后发送给服务端，服务端把响应结果直接返回给客户端。所以该网关只能做负载均衡

### 组合使用 DR 网关和普通网关

使用 DR 网关为普通网关做一层负载均衡，然后具体的复杂功能由普通网关实现，既可以防止普通网关出现瓶颈，又可以附加额外功能。

![image-20210114104855295](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210114104855.png)

### 流量网关和业务网关

普通网关根据其提供的功能不同又可以分为流量网关和业务网关

#### 流量网关



#### 业务网关



## Zuul 的功能

Zuul 是 Netflix 开源的微服务网关，核心是一系列过滤器。这些过滤器可以完成以下功能：

1. 是所有微服务入口，进行分发。
2. 身份认证与安全。识别合法的请求，拦截不合法的请求。
3. 监控。在入口处监控，更全面。
4. 动态路由。动态将请求分发到不同的后端集群。
5. 压力测试。可以逐渐增加对后端服务的流量，进行测试。
6. 负载均衡。也是用 ribbon。
7. 限流。比如我每秒只要 1000 次，10001 次就不让访问了。

Zuul 默认集成了 Ribbon 和 Hyxtrix

## Zuul 的使用

### 初步使用

1. 添加依赖

   ```xml
   <dependency>
       <groupId>org.springframework.cloud</groupId>
       <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
   </dependency>
   
   <!--zuul -->
   <dependency>
       <groupId>org.springframework.cloud</groupId>
       <artifactId>spring-cloud-starter-netflix-zuul</artifactId>
   </dependency>
   ```

2. 在启动类上添加 `@EnableZuulProxy` 注解，该注解声明这是一个 zuul 代理，使用 Ribbon 来定位注册到 Eureka Server 上的微服务，同时整合了 Hystrix 实现容错

3. 配置文件

   ```yaml
   spring:
     application:
       name: zuul
   server:
     port: 9999
   eureka:
     client:
       register-with-eureka: true
       fetch-registry: true
       service-url:
         defaultZone: http://admin:123456@localhost:7900/eureka/
   ```

4. 通过 zuul 即可访问 Eureka Server 中的微服务，`http://网关 ip:网关端口/服务名/微服务路径`，例如 `http://localhost:9999/eureka-consumer/consumer/restTemplate/hystrix-fallback?millis=100`

### 负载均衡

```yaml
${spring.application.name}:
  ribbon:
    NFLoadBalancerRuleClassName: com.netflix.loadbalancer.RandomRule
```

### 监控

#### 路由端点

1. 引入 actuator 依赖

   ```xml
   <dependency>
       <groupId>org.springframework.boot</groupId>
       <artifactId>spring-boot-starter-actuator</artifactId>
   </dependency>
   ```

2. 修改配置

   ```yaml
   management:
     endpoint:
       health:
         enabled: true
         show-details: always
       routes:
         enabled: true
     endpoints:
       web:
         exposure:
           include: '*'
   ```

3. 访问 `/actuator/routes`

4. 返回结果，显示的是 eureka 中的网关和映射关系。如果 eureka 中没有实例，则只显示配置的映射。根据网关请求地址和映射关系可以排查错误

   ```json
   {
       "/eureka-consumer/**": "eureka-consumer",
       "/eureka-provider/**": "eureka-provider"
   }
   ```

#### 过滤器端点

访问 `/actuator/filters`，一共包含 `error`，`post`，`pre`，`route`四种过滤器。其中包含默认的和自定义的。

```json
{
    "error": [
        {
            "class": "org.springframework.cloud.netflix.zuul.filters.post.SendErrorFilter",
            "order": 0,
            "disabled": false,
            "static": true
        }
    ],
    "post": [
        {
            "class": "org.springframework.cloud.netflix.zuul.filters.post.SendResponseFilter",
            "order": 1000,
            "disabled": false,
            "static": true
        }
    ],
    "pre": [
        {
            "class": "org.springframework.cloud.netflix.zuul.filters.pre.DebugFilter",
            "order": 1,
            "disabled": false,
            "static": true
        },
        {
            "class": "org.springframework.cloud.netflix.zuul.filters.pre.FormBodyWrapperFilter",
            "order": -1,
            "disabled": false,
            "static": true
        },
        {
            "class": "org.springframework.cloud.netflix.zuul.filters.pre.Servlet30WrapperFilter",
            "order": -2,
            "disabled": false,
            "static": true
        },
        {
            "class": "org.springframework.cloud.netflix.zuul.filters.pre.ServletDetectionFilter",
            "order": -3,
            "disabled": false,
            "static": true
        },
        {
            "class": "org.springframework.cloud.netflix.zuul.filters.pre.PreDecorationFilter",
            "order": 5,
            "disabled": false,
            "static": true
        }
    ],
    "route": [
        {
            "class": "org.springframework.cloud.netflix.zuul.filters.route.SimpleHostRoutingFilter",
            "order": 100,
            "disabled": false,
            "static": true
        },
        {
            "class": "org.springframework.cloud.netflix.zuul.filters.route.RibbonRoutingFilter",
            "order": 10,
            "disabled": false,
            "static": true
        },
        {
            "class": "org.springframework.cloud.netflix.zuul.filters.route.SendForwardFilter",
            "order": 500,
            "disabled": false,
            "static": true
        }
    ]
}
```

### 配置指定微服务的访问路径

#### 通过虚拟主机名

```yaml
zuul:
  routes:
    eureka-consumer: /zuul-eureka-consumer/**
```

配置前：http://localhost:9999/eureka-consumer/consumer/zuul/fallback?millis=0

配置后：http://localhost:9999/zuul-eureka-consumer/consumer/zuul/fallback?millis=0

配置后也可以使用配置前的 url 进行访问

#### 自定义名称

```yaml
zuul:
  routes:
    # 此处名字随便取
    custom-zuul-name:
      # 自定义的网关路径
      path: /custom-eureka-consumer/**
      # 上游服务的 url
      url: http://localhost:9090/
```

配置后：http://localhost:9999/custom-eureka-consumer/consumer/zuul/fallback?millis=0

此时 zuul 对上游服务的负载均衡（ribbon）就失效了

**解决 ribbon 失效**

```yaml
zuul:
  routes:
    # 此处名字随便取
    custom-zuul-name:
      # 自定义的网关路径
      path: /custom-eureka-consumer/**
      # 自定义一个 service-id
      service-id: custom-service-id
# 对 custom-service-id 进行 ribbon 的配置
custom-service-id:
  ribbon:
    # 上游服务集群的主机（ip）和端口
    listOfServers: localhost:9090,localhost:9091
ribbon:
  eureka:
    # 关闭 ribbon 和 eureka 的集成
    enabled: false
```

类似于 ribbon 的独立使用

#### 通过 service-id

```yaml
zuul:
  routes:
    #此处名字随便取
    custom-zuul-name: 
      # 自定义的网关路径
      path: /custom-eureka-consumer/**
      # 微服务的 service-id
      service-id: eureka-consumer
```

### 将请求转发给自己

```yaml
zuul:
  routes:
    # 此处名字随便取
    xxx:
      # 自定义的网关路径
      path: /forword/**
      # 把请求转发到网关中我们自己定义的 Controller 上
      url: forward:/ownController
```

### 忽略微服务

#### 根据服务名忽略

可结合通过虚拟主机名指定微服务的访问路径进行使用。可以让 zuul 不根据服务名请求上游服务，只能根据自定义的网关路径访问

```yaml
zuul:
  routes:
    eureka-consumer: /zuul-eureka-consumer/**
  ignored-services:
  - eureka-consumer
```

原始路径：http://localhost:9999/eureka-consumer/consumer/zuul/fallback?millis=0

根据虚拟主机名配置后：http://localhost:9999/zuul-eureka-consumer/consumer/zuul/fallback?millis=0

在不配置忽略的时候，两种方式都可以访问。配置之后只有 *根据虚拟主机名配置后* 的路径可以访问

#### 根据表达式忽略

```yaml
zuul:
  routes:
    eureka-consumer: /zuul-eureka-consumer/**
  ignored-patterns:
  - /*consumer/**
```

此时原始路径和根据虚拟主机名配置后的路径就都不能访问了，因为都匹配`/*consumer/**`表达式

#### 忽略全部

忽略所有的服务，此时只有 zuul.routes 中配置的好使

```yaml
zuul:
  routes:
    eureka-consumer: /zuul-eureka-consumer/**
  ignored-services: '*'
```

### 添加前缀

微服务接口一般命名方式都是：`/api/v1/xxx`

```yaml
zuul:
  prefix: /api
  # 是否移除前缀
  strip-prefix: true
```

`strip-prefix` 为 true 时，访问时带上前缀，实际请求会将前缀去掉

例如：访问 http://localhost:9999/api/eureka-consumer/consumer/zuul/fallback?millis=0

实际：http://localhost:9090/eureka-consumer/consumer/zuul/fallback?millis=0

### 敏感 Header

```yaml
zuul:
  # 表示忽略下面的值向微服务传播。此时表示不会将请求头上的 token 传递给上游服务。如果为空，表示所有请求头都透传到上游服务
  sensitive-headers: token
```

## Zuul 过滤器

[Zuul 的使用](#Zuul 的使用) 中主要都是其路由功能的使用

Zuul 的大部分功能都是通过过滤器实现的，其包含 4 种过滤器

- **PRE**：**在请求被路由之前**调用，可利用这种过滤器实现身份验证。选择微服务，记录日志。
- **ROUTING**：**在将请求路由到微服务**调用，用于构建发送给微服务的请求，并用 http clinet（或者 ribbon）请求微服务。
- **POST**：**在调用微服务执行后**。可用于添加 header，记录日志，将响应发给客户端。
- **ERROR**：在上述每个阶段发生错误时，走此过滤器。

### 自定义过滤器

要自定义一个过滤器，只需要要继承 `ZuulFilter`，然后指定**过滤类型**、**过滤顺序**、**是否执行这个过滤器**、**过滤逻辑**就可以了。

```java
import com.netflix.zuul.ZuulFilter;
import com.netflix.zuul.context.RequestContext;
import org.springframework.cloud.netflix.zuul.filters.support.FilterConstants;
import org.springframework.stereotype.Component;

import javax.servlet.http.HttpServletRequest;


@Component
public class CustomPreFilter extends ZuulFilter {

    @Override
    public String filterType() {
        return FilterConstants.PRE_TYPE;
    }

    @Override
    public int filterOrder() {
        // 多个过滤器中的执行顺序，数值越小，优先级越高。
        // 可以通过常量+/-1 来指定在其后/前
        return FilterConstants.PRE_DECORATION_FILTER_ORDER + 1;
    }

    @Override
    public boolean shouldFilter() {
        // 该过滤器是否生效
        return true;
    }

    @Override
    public Object run() {
        // 具体的执行逻辑
        // 获取请求上下文
        RequestContext currentContext = RequestContext.getCurrentContext();
        HttpServletRequest request = currentContext.getRequest();
        String requestURI = request.getRequestURI();
        System.out.println("CustomPreFilter, requestURI: " + requestURI);
        return null;
    }
}
```

## 接口容错

在网关层即可进行 fallback

```java
import com.netflix.hystrix.exception.HystrixTimeoutException;
import org.springframework.cloud.netflix.zuul.filters.route.FallbackProvider;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.client.ClientHttpResponse;
import org.springframework.stereotype.Component;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;

@Component
public class CustomFallback implements FallbackProvider {
    /**
     * 表明为哪个微服务提供回退。
     * 如果需要所有服务调用都支持回退，返回 null 或者 * 即可
     *
     * @return 服务 id
     */
    @Override
    public String getRoute() {
        //        return "eureka-consumer";
        return "*";
    }

    @Override
    public ClientHttpResponse fallbackResponse(String route, Throwable cause) {
        if (cause instanceof HystrixTimeoutException) {
            return response(HttpStatus.GATEWAY_TIMEOUT);
        } else {
            return response(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    private ClientHttpResponse response(final HttpStatus status) {
        return new ClientHttpResponse() {
            @Override
            public HttpStatus getStatusCode() throws IOException {
                return status;
            }

            @Override
            public int getRawStatusCode() throws IOException {
                return status.value();
            }

            @Override
            public String getStatusText() throws IOException {
                return status.getReasonPhrase();
            }

            @Override
            public void close() {
            }

            @Override
            public InputStream getBody() throws IOException {
                String msg = "{\"msg\":\"服务故障\"}";
                return new ByteArrayInputStream(msg.getBytes());
            }

            @Override
            public HttpHeaders getHeaders() {
                HttpHeaders headers = new HttpHeaders();
                headers.setContentType(MediaType.APPLICATION_JSON);
                return headers;
            }
        };
    }
}
```

## 限流

### Zuul 网关限流

#### 令牌桶

![image-20210310202726963](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210310202727.png)

> 假设进入高速公路的车辆需要在入口处领取到通行卡才能进入高速公路。为了节约人力成本，入口处放置自动出卡机。按照国家高速公路交通安全法的规定，在高速公路上行驶的车辆，车速超过 100km/h 时，应与同车道前车保持 100 米以上距离。为了保持最小安全行车距离 100 米，按车速 100km/h 计算，需要间隔至少 3.6 秒才能放行一辆车，因此出卡机每隔 3.6 秒出一张通行卡。在自动出卡机下放置一个盒子，自动出卡机按照 3.6 秒的间隔向盒子中投放通行卡。每辆进入高速公路的车辆，从盒子中领取通行卡之后才可以进入高速公路。
>
> 令牌桶可以看作是一个存放一定数量令牌的容器。系统按设定的速度向桶中放置令牌。当桶中令牌满时，多出的令牌溢出，桶中令牌不再增加。在使用令牌桶对流量规格进行评估时，是以令牌桶中的令牌数量是否足够满足报文的转发为依据的。每个需要被转发的报文，都要从令牌桶中领取一定数量的令牌（具体数量视报文大小而定），才可以被正常转发。如果桶中存在足够的令牌可以用来转发报文，称流量遵守或符合约定值，否则称为不符合或超标。

```java
import com.google.common.util.concurrent.RateLimiter;
import com.netflix.zuul.ZuulFilter;
import com.netflix.zuul.context.RequestContext;
import com.netflix.zuul.exception.ZuulException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cloud.netflix.zuul.filters.support.FilterConstants;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;

/**
 * 限流过滤器：令牌桶
 *
 * @author wangshuo
 * @date 2021/03/10
 */
@Component
@Slf4j
public class LimitFilter extends ZuulFilter {

    /**
     * google guava 提供的类
     * create 的参数：2 表示每秒 2 个；0.1 表示每 10 秒 1 个
     */
    private static final RateLimiter RATE_LIMITER = RateLimiter.create(2);

    @Override
    public String filterType() {
        // 提前拒绝，所以放到 PRE 中
        return FilterConstants.PRE_TYPE;
    }

    @Override
    public int filterOrder() {
        // 设置为最前面的过滤器
        return Integer.MIN_VALUE;
    }

    @Override
    public boolean shouldFilter() {
        return true;
    }

    @Override
    public Object run() throws ZuulException {
        log.info("LimitFilter run......");
        RequestContext ctx = RequestContext.getCurrentContext();
        // 可通过在 ctx 中设置值的方式，让后续过滤器不执行（提前退出）
        if (RATE_LIMITER.tryAcquire()) {
            ctx.set("limited", false);
        } else {
            log.info("limited...");
            ctx.set("limited", true);
            ctx.setSendZuulResponse(false);
            ctx.setResponseStatusCode(HttpStatus.TOO_MANY_REQUESTS.value());
            // 可以通过自定义异常以及全局异常处理给客户端返回标准的 JSON 格式返回值
            throw new RuntimeException("被限流啦");
        }
        return null;
    }
}
```

### 微服务的限流

1. guava 依赖

   ```xml
   <dependency>
       <groupId>com.google.guava</groupId>
       <artifactId>guava</artifactId>
   </dependency>
   ```

2. 自定义 Filter

   ```java
   package org.example.apipassenger.filter;
   
   
   import com.google.common.util.concurrent.RateLimiter;
   import lombok.extern.slf4j.Slf4j;
   import org.springframework.stereotype.Component;
   
   import javax.servlet.*;
   import javax.servlet.http.HttpServletResponse;
   import java.io.IOException;
   import java.io.PrintWriter;
   
   /**
    * @author wangshuo
    * @date 2021/03/10
    */
   @Component
   @Slf4j
   public class LimitFilter implements Filter {
   
       private static final RateLimiter RATE_LIMITER = RateLimiter.create(2);
   
       @Override
       public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
           log.info("limit filter ......");
           if (RATE_LIMITER.tryAcquire()) {
               chain.doFilter(request, response);
           } else {
               HttpServletResponse resp = (HttpServletResponse) response;
               resp.setContentType("application/json");
               resp.setCharacterEncoding("UTF-8");
               PrintWriter pw = resp.getWriter();
               pw.print("{\"code\":\"-1\", \"message\":\"限流啦\"}");
               pw.close();
           }
   
       }
   }
   ```

   

## 高可用

一般做法是在 zuul 的前面加一层 nginx+keepalived

## Zuul 的原理

Zuul 的本质就是 filter，通过 filter 解析来决定去访问哪个微服务。

发请求访问微服务也是通过 filter 实现的。

响应数据，也是通过 filter 实现

请求过来 → PRE（一组，鉴权，限流之类的过滤器） → ROUTE（一组，路由到别的服务，具体微服务） → POST（一组，处理响应）

**源码**

```java
/**
 * 实现了 HttpServlet
 */
public class ZuulServlet extends HttpServlet {
    
    /**
     * 重写了 service 方法，用自己的逻辑来处理请求
     */
    @Override
    public void service(javax.servlet.ServletRequest servletRequest, javax.servlet.ServletResponse servletResponse) throws ServletException, IOException {
        try {
            init((HttpServletRequest) servletRequest, (HttpServletResponse) servletResponse);

            // Marks this request as having passed through the "Zuul engine", as opposed to servlets
            // explicitly bound in web.xml, for which requests will not have the same data attached
            RequestContext context = RequestContext.getCurrentContext();
            context.setZuulEngineRan();
			// 第一种执行顺序：pre → error → post
            try {
                preRoute();
            } catch (ZuulException e) {
                error(e);
                postRoute();
                return;
            }
            // 第二种执行顺序：pre → route → error → post
            try {
                route();
            } catch (ZuulException e) {
                error(e);
                postRoute();
                return;
            }
            // 第三种执行顺序：pre → route → post → error
            try {
                postRoute();
            } catch (ZuulException e) {
                error(e);
                return;
            }

        } catch (Throwable e) {
            error(new ZuulException(e, 500, "UNHANDLED_EXCEPTION_" + e.getClass().getName()));
        } finally {
            RequestContext.getCurrentContext().unset();
        }
    }
}
```

其实共有四种执行顺序

1. pre → error → post
2. pre → route → error → post
3. pre → route → post → error
4. pre → route → post
