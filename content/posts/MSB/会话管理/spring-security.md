---
title: Spring Security
date: '2021-01-24 00:00:00'
tags:
- MSB
- Session Manage
- Spring Security
- Java
---
# Spring Security

## 密码存储

**常见密文存储的几种方式**

- 明文
- Hash(明文)
- Hash(明文 + 盐)

**盐的几种实现**

- 固定盐
- 随机盐(存储到数据库)
- 随机盐(存在密码里)

### 防止破解

没有绝对安全的网络，即使拿不到密码，也可以发送重放攻击。

- 多次加盐取 hash
- 使用更复杂的单向加密算法，如 BCrypt
- 使用 https
- 风控系统
  - 二次安全校验
  - 接口调用安全校验
  - 异地登录校验
  - 大额转账校验

### 常见加密算法

**推荐使用 PBKDF2/BCrypt/SCrypt/Argon2 算法。解密难度依次增加**

| 算法分类                       | 常见算法                   | 原理                                                         | 特点                                 | 有效破解方式 | 破解难度 |
| ------------------------------ | -------------------------- | ------------------------------------------------------------ | ------------------------------------ | ------------ | -------- |
| 明文保存                       |                            |                                                              | 实现简单                             | 无需破解     | 简单     |
| 对称加密                       | 3DES, AES                  | 明文 + 密钥 = 密文<br>密文 + 密钥 = 明文                     | 通过加密后的密文和密钥可以解密出明文 | 获取密钥     | 中       |
| 单向 HASH                       | MD5, SHA1                  | 把任意长的输入字符串变化成固定长的输出字符串。同一字符串加密后的密文是相同的 | 可以通过彩虹表获取到明文             | 碰撞，彩虹表 | 中       |
| 特殊 HASH                       | 单向 HASH 算法+固定盐        | 同一字符串+固定盐加密后的密文是相同的                        | 可以通过建立彩虹表，获取到明文       | 碰撞，彩虹表 | 中       |
| PBKDF2, BCrypt, SCrypt, Argon2 | 多次加随机盐的单向 HASH 算法 | 因为使用随机盐，所以同一字符串每次加密后都是不同的。随机盐保存在密文中 | 不可解密出明文                       |              | 难       |

SCrypt 算法论文中粗略估计了破解各个算法所需的时间 

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210120194943.jpg)

## Ant 风格路径表达式

### 通配符

| 通配符 | 说明                    |
| ------ | ----------------------- |
| `?`   | 匹配任何单字符          |
| `*`    | 匹配 0 或者任意数量的字符 |
| `**`   | 匹配 0 或者更多的目录     |

### 最长匹配原则

例如：请求 URL 为 `/app/dir/file.jsp`, 现在存在种路径匹配模式 `/*/.jsp` 和 `/app/dir/*.jsp`, 那么会根据 `/app/dir/*.jsp` 来匹配

### 匹配顺序

spring security 不能把 `.anyRequest().authenticated()` 写在其他规则前面

## Spring Security 的使用

### 最简单的使用

1. 引入依赖

   ```xml
   <dependency>
       <groupId>org.springframework.boot</groupId>
       <artifactId>spring-boot-starter-security</artifactId>
   </dependency>
   ```

2. 此时启动项目会在控制台打印出随机生成的密码

   ```
   Using generated security password: e7f4ce7d-321c-4a0d-ba7d-ee110debfda4
   ```

3. 再次访问页面，就需要使用用户名和密码进行登录了，默认用户名是 `user`

### 自定义用户名和密码登录

#### 配置文件方式

在配置文件中设置登录名和密码

```yaml
spring:
  security:
    user:
      name: admin
      password: 123456
```

#### 内存方式

在配置类中先创建出用户，保存到内存中，然后登录的时候通过 `UserDetailService` 的 `loadUserByUsername` 方法将用户查询出来，进行比对。

##### 通过重写 `WebSecurityConfigurerAdapter` 的 `configure(AuthenticationManagerBuilder auth)` 方法，调用 `auth.inMemoryAuthentication()`

通过该方式配置后，配置文件中的 user.name 和 user.password 就失效了

```java
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.crypto.password.NoOpPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

/**
 * @EnableWebSecurity : 将其和 @Configuration 共同使用，注解在 WebSecurityConfigurer 的实现类上，来使自定义的配置生效
 * 最常用的方式就是注解在 WebSecurityConfigurerAdapter 的子类上，通过重写其的方法，达到自定义的目的
 *
 * @author wangshuo
 * @date 2021/01/19
 */
@EnableWebSecurity
@Configuration
public class SpringSecurityConfig extends WebSecurityConfigurerAdapter {

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Override
    protected void configure(AuthenticationManagerBuilder auth) throws Exception {
        auth.inMemoryAuthentication()
            /*
            向内存中添加用户信息
            password() 方法中传入的是加密后的字符串，所以需要使用 passwordEncoder 对象对其进行加密
            并且必须调用 roles() 方法，给用户设置一个角色
             */
            .withUser("admin").password(passwordEncoder.encode("admin")).roles("admin")
            .and()
            .withUser("user").password(passwordEncoder.encode("user")).roles("user");
    }

    /**
     * 使用内存的方式进行身份验证必须配置一个 PasswordEncoder
     *
     * @return PasswordEncoder 的实现类对象
     */
    @Bean
    public PasswordEncoder passwordEncoder() {
        // 配置为对密码不加密
        return NoOpPasswordEncoder.getInstance();
    }

}
```

##### 向容器中注入 `UserDetailsService` 的实现类 `InMemoryUserDetailsManager`

通过该方式配置后，配置文件中和上方 `configure` 方法中配置的用户和密码都会失效

```java
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.password.NoOpPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.provisioning.InMemoryUserDetailsManager;

import java.util.Collections;

@EnableWebSecurity
@Configuration
public class SpringSecurityConfig extends WebSecurityConfigurerAdapter {

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Bean
    public UserDetailsService userDetailsService() {
        /*
        实现了 UserDetailsManager, SpringSecurity 还提供了 JdbcUserDetailsManager 用于通过数据库来进行身份认证。
        可通过扩展 UserDetailsManager 接口实现将用户信息保存在其他地方，例如 redis 等
        */
        InMemoryUserDetailsManager manager = new InMemoryUserDetailsManager();
        /**
         * 可以通过如下两种方式创建 UserDetails 的实例对象
         */
        User user = new User("username", passwordEncoder.encode("password"), Collections.singletonList(new SimpleGrantedAuthority("admin")));
        UserDetails userDetails = User.withUsername("username2").password(passwordEncoder.encode("password")).roles("admin").build();
        // 向内存中添加用户
        manager.createUser(user);
        manager.createUser(userDetails);
        return manager;
    }

    /**
     * 使用内存的方式进行身份验证必须配置一个 PasswordEncoder
     *
     * @return PasswordEncoder 的实现类对象
     */
    @Bean
    public PasswordEncoder passwordEncoder() {
        // 配置为对密码不加密
        return NoOpPasswordEncoder.getInstance();
    }

}
```

