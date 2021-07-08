---
title: 分布式锁
date: '2021-03-27 20:54:00'
tags:
- MSB
- Project
- 网约车三期
- Java
---
# 分布式锁

![image-20210325010249566](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210325010250.png)



模拟司机抢单场景，用户向司机服务发送请求，司机服务调用订单服务集群，订单服务需要对订单状态进行修改

OrderController

```java
@RestController
@RequestMapping("/order")
public class OrderController {

    // 无锁
    //@Qualifier("noLockService")
    // JVM 锁
    //@Qualifier("jvmLockService")
    // MySQL 锁
    //@Qualifier("mySqlLockService")
    // Redis 锁
    //@Qualifier("redisLockService")
    // Redisson
    //@Qualifier("redissonLockService")
    // 红锁
    //@Qualifier("redissonRedLockService")
    // redis lua 脚本
    //@Qualifier("redisLuaLockService")
    // redis aop
    @Qualifier("redisAopLockService")
    @Autowired
    private OrderService orderService;


    @GetMapping("/grab")
    public String grab(@RequestParam Integer driverId) {
        System.out.println("司机：" + driverId + " 开始抢单");
        Boolean grab = orderService.grab(1, driverId);
        System.out.println("司机：" + driverId + " 抢单" + (Objects.equals(true, grab) ? "成功" : "失败"));
        return "end";
    }
}
```

## 不同锁方式

### 不加锁

```java
@Service("noLockService")
public class NoLockServiceImpl implements OrderService {

    @Autowired
    private TblOrderDAO tblOrderDAO;

    @Override
    public Boolean grab(Integer orderId, Integer driverId) {
        System.out.println("司机：" + driverId + " 执行抢单逻辑");
        TblOrder tblOrder = tblOrderDAO.selectByPrimaryKey(orderId);
        try {
            TimeUnit.SECONDS.sleep(1);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        if (tblOrder.getStatus() == 0) {
            tblOrder.setStatus((byte) 1);
            tblOrderDAO.updateByPrimaryKey(tblOrder);
            return true;
        }
        return false;
    }
}
```

不加锁，启动单个项目也会出现同一个订单，被多个司机抢走的情况

### JVM 锁

```java
@Service("jvmLockService")
public class JvmLockServiceImpl implements OrderService {

    @Autowired
    private TblOrderDAO tblOrderDAO;

    @Override
    public Boolean grab(Integer orderId, Integer driverId) {
        // 加 jvm 锁
        synchronized (this) {
            System.out.println("司机：" + driverId + " 执行抢单逻辑");
            // 模拟查询出同一个订单
            TblOrder tblOrder = tblOrderDAO.selectByPrimaryKey(orderId);
            try {
                // 模拟其他业务耗时
                TimeUnit.SECONDS.sleep(1);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            // status=0 表示没有被抢走
            if (tblOrder.getStatus() == 0) {
                // 修改状态为已被抢
                tblOrder.setStatus((byte) 1);
                tblOrderDAO.updateByPrimaryKey(tblOrder);
                return true;
            }
            return false;
        }
    }
}
```

使用 JVM 锁，可以保证单个项目没问题，但是如果是集群，则依旧会出现多个司机抢走同一单的情况

### MySQL 锁

1. 创建一个数据表 tbl_order_driver_lock

   > 使用 orderId 作为主键。
   >
   > 当某个线程能把某个 orderId 插入进数据表的时候，就表明其获取到了锁。
   >
   > 由于主键约束，其他线程不能再将相同 orderId 的记录插入到表

   ```sql
   create table tbl_order_driver_lock
   (
   	orderId int not null comment '订单 ID 作为主键，利用主键约束来保证不会重复插入'
   		primary key,
   	driverId int null comment '司机 Id'
   )
   comment '订单表和司机的锁表';
   ```

