---
title: Ribbon 和 RestTemplate
date: '2020-07-04 00:00:00'
tags:
- MSB
- Spring Cloud
- Ribbon
- RestTemplate
- Java
---
# Ribbon 和 RestTemplate

## 服务间调用

微服务中，很多服务系统都在独立的进程中运行，通过各个服务系统之间的协作来实现一个大项目的所有业务功能。服务系统间 使用多种跨进程的方式进行通信协作，而基于 HTTP 的 RESTful 风格的网络请求是最为常见的交互方式之一。

**思考：**如果让我们写服务调用如何写。

1. 硬编码。不好。ip 域名写在代码中。目的：找到服务。

2. 根据服务名，找相应的 ip。目的：这样 ip 切换或者随便变化，对调用方没有影响。

   Map<服务名，服务列表> map;

3. 加上负载均衡。目的：高可用。

spring cloud 提供的方式：

1. RestTemplate
2. Feign

我个人习惯用 RestTemplate，因为自由，方便调用别的第三方的 http 服务。Feign 也可以，更面向对象一些，更优雅一些，就是需要配置。

## 负载均衡

当系统面临大量用户访问，负载过高的时候，通常会增加服务器数量来进行横向扩展（集群），多个服务器的负载需要均衡，以免出现服务器负载不均衡，部分服务器负载较大，部分服务器负载较小的情况。使用负载均衡，使得集群中服务器的负载保持在稳定高效的状态，从而提高整个系统的处理能力。

### 按软硬件分

#### 软件负载均衡

nginx，lvs 等

**常见负载均衡策略**

> 第一层可以使用 DNS，配置多个 A 记录，让 DNS 做第一层分发。
>
> 第二层比较流行的是反向代理。核心原理：代理根据一定规则，将 http 请求转发到服务器集群的单一服务器上。

#### 硬件负载均衡

F5

### 按客户端/服务端分

客户端负载均衡和服务端负载均衡最大的区别在于 ***服务端地址列表的存储位置，以及负载算法在哪里***。

#### 客户端的负载均衡

在客户端负载均衡中，所有的客户端节点都有一份自己要访问的服务端地址列表，这些列表统统都是从注册中心获取的。ribbon 就是客户端负载均衡。

#### 服务端的负载均衡

在服务端负载均衡中，客户端节点只知道单一服务代理的地址，服务代理则知道所有服务端的地址。nginx 就是服务端负载均衡。

## Ribbon

Ribbon 是 Netflix 开发的客户端负载均衡器，为 Ribbon 配置**服务提供者地址列表**后，Ribbon 就可以基于某种**负载均衡策略算法**，自动地帮助服务消费者去请求提供者。Ribbon 默认为我们提供了很多负载均衡算法，例如轮询，随机等。我们也可以实现自定义负载均衡算法。

### 手写负载均衡

1. 知道自己的请求目的地（虚拟主机名，默认是 spring.application.name）
2. 获取所有服务端地址列表（也就是注册表）
3. 选出一个地址，找到虚拟主机名对应的 ip，port（将虚拟主机名 对应到 ip 和 port 上）
4. 发起实际请求（最朴素的请求）

```java
@RestController
public class ConsumerController {
    @Autowired
    DiscoveryClient discoveryClient;

    @GetMapping("/client5")
    public Object client5() {
        // 1. 根据虚拟主机名获取所有 app
        Application app = eurekaClient.getApplication("eureka-provider");
        // 2. 获取 app 下的所有实例
        List<InstanceInfo> instances = app.getInstances();
        if (instances.size() > 0) {
            // 3. 随机选择一个实例
            InstanceInfo instance = instances.get((int) (Math.random() * instances.size()));
            InstanceInfo.InstanceStatus status = instance.getStatus();
            if (status.equals(InstanceInfo.InstanceStatus.UP)) {
                String url = "http://" + instance.getIPAddr() + ":" + instance.getPort() + "/getHi";
                // 4. 发起请求
                return new RestTemplate().getForObject(url, String.class);
            }
        }
        return null;
    }
}
```

### Ribbon 的组成

官网首页：https://github.com/Netflix/ribbon

- ribbon-core：核心的通用性代码。api 一些配置。

- ribbon-eureka：基于 eureka 封装的模块，能快速集成 eureka。

- ribbon-examples：学习示例。

- ribbon-httpclient：基于 apache httpClient 封装的 rest 客户端，集成了负载均衡模块，可以直接在项目中使用。

- ribbon-loadbalancer：负载均衡模块。

- ribbon-transport：基于 netty 实现多协议的支持。比如 http，tcp，udp 等。

