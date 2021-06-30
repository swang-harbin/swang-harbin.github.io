---
title: internal-common
date: '2021-02-23 20:54:00'
tags:
- MSB
- Project
- 网约车三期
- Java
---

# internal-common
```xml
<artifactId>internal-common</artifactId>
<!-- 
    如果一个项目依赖于带-SNAPSHOT 的 jar，例如 XXX-SNAPSHOT.jar，那么每次构建该项目的时候它都会优先去远程仓库检查是否有更新，如果有就将它拉取过来，可以保证使用的 jar 包是最新的，在开发的时候使用，可以提高团队协作效率；但是不能在生产环境中使用，否则可能会将没有经过测试的 jar 打包到了生产环境中。
    如果一个项目依赖与不带-SNAPSHOT 的 jar，例如 XXX.jar，那么每次构建该项目的时候如果本地有该 jar，就不会去判断远程仓库上是否有更新了。
-->
<version>0.0.1-SNAPSHOT</version>
<name>internal-common</name>
```



api-passenger：发送验证码

- URI：`sms/verify-code/send`

- 参数：

  ```json
  {
      "phoneNumber": "13812345678"
  }
  ```

service-verification-code：生成验证码

- URI：`verify-code/generate/{身份}/{手机号}
  - 身份：司机，乘客，用于区分乘客类型
  - 手机号：

service-sms：发送短信（通用），腾讯短信通，阿里短信服务，华信

- URL：`send/sms-template`

- 参数：

  ```json
  {
      "receivers":[13812345678],
      "data":[
          {
              "id":"SMS 144145499",
              "templateMap":{
                  "code":"018900"
              }
          }
      ]
  }
  ```

  - data.id：短信模板 id

    > - **模板内容**为：`您正在申请手机注册，验证码为：${code}，5 分钟内有效！`。
    > - **模板变量**为：`${code}`。






随机数生成代码

```java
// method2 会比 method1 提高大约 10 背效率
int sum = 1000000;
// method1 230ms 左右
for (int i = 0; i < sum; i++) {
    String code = (Math.random() + "").substring(2, 8);
}
// method2 30ms 左右
for (int i = 0; i < sum; i++) {
    String code = String.valueOf((int) ((Math.random() * 9 + 1) * 100000));
}
```



常用的，不变的用缓存，不要每次都用 DB，例如短信模板



提升 QPS

- 提高并发数：
  - 能用多线程使用多线程
  - 增加各种连接数：tomcat，mysql，redis 等连接数
  - 服务无状态，便于横向扩张（添加机器）
  - 让服务能力对等（eureka server 的 url 乱序）
- 减少响应时间
  - 异步（保证最终一致性即可，不需要及时的，例如下单成功的邮件），流量削峰
  - 缓存：减少磁盘 IO，适合读多写少的场景 
  - 数据库优化
  - 大量数据分批次返回
  - 减少调用链（微服务中，同一功能如果用到的模块少，不需要提取到 common 工程），减少网络 IO
  - 长连接。不要轮询



减少 IO，I/O 瓶颈：网络，磁盘



估算线程数

8 核 16 线程，应该开几个线程

线程数 = CPU 可用核数 / (1 - 阻塞系数)

阻塞系数：io 密集型接近 1，计算（CPU）密集型接近 0



## 登录功能

![image-20210305192506944](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210305192507.png)

通过网关 Zuul 来验证 Token



Zuul 设置 ZuulFilter 不执行后面的 ZuulFilter

```java

```



三级等保：手机号，身份证号脱敏





## 听单，SSE（server sent events）

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>

    <script>
        console.info("司机听单中");
        var source = new EventSource("/sse/listen/driver/1");
        source.onmessage = function (evt) {
            console.info("听单");
            console.info(evt.data);
            document.getElementById("rdiv").innerText = evt.data;
        }
    </script>
</head>
<body>
听单：<span id="rdiv"></span>
</body>
</html>
```

```java
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/sse")
public class SseController {
    @GetMapping(value = "/listen/driver/{driverId}", produces = "text/event-stream;charset=utf-8")
    public String getStream(@PathVariable String driverId) {
        // 要带\n\n
        return "data:" + Math.random() + "\n\n";
    }
}
```



本地事务，柔性事务，分布式事务 seata