2. 自己写一个 MySQL 锁类

   ```java
   @Data
   @Component
   public class MySqlLock implements Lock {
   
       private ThreadLocal<TblOrderDriverLock> threadLocal;
   
       @Autowired
       private TblOrderDriverLockDAO tblOrderDriverLockDAO;
   
       /**
        * 阻塞式获取锁
        */
       @Override
       public void lock() {
           while (!tryLock()) {
           }
       }
   
       /**
        * 非阻塞式获取锁
        *
        * @return 获取到锁返回 true，否则返回 false
        */
       @Override
       public boolean tryLock() {
           try {
               TblOrderDriverLock tblOrderDriverLock = threadLocal.get();
               tblOrderDriverLockDAO.insertSelective(tblOrderDriverLock);
               return true;
           } catch (Exception e) {
               return false;
           }
       }
   
       /**
        * 带超时时间的非阻塞式获取锁
        *
        * @param time 超时时间
        * @param unit 时间单位
        * @return 获取到锁返回 true，超时没有获取到锁返回 true
        * @throws InterruptedException
        */
       @Override
       public boolean tryLock(long time, TimeUnit unit) throws InterruptedException {
           long deadline = System.currentTimeMillis() + unit.toMillis(time);
           while (!tryLock()) {
               if (System.currentTimeMillis() > deadline) {
                   return false;
               }
               TimeUnit.MILLISECONDS.sleep(10);
           }
           return true;
       }
   
       /**
        * 解锁
        */
       @Override
       public void unlock() {
           tblOrderDriverLockDAO.deleteByPrimaryKey(threadLocal.get().getOrderid());
           threadLocal.remove();
       }
   
       @Override
       public void lockInterruptibly() throws InterruptedException {
   
       }
   
       @Override
       public Condition newCondition() {
           return null;
       }
   }
   ```

3. 在业务中使用 MySQL 锁

   ```java
   @Service("mySqlLockService")
   public class MySqlLockServiceImpl implements OrderService {
   
       @Autowired
       private TblOrderDAO tblOrderDAO;
   
       private ThreadLocal<TblOrderDriverLock> threadLocal = new ThreadLocal<>();
   
       @Autowired
       private MySqlLock mySqlLock;
   
       @Override
       public Boolean grab(Integer orderId, Integer driverId) {
           // 1. 生成 锁
           TblOrderDriverLock lock = new TblOrderDriverLock();
           lock.setOrderid(orderId);
           lock.setDriverid(driverId);
   
           threadLocal.set(lock);
           mySqlLock.setThreadLocal(threadLocal);
           // 上锁
           mySqlLock.lock();
           try {
               System.out.println("司机：" + driverId + " 执行抢单逻辑");
               TblOrder tblOrder = tblOrderDAO.selectByPrimaryKey(orderId);
               try {
                   TimeUnit.SECONDS.sleep(1);
               } catch (InterruptedException e) {
                   e.printStackTrace();
               }
               if (tblOrder.getStatus() == 0) {
                   tblOrder.setStatus((byte) 1);
                   tblOrderDAO.updateByPrimaryKey(tblOrder);
                   return true;
               }
               return false;
           } finally {
               // 解锁
               mySqlLock.unlock();
           }
       }
   }
   ```

并发量小的时候可以用，并发量高不要用，性能低。

还需要添加一个触发器，用来定时将长时间存在 tbl_order_driver_lock 表中的记录删除。因为可能某个线程获取到锁后，数据库宕机了，这样该线程释放锁的时候就没法将该记录删除，导致该订单没有被抢到，同时其他线程也没法获取到这个订单的锁

### Redis 锁

#### Redis

```java
@Service("redisLockService")
public class RedisLockServiceImpl implements OrderService {

    @Autowired
    private TblOrderDAO tblOrderDAO;

    @Autowired
    private RedisTemplate<String, Object> redisTemplate;

    @Override
    public Boolean grab(Integer orderId, Integer driverId) {
        // 1. 生成锁
        String lockKey = "grab_order_" + orderId;
        String lockVal = String.valueOf(driverId);
        // 2. 插入锁
        int timeout = 10;
        TimeUnit unit = TimeUnit.MINUTES;
        Boolean lockStatus = redisTemplate.opsForValue().setIfAbsent(lockKey, lockVal, timeout, unit);

        if (lockStatus == null || !lockStatus) {
            // 加锁失败，返回 false
            return false;
        }

        // 使用守护线程，定时对 key 续期
        // TODO 此处可使用线程池进行优化
        Thread t = new Thread(() -> {
            while(true){
                Object val = redisTemplate.opsForValue().get(lockKey);
                if (lockVal.equals(val)) {
                    int sleepTime = timeout / 3;
                    try {
                        unit.sleep(sleepTime);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                    if(redisTemplate.hasKey(lockKey)){
                        redisTemplate.expire(lockKey, timeout, unit);
                    }
                }
            }
        });
        t.setDaemon(true);
        t.start();

        // 3. 业务代码
        try {
            System.out.println("司机：" + driverId + " 执行抢单逻辑");
            TblOrder tblOrder = tblOrderDAO.selectByPrimaryKey(orderId);
            try {
                TimeUnit.SECONDS.sleep(1);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            if (tblOrder.getStatus() == 0) {
                tblOrder.setStatus((byte) 1);
                tblOrderDAO.updateByPrimaryKey(tblOrder);
                return true;
            }
            return false;
        } finally {
            // 4. 释放锁，此处判断防止释放掉别人加的锁
            if (lockVal.equals(redisTemplate.opsForValue().get(lockKey))) {
                redisTemplate.delete(lockKey);
            }
        }
    }
}
```