#### 数据库方式

1. 引入依赖

   ```xml
   <dependency>
       <groupId>org.springframework.boot</groupId>
       <artifactId>spring-boot-starter-jdbc</artifactId>
   </dependency>
   <dependency>
       <groupId>mysql</groupId>
       <artifactId>mysql-connector-java</artifactId>
   </dependency>
   ```

2. 创建数据表

   ```mysql
   -- Spring Security 默认需要两张数据表，建表语句存储在 org.springframework.security.core.userdetails.jdbc.users.ddl.users.ddl 中。
   -- 语法不匹配，需要自行修改
   create table users(username varchar_ignorecase(50) not null primary key,password varchar_ignorecase(500) not null,enabled boolean not null);
   create table authorities (username varchar_ignorecase(50) not null,authority varchar_ignorecase(50) not null,constraint fk_authorities_users foreign key(username) references users(username));
   create unique index ix_auth_username on authorities (username,authority);
   -- mysql 用
   create table users(username varchar(50) not null primary key,password varchar(500) not null,enabled boolean not null);
   create table authorities (username varchar(50) not null,authority varchar(50) not null,constraint fk_authorities_users foreign key(username) references users(username));
   create unique index ix_auth_username on authorities (username,authority);
   ```

3. 设置数据库连接

   ```yaml
   spring:
     datasource:
       username: root
       password: root
       url: jdbc:mysql://localhost:3306/spring-security?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Shanghai
   ```

4. 自定义用户名和密码，包含两种方式，二选一即可

   - 重写 `WebSecurityConfigurerAdapter` 的 `configure(AuthenticationManagerBuilder auth)` 方法，调用 `auth.jdbcAuthentication`

     ```java
     import org.springframework.beans.factory.annotation.Autowired;
     import org.springframework.context.annotation.Bean;
     import org.springframework.context.annotation.Configuration;
     import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
     import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
     import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
     import org.springframework.security.crypto.password.NoOpPasswordEncoder;
     import org.springframework.security.crypto.password.PasswordEncoder;
     import org.springframework.security.provisioning.JdbcUserDetailsManager;
     
     import javax.sql.DataSource;
     import java.util.Collections;
     
     @EnableWebSecurity
     @Configuration
     public class SpringSecurityConfig extends WebSecurityConfigurerAdapter {
     
         @Autowired
         private PasswordEncoder passwordEncoder;
     
         @Autowired
         private DataSource dataSource;
     
         @Override
         protected void configure(AuthenticationManagerBuilder auth) throws Exception {
             /*
             也可以调用 .getUserDetailsService() 获取 UserDetailsService 对象，然后调用方法创建。
             inMemoryAuthentication 方法也可以通过这种方式使用
             */
             auth.jdbcAuthentication()
                 // 使用数据库方式，必须指定数据源
                 .dataSource(dataSource)
                 // 向数据库中添加用户
                 .withUser("admin").password(passwordEncoder.encode("123456")).roles("admin")
                 .and()
                 .withUser("user").password(passwordEncoder.encode("123456")).roles("user");
         }
     
         /**
          * 使用数据库的方式进行身份验证也必须配置一个 PasswordEncoder
          *
          * @return PasswordEncoder 的实现类对象
          */
         @Bean
         public PasswordEncoder passwordEncoder() {
             // 配置为对密码不加密
             return NoOpPasswordEncoder.getInstance();
         }
     
     }
     ```
     
   - 向容器中注入 `UserDetailsService` 的实现类 `JdbcUserDetailsManager`
   
     ```java
     import org.springframework.beans.factory.annotation.Autowired;
     import org.springframework.context.annotation.Bean;
     import org.springframework.context.annotation.Configuration;
     import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
     import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
     import org.springframework.security.core.authority.SimpleGrantedAuthority;
     import org.springframework.security.core.userdetails.User;
     import org.springframework.security.core.userdetails.UserDetails;
     import org.springframework.security.core.userdetails.UserDetailsService;
     import org.springframework.security.crypto.password.NoOpPasswordEncoder;
     import org.springframework.security.crypto.password.PasswordEncoder;
     import org.springframework.security.provisioning.JdbcUserDetailsManager;
     
     import javax.sql.DataSource;
     import java.util.Collections;
     
     
     @EnableWebSecurity
     @Configuration
     public class SpringSecurityConfig extends WebSecurityConfigurerAdapter {
     
         @Autowired
         private PasswordEncoder passwordEncoder;
     
         @Autowired
         private DataSource dataSource;
     
         @Override
         @Bean
         protected UserDetailsService userDetailsService() {
             JdbcUserDetailsManager manager = new JdbcUserDetailsManager(dataSource);
             User user = new User("username", passwordEncoder.encode("password"), Collections.singletonList(new SimpleGrantedAuthority("admin")));
             UserDetails userDetails = User.withUsername("username2").password(passwordEncoder.encode("password")).roles("admin").build();
             // 向数据库中添加用户
             manager.createUser(user);
             manager.createUser(userDetails);
             return manager;
         }
     
         /**
          * 使用数据库的方式进行身份验证也必须配置一个 PasswordEncoder
          *
          * @return PasswordEncoder 的实现类对象
          */
         @Bean
         public PasswordEncoder passwordEncoder() {
             // 配置为对密码不加密
             return NoOpPasswordEncoder.getInstance();
         }
     
     }
     ```

#### 自定义方式

可以通过实现 `UserDetailsService` 接口，来自定义查询用户的方法 `loadUserByUsername()`, 例如可以从 redis 等查询。

还可以直接实现 `UserDetailsManager` 接口(`UserDetailsManager` 接口继承了 `UserDetailsService` 接口), 来自定义查找/创建/更新/删除用户的逻辑，以及修改密码，判断用户是否存在的逻辑，之后参照 `InMemoryUserDetailsManager`/`JdbcUserDetailsManager` 向容器中注入 `UserDetailsService` 实现类的方式使用即可。

**用到的类介绍**

- `UserDetailsService` : 定义了根据用户名加载用户信息的方法。实现类有从内存/数据库等查询出用户的信息，然后包装成 `UserDetails` 对象进行返回。可通过自定义扩展，从其他持久化组件中(例如 redis)获取用户信息，或者使用 JPA/Mybatis 等方式从数据库查询用户信息
- `UserDetailsManager`: 继承自 `UserDetailsService` 接口，包含了对用户信息的加载/创建/更新/删除/修改密码/存在的方法，常用的实现类有`InMemoryUserDetailsManager` 和 `JdbcUserDetailsManager`, 可通过自定义扩展，从其他持久化组件中(例如 redis)对用户信息进行操作，或者使用 JPA/Mybatis 等方式操作数据库中的信息
- `UserDetails`: 提供了用户的核心信息。出于安全目的, Spring Security 不会直接使用它的实现类。它们只是存储用户信息，这些信息随后封装到 Authentication 对象中。这允许将与安全无关的用户信息(例如电子邮件地址，电话号码等)存储在该类的实现类中。
- `User`: `UserDetails` 的实现类。包含了用户的用户名，密码，权限，以及相关状态信息。可通过扩展该类或者重新编写 `UserDetails` 的实现来加入相关的信息。