虚拟小号：阿里小号，可以把电话录音都存到 oss 上，方便后续审查



数据结构 + 算法



原料 + 规则 + 操作



![image-20210307012622040](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210307012622.png)



## 灰度发布

又叫金丝雀发布，指在黑与白之间，能够平滑过渡的一种发布方式。

让大部分用户依旧使用旧的系统，选出小部分符合条件的用户来访问新系统。依据测试条件，逐步对所有用户开放新系统。



借助灰度发布可以进行**A/B 测试**，步骤：

1. 制定灰度规则，区分哪些用户，走哪些服务



eureka 的 metadata 可以通过 github wiki 提供的 url 进行动态修改，所以可以通过修改 metadata 和用户的信息进行匹配，来进行 A/B 测试。



### Zuul 灰度发布

可以通过在 eureka client 的 metadata 中设置 version 属性，并在 zuulFilter 中对请求进行过滤

1. 通过设置 eureka 的 matedata-map 来表示服务的版本

   ```yaml
   eureka:
     instance:
       metadata-map:
         version: v1
   ```

2. 通过数据库记录灰度发布用户的信息

   ```sql
   create table common_gray_rule
   (
       id           int         not null,
       user_id      int         null,
       service_name varchar(32) null,
       meta_version varchar(32) null,
       constraint common_gray_rule_id_uindex
           unique (id)
   );
   
   alter table common_gray_rule
       add primary key (id);
   
   INSERT INTO `online-taxi-three`.common_gray_rule (id, user_id, service_name, meta_version) VALUES (1, 1, 'api-passenger', 'v2');
   ```

3. 在 ZuulFilter 中对用户进行过滤

   ```java
   package com.example.cloudzuul.filter;
   
   import com.example.cloudzuul.dao.CommonGrayRuleDAO;
   import com.example.cloudzuul.entity.CommonGrayRule;
   import com.netflix.zuul.ZuulFilter;
   import com.netflix.zuul.context.RequestContext;
   import com.netflix.zuul.exception.ZuulException;
   import io.jmnarloch.spring.cloud.ribbon.support.RibbonFilterContextHolder;
   import org.springframework.beans.factory.annotation.Autowired;
   import org.springframework.cloud.netflix.zuul.filters.support.FilterConstants;
   import org.springframework.stereotype.Component;
   
   import javax.servlet.http.HttpServletRequest;
   import java.util.List;
   
   @Component
   public class GrayFilter extends ZuulFilter {
   
       @Autowired
       private CommonGrayRuleDAO commonGrayRuleDAO;
   
       @Override
       public String filterType() {
           return FilterConstants.ROUTE_TYPE;
       }
   
       @Override
       public int filterOrder() {
           return 0;
       }
   
       @Override
       public boolean shouldFilter() {
           return true;
       }
   
       @Override
       public Object run() throws ZuulException {
           // 从请求头中获取 token，然后根据 token 里存的用户信息，查库
           RequestContext context = RequestContext.getCurrentContext();
           HttpServletRequest request = context.getRequest();
           String requestURI = request.getRequestURI();
           Integer userid = Integer.parseInt(request.getHeader("userid"));
           List<CommonGrayRule> rules = commonGrayRuleDAO.selectByUserId(userid);
           String version = "v1";
           // 如果有灰度测试资格
           if (!rules.isEmpty()) {
               for (CommonGrayRule rule : rules) {
                   if (requestURI.contains(rule.getServiceName())) {
                       version = rule.getMetaVersion();
                       break;
                   }
               }
           }
           // 将请求转发到指定版本的服务上
           RibbonFilterContextHolder.getCurrentContext().add("version", version);
           return null;
       }
   }
   ```

### Ribbon 灰度实现

![image-20210308163322608](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210308163323.png)