注意事项：

1. 在插入锁的时候，一定要使用原子性操作来设置过期时间，防止过期时间设置失败

2. 释放锁的时候一定要进行判断，防止释放掉别人加的锁，val 可以是业务中的数据等

3. 要使用守护线程对锁进行续期，防止业务执行时间超过锁过期时间，释放掉别人加的锁

   > 例如抢单业务，设置了锁失效时间是 10 分钟，第一个抢到锁的线程执行了 12 分钟，在 10 分钟的时候锁失效了，所以另一个线程也抢到了同一个订单，并加了自己的锁，等 12 分钟的时候，第一个线程释放锁，如果不加判断，就会释放掉后面线程给加的锁

**该方式在生产环境不推荐使用，仅用于面试**

#### Redission

1. 引入依赖

   ```xml
   <dependency>
       <groupId>org.redisson</groupId>
       <artifactId>redisson-all</artifactId>
       <version>3.15.0</version>
   </dependency>
   ```

2. 配置 Redisson

   ```java
   import org.redisson.Redisson;
   import org.redisson.api.RedissonClient;
   import org.redisson.config.Config;
   import org.springframework.context.annotation.Bean;
   import org.springframework.context.annotation.Configuration;
   
   @Configuration
   public class RedissonConfig {
   
       @Bean
       public RedissonClient redissonClient() {
           Config config = new Config();
           config.useSingleServer()
                   .setAddress("redis://localhost:6379")
                   .setDatabase(0);
           return Redisson.create(config);
       }
   }
   ```

3. 业务代码

   ```java
   @Service("redissonLockService")
   public class RedissonLockServiceImpl implements OrderService {
   
       @Autowired
       private TblOrderDAO tblOrderDAO;
   
       @Autowired
       private RedissonClient redissonClient;
   
       @Override
       public Boolean grab(Integer orderId, Integer driverId) {
           // 1. 生成锁
           String lockKey = "grab_order_" + orderId;
           RLock lock = redissonClient.getLock(lockKey);
           
           try {
               // 2. 加锁。默认的超时时间是 30 秒，每过 1/3 x 30 秒会自动续期
               lock.lock();
               // 3. 业务代码
               System.out.println("司机：" + driverId + " 执行抢单逻辑");
               TblOrder tblOrder = tblOrderDAO.selectByPrimaryKey(orderId);
               try {
                   TimeUnit.SECONDS.sleep(1);
               } catch (InterruptedException e) {
                   e.printStackTrace();
               }
               if (tblOrder.getStatus() == 0) {
                   tblOrder.setStatus((byte) 1);
                   tblOrderDAO.updateByPrimaryKey(tblOrder);
                   return true;
               }
               return false;
           } finally {
               // 4. 释放锁
               lock.unlock();
           }
       }
   }
   ```

#### Redission 红锁

1. 引入依赖

   ```xml
   <dependency>
       <groupId>org.redisson</groupId>
       <artifactId>redisson-all</artifactId>
       <version>3.15.0</version>
   </dependency>
   ```

2. 配置文件

   ```java
   import org.redisson.Redisson;
   import org.redisson.api.RedissonClient;
   import org.redisson.config.Config;
   import org.springframework.context.annotation.Bean;
   import org.springframework.context.annotation.Configuration;
   
   @Configuration
   public class RedissonRedLockConfig {
   
       @Bean
       public RedissonClient redissonRedClient1() {
           Config config = new Config();
           config.useSingleServer()
                   .setAddress("redis://127.0.0.1:6379")
                   .setDatabase(0);
           return Redisson.create(config);
       }
   
       @Bean
       public RedissonClient redissonRedClient2() {
           Config config = new Config();
           config.useSingleServer()
                   .setAddress("redis://127.0.0.1:6479")
                   .setDatabase(0);
           return Redisson.create(config);
       }
   
       @Bean
       public RedissonClient redissonRedClient3() {
           Config config = new Config();
           config.useSingleServer()
                   .setAddress("redis://127.0.0.1:6579")
                   .setDatabase(0);
           return Redisson.create(config);
       }
   }
   ```