### Spring Security 登录验证流程

参考 [Spring Security 验证流程剖析及自定义验证方法](https://www.cnblogs.com/xz816111/p/8528896.html)

Spring Security 本质上是一连串的 Filter, 然后又以单独的 Filter 形式插入到 Filter Chain 中，名称是 FilterChainProxy.

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210126094833.png)实际上 FilterChainProxy 下面又多条 Filter Chain, 来针对不同的 URL 做验证，而 Filter Chain 中所拥有的 Filter 则会根据定义的服务自动递减。所以不需要显式再定义这些 Filter, 除非想要实现自己的逻辑。

#### ![](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210126095315.png)关键类

##### Authentication

`Authentication` 是一个接口，用来表示用户的认证信息，在用户登录认证之前，其相关信息会被封装为一个 `Authentication` 类型的具体实现对象，在登录认证成功之后又会生成一个信息更全面，包含用户权限等信息的 `Authentication` 对象，然后把它保存在 `SecurityContextHolder` 所持有的 `SecurityContext` 中，供后续进行调用。

##### AuthenticationManager

用来做验证的最主要的接口

```java
public interface AuthenticationManager {

    /**
     * 运行后有三种情况
     * 1. 验证成功，返回一个带有用户详细信息的 Authentication 对象
     * 2. 验证失败，抛出 AuthenticationException 异常
     * 3. 无法判断，返回 null
     */
    Authentication authenticate(Authentication authentication) throws AuthenticationException;

}
```

##### ProviderManager

`ProviderManager` 是上面 `AuthenticationManager` 的具体实现，它不自己处理验证，而是将验证委托给 `AuthenticationProvider` 列表，然后依次调用 `AuthenticationProvider` 进行认证，只要有一个 `AuthenticationProvider` 认证成功，就直接将该结果作为 `ProviderManager` 的认证结果返回。

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210126100423.jpg)

#### 认证过程

1. 用户使用用户名和密码进行登录
2. Sprnig Security 将传入的用户名和密码封装成一个未认证的 `Authentication` 接口实现类，最常见的是 `UsernamePasswordAuthenticationToken`
3. 把上一步生成的 `Authentication` 交给 `AuthenticationManager` 的实现类 `ProviderManager` 进行验证
4. `ProviderManager` 依次调用 `AuthenticationProvider` 进行认证，认证成功后返回一个包含用户权限等信息的 `Authentication` 对象
5. 把认证后的 `Authentication` 对象存储到 `SpringSecurityContext` 里

#### UsernamePassword 认证过程示例

1. `UsernamePasswordAuthenticationFilter` : 根据前端传入的用户名和密码生成一个未认证的令牌，并交给 `AuthenticationManager` 处理

   ```java
   public class UsernamePasswordAuthenticationFilter extends AbstractAuthenticationProcessingFilter {
       
       private static final AntPathRequestMatcher DEFAULT_ANT_PATH_REQUEST_MATCHER = new AntPathRequestMatcher("/login","POST");
       
       public UsernamePasswordAuthenticationFilter() {
           // 匹配请求的 URL
           super(DEFAULT_ANT_PATH_REQUEST_MATCHER);
       }
   
       @Override
       public Authentication attemptAuthentication(HttpServletRequest request, HttpServletResponse response)
           throws AuthenticationException {
           // 如果不是 POST 请求，直接抛异常
           if (this.postOnly && !request.getMethod().equals("POST")) {
               throw new AuthenticationServiceException("Authentication method not supported: " + request.getMethod());
           }
           // 从请求中拿登录名和密码
           String username = obtainUsername(request);
           username = (username != null) ? username : "";
           username = username.trim();
           String password = obtainPassword(request);
           password = (password != null) ? password : "";
           // 此时不知道用户名和密码是否是正确的，先构建一个未认证的 Token
           UsernamePasswordAuthenticationToken authRequest = new UsernamePasswordAuthenticationToken(username, password);
           // Allow subclasses to set the "details" property
           // 先把这个 Token 存起来
           setDetails(request, authRequest);
           // AuthenticationManager 把该 Token 交给适合的 uthenticationProvider 进行验证
           return this.getAuthenticationManager().authenticate(authRequest);
       }
   
   }
   ```

2. `AuthenticationManager` 会注册多个 `AuthenticationProvider`, `AuthenticationManager` 根据各个 `AuthenticationProvider` 的 `supports()` 方法的返回值，判断是否要将该 Token 交给该 `AuthenticationProvider` 处理

   ```java
   public interface AuthenticationProvider {
       Authentication authenticate(Authentication var1) throws AuthenticationException;
   
       // 根据 Token 的类型，判断是否使用该 AuthenticationProvider 处理
       boolean supports(Class<?> var1);
   }
   ```

3. `AuthenticationProvider` 的实现类 `AbstractUserDetailsAuthenticationProvider` 和 `UsernamePasswordAuthenticationToken`. 主要就是对未认证的 Token 中的信息进行认证，从数据库/内存等地方查询出已保存过的用户信息，进行比对，匹配成功后返回一个认证过的令牌(Authentication 对象). 

   所以如果我们进行扩展的时候，可以自定义一个 Provider, 来对前端传入的信息进行验证。注意此处加载已存在用户的 `loadUserByUsername` 方法，是 `UserDetailsService` 接口的方法，所以扩展的时候，也需要自定义一个该接口的实现类，自定义从何处查询已存在用户的信息。用户信息都被包装成了 `UserDetails` 类型的对象。

   如果其中一个 Provider 认证失败，会调用它的 `parent` 进行验证，参照 `ProviderManager.authenticate()` 方法，只要有一个验证成功就返回，当所有都验证失败才失败。

   ```java
   public abstract class AbstractUserDetailsAuthenticationProvider
       implements AuthenticationProvider, InitializingBean, MessageSourceAware {
   
       @Override
       public Authentication authenticate(Authentication authentication) throws AuthenticationException {
           Assert.isInstanceOf(UsernamePasswordAuthenticationToken.class, authentication,
                               () -> this.messages.getMessage("AbstractUserDetailsAuthenticationProvider.onlySupports",
                                                              "Only UsernamePasswordAuthenticationToken is supported"));
           // 取出 Token 里保存的用户名
           String username = determineUsername(authentication);
           boolean cacheWasUsed = true;
           // 从缓存里拿用户信息
           UserDetails user = this.userCache.getUserFromCache(username);
           if (user == null) {
               cacheWasUsed = false;
   
               // 如果缓存里没有，使用该方法获取
               user = retrieveUser(username, (UsernamePasswordAuthenticationToken) authentication);
   
               Object principalToReturn = user;
               if (this.forcePrincipalAsString) {
                   principalToReturn = user.getUsername();
               }
               // 创建一个认证过的令牌
               return createSuccessAuthentication(principalToReturn, authentication, user);
           }
   
           // 在实现类 DaoAuthenticationProvider 中
           @Override
           protected final UserDetails retrieveUser(String username, UsernamePasswordAuthenticationToken authentication)
               throws AuthenticationException {
               prepareTimingAttackProtection();
   
               // 加载用户
               UserDetails loadedUser = this.getUserDetailsService().loadUserByUsername(username);
               if (loadedUser == null) {
                   throw new InternalAuthenticationServiceException(
                       "UserDetailsService returned null, which is an interface contract violation");
               }
               // 返回用户
               return loadedUser;
           }
   
           // 支持处理 UsernamePasswordAuthenticationToken 类型的 Token
           @Override
           public boolean supports(Class<?> authentication) {
               return (UsernamePasswordAuthenticationToken.class.isAssignableFrom(authentication));
           }
       }
   ```