1. 自定义 Rule 规则（根据用户信息，选择合适的服务）

   ```java
   package org.example.apipassenger.config;
   
   import com.netflix.client.config.IClientConfig;
   import com.netflix.loadbalancer.AbstractLoadBalancerRule;
   import com.netflix.loadbalancer.ILoadBalancer;
   import com.netflix.loadbalancer.Server;
   import com.netflix.niws.loadbalancer.DiscoveryEnabledServer;
   import org.example.apipassenger.util.RibbonParametersUtil;
   import org.springframework.beans.factory.annotation.Autowired;
   
   import java.util.List;
   import java.util.Map;
   
   /**
    * @author wangshuo
    * @date 2021/03/08
    */
   public class GrayRule extends AbstractLoadBalancerRule {
   
       @Autowired
       private RibbonParametersUtil ribbonParametersUtil;
   
       @Override
       public void initWithNiwsConfig(IClientConfig clientConfig) {
       }
   
       @Override
       public Server choose(Object key) {
           return choose(getLoadBalancer(), key);
       }
   
       public Server choose(ILoadBalancer lb, Object key) {
   
           Server grayServer = null;
           Server normalServer = null;
           // 获取所有可达的服务
           List<Server> reachableServers = lb.getReachableServers();
   
           // 根据用户选服务
           // 根据当前线程取用户 id，此处使用 version 代替
           String grayVersion = "v2";
           String userVersion = null;
           Map<String, String> map = ribbonParametersUtil.get();
           if (map != null && map.containsKey("version")) {
               userVersion = map.get("version");
           }
   
           // 根据用户选服务
           for (int i = 0; i < reachableServers.size(); i++) {
               DiscoveryEnabledServer des = (DiscoveryEnabledServer) reachableServers.get(i);
               Map<String, String> metadata = des.getInstanceInfo().getMetadata();
               if (grayVersion.equals(metadata.get("version")) && grayVersion.equals(userVersion)) {
                   grayServer = des;
                   break;
               } else {
                   normalServer = des;
               }
           }
           return grayServer == null ? normalServer : grayServer;
       }
   
   }
   ```

2. 拦截用户请求，将用户的信息存储到 ThreadLocal 中，以便在上方 IRule 中获取

   ```java
   package org.example.apipassenger.aspect;
   
   import org.aspectj.lang.JoinPoint;
   import org.aspectj.lang.annotation.Aspect;
   import org.aspectj.lang.annotation.Before;
   import org.aspectj.lang.annotation.Pointcut;
   import org.example.apipassenger.util.RibbonParametersUtil;
   import org.springframework.beans.factory.annotation.Autowired;
   import org.springframework.stereotype.Component;
   import org.springframework.web.context.request.RequestContextHolder;
   import org.springframework.web.context.request.ServletRequestAttributes;
   
   import javax.servlet.http.HttpServletRequest;
   import java.util.HashMap;
   import java.util.Map;
   
   /**
    * @author wangshuo
    * @date 2021/03/08
    */
   @Aspect
   @Component
   public class RequestAspect {
   
       @Autowired
       private RibbonParametersUtil ribbonParametersUtil;
   
       @Pointcut("execution(* org.example.apipassenger.controller..*Controller*.*(..))")
       private void anyMethod() {
       }
   
       @Before("anyMethod()")
       public void before(JoinPoint joinPoint) {
           HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.getRequestAttributes()).getRequest();
           String version = request.getHeader("version");
           Map<Object, Object> map = new HashMap<>(16);
           map.put("version", version);
           ribbonParametersUtil.set(map);
       }
   }
   ```

3. ThreadLocal 工具类

   ```java
   package org.example.apipassenger.util;
   
   import org.springframework.stereotype.Component;
   
   /**
    * @author wangshuo
    * @date 2021/03/08
    */
   @Component
   public class RibbonParametersUtil {
   
       public static final ThreadLocal LOCAL = new ThreadLocal();
   
       public <T> T get() {
           return (T) LOCAL.get();
       }
   
       public <T> void set(T t) {
           LOCAL.set(t);
       }
   }
   ```

4. 配置类

   ```java
   package org.example.apipassenger.config;
   
   import com.netflix.loadbalancer.IRule;
   import org.springframework.context.annotation.Bean;
   import org.springframework.context.annotation.Configuration;
   
   /**
    * @author wangshuo
    * @date 2021/03/08
    */
   @Configuration
   public class GrayRibbonConfig {
   
       @Bean
       public IRule iRule() {
           return new GrayRule();
       }
   }
   ```

#### 简单方式

1. 引入依赖

   ```xml
   <dependency>
       <groupId>io.jmnarloch</groupId>
       <artifactId>ribbon-discovery-filter-spring-cloud-starter</artifactId>
       <version>2.1.0</version>
   </dependency>
   ```