3. 业务代码

   ```java
   @Service("redissonRedLockService")
   public class RedissonRedLockServiceImpl implements OrderService {
   
       @Autowired
       private TblOrderDAO tblOrderDAO;
   
       @Autowired
       @Qualifier("redissonRedClient1")
       private RedissonClient redissonRedClient1;
   
       @Autowired
       @Qualifier("redissonRedClient2")
       private RedissonClient redissonRedClient2;
   
       @Autowired
       @Qualifier("redissonRedClient3")
       private RedissonClient redissonRedClient3;
   
       @Override
       public boolean grab(Integer orderId, Integer driverId) {
           // 1. 生成锁
           String lockKey = "grab_order_" + orderId;
   
           // 2. 红锁
           RLock lock1 = redissonRedClient1.getLock(lockKey);
           RLock lock2 = redissonRedClient2.getLock(lockKey);
           RLock lock3 = redissonRedClient3.getLock(lockKey);
           RedissonRedLock redLock = new RedissonRedLock(lock1, lock2, lock3);
   
           try {
               // 3. 加锁。默认的超时时间是 30 秒，每过 1/3 x 30 秒会自动续期
               redLock.lock();
               // 4. 业务代码
               System.out.println("司机：" + driverId + " 执行抢单逻辑");
               TblOrder tblOrder = tblOrderDAO.selectByPrimaryKey(orderId);
               try {
                   TimeUnit.SECONDS.sleep(1);
               } catch (InterruptedException e) {
                   e.printStackTrace();
               }
               if (tblOrder.getStatus() == 0) {
                   tblOrder.setStatus((byte) 1);
                   tblOrderDAO.updateByPrimaryKey(tblOrder);
                   return true;
               }
               return false;
           } finally {
               // 5. 释放锁
               redLock.unlock();
           }
       }
   }
   ```

使用了 3 台独立的 redis，也可以自己扩容，但是必须是奇数个

#### Redis Lua 脚本

RedisTemplate 执行 lua 脚本的时候，lua 脚本中的代码是原子性的

1. set 锁的 lua 脚本

   ```lua
   --- 获取 key
   local key = KEYS[1]
   --- 获取 value
   local val = KEYS[2]
   --- 获取一个参数
   local expire = ARGV[1]
   --- 如果 redis 找不到这个 key 就去插入
   if redis.call("get", key) == false then
       --- 如果插入成功，就去设置过期值
       if redis.call("set", key, val) then
           --- 由于 lua 脚本接收到参数都会转为 String，所以要转成数字类型才能比较
           if tonumber(expire) > 0 then
               --- 设置过期时间
               redis.call("expire", key, expire)
           end
           return true
       end
       return false
   else
       return false
   end
   ```

2. 删除锁的 lua 脚本

   ```lua
   if redis.call("get", KEYS[1]) == ARGV[1] then
     return redis.call("del", KEYS[1])
   else
     return 0
   end
   ```

3. lua 脚本配置类

   ```java
   import org.springframework.context.annotation.Bean;
   import org.springframework.context.annotation.Configuration;
   import org.springframework.core.io.ClassPathResource;
   import org.springframework.data.redis.core.script.DefaultRedisScript;
   import org.springframework.scripting.support.ResourceScriptSource;
   
   @Configuration
   public class RedisLuaConfig {
   
       @Bean(name = "redisSetScript")
       public DefaultRedisScript<Boolean> redisSetScript() {
           DefaultRedisScript<Boolean> redisScript = new DefaultRedisScript<>();
           redisScript.setScriptSource(new ResourceScriptSource(new ClassPathResource("luascript/lock-set.lua")));
           redisScript.setResultType(Boolean.class);
           return redisScript;
       }
   
       @Bean(name = "redisDelScript")
       public DefaultRedisScript<Boolean> redisDelScript() {
           DefaultRedisScript<Boolean> redisScript = new DefaultRedisScript<>();
           redisScript.setScriptSource(new ResourceScriptSource(new ClassPathResource("luascript/lock-del.lua")));
           redisScript.setResultType(Boolean.class);
           return redisScript;
       }
   }
   ```