### 自定义登录验证

1. 自定义 `UserDetails` 接口的实现

   ```java
   package com.example.springsecurity.custom;
   
   import org.springframework.security.core.GrantedAuthority;
   import org.springframework.security.core.authority.AuthorityUtils;
   import org.springframework.security.core.userdetails.UserDetails;
   
   import java.util.Collection;
   
   /**
    * 自定义的用户对象，可以直接对应数据库中的用户表。
    * 用户表也可以不对应 UserDetails 的实现对象，在需要用到 UserDetails 对象的时候将数据表对应的对象转为 UserDetails 对象也可以
    *
    * @author wangshuo
    * @date 2021/01/21
    */
   public class CustomUser implements UserDetails {
   
       private String username;
   
       private String password;
   
       private String name;
   
   
       /**
        * 装填用户的角色列表
        *
        * @return 用户角色列表
        */
       @Override
       public Collection<? extends GrantedAuthority> getAuthorities() {
           // 将用户对应的角色信息转为集合
           return AuthorityUtils.createAuthorityList("ROLE_ADMIN", "ROLE_USER");
       }
   
       @Override
       public String getPassword() {
           return this.password;
       }
   
       @Override
       public String getUsername() {
           return this.username;
       }
   
       @Override
       public boolean isAccountNonExpired() {
           return true;
       }
   
       @Override
       public boolean isAccountNonLocked() {
           return true;
       }
   
       @Override
       public boolean isCredentialsNonExpired() {
           return true;
       }
   
       @Override
       public boolean isEnabled() {
           return true;
       }
   
       public CustomUser setUsername(String username) {
           this.username = username;
           return this;
       }
   
       public CustomUser setPassword(String password) {
           this.password = password;
           return this;
       }
   
       public String getName() {
           return name;
       }
   
       public CustomUser setName(String name) {
           this.name = name;
           return this;
       }
   }
   
   ```

2. 实现 `UserDetailsService` 接口

   ```java
   package com.example.springsecurity.custom;
   
   import org.springframework.security.core.userdetails.UserDetails;
   import org.springframework.security.core.userdetails.UserDetailsService;
   import org.springframework.security.core.userdetails.UsernameNotFoundException;
   import org.springframework.stereotype.Service;
   
   import java.util.Collections;
   import java.util.Map;
   
   /**
    * @author wangshuo
    * @date 2021/01/21
    */
   @Service
   public class CustomUserDetailsService implements UserDetailsService {
   
       CustomUser customUser = new CustomUser();
   
       {
           customUser.setUsername("admin");
           customUser.setPassword("123456");
           customUser.setName("管理员");
       }
   
       // 模拟数据库
       Map<String, CustomUser> map = Collections.singletonMap(customUser.getUsername(), customUser);
   
       @Override
       public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
           // 可以使用 JPA/Mybatis 从数据库里根据账户名查询出用户信息，封装成 UserDetails 对象
           CustomUser customUser = map.get(username);
           return customUser;
       }
   }
   ```
   
3. 自定义 `AuthenticationProvider`

   ```java
   package com.example.springsecurity.custom;
   
   import org.springframework.beans.factory.annotation.Autowired;
   import org.springframework.security.authentication.AuthenticationProvider;
   import org.springframework.security.authentication.BadCredentialsException;
   import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
   import org.springframework.security.core.Authentication;
   import org.springframework.security.core.AuthenticationException;
   import org.springframework.security.core.GrantedAuthority;
   import org.springframework.security.core.userdetails.UserDetails;
   import org.springframework.security.core.userdetails.UserDetailsService;
   import org.springframework.security.crypto.password.PasswordEncoder;
   import org.springframework.stereotype.Component;
   
   import java.util.Collection;
   
   /**
    * 用来对前端传入的用户名和凭证进行验证
    *
    * @author wangshuo
    * @date 2021/01/21
    */
   @Component
   public class CustomAuthenticationProvider implements AuthenticationProvider {
   
       @Autowired
       private UserDetailsService customUserDetailsService;
   
       @Autowired
       private PasswordEncoder passwordEncoder;
   
       @Override
       public Authentication authenticate(Authentication authentication) throws AuthenticationException {
   
           // http 请求传入的用户名和密码
           String username = authentication.getName();
           String password = (String) authentication.getCredentials();
   
           // 从内存/数据库中查询出用户信息
           UserDetails userDetails = customUserDetailsService.loadUserByUsername(username);
   
           // 内存/数据库没有该用户信息，或者密码不匹配，抛出异常
           if (userDetails == null || !passwordEncoder.matches(password, userDetails.getPassword())) {
               throw new BadCredentialsException("用户名或密码错误");
           }
   
           // 获取到用户的权限信息
           Collection<? extends GrantedAuthority> authorities = userDetails.getAuthorities();
           // 封装成 Authentication 类型的对象
           return new UsernamePasswordAuthenticationToken(userDetails, password, authorities);
       }
   
       /**
        * 是否支持处理当前 Authentication 类型对象
        *
        * @param aClass
        * @return
        */
       @Override
       public boolean supports(Class<?> aClass) {
           return true;
       }
   }
   ```
   
4. 在配置类中将自定义的 `AuthenticationProvider` 添加到 `AuthenticationManager` 里

   ```java
   @EnableWebSecurity
   @Configuration
   public class SpringSecurityConfig extends WebSecurityConfigurerAdapter {
   
       @Autowired
       private CustomAuthenticationProvider customAuthenticationProvider;
   
       @Override
       protected void configure(AuthenticationManagerBuilder auth) throws Exception {
           auth.authenticationProvider(new CustomAuthenticationProvider());
       }
   
   }
   ```


