---
title: 会话管理入门
date: '2021-01-31 00:00:00'
tags:
- MSB
- Session Manage
- Java
---

# 会话管理入门

## 什么是会话？会话管理常见的技术及框架

## Session，Cookies，Token

浏览器使用 HTTP 协议请求后台服务的时候，由于 HTTP 协议是无状态的，所以需要一种方式让服务器可以识别每次发送请求的浏览器是谁。常用的方式包括 session 和 token。

### Session&Cookies

![image-20210118171234872](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210118171235.png)

session 是会话级别的，sessionId 是保存在单个服务器本地的，如果搭建后端服务集群，sessionId 是不会共享的，所以浏览器从某个服务器获取 sessionId 后，去访问其他服务器是不行的。

当然也可以使用 Spring Session 等框架进行 session 共享来达到在服务集群中保持会话的目的。还可以把 session 放到第三方中间件中（例如 redis）

### Token

token 主要也是用于解决集群/微服务中身份验证的问题。同时其还可以支持跨平台。

![image-20210118191248230](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210118191248.png)

使用 token 的方式服务器端可以不保存 token，而是将 token 只保存在前端，token 中可以包含用户的 id 等信息，后端服务器拿到 token 后验证用户身份。如果单纯使用明文来设置 token，会存在安全风险，所以可以通过 jwt 来对 token 进行加密。

### JWT（Json Web Tokens）

JWT 是由三段信息构成：header、payload、signature

## 浏览器同源策略

**同源**：如果两个 URL 的 protocol、host、post 都相同的话，则这两个 URL 是同源的，否则就不是同源的。

**非同源网站间有三种行为受到限制** 

1. Cookie、LocalStorage 和 IndexDB 无法读取
2. DOM 无法获得
3. AJAX 请求不能发送

最常接触到的就是 AJAX 请求不能发送的问题：在做前后端分离的时候，如果前后端部署的时候是不同源的，例如前端部署在 8080 端口，后端部署在 9090 端口，那么就会出现前端发送 ajax 请求的时候报跨域请求的错误。

### Ajax 跨域请求的解决方案

除了架设服务器代理外，还包括三种方法规避

1. JSONP
2. WebSocket
3. CORS

#### JSONP

它的基本思想是：网页添加一个 `<script>` 标签，向服务器请求 JSON 数据，这种做法不受同源策略的限制。服务器收到请求后，将数据放在一个指定名字的回调函数里传过来。

JSONP 新旧浏览器都支持，同时请求的时候会将 Cookie 信息也发送过去

1. 首先，网页插入 `<script>` 元素，由它向跨源网址（example.com）发送请求

   ```javascript
   <script type="text/javascript" src="http://example.com/ip?callback=foo"></script>
   
   // 根据 example.com 提供的回调函数，在当前页面中添加该函数
   function foo(data) {
     console.log('Your public IP address is: ' + data.ip);
   };
   ```

   上面代码通过 `<script>` 元素，向服务器 `example.com` 发出请求。注意，该请求的查询字符串有一个 `callback` 参数，用来指定回调函数的名字，这对于 JSONP 是必需的。

   服务器收到这个请求以后，会将数据放在回调函数的参数位置返回。

   ```javascript
   // example.com/ip 接口，可以是 js 实现，也可以是其他语言
   <body onload='onload'></body>
   <script type="text/javascript">
       function onload(){
       // 可以调用与 example.com 同源的服务
       var data = {"ip": "8.8.8.8"};
       // 调用 foo 方法，把返回值作为参数传递
       foo(data);
   }
   </script>
   ```

   由于 `<script>` 元素请求的脚本，直接作为代码运行。这时，只要浏览器定义了 `foo` 函数，该函数就会立即调用。作为参数的 JSON 数据被视为 JavaScript 对象，而不是字符串，因此避免了使用 `JSON.parse` 的步骤。

#### CORS

CORS（Cross-Origin Resource Sharing，跨源资源分享）是 W3C 标准，**是跨源 AJAX 请求的根本解决方法**。相比 JSONP 只能发 `GET` 请求，CORS 允许任何类型的请求。