4. 业务代码

   ```java
   package com.example.dlorder.service.impl;
   
   import com.example.dlorder.dao.TblOrderDAO;
   import com.example.dlorder.entity.TblOrder;
   import com.example.dlorder.service.OrderService;
   import org.springframework.beans.factory.annotation.Autowired;
   import org.springframework.beans.factory.annotation.Qualifier;
   import org.springframework.data.redis.core.RedisTemplate;
   import org.springframework.data.redis.core.script.DefaultRedisScript;
   import org.springframework.stereotype.Service;
   
   import java.util.Arrays;
   import java.util.List;
   import java.util.concurrent.TimeUnit;
   
   /**
    * @author wangshuo
    * @date 2021/03/26
    */
   @Service("redisLuaLockService")
   public class RedisLuaLockServiceImpl implements OrderService {
   
       @Autowired
       private TblOrderDAO tblOrderDAO;
   
       @Autowired
       @Qualifier("redisSetScript")
       private DefaultRedisScript<Boolean> redisSetScript;
   
       @Autowired
       @Qualifier("redisDelScript")
       private DefaultRedisScript<Boolean> redisDelScript;
   
       @Autowired
       private RedisTemplate<String, String> redisTemplate;
   
   
       @Override
       public Boolean grab(Integer orderId, Integer driverId) {
           // 1. 生成锁
           String lockKey = "grab_order_" + orderId;
           String lockVal = "driverId_" + driverId;
           String expireTime = "1000";
           List<String> keys = Arrays.asList(lockKey, lockVal);
   
           try {
               // 2. 执行加锁的脚本
               Boolean lockStatus = redisTemplate.execute(redisSetScript, keys, expireTime);
   
               if (!lockStatus) {
                   // 锁定失败，直接返回 false
                   return false;
               }
   
               // 使用守护线程，定时对 key 续期
               // TODO 此处可使用线程池进行优化
               Thread t = new Thread(() -> {
                   while(true){
                       Object val = redisTemplate.opsForValue().get(lockKey);
                       if (lockVal.equals(val)) {
                           int sleepTime = timeout / 3;
                           try {
                               unit.sleep(sleepTime);
                           } catch (InterruptedException e) {
                               e.printStackTrace();
                           }
                           if(redisTemplate.hasKey(lockKey)){
                               redisTemplate.expire(lockKey, timeout, unit);
                           }
                       }
                   }
               });
               t.setDaemon(true);
               t.start();
   
               // 3. 业务代码
               System.out.println("司机：" + driverId + " 执行抢单逻辑");
               TblOrder tblOrder = tblOrderDAO.selectByPrimaryKey(orderId);
               try {
                   TimeUnit.SECONDS.sleep(1);
               } catch (InterruptedException e) {
                   e.printStackTrace();
               }
               if (tblOrder.getStatus() == 0) {
                   tblOrder.setStatus((byte) 1);
                   tblOrderDAO.updateByPrimaryKey(tblOrder);
                   return true;
               }
               return false;
           } finally {
               // 4. 释放锁
               redisTemplate.execute(redisDelScript,
                                     Arrays.asList(lockKey), lockVal);
           }
       }
   }
   ```
   
   注意事项：RedisTemplate<String, String>的泛型都使用了 String，所以传参的时候也要都是 String 类型，这样传到 lua 脚本中的也都是 String 类型

#### SpringIntegrationRedis+AOP

1. 引入依赖

   ```xml
   <dependency>
       <groupId>org.springframework.boot</groupId>
       <artifactId>spring-boot-starter-integration</artifactId>
   </dependency>
   <dependency>
       <groupId>org.springframework.integration</groupId>
       <artifactId>spring-integration-redis</artifactId>
   </dependency>
   <dependency>
       <groupId>org.springframework.boot</groupId>
       <artifactId>spring-boot-starter-data-redis</artifactId>
   </dependency>
   ```

2. 配置 RedisLockRegistry

   ```java
   import org.springframework.context.annotation.Bean;
   import org.springframework.context.annotation.Configuration;
   import org.springframework.data.redis.connection.RedisConnectionFactory;
   import org.springframework.integration.redis.util.RedisLockRegistry;
   import java.util.concurrent.TimeUnit;
   
   @Configuration
   public class RedisLockRegistryConf {
       @Bean
       public RedisLockRegistry redisLockRegistry(RedisConnectionFactory redisConnectionFactory) {
           return new RedisLockRegistry(redisConnectionFactory, "REGISTRY_KEY");
       }
       /**
        * 可根据不同的业务设置不同的 registryKey
        * 此处模拟抢单场景，所以设置 registryKey 为 GRAB_ORDER
        * 实际存储到 redis 中的 key 是 registryKey:lockKey 形式
        * lockKey 在业务中调用 RedisLockRegistry 的 obtain(lockKey)方法时，手动设置
        */
       @Bean
       public RedisLockRegistry grabOrderRlr(RedisConnectionFactory redisConnectionFactory) {
           return new RedisLockRegistry(redisConnectionFactory, "GRAB_ORDER", TimeUnit.SECONDS.toMillis(15));
       }
   }
   ```