2. 在 Aspect 中定义灰度发布的规则进行请求转发

   ```java
   package org.example.apipassenger.aspect;
   
   import io.jmnarloch.spring.cloud.ribbon.api.RibbonFilterContext;
   import io.jmnarloch.spring.cloud.ribbon.support.RibbonFilterContextHolder;
   import org.aspectj.lang.JoinPoint;
   import org.aspectj.lang.annotation.Aspect;
   import org.aspectj.lang.annotation.Before;
   import org.aspectj.lang.annotation.Pointcut;
   import org.springframework.stereotype.Component;
   import org.springframework.web.context.request.RequestContextHolder;
   import org.springframework.web.context.request.ServletRequestAttributes;
   
   import javax.servlet.http.HttpServletRequest;
   
   /**
    * @author wangshuo
    * @date 2021/03/08
    */
   @Aspect
   @Component
   public class RequestAspect {
   
   
       @Pointcut("execution(* org.example.apipassenger.controller..*Controller*.*(..))")
       private void anyMethod() {
       }
   
       @Before("anyMethod()")
       public void before(JoinPoint joinPoint) {
           HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.getRequestAttributes()).getRequest();
           // 从数据库中查询出用户的灰度发布相关信息
           String version = request.getHeader("version");
           RibbonFilterContext context = RibbonFilterContextHolder.getCurrentContext();
           // 制定灰度发布规则，将请求转发到响应的服务器
           context.add("version", version);
       }
   }
   
   ```

   

## 蓝绿发布

小规模发布，用户都在白天用，可以在晚上挺服务更新

如果用户规模大，白天晚上都会有很多人用，怎么做到不停服更新



绿色环境表示当前正常运行的已上线版本，蓝色环境表示需要被上线的新版本。

1. 将蓝色环境的服务都启动起来，并进行测试
2. 如果测试没问题，修改网关层，把请求转发到蓝色环境
3. 如果上线没问题，即可把绿色环境的服务器全部删除

通过蓝绿部署需要扩充 2 倍的服务器，费钱。



## 滚动发布

由于蓝绿发布需要扩充 2 倍的服务器，太费钱，所以出现了滚动发布的方式。

1. 先将绿色环境的服务器停 1 台
2. 然后将蓝色环境的服务器启动 1 台，替换掉停掉的绿色服务器
3. 然后依次停 1 台绿色，启一台蓝的，直到所有都换成蓝的

会出现新服务和老服务混在一起的情况，如果发布过程中有一个请求报错了，是老服务出的错，此时就又需要把所有老服务再恢复回去。



## 网关 Zuul 在生产中的问题

网关 Zuul 生产中的问题：3 个问题：

1. token 不向后传（单体项目->微服务）

   ![image-20210308204738502](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210308204738.png)

   在网关中添加如下配置即可

   ```yaml
   zuul:
     # 表示忽略下面的值向微服务传播。以下配置为空，表示所有请求头都透传到后面的微服务
     sensitive-headers:
   ```

   如果是微服务的话，不应该通过该方式全部传过去。应该将鉴权提到网关层来处理。

   默认不传下方三个头信息

   ![image-20210308213935489](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210308213935.png)

2. 老项目改造中的路由问题（原来 url 不能变，通过网关去适应）

   https://www.cnblogs.com/logan-w/p/12498943.html

   前端已经写好了调用接口的 url，例如：/account/xx，但是服务端真实提供的是/account/xxx 接口，需要将前端向/account/xx 发送的请求路由到/account/xxx 上

   > 1. 可以在 Zuul 中添加自定义 Filter，在 Filter 中对请求进行转发

3. 动态路由

   在 Filter 中可以根据用户的地域等信息做动态路由

网关要做的事

- 分发服务
- 身份认证（鉴权）
- 过滤请求
- 监控
- 路由（动态）
- 限流

后面服务要重复做的事情，可以放到网关来做



可以将过滤器是否生效存储到数据库中，然后在后台提供页面，动态控制。

> 比如新项目，前期需要拉新，所以允许一个设备注册多个帐号。后期不需要拉新了，就让设备黑名单过滤器生效，限制设备的注册用户数。