参考 [跨域资源共享 CORS 详解](http://www.ruanyifeng.com/blog/2016/04/cors.html)

##### 简单请求和非简单请求

浏览器将 CORS 请求分成两类：简单请求（simple request）和非简单请求（not-so-simple request）。

只要同时满足以下两大条件，就属于简单请求。凡是不同时满足下面两个条件，就属于非简单请求。

1. 请求方法是以下三种方法之一

- HEAD
- GET
- POST

2. HTTP 的头信息不超出以下几种字段

- Accept
- Accept-Language
- Content-Language
- Last-Event-ID
- Content-Type：只限于三个值 `application/x-www-form-urlencoded`、`multipart/form-data`、`text/plain`

这是为了兼容表单（form），因为历史上表单一直可以发出跨域请求。AJAX 的跨域设计就是，只要表单可以发，AJAX 就可以直接发。

浏览器对这两种请求的处理，是不一样的。

###### 简单请求

对于简单请求，浏览器直接发出 CORS 请求。具体来说，就是在头信息之中，增加一个 `Origin` 字段。

下面是一个例子，浏览器发现这次跨源 AJAX 请求是简单请求，就自动在头信息之中，添加一个 `Origin` 字段。

```http
GET /cors HTTP/1.1
Origin: http://api.bob.com
Host: api.alice.com
Accept-Language: en-US
Connection: keep-alive
User-Agent: Mozilla/5.0...
```

上面的头信息中，`Origin` 字段用来说明，本次请求来自哪个源（协议 + 域名 + 端口）。服务器根据这个值，决定是否同意这次请求。

如果 `Origin` 指定的源，不在许可范围内，服务器会返回一个正常的 HTTP 回应。浏览器发现，这个回应的头信息没有包含 `Access-Control-Allow-Origin` 字段（详见下文），就知道出错了，从而抛出一个错误，被 `XMLHttpRequest` 的 `onerror` 回调函数捕获。注意，这种错误无法通过状态码识别，因为 HTTP 回应的状态码有可能是 200。

如果 `Origin` 指定的域名在许可范围内，服务器返回的响应，会多出几个头信息字段。

```http
Access-Control-Allow-Origin: http://api.bob.com
Access-Control-Allow-Credentials: true
Access-Control-Expose-Headers: FooBar
Content-Type: text/html; charset=utf-8
```

上面的头信息之中，有三个与 CORS 请求相关的字段，都以 `Access-Control-` 开头。

**（1）Access-Control-Allow-Origin**

该字段是必须的。它的值要么是请求时 `Origin` 字段的值，要么是一个 `*`，表示接受任意域名的请求。

**（2）Access-Control-Allow-Credentials**

该字段可选。它的值是一个布尔值，表示是否允许发送 Cookie。默认情况下，Cookie 不包括在 CORS 请求之中。设为 `true`，即表示服务器明确许可，Cookie 可以包含在请求中，一起发给服务器。这个值也只能设为 `true`，如果服务器不要浏览器发送 Cookie，删除该字段即可。

**（3）Access-Control-Expose-Headers**

该字段可选。CORS 请求时，`XMLHttpRequest` 对象的 `getResponseHeader()` 方法只能拿到 6 个基本字段：`Cache-Control`、`Content-Language`、`Content-Type`、`Expires`、`Last-Modified`、`Pragma`。如果想拿到其他字段，就必须在 `Access-Control-Expose-Headers` 里面指定。上面的例子指定 `getResponseHeader('FooBar')` 可以返回 `FooBar` 字段的值。

###### 非简单请求

**预检请求**

非简单请求是那种对服务器有特殊要求的请求，比如请求方法是 `PUT` 或 `DELETE`，或者 `Content-Type` 字段的类型是 `application/json`。

非简单请求的 CORS 请求，会在正式通信之前，增加一次 HTTP 查询请求，称为“预检”请求（preflight）。

浏览器先询问服务器，当前网页所在的域名是否在服务器的许可名单之中，以及可以使用哪些 HTTP 动词和头信息字段。只有得到肯定答复，浏览器才会发出正式的 `XMLHttpRequest` 请求，否则就报错。

下面是一段浏览器的 JavaScript 脚本。

> ```javascript
> var url = 'http://api.alice.com/cors';
> var xhr = new XMLHttpRequest();
> xhr.open('PUT', url, true);
> xhr.setRequestHeader('X-Custom-Header', 'value');
> xhr.send();
> ```

上面代码中，HTTP 请求的方法是 `PUT`，并且发送一个自定义头信息 `X-Custom-Header`。

浏览器发现，这是一个非简单请求，就自动发出一个“预检”请求，要求服务器确认可以这样请求。下面是这个“预检”请求的 HTTP 头信息。

> ```http
> OPTIONS /cors HTTP/1.1
> Origin: http://api.bob.com
> Access-Control-Request-Method: PUT
> Access-Control-Request-Headers: X-Custom-Header
> Host: api.alice.com
> Accept-Language: en-US
> Connection: keep-alive
> User-Agent: Mozilla/5.0...
> ```

“预检”请求用的请求方法是 `OPTIONS`，表示这个请求是用来询问的。头信息里面，关键字段是 `Origin`，表示请求来自哪个源。

除了 `Origin` 字段，“预检”请求的头信息包括两个特殊字段。

**（1）Access-Control-Request-Method**

该字段是必须的，用来列出浏览器的 CORS 请求会用到哪些 HTTP 方法，上例是 `PUT`。

**（2）Access-Control-Request-Headers**

该字段是一个逗号分隔的字符串，指定浏览器 CORS 请求会额外发送的头信息字段，上例是 `X-Custom-Header`。

**预检请求的回应**

服务器收到“预检”请求以后，检查了 `Origin`、`Access-Control-Request-Method` 和 `Access-Control-Request-Headers` 字段以后，确认允许跨源请求，就可以做出回应。

> ```http
> HTTP/1.1 200 OK
> Date: Mon, 01 Dec 2008 01:15:39 GMT
> Server: Apache/2.0.61 (Unix)
> Access-Control-Allow-Origin: http://api.bob.com
> Access-Control-Allow-Methods: GET, POST, PUT
> Access-Control-Allow-Headers: X-Custom-Header
> Content-Type: text/html; charset=utf-8
> Content-Encoding: gzip
> Content-Length: 0
> Keep-Alive: timeout=2, max=100
> Connection: Keep-Alive
> Content-Type: text/plain
> ```

上面的 HTTP 回应中，关键的是 `Access-Control-Allow-Origin` 字段，表示 `http://api.bob.com` 可以请求数据。该字段也可以设为星号，表示同意任意跨源请求。

> ```http
> Access-Control-Allow-Origin: *
> ```

如果服务器否定了“预检”请求，会返回一个正常的 HTTP 回应，但是没有任何 CORS 相关的头信息字段。这时，浏览器就会认定，服务器不同意预检请求，因此触发一个错误，被 `XMLHttpRequest` 对象的 `onerror` 回调函数捕获。控制台会打印出如下的报错信息。

> ```bash
> XMLHttpRequest cannot load http://api.alice.com.
> Origin http://api.bob.com is not allowed by Access-Control-Allow-Origin.
> ```

服务器回应的其他 CORS 相关字段如下。

> ```http
> Access-Control-Allow-Methods: GET, POST, PUT
> Access-Control-Allow-Headers: X-Custom-Header
> Access-Control-Allow-Credentials: true
> Access-Control-Max-Age: 1728000
> ```

**（1）Access-Control-Allow-Methods**

该字段必需，它的值是逗号分隔的一个字符串，表明服务器支持的所有跨域请求的方法。注意，返回的是所有支持的方法，而不单是浏览器请求的那个方法。这是为了避免多次“预检”请求。

**（2）Access-Control-Allow-Headers**

如果浏览器请求包括 `Access-Control-Request-Headers` 字段，则 `Access-Control-Allow-Headers` 字段是必需的。它也是一个逗号分隔的字符串，表明服务器支持的所有头信息字段，不限于浏览器在“预检”中请求的字段。

**（3）Access-Control-Allow-Credentials**

该字段与简单请求时的含义相同。

**（4）Access-Control-Max-Age**

该字段可选，用来指定本次预检请求的有效期，单位为秒。上面结果中，有效期是 20 天（1728000 秒），即允许缓存该条回应 1728000 秒（即 20 天），在此期间，不用发出另一条预检请求。

**浏览器的正常请求和回应**

一旦服务器通过了“预检”请求，以后每次浏览器正常的 CORS 请求，就都跟简单请求一样，会有一个 `Origin` 头信息字段。服务器的回应，也都会有一个 `Access-Control-Allow-Origin` 头信息字段。

下面是“预检”请求之后，浏览器的正常 CORS 请求。

> ```http
> PUT /cors HTTP/1.1
> Origin: http://api.bob.com
> Host: api.alice.com
> X-Custom-Header: value
> Accept-Language: en-US
> Connection: keep-alive
> User-Agent: Mozilla/5.0...
> ```

上面头信息的 `Origin` 字段是浏览器自动添加的。

下面是服务器正常的回应。

> ```http
> Access-Control-Allow-Origin: http://api.bob.com
> Content-Type: text/html; charset=utf-8
> ```

上面头信息中，`Access-Control-Allow-Origin` 字段是每次回应都必定包含的。

## Shiro

Shiro 是 Java 的一个安全框架。目前，使用 Apache Shiro 的人越来越多，因为对比 Spring Security 它相当简单，可能没有 SpringSecuriry 功能强大，但是在实际工作时可能并不需要那么复杂的东西，所以使用小而简单的 Shiro 就足够了。

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210118211318.png)

