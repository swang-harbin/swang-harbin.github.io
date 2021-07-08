---
title: Spring Security 集群环境下的使用
date: '2021-01-26 00:00:00'
tags:
- MSB
- Session Manage
- Spring Security
- Java
---
# Spring Security 集群环境下的使用

Spring Security 在集群环境下要解决的主要就是 SSO 问题，登录一次就可以访问所有相互信任的应用系统。

## 有状态会话和无状态会话

用户在登录的时候，主要包含两个操作：认证和鉴权。认证通常指验证用户的用户名和密码；鉴权是给用户授权。

会话是否有状态主要就是根据服务器端是否保留用户的信息来区分，有状态会话会保存，无状态会话不保存。

有状态会话通常使用 session+cookie 的方式对用户进行认证，无状态会话通常使用 Token 的方式。

![image-20210118171234872](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210118171235.png)


![image-20210118191248230](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210118191248.png)

有状态的会话会将用户的信息保存在服务端，并设置一个 sessionId，当客户端访问的时候，根据 sessionId 从服务端获取到用户的信息。

无状态会话会将用户的信息保存在客户端，当客户端访问的时候，将客户端携带过来的 token 进行解析来获取到用户的信息。

## Session 共享

为了解决集群环境下，不能单点登录的问题，所以出现了 session 共享的解决方案。session 共享依旧属于有状态的会话。

session 共享有两种实现方案

1. 各个服务间自己进行复制：存在数据一致性的问题
2. 把 session 放到中间件（如 redis）里：可以保证数据一致性，但由于需要与中间件进行通讯，会增加网络开销。

### SpringSession + Redis 实现 Session 共享

1. 依赖

   ```xml
   <dependency>
       <groupId>org.springframework.boot</groupId>
       <artifactId>spring-boot-starter-data-redis</artifactId>
   </dependency>
   <dependency>
       <groupId>org.springframework.boot</groupId>
       <artifactId>spring-boot-starter-security</artifactId>
   </dependency>
   <dependency>
       <groupId>org.springframework.session</groupId>
       <artifactId>spring-session-data-redis</artifactId>
   </dependency>
   <dependency>
       <groupId>org.springframework.boot</groupId>
       <artifactId>spring-boot-starter-web</artifactId>
   </dependency>
   ```

2. 配置文件

   ```yaml
   server:
     port: 8080
   spring:
     redis:
       host: localhost
       port: 6379
     security:
       user:
         name: admin
         password: 123456
   ```

## JWT