### Spring Cloud 中 Ribbon 的使用

1. Ribbon 可以单独使用，作为一个独立的负载均衡组件。只是需要我们手动配置 服务地址列表。
2. Ribbon 与 Eureka 配合使用时，Ribbon 可自动从 Eureka Server 获取服务提供者地址列表（DiscoveryClient），并基于负载均衡算法，请求其中一个服务提供者实例。
3. Ribbon 与 OpenFeign 和 RestTemplate 进行无缝对接，让二者具有负载均衡的能力。OpenFeign 默认集成了 ribbon。

在 Spring Cloud 中如果需要使用客户端负载均衡，只需要使用`@LoadBalanced`注解即可，这样客户端在发起请求的时候会根据负载均衡策略从服务端列表中选择一个服务端，向该服务端发起网络请求，从而实现负载均衡。

### 负载均衡算法

默认实现

- ZoneAvoidanceRule（区域权衡策略）：复合判断 Server 所在区域的性能和 Server 的可用性，轮询选择服务器。

其他规则：

- BestAvailableRule（最低并发策略）：会先过滤掉由于多次访问故障而处于断路器跳闸状态的服务，然后选择一个并发量最小的服务。逐个找服务，如果断路器打开，则忽略。

- RoundRobinRule（轮询策略）：以简单轮询选择一个服务器。按顺序循环选择一个 server。

- RandomRule（随机策略）：随机选择一个服务器。

- AvailabilityFilteringRule（可用过滤策略）：会先过滤掉多次访问故障而处于断路器跳闸状态的服务和过滤并发的连接数量超过阀值得服务，然后对剩余的服务列表安装轮询策略进行访问。

- WeightedResponseTimeRule（响应时间加权策略）：据平均响应时间计算所有的服务的权重，响应时间越快服务权重越大，容易被选中的概率就越高。刚启动时，如果统计信息不中，则使用 RoundRobinRule（轮询）策略，等统计的信息足够了会自动的切换到 WeightedResponseTimeRule。响应时间长，权重低，被选择的概率低。反之，同样道理。此策略综合了各种因素（网络，磁盘，IO 等），这些因素直接影响响应时间。

- RetryRule（重试策略）：先按照 RoundRobinRule（轮询）的策略获取服务，如果获取的服务失败则在指定的时间会进行重试，进行获取可用的服务。如多次获取某个服务失败，就不会再次获取该服务。主要是在一个时间段内，如果选择一个服务不成功，就继续找可用的服务，直到超时。

### 切换负载均衡策略

#### 注解方式

##### 给所有服务指定 ribbon 策略

###### 第一种方式

```java
/**
 * 添加该配置类，并让其被 SpringBoot 主程序扫描到容器中
 */
@Configuration
public class IRuleConfig {

    /**
     * 修改 Ribbon 的负载均衡策略
     */
    @Bean
    public IRule iRule() {
        return new RandomRule();
    }
}
```

###### 第二种方式

```java
/**
 * 不让其被主程序扫描到容器中
 */
// @Configuration
public class IRuleConfig {
    /**
     * 修改 Ribbon 的负载均衡策略
     */
    @Bean
    public IRule iRule() {
        return new RandomRule();
    }
}
```

```java
@SpringBootApplication
// 在主程序类中使用该注解引用上方的配置类，使其生效
@RibbonClients(defaultConfiguration = IRuleConfig.class)
public class EurekaConsumerApplication {

    public static void main(String[] args) {
        SpringApplication.run(EurekaConsumerApplication.class, args);
    }

}
```

##### 针对服务指定 ribbon 策略

1. 添加该配置类，但是不能让其被主程序扫描到

```java
/**
 * 不让其被主程序扫描到容器中
 */
// @Configuration
public class IRuleConfig {
    /**
     * 修改 Ribbon 的负载均衡策略
     */
    @Bean
    public IRule iRule() {
        return new RandomRule();
    }
}
```

2. 新建一个配置类

```java
@Configuration
// 针对特定服务指定配置类
@RibbonClient(name = "eureka-provider", configuration = IRuleConfig.class)
public class RibbonConfig {
}
```

#### 配置文件方式

***配置文件方式优先级高于注解方式***

##### 针对服务指定 ribbon 策略

`${spring.application.name}`：替换为某个指定服务的服务名称

```yaml
${spring.application.name}:
  ribbon:
    NFLoadBalancerRuleClassName: com.netflix.loadbalancer.RandomRule
```

示例：

```yaml
# 为 eureka-provider 服务指定负载均衡策略
eureka-provider:
  ribbon:
    NFLoadBalancerRuleClassName: com.netflix.loadbalancer.RandomRule
```