### 核心功能

**Authentication**：身份认证/登录，验证用户是不是拥有相应的身份

**Authorization**：授权，即权限验证。验证某个已认证的用户是否拥有某个权限；即判断用户能否做事情，常见的如：验证某个用户是否拥有某个角色。或者细粒度的验证某个用户对某个资源是否具有某个权限。

**Session Manager**：会话管理，即用户登录后就是一次会话，在没有退出之前，它的所有信息都在会话中；会话可以是普通 JAVASE 环境的，也可以是如 Web 环境的

**Cryptography**：加密，保护数据的安全性，如密码加密存储到数据库，而不是明文存储

**Web Support**：Web 支持，可以非常容易的集成到 Web 环境

**Caching**：缓存，比如多用户登录后，其用户信息，拥有的角色/权限不必每次去查数据库，这样可以提高效率

**Concurrency**：shiro 支持多线程应用的并发验证，即如在一个线程中开启另一个线程，能把权限自动传播过去

**Testing**：提供测试支持

**Run As**：允许一个用户假装为另一个用户（如果他们允许）的身份进行访问

**Remember Me**：记住我，这是个非常常见的功能，即一次登录后，下次再来就不用登录了

### 组件

**Subject**：主体，代表当前“用户”，这个用户不一定是具体的人，与当前应用交互的任何东西都是 Subject，如网络爬虫，机器人等；即一个抽象概念。所有 Subject 都绑定到 SecurityManager，与 Subject 的所有交互都会委托给 SecurityManager；可以把 Subject 认为是一个门面，SecurityManger 才是实际的执行者

