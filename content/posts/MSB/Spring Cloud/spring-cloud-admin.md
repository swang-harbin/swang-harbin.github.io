---
title: Spring Cloud Admin
date: '2020-07-04 00:00:00'
tags:
- MSB
- Spring Cloud
- Java
---
# Spring Cloud Admin

spring cloud admin 包含服务端和客户端，需要二者配合使用

## 配置使用

1. 服务端添加依赖

   ```xml
   <!-- Admin 服务 -->
   <dependency>
       <groupId>de.codecentric</groupId>
       <artifactId>spring-boot-admin-starter-server</artifactId>
   </dependency>
   <!-- Admin 界面 -->
   <dependency>
       <groupId>de.codecentric</groupId>
       <artifactId>spring-boot-admin-server-ui</artifactId>
   </dependency>
   ```

2. 服务端启动类添加 `@EnableAdminServer` 注解

3. 客户端添加依赖，每个需要被监控的服务都需要添加

   ```xml
   <!-- Admin 客户端-->
   <dependency>
       <groupId>de.codecentric</groupId>
       <artifactId>spring-boot-admin-starter-client</artifactId>
       <version>2.3.1</version>
   </dependency>
   <!-- actuator 监控 -->
   <dependency>
       <groupId>org.springframework.boot</groupId>
       <artifactId>spring-boot-starter-actuator</artifactId>
   </dependency>
   ```

4. 客户端配置文件，每个需要被监控的服务都需要加

   ```yaml
   spring:
     boot:
       admin:
         client:
           # admin 服务端地址，用于上报信息
           url: http://localhost:6010
   management:
     endpoints:
       web:
         exposure:
           # 暴露端点
           include: '*'
     endpoint:
       health:
         enabled: true
         show-details: always
   ```

5. 访问 `http://localhost:6010`，用户名密码默认都是 root

**注意事项**

eureka-server 如果包含了用户名和密码验证，使用如下方式将用户名和密码传给 spring cloud admin

```yaml
spring:
  boot:
    admin:
      client:
        # admin 服务端地址，用于上报信息
        url: http://localhost:6010
        instance:
          metadata:
            # 把 erueka server 设置的用户名和密码传递给 spring cloud admin
            user.name: ${spring.security.user.name}
            user.password: ${spring.security.user.password}
```

## 添加 Spring Security

spring cloud admin 也可以添加 spring security 验证

1. 引入依赖

   ```xml
   <!-- spring security starter -->
   <dependency>
       <groupId>org.springframework.boot</groupId>
       <artifactId>spring-boot-starter-security</artifactId>
   </dependency>
   ```

2. 添加配置

   ```yaml
   spring:
     security:
       user:
         name: username
         password: password
   ```

3. 客户端对应的需要添加 spring cloud admin 用户名和密码的配置

   ```yaml
   spring:
     boot:
       admin:
         client:
           username: username
           password: password
   ```

## 服务状态通知

### 邮件通知

1. 在服务端添加依赖

   ```xml
   <!-- 邮件服务 -->
   <dependency>
       <groupId>org.springframework.boot</groupId>
       <artifactId>spring-boot-starter-mail</artifactId>
   </dependency>
   ```

2. 配置文件

   ```yaml
   spring:
     # 邮件设置
     mail:
       host: smtp.qq.com
       # QQ 号
       username: QQ 号
       # 授权码
       password: xxxxxxx 授权码
       properties:
         mail:
           smpt:
             auth: true
             # https
             starttls:
               enable: true
               required: true
   #收件邮箱
   spring.boot.admin.notify.mail.to: xxxxxxxx@qq.com
   # 发件邮箱
   spring.boot.admin.notify.mail.from: xxxxxxx@qq.com
   ```

3. 下线一个服务即可收到邮件

### 钉钉群通知