### 忽略静态资源

有两种方式可以取消对静态资源的验证.`AuthenticationManagerBuilder` 方式在 `HttpSecurity` 之前执行，所以配置在 `AuthenticationManagerBuilder` 中可以提前响应，从而提高响应速度。

#### 通过 configure(AuthenticationManagerBuilder auth)方法

```java
@EnableWebSecurity
@Configuration
public class SpringSecurityConfig extends WebSecurityConfigurerAdapter {
    @Override
    public void configure(WebSecurity web) throws Exception {
        web.ignoring().antMatchers("/img/**");
    }
}
```

#### 通过 configure(HttpSecurity http)方法

```java
@EnableWebSecurity
@Configuration
public class SpringSecurityConfig extends WebSecurityConfigurerAdapter {
    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http.authorizeRequests()
            	// permitAll: 无论是否登录都允许访问; anonymous: 仅允许匿名访问，不允许登录后访问
                .antMatchers("/img/**").permitAll();
    }
}
```

### 设置密码加密方式

在配置类中创建 `PasswordEncoder` 接口的实现类

```java
@Bean
public PasswordEncoder passwordEncoder() {
    // 在这返回 PasswordEncoder 的不同实现类
    return new BCryptPasswordEncoder();
}
```

可用通过扩展 `PasswordEncoder` 接口自定义加密算法

### 记住我

```java
@EnableWebSecurity
@Configuration
public class SpringSecurityConfig extends WebSecurityConfigurerAdapter {  
    @Override
    protected void configure(HttpSecurity http) throws Exception {
        // 启用默认的表单登录
        http.formLogin()
            .and()
            // 所有请求都需要验证
            .anyRequest().authenticated()
            .and()
            // 开启记住我功能
            .rememberMe();
    }
}
```

Spring Security 默认 rememberMe 的实现是在 cookie 中放入一个名为 `remember-me` 的标识, Value 是使用 Base64 加密后的字符串，解密后的内容包含用户名，失效时间和签名，签名是根据用户名，失效时间，盐来计算出来的，用于验证该 cookie 是否被篡改。

使用该方式的好处是：如果搭建分布式系统，不需要进行 session 同步或者将 session 保存在第三方(如 redis)中，即可对 remember-me 进行验证。

### 同一用户多地点登录

此配置和记住我有冲突。

#### 踢掉其他已登录的用户

```java
@EnableWebSecurity
@Configuration
public class SpringSecurityConfig extends WebSecurityConfigurerAdapter {  
    @Override
    protected void configure(HttpSecurity http) throws Exception {
        // 启用默认的表单登录
        http.formLogin()
            .and()
            // 所有请求都需要验证
            .anyRequest().authenticated()
            .and()
            .sessionManagement()
            // 设置同一帐号同时最多只能有 1 个 session
            .maximumSessions(1);
    }

    /**
     * 及时清理过期的 session
     */
    @Bean
    HttpSessionEventPublisher httpSessionEventPublisher() {
        return new HttpSessionEventPublisher();
    }
}
```

#### 禁止其他终端登录

```java
@EnableWebSecurity
@Configuration
public class SpringSecurityConfig extends WebSecurityConfigurerAdapter {  
    @Override
    protected void configure(HttpSecurity http) throws Exception {
        // 启用默认的表单登录
        http.formLogin()
            .and()
            // 所有请求都需要验证
            .anyRequest().authenticated()
            .and()
            .sessionManagement()
            // 设置同一帐号同时最多只能有 1 个 session
            .maximumSessions(1)
            // 防止最大 session 外的用户登录
            .maxSessionsPreventsLogin(true)
    }
}
```

### 自定义配置信息

#### 登录和注销相关配置

登录相关的配置在 `formLogin()` 里，注销相关的配置在 `logout()` 里

```java
@EnableWebSecurity
@Configuration
public class SpringSecurityConfig extends WebSecurityConfigurerAdapter {  
    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http.formLogin()
            // 设置登录页面
            .loginPage("/login.html")
            // 设置登录的 action
            .loginProcessingUrl("/login")
            // 登录成功默认跳转到哪个 url. alwaysUse 默认是 false, 即如果是从 index.html 进行登录，那么登录成功后就会调转到 index.html
            .defaultSuccessUrl("/index.html")
            // 设置表单登录的时候，传过来的用户名和密码的 name
            .usernameParameter("username")
            .passwordParameter("password")
            // 登录失败的时候跳转的 url
            .failureUrl("/error.html?error1")
            // 登录失败的处理器
            .failureHandler((httpServletRequest, httpServletResponse, e) -> {
                // 可以在此处获取到登录失败时抛出的异常，并且可以在此处限制登录次数
                e.printStackTrace();
                System.out.println("登录失败");
            })
            // 登录成功的处理器
            .successHandler((httpServletRequest, httpServletResponse, authentication) -> {
                // 可以在此处根据不同的用户角色跳转到不同的页面, authentication 里包含了用户的权限信息
                System.out.println("登录成功");
            })
            .and()
            // 退出登录的设置
            .logout()
            // 退出登录的 url
            .logoutUrl("/logout")
            // 成功退出后跳转到的页面
            .logoutSuccessUrl("/index.html")
            // 成功退出后会触发的事件
            .logoutSuccessHandler((httpServletRequest, httpServletResponse, authentication) -> {
                System.out.println("退出成功-1");
            })
            // 成功对出后会触发的事件
            .addLogoutHandler((httpServletRequest, httpServletResponse, authentication) -> {
                System.out.println("退出成功-2");
            });
    }
}
```

**常见登录异常**

![image-20210121232239596](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210121232240.png)

- **LockedException** 账户被锁定
- **CredentialsExpiredException** 密码过期
- **AccountExpiredException** 账户过期
- **DisabledException** 账户被禁用
- **BadCredentialsException** 密码错误
- **UsernameNotFoundException** 用户名错误

#### 授权请求

```java
@EnableWebSecurity
@Configuration
public class SpringSecurityConfig extends WebSecurityConfigurerAdapter {  
    @Override
    protected void configure(HttpSecurity http) throws Exception {
        // 授权请求
        http.authorizeRequests()
            // antMatchers() 设置匹配的 url, 然后后方的设置访问权限
            // permitAll: 允许所有人访问，无论是否登录
            .antMatchers("/login", "/index.html").permitAll()
            // anonymous: 仅允许匿名用户访问，登录后不可访问
            .antMatchers("/xx").anonymous()
            // hasRole: 指定有某个角色的用户才能访问
            .antMatchers("/admin/**").hasRole("ADMIN")
            // denyAll: 不允许所有人访问
            .antMatchers("/xxoo").denyAll()
            // hasIpAddress: 指定 IP 访问不需要登录
            .antMatchers("/ooxx").hasIpAddress("127.0.0.1")
            // anyRequest: 其他所有请求; authenticated: 均需要认证后访问。手动设置 url 权限一定要在其之前，否则会报错
            .anyRequest().authenticated();
    }
}

```