**SecurityManager**：安全管理器，即所有与安全有关的操作都会与 SecurityManager 交互，且它管理着所有 Subject；可以看出它是 Shiro 的核心，它负责与后面介绍的其他组件进行交互，如果学习过 SpringMVC，可以把它看成是 DispatcherServlet。

**Realm**：域，Shiro 从 Realm 获取安全数据（如用户，角色，权限），就是说 SecurityManager 要验证用户身份，那么它需要从 Realm 获取相应的用户进行比较以确定用户身份是否合法；也需要从 Realm 得到用户相应的角色/权限进行验证用户是否能进行操作；可以把 Realm 看成 DataSource，即安全数据源

**记住一点，Shiro 不会去维护用户、维护权限；这些需要我们自己去设计 / 提供；然后通过 Realm 注入给 Shiro 即可。**

## Spring Security

Spring Security 是一个能够为基于 Spring 的企业应用系统提供声明式的安全访问控制解决方案的安全框架。它提供了一组可以在 Spring 应用上下文中配置的 Bean，充分利用了 Spring AOP 和 Servlet 过滤器的功能。它提供全面的安全性解决方案，同时在 Web 请求级和方法调用级处理身份确认和授权。

Spring Security 的前身是 Acegi Security

## SSO

Single Sign On，单点登录。在多个应用系统中，用户只需一次登录就可以访问所有相互信任的应用系统

核心实现理念就是使用第三方应用来完成认证/鉴权

## Session 共享

集群中的服务共享 session。或者把 session 存放到第三方中间件（例如 redis）里

## OpenID

OpenID，主要用于使用第三方帐号（例如微信）登录某个网站。比如在使用微信扫码登录某个网站的时候，该网站是可以获取到微信提供的当前用户的公开信息的，其中就包含一个 openId 属性，该属性并不是真实的微信帐号，也不是微信官方数据库中的主 ID，就是给其他网站使用的一个 ID，其他网站可以通过该 ID 来确定当前用户是谁。

## OAuth