### 自定义负载均衡策略

继承 `AbstractLoadBalanceRule` 类

```java
package com.example.eurekaconsumer.config;

import com.netflix.client.config.IClientConfig;
import com.netflix.loadbalancer.AbstractLoadBalancerRule;
import com.netflix.loadbalancer.ILoadBalancer;
import com.netflix.loadbalancer.Server;

import java.util.List;

/**
 * 自定义 Ribbon 负载均衡策略，需要继承 AbstractLoadBalancerRule
 *
 * @author wangshuo
 * @date 2021/01/07
 */
public class MyRule extends AbstractLoadBalancerRule {


    public Server choose(ILoadBalancer lb) {
        // 获取所有存活的服务
        List<Server> reachableServers = lb.getReachableServers();
        // 获取所有服务
        List<Server> allServers = lb.getAllServers();
        if (reachableServers.size() > 0) {
            // 随机返回一个服务
            return reachableServers.get((int) (Math.random() * reachableServers.size()));
        }
        return null;
    }

    @Override
    public Server choose(Object key) {
        // getLoadBalancer() 返回的 ILoadBalancer 包含 appName 为 key 的服务
        return choose(getLoadBalancer());
    }

    @Override
    public void initWithNiwsConfig(IClientConfig iClientConfig) {

    }

}
```

### Ribbon 独立使用

Ribbon 可以和服务注册中心 Eureka 一起工作，从服务注册中心获取服务端的地址信息，也可以在配置文件中使用 listOfServers 字段来设置服务端地址。

**1. 去掉 eureka-client 的依赖，只需要依赖 ribbon**

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-ribbon</artifactId>
</dependency>
```

**2. 配置文件**

```yaml
# 被负载均衡的服务端服务名
${srping.application.name}:
    ribbon:
      # 指定负载均衡策略，默认是轮询，此处配置为随机
      NFLoadBalancerRuleClassName: com.netflix.loadbalancer.RandomRule
      eureka:
        # 关闭从 Eureka 注册中心获取注册表
        enabled: false
      # 手动设置需要负载均衡的服务端地址
      listOfServers: localhost:8080,localhost:8081
```

### Ribbon 的超时和重试

**超时机制**

```yaml
ribbon:
  # 连接超时时间（ms）
  ConnectTimeout: 1000
  # 业务逻辑超时时间（ms）
  ReadTimeout: 2000
```

**超时重试机制**

当服务请求超时后，Ribbon 会根据其重试机制进行重试调用。默认情况下，如果只有一个 provider 的实例，其会重试调用该 provider 一次；如果有多个 provider 的实例，会先重试调用该 provider 一次，如果还超时，就会调用 provider 的 1 个负载均衡实例一次，如果还超时，就会返回超时异常。

```yaml
ribbon:
  # 同一台实例最大重试次数，不包括首次调用
  MaxAutoRetries: 1
  # 重试负载均衡其他的实例最大重试次数，不包括首次调用
  MaxAutoRetriesNextServer: 1
  # 是否所有操作都重试，所有操作指 GET 和 POST 请求，建议配置为 false，仅对 GET 请求进行重试，因为 POST 是更新操作，重试可能会出问题
  OkToRetryOnAllOperations: false
```

如果某次请求调用时，某个实例调用失败了，那么在 6 秒内如果又接收到了该请求，就不会去调用之前调用失败的实例了。6 秒后会恢复对该实例的调用

**小技巧**

```yaml
# ribbon 可以使用该方式针对某个服务进行修改配置，如果直接以 ribbon.xx，就是全局配置
${srping.application.name}:
    ribbon:
```

## RESTful

RESTful 网络请求是指 RESTful 风格的网络请求，其中 REST 是 Resource Representational State Transfer 的缩写，直接翻译即“资源表现层状态转移”。

- Resource 代表互联网资源。所谓“资源”是网络上的一个实体，或者说网上的一个具体信息。它可以是一段文本，一首歌曲，一种服务，可以使用一个 URI 指向它，每种“资源”对应一个 URI。
- Representational 是“表现层”意思。“资源”是一种消息实体，它可以有多种外在的表现形式，我们把“资源”具体呈现出来的形式叫作它的“表现层”。比如说文本可以用 TXT 格式进行表现，也可以使用 XML 格式，JSON 格式和二进制格式；视频可以用 MP4 格式表现，也可以用 AVI 格式表现。URI 只代表资源的实体，不代表它的形式。它的具体表现形式，应该由 HTTP 请求的头信息 Accept 和 Content-Type 字段指定，这两个字段是对“表现层”的描述。
- State Transfer 是指“状态转移”。客户端访问服务的过程中必然涉及数据和状态的转化。如果客户端想要操作服务端资源，必须通过某种手段，让服务器端资源发生“状态转移”。而这种转化是建立在表现层之上的，所以被称为“表现层状态转移”。客户端通过使用 HTTP 协议中的四个动词来实现上述操作，它们分别是：获取资源的 GET，新建或更新资源的 POST，更新资源的 PUT 和删除资源的 DELETE。

RESTful 的使用层次

> 第一个层次（Level 0）的 Web 服务只是使用 HTTP 作为传输方式，实际上只是远程方法调用（RPC）的一种具体形式。SOAP 和 XML-RPC 都属于此类。
> 第二个层次（Level 1）的 Web 服务引入了资源的概念。每个资源有对应的标识符和表达。
> 第三个层次（Level 2）的 Web 服务使用不同的 HTTP 方法来进行不同的操作，并且使用 HTTP 状态码来表示不同的结果。如 HTTP GET 方法来获取资源，HTTP DELETE 方法来删除资源。
> 第四个层次（Level 3）的 Web 服务使用 HATEOAS。在资源的表达中包含了链接信息。客户端可以根据链接来发现可以执行的动作。

## RestTemplate

RestTemplate 是 Spring 提供的同步 HTTP 网络客户端接口，它可以简化客户端与 HTTP 服务器之间的交互，并且它强制使用 RESTful 风格。它会处理 HTTP 连接和关闭，只需要使用者提供服务器的地址（URL）和模板参数。

1. 依赖注入

   ```java
   package com.example.eurekaconsumer.config;
   
   import org.springframework.cloud.client.loadbalancer.LoadBalanced;
   import org.springframework.context.annotation.Bean;
   import org.springframework.context.annotation.Configuration;
   import org.springframework.web.client.RestTemplate;
   
   /**
    * @author wangshuo
    * @date 2021/01/07
    */
   @Configuration
   public class RestTemplateConfig {
   
       /**
        * 必须添加 LoadBalanced 注解才能通过服务名进行调用，并进行负载均衡
        */
       @Bean
       @LoadBalanced
       public RestTemplate restTemplate() {
           return new RestTemplate();
       }
   }
   ```

2. 服务调用

   ```java
   String url ="http://eureka-provider/getHi";
   String respStr = restTemplate.getForObject(url, String.class);
   ```

### 不同请求方式示例

#### GET 请求处理

- **getForEntity()**：返回值是一个 ResponseEntity，ResponseEntity 是 Spring 对 HTTP 请求响应结果的封装，包含了几种重要的元素，如：responseCode，contentType，contentLength，responseBody 等
- **getForObject()**：把响应结果的请求体映射为一个对象进行返回

如果需要请求头等信息使用 getForEntity，只需要将请求体封装成对象用 getForObject

##### 1. 返回字符串

**生产者**

```java
@GetMapping("/string")
public String getString() {
    return "字符串";
}
```

**消费者**

```java
@GetMapping("/string")
public String getString() {
    String url = "http://eureka-provider/provider/restTemplate/string";
    return restTemplate.getForObject(url, String.class);
}
```

##### 2. 返回 Map

**生产者**

```java
@GetMapping("/map")
public Map<String, String> getMap() {
    return Collections.singletonMap("name", "zhangsan");
}
```

**消费者**

```java
@GetMapping("/map")
public Map<String, String> getMap() {
    String url = "http://eureka-provider/provider/restTemplate/map";
    return (Map<String, String>) restTemplate.getForObject(url, Map.class);
}
```

##### 3. 返回对象

**生产者**

```java
@GetMapping("/obj")
public Person getObj() {
    return new Person()
        .setName("zhangsan")
        .setAge(18);
}
```

**消费者**

```java
@GetMapping("/obj")
public Person getObj() {
    String url = "http://eureka-provider/provider/restTemplate/obj";
    return restTemplate.getForObject(url, Person.class);
}
```

**Person 类**

```java
public class Person {

    private String name;

    private Integer age;

    public String getName() {
        return name;
    }

    public Person setName(String name) {
        this.name = name;
        return this;
    }

    public Integer getAge() {
        return age;
    }