#### CSRF 问题

Spring Security 使用 CSRF Token 的方式解决 CSRF 问题。

**CSRF Token 原理 :** 用户登录时，系统发放并一个 CsrfToken, 用户携带该 CsrfToken 与用户名和密码等参数完成登录。登录成功后，系统会记录该 CsrfToken, 之后用户的任何请求都需要携带该 CsrfToken, 并由系统进行校验。

Spring Security 默认提供了两种方式的 CSRF Token : **HttpSessionCsrfTokenRepository**, **CookieCsrfTokenRepository**

##### HttpSessionCsrfTokenRepository

默认情况下, Spring Security 加载的就是该 SessionCsrfToken, 其将 CsrfToken 存储在 HttpSession 中，并要求前端把 CsrfToken 放在名为 **_csrf** 的请求参数或者名为 **X-CSRF-TOKEN** 的请求头中。

##### CookieCsrfTokenRepository

把 CsrfToken 存储在用户的 Cookie 中。

> **cookie 的值只能被同域的网站读取，所以第三方网站无法获取到 cookie 的值. CSRS 攻击本身是不知道 cookie 的值的，只是利用了当请求自动携带 cookie 时可以通过身份验证的漏洞. CSRF Token 方式要求每次请求的时候通过参数或者请求头将 cookie 中保存的 CsrfToken 的值一起发送给服务端，所以需要前端手动把 cookie 中 CsrfToken 的值取出来作为参数放在请求中.**

**好处 :** 

1. 可以减少服务器 HttpSession 存储 CsrfToken 产生的内存消耗。
2. 前端可以通过 JavaScript 读取 cookie 中的值(需要将 cookie 的 httpOnly 设置为 false), 而不需要服务端注入参数

`CookieCsrfTokenRepository` 默认会将 CsrfToken 放在名为 **XSRF-TOKEN** 的 cookie 中，并要求前端把 CsrfToken 放在名为 **_csrf** 的请求参数中或者名为 **X-XSRF-TOKEN** 的请求头中

```java
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.web.csrf.CookieCsrfTokenRepository;

@EnableWebSecurity
@Configuration
public class SpringSecurityConfig extends WebSecurityConfigurerAdapter {

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http.csrf()
			// 指定使用 CookieCsrfTokenRepository, 并将该 Cookie 的 HttpOnly 设置为 False, 使得 JavaScript 可以读取值
            .csrfTokenRepository(CookieCsrfTokenRepository.withHttpOnlyFalse());
    }

}
```

### 防火墙

#### IP 白名单

指定 IP 可以不登录即可访问

```java
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.web.csrf.CookieCsrfTokenRepository;

@EnableWebSecurity
@Configuration
public class SpringSecurityConfig extends WebSecurityConfigurerAdapter {

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http.authorizeRequests()
            .anyRequest().authenticated()
            .antMatchers("/xxoo").hasIpAddress("127.0.0.1");
    }

}
```

#### IP 黑名单

用 Filter(JavaEE 提供的)或者 HandlerInterceprot(SpringMVC 提供的)实现。通常 IP 黑名单都是在负载均衡/网关层尽早拦截，不让其打到真实的服务上。

#### HttpFirewall

Spring Security 提供了一个 `HttpFirewall`, 用于处理 http 请求，包含两个实现 `StrictHttpFirewall` 和 `DefaultHttpFirewall`, 默认使用严格的 `StrictHttpFirewall`

##### Method

拒绝不允许的 HTTP 方法。默认被允许的 HTTP Method 有 `[DELETE, GET, HEAD, OPTIONS, PATCH, POST, PUT]`

##### URL

 1. 拒绝不规范的 URL, 在其 `requestURI`/`contextPath`/`servletPath`/`pathInfo` 中，必须不能包含以下字符串序列之一 :

    ```java
    ["//", "./", "/…/", "/."]
    ```

    - `requestURI`: URL 中去除协议，主机名，端口之后其余的部分
    - `contextPath`: `requetURI` 中对应 webapp 的部分
    - `servletPath`: `requestURI` 中对应识别 Servlet 的部分
    - `pathInfo`: requestURI 中去掉 `contextPath`, `servletPath` 剩下的部分

2. 拒绝包含非可打印的 ASCII 字符的 URL

3. 拒绝包含分号的 URL: `;`, `%3b`, `%3B`

   ```java
   setAllowSemicolon(boolean)
   ```

4. 拒绝包含 URL 编码的单斜杠的 URL:  `%2f`, `%2F`

   ```java
   setAllowUrlEncodedSlash(boolean)
   ```

5. 拒绝包含双斜杠的 URL : `//`, `%2f%2f`, `%2F%2F`, `%2f%2F`, `%2F%2f`

    ```java
    setAllowUrlEncodedDoubleSlash(boolean)
    ```

6. 拒绝包含反斜杠的 URL: `\`, `%5c`, `%5C`

    ```java
    setAllowBackSlash(boolean)
    ```

7. 拒绝包含空字符的 URL : 

   ```java
   setAllowNull(boolean)
   ```

8. 拒绝包含 URL 编码的百分号的 URL :  `%25`

    ```java
    setAllowUrlEncodedPercent(boolean)
    ```

9. 默认不能包含英文句号 : `%2e`, `%2E`

   ```java
   setAllowUrlEncodedPeriod(boolean)
   ```

##### 其他

- 拒绝不允许的主机。请参阅 setAllowedHostnames(Predicate)
- 拒绝不允许的标题名称。参见 setAllowedHeaderNames(Predicate)
- 拒绝不允许的标头值。参见 setAllowedHeaderValues(Predicate)
- 拒绝不允许的参数名称。参见 setAllowedParameterNames(Predicate)
- 拒绝不允许的参数值。参见 setAllowedParameterValues(Predicate)

#### 防火墙与 SQL 注入

`'`, `;`, `--`, `%` 等多出非法字符已经在请求参数中被禁用，所以已经防止了 SQL 注入问题。这也是为什么用户名中不能含有特殊字符的原因之一。

### 权限

#### RBAC 模型

参考 [RBAC 模型：基于用户-角色-权限控制的一些思考](http://www.woshipm.com/pd/1150093.html)

最普通的权限管理方式是直接使用用户关联权限，来进行权限控制，但是使用该方式会降低扩展性，仅适合用户数量少，角色类型少的平台。

最常用的权限管理方式就是 RBAC(Role-Based Access Control), 基于角色的权限控制。通过用户关联角色，角色关联权限(资源)的方式间接赋予用户权限。这种方式可以根据角色，批量的管理用户权限。

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210122163320.png)

RBAC 模型可以分为: RBAC0, RBAC1, RBAC2, RBAC3. 其中 RBAC0 是基础思想, RBAC1, RBAC2, RBAC3 都是以 RBAC0 为基础进行的升级。一般情况下, RBAC0 模型即可满足常规的权限系统管理了。