3. 添加自定义注解

   ```java
   import java.lang.annotation.ElementType;
   import java.lang.annotation.Retention;
   import java.lang.annotation.RetentionPolicy;
   import java.lang.annotation.Target;
   import java.util.concurrent.TimeUnit;
   
   @Target(ElementType.METHOD)
   @Retention(RetentionPolicy.RUNTIME)
   public @interface DistributeLock {
       /**
        * RedisLockRegistry 的 Bean 名称
        */
       String redisLockRegistry() default "redisLockRegistry";
       /**
        * 等待时长，为 0 表示不等待
        */
       long waitTime() default 0;
       /**
        * 时间单位
        */
       TimeUnit timeUnit() default TimeUnit.SECONDS;
       /**
        * 锁的 key
        * 支持 SPEL 表达式
        * 为空则使用方法签名
        */
       String key() default "";
   }
   ```

4. 添加 AOP 切面，对标注了上方的 `DistributeLock` 注解的方法进行拦截

   ```java
   import com.example.dlorder.annotation.DistributeLock;
   import com.google.gson.Gson;
   import lombok.extern.slf4j.Slf4j;
   import org.apache.commons.lang.StringUtils;
   import org.aspectj.lang.ProceedingJoinPoint;
   import org.aspectj.lang.annotation.Around;
   import org.aspectj.lang.annotation.Aspect;
   import org.aspectj.lang.annotation.Pointcut;
   import org.aspectj.lang.reflect.MethodSignature;
   import org.springframework.beans.factory.annotation.Autowired;
   import org.springframework.core.LocalVariableTableParameterNameDiscoverer;
   import org.springframework.expression.EvaluationContext;
   import org.springframework.expression.Expression;
   import org.springframework.expression.ExpressionParser;
   import org.springframework.expression.spel.standard.SpelExpressionParser;
   import org.springframework.expression.spel.support.StandardEvaluationContext;
   import org.springframework.integration.redis.util.RedisLockRegistry;
   import org.springframework.stereotype.Component;
   import org.springframework.web.context.WebApplicationContext;
   
   import java.lang.reflect.Method;
   import java.util.concurrent.locks.Lock;
   
   @Slf4j
   @Aspect
   @Component
   public class DistributeLockAop {
   
       private final ExpressionParser parser = new SpelExpressionParser();
   
       private final LocalVariableTableParameterNameDiscoverer discoverer = new LocalVariableTableParameterNameDiscoverer();
   
       @Autowired
       private WebApplicationContext webApplicationContext;
   
       @Pointcut("@annotation(com.example.dlorder.annotation.DistributeLock)")
       private void pointcut() {
       }
   
       @Around("pointcut()")
       public Object around(ProceedingJoinPoint pjp) throws Throwable {
           MethodSignature signature = (MethodSignature) pjp.getSignature();
           Method method = signature.getMethod();
           String className = pjp.getTarget().getClass().getName();
           Object[] args = pjp.getArgs();
           DistributeLock annotation = method.getAnnotation(DistributeLock.class);
           String rlrName = annotation.redisLockRegistry();
   
           RedisLockRegistry redisLockRegistry = (RedisLockRegistry) webApplicationContext.getBean(rlrName);
   
           // 把 key 中的 SPEL 表达式进行转换
           String key = annotation.key();
           Object oKey = parseSpel(method, args, key, Object.class, key);
           // 如果 key 是空值，就用签名做 key
           String lockKey = StringUtils.isEmpty(key) ? signature.toString() : new Gson().toJson(oKey);
   
           /*
           放到 redis 中的锁的 key 格式是 registryKey:lockKey
           registryKey 是在创建 RedisLockRegistry 的 Bean 的时候设置的，lockKey 是该方法的入参
            */
           Lock lock = redisLockRegistry.obtain(lockKey);
           // 尝试加锁
           boolean lockStatus = lock.tryLock(annotation.waitTime(), annotation.timeUnit());
   
           Object proceed = null;
   
           // 获取到锁了
           if (lockStatus) {
               try {
                   /*
                   TODO 此处应该定时对 key 续期，防止业务执行时间超过 redisKey 的失效时间，出现提前释放锁的情况
                   但是 Spring Integration 的 RedisLockRegistry 本身并没有提供自动续期机制
                   在这里也不能通过 RedisLockRegistry 动态获取到 registryKey，所以手动续期代码需要写死代码
                   考虑可以不使用 Spring Integration，使用其他方式(redisTemplate/lua 脚本+手写续期代码 或 redisson)
                   如果使用该方式，需保证业务执行时间必须小于锁失效时间
                    */
   
                   // 执行业务方法
                   proceed = pjp.proceed();
               } catch (Exception e) {
                   log.error("执行业务发生错误，class={}，method={}，args={}", className, method, args);
                   throw e;
               } finally {
                   try {
                       // 解锁
                       lock.unlock();
                   } catch (Exception e) {
                       log.error("解锁发生异常", e);
                   }
               }
           }
           return proceed;
       }
   
       /**
        * 解析 spel 表达式
        *
        * @param method        方法
        * @param agrs          方法参数
        * @param spel          表达式
        * @param clazz         返回结果的类型
        * @param defaultResult 默认结果
        * @return 执行 spel 表达式后的结果
        */
       private <T> T parseSpel(Method method, Object[] agrs, String spel, Class<T> clazz, T defaultResult) {
           String[] params = discoverer.getParameterNames(method);
           EvaluationContext context = new StandardEvaluationContext();
           if (params != null) {
               for (int i = 0; i < params.length; i++) {
                   context.setVariable(params[i], agrs[i]);
               }
           }
           try {
               Expression expression = parser.parseExpression(spel);
               return expression.getValue(context, clazz);
           } catch (Exception e) {
               return defaultResult;
           }
       }
   }
   ```