    public Person setAge(Integer age) {
        this.age = age;
        return this;
    }
}
```

##### 4. 传参调用-使用占位符

**生产者**

```java
@GetMapping("/obj-with-param")
public Person getObjWithParam(@RequestParam String name, @RequestParam Integer age) {
    return new Person()
        .setName(name)
        .setAge(age);
}
```

**消费者**

```java
@GetMapping("/obj-with-param")
public Person getObjWithParam(@RequestParam String name, @RequestParam Integer age) {
    // 参数使用占位符
    String url = "http://eureka-provider/provider/restTemplate/obj-with-param?name={1}&age={2}";
    // 传入的值要与占位符顺序一致
    return restTemplate.getForObject(url, Person.class, name, age);
}
```

##### 5. 传参调用-使用 map

**生产者**

```java
@GetMapping("/obj-with-param")
public Person getObjWithParam(@RequestParam String name, @RequestParam Integer age) {
    return new Person()
        .setName(name)
        .setAge(age);
}
```

**消费者**

```java
@GetMapping("/obj-with-map-param")
public Person getObjWithParam(@RequestParam Map<String, String> map) {
    // 参数使用占位符，此处{name}与 map 中的 key 要一一对应，如果 map 中没有该 key 会报错
    String url = "http://eureka-provider/provider/restTemplate/obj-with-param?name={name}&age={age}";
    // 把 map 作为参数传递
    return restTemplate.getForObject(url, Person.class, map);
}
```

#### POST 请求处理

- **postForEntity()**：返回值是一个 ResponseEntity，ResponseEntity 是 Spring 对 HTTP 请求响应结果的封装，包含了几种重要的元素，如：responseCode，contentType，contentLength，responseBody 等
- **postForObject()**：把响应结果的请求体映射为一个对象进行返回
- **postForLocation()**：用于资源重定向

postForEntity，postForObject 和 getForEntity，getForObject 用法大致一致

##### postForObject

**生产者**

```java
@PostMapping("/obj")
public Person postObj(@RequestBody Person person) {
    return person;
}
```

**消费者**

```java
@PostMapping("/obj")
public Person postForObject(@RequestBody Person person) {
    String url = "http://eureka-provider/provider/restTemplate/obj";
    return restTemplate.postForObject(url, person, Person.class);
}
```

##### postForLocation

**生产者**

```java
@PostMapping("/location")
public URI postForLocation(@RequestBody Person person, HttpServletResponse response) throws URISyntaxException {
    URI uri = new URI("https://www.baidu.com/s?wd=" + person.getName());
    // 需要设置头信息，否则返回的是 null
    response.setHeader("Location", uri.toString());
    return uri;
}
```

**消费者**

```java
@PostMapping("/location")
public URI postForLocation(@RequestBody Person person) {
    String url = "http://eureka-provider/provider/restTemplate/location";
    URI uri = restTemplate.postForLocation(url, person);
    System.out.println(uri);
    return uri;
}
```

#### DELETE，PATCH，PUT，OPTIONS（略）

#### exchange

exchange 提供统一的方法模板进行四种请求：GET，POST，DELETE，PUT，可以自定义 http 请求的头信息

```java
@GetMapping("/exchange")
public Object exchange(Person person) {
    String url = "http://eureka-provider/provider/restTemplate/obj";
    // 自定义 requestHeaders
    HttpHeaders httpHeaders = new HttpHeaders();
    httpHeaders.setContentType(MediaType.APPLICATION_JSON);
    // 设置 requestBody，requestHeaders
    HttpEntity httpEntity = new HttpEntity(person, httpHeaders);
    return restTemplate.exchange(url, HttpMethod.POST, httpEntity, Person.class).getBody();
}
```



### 拦截器

会拦截 restTemplate 发出的所有请求，可以对 restTemplate 发出的请求和响应结果进行附加操作。

需要实现`ClientHttpRequestInterceptor`接口

1. 添加拦截器

```java
import org.springframework.http.HttpRequest;
import org.springframework.http.client.ClientHttpRequestExecution;
import org.springframework.http.client.ClientHttpRequestInterceptor;
import org.springframework.http.client.ClientHttpResponse;

import java.io.IOException;

/**
 * @author wangshuo
 * @date 2021/01/09
 */
public class com.example.eurekaconsumer.interceptor.MyClientHttpRequestInterceptor implements ClientHttpRequestInterceptor {

    @Override
    public ClientHttpResponse intercept(HttpRequest request, byte[] body, ClientHttpRequestExecution execution) throws IOException {
        
        System.out.println("拦截啦！！！");
        System.out.println(request.getURI());
		
        ClientHttpResponse response = execution.execute(request, body);

        System.out.println(response.getHeaders());
        return response;
    }

}
```

2. 添加到 restTemplate 中

```java
@Bean
@LoadBalanced
public RestTemplate restTemplate() {
    RestTemplate restTemplate = new RestTemplate();
    // 添加拦截器
    restTemplate.getInterceptors()
        .add(new MyClientHttpRequestInterceptor());
    return restTemplate;
}
```