##### RBAC0

最简单的角色，用户，权限模型。包含了两种情况 :

1. 用户和角色是多对一的关系，一个用户只能充当一种角色，一种角色可以有多个用户担当。
2. 用户和角色是多对多的关系，一个用户可以同时充当多种角色，一个角色可以有多个用户担当。

如果系统功能单一，使用人员较少，岗位权限相对清晰且确保不会出现兼岗的情况，可以考虑用多对一的权限体系。其余情况尽量使用多对多的权限体系，保证系统的扩展性。

##### RBAC1

相对于 RBAC0 模型，引入了子角色和继承的概念，即子角色可以继承父角色的所有权限。

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210122164327.png)

使用场景：如某个业务部门，有经理、主管、专员。主管的权限不能大于经理，专员的权限不能大于主管，如果采用 RBAC0 模型做权限系统，极可能出现分配权限失误，最终出现主管拥有经理都没有的权限的情况。

##### RBAC2

基于 RBAC0 模型，增加了对角色的一些限制：角色互斥、基数约束、先决条件角色等。

- **角色互斥：**同一用户不能分配到一组互斥角色集合中的多个角色，互斥角色是指权限互相制约的两个角色。案例：财务系统中一个用户不能同时被指派给会计角色和审计员角色。
- **基数约束：**一个角色被分配的用户数量受限，它指的是有多少用户能拥有这个角色。例如：一个角色专门为公司 CEO 创建的，那这个角色的数量是有限的。
- **先决条件角色：**指要想获得较高的权限，要首先拥有低一级的权限。例如：先有副总经理权限，才能有总经理权限。
- **运行时互斥：**例如，允许一个用户具有两个角色的成员资格，但在运行中不可同时激活这两个角色。

##### RBAC3

称为统一模型，它包含了 RBAC1 和 RBAC2，利用传递性，也把 RBAC0 包括在内，综合了 RBAC0、RBAC1 和 RBAC2 的所有特点。

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210122164654.png)

#### 配置类中的权限设置

`antMatchers` 中的路径就相当于 RBAC 模型中的资源，后方的 `hasRole` 是所需的角色。这种方式都是写死的

```java
@EnableWebSecurity
@Configuration
public class SpringSecurityConfig extends WebSecurityConfigurerAdapter {  
    @Override
    protected void configure(HttpSecurity http) throws Exception {
        // 授权请求
        http.authorizeRequests()
            // antMatchers() 设置匹配的 url, 然后后方的设置访问权限
            // permitAll: 允许所有人访问，无论是否登录
            .antMatchers("/login", "/index.html").permitAll()
            // anonymous: 仅允许匿名用户访问，登录后不可访问
            .antMatchers("/xx").anonymous()
            // hasRole: 指定有某个角色的用户才能访问
            .antMatchers("/admin/**").hasRole("ADMIN")
            // denyAll: 不允许所有人访问
            .antMatchers("/xxoo").denyAll()
            // hasIpAddress: 指定 IP 访问不需要登录
            .antMatchers("/ooxx").hasIpAddress("127.0.0.1")
            // anyRequest: 其他所有请求; authenticated: 均需要认证后访问。手动设置 url 权限一定要在其之前，否则会报错
            .anyRequest().authenticated();
    }
}
```

#### 角色的继承

```java
@Bean
public RoleHierarchy roleHierarchy(){
    RoleHierarchyImpl roleHierarchy = new RoleHierarchyImpl();
    // ADMIN 角色大于 USER 角色，所以 ADMIN 包含 USER 的所有权限
    roleHierarchy.setHierarchy("ADMIN > USER");
    return roleHierarchy;
}
```

#### 方法级别的权限认证

1. 在配置类上添加 `@EnableGlobalMethodSecurity` 注解，其包含如下属性 : 

   - securedEnabled : 是否应启用 Spring Security 的 `Secured` 注解
   - prePostEnabled : 是否应启用 Spring Security 的 `PreAuthorize` 和 `PostAuthorize` 注解
   - jsr250Enabled : 是否应启用 JSR-250 批注

2. 在方法上使用注解可访问权限，包含多种注解

   - `@Secured `: 可以设置角色列表，多个角色之间是'或'的关系

     ```java
     @Secured({"ROLE_ADMIN", "ROLE_USER"})
     ```

   - `@PreAuthorize` : 前置认证，在方法执行前验证权限。可以根据 `hasRole()`, `hasAnyRole()`, `permitAll()` 等表达式的返回值来设置权限，支持 SPEL 表达式，可以通过 `and`, `or` 等关键字将多个表达式进行组合使用

     ```java
     @PreAuthorize("hasAnyRole('ROLE_ADMIN') && hasRole('ROLE_USER')")
     ```

   - `@PostAuthorize`: 后置认证，在方法执行后验证权限。与 `PreAuthorize` 相似，可以根据 `hasRole()`, `hasAnyRole()`, `permitAll()` 等表达式的返回值来设置权限，支持 SPEL 表达式，可以通过 `and`, `or` 等关键字将多个表达式进行组合使用，还可以根据方法的返回值来判断是否有权限。

     ```java
     // returnObejct 是注解内置的对象，代表方法的返回值
     @PostAuthorize("returnObject==1")
     ```

### 当前用户的认证信息

获取到 Spring Security 中当前登录用户的认证信息，包含用户的用户名，密码，权限等认证信息

```java
Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
```

### 图形验证码

目的：防机器暴力登录

#### Kaptcha