5. 业务方法

   ```java
   import com.example.dlorder.annotation.DistributeLock;
   import com.example.dlorder.dao.TblOrderDAO;
   import com.example.dlorder.entity.TblOrder;
   import com.example.dlorder.service.OrderService;
   import org.springframework.beans.factory.annotation.Autowired;
   import org.springframework.stereotype.Service;
   
   import java.util.concurrent.TimeUnit;
   
   @Service("redisAopLockService")
   public class RedisAopLockServiceImpl implements OrderService {
   
       @Autowired
       private TblOrderDAO tblOrderDAO;
       
   	// 添加 DistributeLock 注解即可
       @DistributeLock(redisLockRegistry = "grabOrderRlr", key = "#orderId")
       @Override
       public Boolean grab(Integer orderId, Integer driverId) {
           System.out.println("司机：" + driverId + " 执行抢单逻辑");
           TblOrder tblOrder = tblOrderDAO.selectByPrimaryKey(orderId);
           try {
               TimeUnit.SECONDS.sleep(1);
           } catch (InterruptedException e) {
               e.printStackTrace();
           }
           if (tblOrder.getStatus() == 0) {
               tblOrder.setStatus((byte) 1);
               tblOrderDAO.updateByPrimaryKey(tblOrder);
               return true;
           }
           return false;
       }
   }
   ```

#### AOP 整合