参考 [理解 OAuth 2.0](https://www.ruanyifeng.com/blog/2014/05/oauth_2_0.html)

### 名词定义

（1）**Third-party application**：第三方应用程序，本文中又称“客户端”（client），即上一节例子中的“云冲印”。

（2）**HTTP service**：HTTP 服务提供商，本文中简称“服务提供商”，即上一节例子中的 Google。

（3）**Resource Owner**：资源所有者，本文中又称“用户”（user）。

（4）**User Agent**：用户代理，本文中就是指浏览器。

（5）**Authorization server**：认证服务器，即服务提供商专门用来处理认证的服务器。

（6）**Resource server**：资源服务器，即服务提供商存放用户生成的资源的服务器。它与认证服务器，可以是同一台服务器，也可以是不同的服务器。

### OAuth 的思路

OAuth 在“客户端”与“服务提供商”之间，设置了一个授权层（authorization layer）。“客户端”不能直接登录“服务提供商”，只能登录授权层，以此将用户与客户端区分开来。“客户端”登录授权层所用的令牌（token），与用户的密码不同。用户可以在登录的时候，指定授权层令牌的权限范围和有效期。

“客户端”登录授权层以后，“服务提供商”根据令牌的权限范围和有效期，向“客户端”开放用户储存的资料。

这个授权层

### 运行流程

![OAuth 运行流程](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210118230055.png)

（A）用户打开客户端以后，客户端要求用户给予授权。

（B）用户同意给予客户端授权。

（C）客户端使用上一步获得的授权，向认证服务器申请令牌。

（D）认证服务器对客户端进行认证以后，确认无误，同意发放令牌。

（E）客户端使用令牌，向资源服务器申请获取资源。

（F）资源服务器确认令牌无误，同意向客户端开放资源。

### OpenID 和 OAuth 的区别

OAuth 主要关注授权（authorization），OpenID 主要关注认证（authentication），前者关注“用户能做什么”，后者关注“用户是谁”. OAuth 是大于 OpenID 的，OAuth 可以提供更多的权限给客户端，OpenID 只是提供公开的信息给客户端。

## CAS

Central Authentication Service，中央认证服务。对于完全不同域名的系统，cookie 是无法跨域名共享的，所以使用 CAS 是直接启用一个专门用于登录的域名来提供所有的系统登录。

## XSS 和 CSRF

### XSS

Cross Site Scripting，跨站脚本攻击。攻击者将恶意脚本代码嵌入到正常用户会访问到的页面中，当用户访问该页面时，即可导致自动执行该恶意脚本，从而进行恶意攻击。

常见的方式例如在论坛的发帖或回复的时候，在评论中添加 `<script>` 等标签，引入恶意脚本，如果网站没有对评论中的标签进行转义等操作，当其他用户访问到该页面的时候，就会自动执行该恶意脚本。

**常用的 XSS 攻击手段和目的有**

1. 盗用 cookie，获取敏感信息。
2. 利用植入 Flash，通过 crossdomain 权限设置进一步获取更高权限；或者利用 Java 等得到类似的操作。
3. 利用 iframe、frame、XMLHttpRequest 或上述 Flash 等方式，以（被攻击）用户的身份执行一些管理动作，或执行一些一般的如发微博、加好友、发私信等操作。
4. 利用可被攻击的域受到其他域信任的特点，以受信任来源的身份请求一些平时不允许的操作，如进行不当的投票活动。
5. 在访问量极大的一些页面上的 XSS 可以攻击一些小型网站，实现 DDoS 攻击的效果。

#### 解决方法

常用的方法是添加过滤器，对输入框输入的数据进行转义，把其中的 html 标签进行转义，例如把 `<` 转义为 `&lt;`，`>` 转义为 `$gt;` 等

### CSRF

Cross-site request forgery，跨站请求伪造，也称为 one-click attack 或者 session riding。

> 比如某个银行的转账操作 URL 地址为：http://www.examplebank.com/withdraw?account=AccoutName&amount=1000&for=PayeeName
>
> 那么，一个恶意攻击者可以在另一个网站上使用 `<img>` 标签放置一个 `<img src="http://www.examplebank.com/withdraw?account=Alice&amount=1000&for=Badman">`
>
> 如果有一个用户刚登录了该银行不久，登录信息尚未过期，此时他访问了该恶意站点，那么他就会损失 1000 资金

CSRF 主要就是利用 `img` 等标签不受同源策略的限制，并且在恶意网站获取用户在某网站的 cookie 认证信息，从而模拟该用户向该网站发送请求。通过 `img` 标签的 src 属性发送的请求，会把 cookie 也携带过去。

#### 解决方法

由于 CSRF 主要针对的就是获取到用户的 cookie 信息，所以单独使用 cookie 已经是不安全的。

##### CSRF Token

用户登录时，系统发放并一个 CsrfToken，用户携带该 CsrfToken 与用户名和密码等参数完成登录。登录成功后，系统会记录该 CsrfToken，之后用户的任何请求都需要携带该 CsrfToken（可以放到请求参数或请求头中），并由系统进行校验。

##### 使用请求头的 referer

通过请求头中的 `referer` 字段判断请求的来源。没一个发送给后端的请求，在请求头中都会包含一个 `referer` 字段，这个字段标识着请求的来源。在后端可以通过过滤器获取请求的 `referer` 字段，判断 `referer` 字段是否是以自己网站的域名开头或是信任网站。