[钉钉开放平台](https://ding-doc.dingtalk.com/document/app)

1. 自定义消息类

   ```java
   package com.example.cloudadmin.notifier.dingding;
   
   public class Message {
   
       private String msgtype;
   
       private MessageInfo text;
   
       public String getMsgtype() {
           return msgtype;
       }
   
       public void setMsgtype(String msgtype) {
           this.msgtype = msgtype;
       }
   
       public MessageInfo getText() {
           return text;
       }
   
       public void setText(MessageInfo text) {
           this.text = text;
       }
   
       static class MessageInfo {
   
           private String content;
   
           public MessageInfo(String content) {
               this.content = content;
           }
   
           public String getContent() {
               return content;
           }
   
           public void setContent(String content) {
               this.content = content;
           }
       }
   }
   ```

2. 消息工具类

   ```java
   package com.example.cloudadmin.notifier.dingding;
   
   import com.fasterxml.jackson.databind.ObjectMapper;
   
   import java.io.InputStream;
   import java.io.OutputStream;
   import java.net.HttpURLConnection;
   import java.net.URL;
   
   public class DingDingMessageUtil {
   
       /**
        * 创建完钉钉机器人生成的地址和 token
        */
       private static final String WEBHOOK = "https://oapi.dingtalk.com/robot/send?access_token=" +
           "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
   
       public static void sendTextMessage(String msg) {
           try {
               Message message = new Message();
               message.setMsgtype("text");
               message.setText(new Message.MessageInfo(msg));
               URL url = new URL(WEBHOOK);
               // 建立 http 连接
               HttpURLConnection conn = (HttpURLConnection) url.openConnection();
               conn.setDoOutput(true);
               conn.setDoInput(true);
               conn.setUseCaches(false);
               conn.setRequestMethod("POST");
               conn.setRequestProperty("Charset", "UTF-8");
               conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
               conn.connect();
               OutputStream out = conn.getOutputStream();
               String textMessage = new ObjectMapper().writeValueAsString(message);
               byte[] data = textMessage.getBytes();
               out.write(data);
               out.flush();
               out.close();
               InputStream in = conn.getInputStream();
               byte[] data1 = new byte[in.available()];
               in.read(data1);
               System.out.println(new String(data1));
           } catch (Exception e) {
               e.printStackTrace();
           }
       }
   }
   ```

3. 服务状态改变监听器的实现

   ```java
   package com.example.cloudadmin.notifier.dingding;
   
   import com.fasterxml.jackson.core.JsonProcessingException;
   import com.fasterxml.jackson.databind.ObjectMapper;
   import de.codecentric.boot.admin.server.domain.entities.Instance;
   import de.codecentric.boot.admin.server.domain.entities.InstanceRepository;
   import de.codecentric.boot.admin.server.domain.events.InstanceEvent;
   import de.codecentric.boot.admin.server.notify.AbstractStatusChangeNotifier;
   import reactor.core.publisher.Mono;
   
   import java.util.Map;
   
   public class DingDingNotifier extends AbstractStatusChangeNotifier {
   
       /**
        * 自定义的 keywords，创建钉钉机器人的时候设置的
        */
       private static final String KEYWORDS = "服务预警";
   
       public DingDingNotifier(InstanceRepository repository) {
           super(repository);
       }
   
       @Override
       protected Mono<Void> doNotify(InstanceEvent event, Instance instance) {
           String serviceName = instance.getRegistration().getName();
           String serviceUrl = instance.getRegistration().getServiceUrl();
           String status = instance.getStatusInfo().getStatus();
           Map<String, Object> details = instance.getStatusInfo().getDetails();
           StringBuilder str = new StringBuilder();
           str.append(KEYWORDS)
               .append("：【")
               .append(serviceName)
               .append("】")
               .append("【服务地址】")
               .append(serviceUrl)
               .append("【状态】")
               .append(status)
               .append("【详情】");
           try {
               str.append(new ObjectMapper().writeValueAsString(details));
           } catch (JsonProcessingException e) {
               e.printStackTrace();
           }
           return Mono.fromRunnable(() -> DingDingMessageUtil.sendTextMessage(str.toString()));
       }
   
   }
   ```

4. 配置类

   ```java
   package com.example.cloudadmin.config;
   
   import com.example.cloudadmin.notifier.dingding.DingDingNotifier;
   import de.codecentric.boot.admin.server.domain.entities.InstanceRepository;
   import org.springframework.context.annotation.Bean;
   import org.springframework.context.annotation.Configuration;
   
   @Configuration
   public class NotifierConfig {
   
       @Bean
       public DingDingNotifier dingDingNotifier(InstanceRepository repository) {
           return new DingDingNotifier(repository);
       }
   
   }
   ```