可以参考 [SpringIntegrationRedis+AOP](#SpringIntegrationRedis+AOP)，将 SpringIntegrationRedis 替换为其他方式，来达到对业务无侵入式的加锁

## 设计分布式锁的注意事项

互斥锁：同时只能有一个服务能获取锁

防死锁：不要发生死锁，也不要让之后的客户端加不上锁

自己的锁自己解：防止自己加的锁被其他服务给解除了

容错性：例如可以使用多个 redis，提高系统稳定性

## 不同锁方式对比

| 锁类型                         | 单服务线程安全 | 多服务线程安全 | 性能 | 自动续期                                     | 稳定性                        |
| ------------------------------ | -------------- | -------------- | ---- | -------------------------------------------- | ----------------------------- |
| 不加锁                         | 不安全         | 不安全         | -    | 无                                           |                               |
| JVM 锁                          | 安全           | 不安全         | -    | 不需要                                       |                               |
| MySQL 锁                        | 安全           | 安全           | 低   | 不需要                                       |                               |
| Redis                          | 安全           | 安全           | -    | 需要自己写自动续期代码                       |                               |
| Redission                      | 安全           | 安全           | -    | 自带自动续期，不需要自己写                   |                               |
| Redission 红锁                  | 安全           | 安全           | -    | 自带自动续期，不需要自己写                   | 稳定性高（使用多个单独的 Redis） |
| Redis Lua 脚本                  | 安全           | 安全           | -    | 需要自己写自动续期代码                       |                               |
| Spring Integration Redis + AOP | 安全           | 安全           | -    | 未提供自动续期代码，需要在切面类中写“死”代码 |                               |

## Redisson 红锁细节

### 源码

```java
public boolean tryLock(long waitTime, long leaseTime, TimeUnit unit) throws InterruptedException {
    long newLeaseTime = -1;
    if (leaseTime != -1) {
        if (waitTime == -1) {
            newLeaseTime = unit.toMillis(leaseTime);
        } else {
            newLeaseTime = unit.toMillis(waitTime)*2;
        }
    }
	// 获取系统当前时间
    long time = System.currentTimeMillis();
    long remainTime = -1;
    if (waitTime != -1) {
        remainTime = unit.toMillis(waitTime);
    }
    long lockWaitTime = calcLockWaitTime(remainTime);

    int failedLocksLimit = failedLocksLimit();
    List<RLock> acquiredLocks = new ArrayList<>(locks.size());
    // 遍历所有的 RLock
    for (ListIterator<RLock> iterator = locks.listIterator(); iterator.hasNext();) {
        RLock lock = iterator.next();
        boolean lockAcquired;
        try {
            // 对每个 RLock 都进行加锁
            if (waitTime == -1 && leaseTime == -1) {
                lockAcquired = lock.tryLock();
            } else {
                long awaitTime = Math.min(lockWaitTime, remainTime);
                lockAcquired = lock.tryLock(awaitTime, newLeaseTime, TimeUnit.MILLISECONDS);
            }
        } catch (RedisResponseTimeoutException e) {
            unlockInner(Arrays.asList(lock));
            lockAcquired = false;
        } catch (Exception e) {
            lockAcquired = false;
        }

        if (lockAcquired) {
            acquiredLocks.add(lock);
        } else {
            // 所有锁的数量 - 锁成功的锁的数量
            // failedLocksLimit() = 所有锁数量 - (所有锁数量/2 + 1)
            // 锁成功的锁数量 == 所有锁数量/2 + 1
            if (locks.size() - acquiredLocks.size() == failedLocksLimit()) {
                break;
            }

            if (failedLocksLimit == 0) {
                unlockInner(acquiredLocks);
                if (waitTime == -1) {
                    return false;
                }
                failedLocksLimit = failedLocksLimit();
                acquiredLocks.clear();
                // reset iterator
                while (iterator.hasPrevious()) {
                    iterator.previous();
                }
            } else {
                failedLocksLimit--;
            }
        }

        if (remainTime != -1) {
            // 当前时间 - 开始加锁的时间
            remainTime -= System.currentTimeMillis() - time;
            time = System.currentTimeMillis();
            if (remainTime <= 0) {
                unlockInner(acquiredLocks);
                return false;
            }
        }
    }

    if (leaseTime != -1) {
        List<RFuture<Boolean>> futures = new ArrayList<>(acquiredLocks.size());
        for (RLock rLock : acquiredLocks) {
            RFuture<Boolean> future = ((RedissonLock) rLock).expireAsync(unit.toMillis(leaseTime), TimeUnit.MILLISECONDS);
            futures.add(future);
        }

        for (RFuture<Boolean> rFuture : futures) {
            rFuture.syncUninterruptibly();
        }
    }

    return true;
}
```

### 锁流程

![image-20210326233010587](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210326233011.png)

加成功锁的数量一定要超过一半，最终才是加锁成功。

1. 可以启 5 台 redis
2. 用 shell 手动向 2 个 redis 中插入 lock，然后使用 Redisson 红锁向 5 个 redis 中加锁，最终是可以成功的
3. 用 shell 手动向 3 个 redis 中插入 lock，然后使用 Redisson 红锁向 5 个 redis 中加锁，最终是失败的

### 生产环境问题

![image-20210326232437460](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210326232438.png)

1. 线程 1 给 1、2、3 加锁成功了，最终获取到锁
2. 3 号故障了，并且没有做持久化
3. 恢复 3 号之后，3 号中没有 1 号的锁数据了。此时线程 2 给 3、4、5 加锁成功了，最终也获取到了锁
4. 出现了线程 1 和线程 2 同时都获取到了锁，打破了互斥性

需要运维在恢复 3 号的时候做延时启动（延时时间 \> 锁失效时间）

## 秒杀问题

并发读和并发写特别多

前提：首先，已有的交易系统功能要完善，稳定

特点：短时间内高并发

准：不多卖，不少卖（分布式锁）

快：服务响应速度要快

稳：服务的可用性

防止少买，使用阻塞锁，然后把库存分段



请求量要少：接口数据少

请求链路要短：

依赖要少：

不要单点：



CDN：

动静分离

提前预估

削峰：放到消息队列等着



网络（请求转发），CPU（并发），内存（redis），硬盘（mysql）