参考 [Kaptcha](https://www.jianshu.com/p/a3525990cd82)

Kaptcha 是一个可高度配置的实用验证码生成工具，可自由配置的选项如：

- 验证码的字体
- 验证码字体的大小
- 验证码字体的字体颜色
- 验证码内容的范围(数字，字母，中文汉字！)
- 验证码图片的大小，边框，边框粗细，边框颜色
- 验证码的干扰线
- 验证码的样式(鱼眼样式、3D、普通模糊、...)

##### Kaptcha 详细配置表

| Constant                         | 描述                                                         | 默认值                                                |
| -------------------------------- | ------------------------------------------------------------ | ----------------------------------------------------- |
| kaptcha.border                   | 图片边框，合法值：yes , no                                   | yes                                                   |
| kaptcha.border.color             | 边框颜色，合法值：r,g,b (and optional alpha) 或者 white,black,blue. | black                                                 |
| kaptcha.image.width              | 图片宽                                                       | 200                                                   |
| kaptcha.image.height             | 图片高                                                       | 50                                                    |
| kaptcha.producer.impl            | 图片实现类                                                   | com.google.code.kaptcha.impl.DefaultKaptcha           |
| kaptcha.textproducer.impl        | 文本实现类                                                   | com.google.code.kaptcha.text.impl.DefaultTextCreator  |
| kaptcha.textproducer.char.string | 文本集合，验证码值从此集合中获取                             | abcde2345678gfynmnpwx                                 |
| kaptcha.textproducer.char.length | 验证码长度                                                   | 5                                                     |
| kaptcha.textproducer.font.names  | 字体                                                         | Arial, Courier                                        |
| kaptcha.textproducer.font.size   | 字体大小                                                     | 40px.                                                 |
| kaptcha.textproducer.font.color  | 字体颜色，合法值：r,g,b  或者 white,black,blue.             | black                                                 |
| kaptcha.textproducer.char.space  | 文字间隔                                                     | 2                                                     |
| kaptcha.noise.impl               | 干扰实现类                                                   | com.google.code.kaptcha.impl.DefaultNoise             |
| kaptcha.noise.color              | 干扰 颜色，合法值：r,g,b 或者 white,black,blue.             | black                                                 |
| kaptcha.obscurificator.impl      | 图片样式：<br />水纹 com.google.code.kaptcha.impl.WaterRipple <br /> 鱼眼 com.google.code.kaptcha.impl.FishEyeGimpy <br /> 阴影 com.google.code.kaptcha.impl.ShadowGimpy | com.google.code.kaptcha.impl.WaterRipple              |
| kaptcha.background.impl          | 背景实现类                                                   | com.google.code.kaptcha.impl.DefaultBackground        |
| kaptcha.background.clear.from    | 背景颜色渐变，开始颜色                                       | light grey                                            |
| kaptcha.background.clear.to      | 背景颜色渐变，结束颜色                                      | white                                                 |
| kaptcha.word.impl                | 文字渲染器                                                   | com.google.code.kaptcha.text.impl.DefaultWordRenderer |
| kaptcha.session.key              | session key                                                  | KAPTCHA_SESSION_KEY                                   |
| kaptcha.session.date             | session date                                                 | KAPTCHA_SESSION_DATE                                  |

##### Spring MVC 整合 Kaptcha

1. 引入依赖

   ```xml
   <dependency>
       <groupId>com.github.penggle</groupId>
       <artifactId>kaptcha</artifactId>
       <version>2.3.2</version>
   </dependency>
   ```

2. 配置类

   ```java
   import com.google.code.kaptcha.Producer;
   import com.google.code.kaptcha.impl.DefaultKaptcha;
   import com.google.code.kaptcha.util.Config;
   import org.springframework.context.annotation.Bean;
   import org.springframework.context.annotation.Configuration;
   
   import java.util.Properties;
   
   
   @Configuration
   public class KaptchaConfig {
   
       @Bean(name = "captchaProducer")
       public Producer captchaProducer() {
           DefaultKaptcha kaptcha = new DefaultKaptcha();
           Properties properties = new Properties();
           properties.setProperty("kaptcha.border", "yes");
           properties.setProperty("kaptcha.border.color", "105.179.90");
           properties.setProperty("kaptcha.textproducer.font.color", "blue");
           properties.setProperty("kaptcha.image.width", "125");
           properties.setProperty("kaptcha.image.height", "45");
           properties.setProperty("kaptcha.textproducer.font.size", "45");
           properties.setProperty("kaptcha.session.key", "code");
           properties.setProperty("kaptcha.textproducer.char.length", "4");
           properties.setProperty("kaptcha.textproducer.font.names", "宋体，楷体，微软雅黑");
           kaptcha.setConfig(new Config(properties));
           return kaptcha;
       }
   
   }
   ```

3. Controller 层

   ```java
   import com.google.code.kaptcha.Constants;
   import com.google.code.kaptcha.Producer;
   import org.springframework.beans.factory.annotation.Autowired;
   import org.springframework.stereotype.Controller;
   import org.springframework.web.bind.annotation.GetMapping;
   
   import javax.imageio.ImageIO;
   import javax.servlet.ServletOutputStream;
   import javax.servlet.http.HttpServletRequest;
   import javax.servlet.http.HttpServletResponse;
   import java.awt.image.BufferedImage;
   import java.io.IOException;
   
   
   @Controller
   public class KaptchaController {
   
       @Autowired
       private Producer captchaProducer;
   
       @GetMapping("/verification")
       public void verification(HttpServletRequest request, HttpServletResponse response) {
           response.setDateHeader("Expires", 0);
           // Set standard HTTP/1.1 no-cache headers.
           response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
           // Set IE extended HTTP/1.1 no-cache headers (use addHeader).
           response.addHeader("Cache-Control", "post-check=0, pre-check=0");
           // Set standard HTTP/1.0 no-cache header.
           response.setHeader("Pragma", "no-cache");
           // return a jpeg
           response.setContentType("image/jpeg");
           // create the text for the image
           String capText = captchaProducer.createText();
           // store the text in the session
           request.getSession().setAttribute(Constants.KAPTCHA_SESSION_KEY, capText);
           // create the image with the text
           BufferedImage bi = captchaProducer.createImage(capText);
           try (ServletOutputStream out = response.getOutputStream()) {
               // write the data out
               ImageIO.write(bi, "jpg", out);
           } catch (IOException e) {
   
           }
       }
   }
   ```

4. 添加一个 Filter, 提前校验验证码。

   ```java
   import com.google.code.kaptcha.Constants;
   import org.springframework.security.authentication.AuthenticationServiceException;
   
   import javax.servlet.*;
   import javax.servlet.http.HttpServletRequest;
   import javax.servlet.http.HttpServletResponse;
   import java.io.IOException;
   
   public class CodeFilter implements Filter {
   
   
       @Override
       public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
           HttpServletRequest req = (HttpServletRequest) request;
           HttpServletResponse resp = (HttpServletResponse) response;
   
           String uri = req.getServletPath();
   
           // 只拦截登录请求
           if (uri.equals("/login") && req.getMethod().equalsIgnoreCase("post")) {
   
               // 拿到 session 中的验证码
               String sessionCode = req.getSession().getAttribute(Constants.KAPTCHA_SESSION_KEY).toString();
               // 获取用户传过来的验证码
               String formCode = req.getParameter("code").trim();
   
               if (formCode.length() == 0) {
                   throw new RuntimeException("验证码不能为空");
               }
               if (sessionCode.equalsIgnoreCase(formCode)) {
                   // 验证通过
                   chain.doFilter(request, response);
               }
               throw new AuthenticationServiceException("验证码错误");
           }
           chain.doFilter(request, response);
       }
   }
   ```

5. 配置 Filter

   ```java
   @EnableWebSecurity
   @Configuration
   public class SpringSecurityConfig extends WebSecurityConfigurerAdapter {
       @Override
       protected void configure(HttpSecurity http) throws Exception {
           // 在验证用户名和密码之前执行验证码的 Filter
           http.addFilterBefore(new CodeFilter(), UsernamePasswordAuthenticationFilter.class);
       }
   }
   ```