[JSON Web Token](https://jwt.io)，基于 JSON 的令牌安全验证（在某些特定场合可以替代 session 或 cookie），一次生成随处校验

### JWT 的组成

JWT 由三段信息构成，将三段信息用`.`连接在一起就构成了一个 JWT 字符串。例如

```jwt
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
```

三部分分别为头部（header），载荷（playload），签名（signature）

### 头部信息（header）

用于记录 Token 的基本信息，header 包含两部分属性

- Token 类型
- 加密算法

#### 示例

```json
{
    "alg": "HS256",
    "typ": "JWT"
}
```

将该 json 进行 base64 加密，即可得到 JWT 的第一部分

```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9
```

### 载荷（playload）

用于存放数据的地方，自定义的数据都放在这里。**该处存储的数据是可以被解密的，所以最好存储加密后的数据**。

存储在这里的数据称为 claims。有三种类型的 claims。

- JWT 标准中已注册的 claims（Registered Claims）
- 公共 claims（Public Claims）
- 私有 claims（Private Claims）

#### Registered Claims

JWT 标准中预先定义的 claims。提供了一系列常用的 claims。

- `iss`：JWT 的发行人（issuer）
- `sub`：JWT 的主题（subject）。须在 iss 范围内唯一或全球唯一，用于标识该 token 应用于哪个特定应用程序
- `aud`：JWT 的接收人（audience）。
- `exp`：JWT 的到期时间（expiration time），到期时间必须大于签发时间
- `nbf`：JWT 在某个时间之后（Not Before）才生效。该时间必须在签发时间和到期时间之间
- `jti`：JWT 的唯一身份标识（JWT ID）

#### Public Claims

可以添加任何信息。属性名不能冲突，所以推荐定义 [IANA JSON Web Token Registry](https://www.iana.org/assignments/jwt/jwt.xhtml) 里包含的属性名

#### Private Claims

也可以添加任何信息。可以添加发行人和接收人协商好的数据。属性名即不在 Registered 里，也不在 Public 里。属性名可以冲突，所以要谨慎使用。

##### 示例

```json
{   
    "sub": "1234567890",
    "name": "John Doe",
    "iat": 1516239022
}
```

将该 json 进行 base64 加密，即可得到 JWT 的第二部分

```
eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ
```

#### 验证签名（VERIFY SIGNATURE）

将 **Base64 加密后的 header** 和 **Base64 加密后的 payload** 通过 `.` 进行连接，根据 header 中指定的**加密算法**加入**自定义的密钥**进行加密，即可得到 JWT 的第三部分

```
TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ
```

### 拼接 JWT

把得到的三部分用 `.` 连接在一起，即可得到完整的 JWT

```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
```

## JWT 的使用方式

客户端收到服务器返回的 JWT，可以储存在 Cookie 里面，也可以储存在 localStorage。

此后，客户端每次与服务器通信，都要带上这个 JWT。你可以把它放在 Cookie 里面自动发送，但是这样不能跨域，所以更好的做法是放在 HTTP 请求的头信息 `Authorization` 字段里面。

```http
Authorization: Bearer <token>
```

另一种做法是，跨域的时候，JWT 就放在 POST 请求的数据体里面。

## JWT 的使用

1. 引入依赖

   ```xml
   <dependency>
       <groupId>io.jsonwebtoken</groupId>
       <artifactId>jjwt</artifactId>
       <version>0.9.1</version>
   </dependency>
   ```

2. 工具类

   ```java
   package com.example.jwt.util;
   
   import io.jsonwebtoken.Claims;
   import io.jsonwebtoken.Jwts;
   import io.jsonwebtoken.SignatureAlgorithm;
   
   import java.util.Date;
   import java.util.concurrent.TimeUnit;
   
   
   public class JwtUtils {
   
       private static final String SECRET = "ko346134h_we]rg3in_yip1!";
   
       public static final SignatureAlgorithm SIGNATURE_ALGORITHM = SignatureAlgorithm.HS256;
   
   
       private static final Long TTL_MILLIS = TimeUnit.HOURS.toMillis(12);
   
       public static String createToken(String subject) {
           Date now = new Date();
           return Jwts.builder()
               .setSubject(subject)
               .setIssuedAt(now)
               .setExpiration(new Date(now.getTime() + TTL_MILLIS))
               .signWith(SIGNATURE_ALGORITHM, SECRET)
               .compact();
   
       }
   
       public static String parseJWT(String jwt) {
           Claims claims = Jwts.parser()
               .setSigningKey(SECRET)
               .parseClaimsJws(jwt).getBody();
           return claims.getSubject();
       }
   
   }
   ```

3. 在 Filter 中进行验证

   ```java
   @WebFilter("/")
   @Component
   public class JwtFilter implements Filter {
   
       @Override
       public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
           HttpServletRequest req = (HttpServletRequest) request;
           String token = req.getHeader("Authorization");
   
           String subject = JwtUtils.parseJWT(token);
           System.out.println(subject);
   
           chain.doFilter(request, response);
   
       }
   
   }
   ```

## Token 安全防御

### Token 的携带方式

#### 浏览器

- HTTP HEADER
- URL
- Cookies
- Local Storage

#### APP

- 本地存储
- 前后端签名，私钥存储

### HMAC

数据在传输过程中对数据产生的摘要，用于防篡改

### 攻击方式

- XSS 重放攻击
- CSRF 跨域攻击
- 防程序员

### 防范措施

- 防 XSS 和 CSRF

- 防程序员：例如使用 Spring Cloud Config 作为配置中心，在 git 上使用 `dev` 和 `prod` 两个分支，让开发人员没有 `prod` 分支的权限。但是此时依旧可以通过打印日志的方式，打印出密钥。所以只能通过代码审查 + 制度双重制约。

## OAuth2.0

参考 [理解 OAuth 2.0](https://www.ruanyifeng.com/blog/2014/05/oauth_2_0.html)

[OAuth 2.0 Migration Guide](https://github.com/spring-projects/spring-security/wiki/OAuth-2.0-Migration-Guide)

