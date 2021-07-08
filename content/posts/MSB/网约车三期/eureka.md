---
title: Eureka
date: '2021-01-02 21:23:00'
tags:
- MSB
- Project
- 网约车三期
- Eureka
- Java
---
# eureka

**github**：https://github.com/Netflix/eureka/

**帮助文档**：https://github.com/Netflix/eureka/wiki

**调试环境**：

Spring Boot version：2.3.0.RELEASE

Spring Cloud version：Hoxton.SR4

**eureka 简介**：

eureka 是 Netflix 开发的服务发现框架，本身是一个基于 REST 的服务（即对服务的注册，续约，下线等操作都是基于 http/https 请求的方式）;

eureka 包含两个组件：eureka server 和 eureka client

- eureka server 提供服务注册服务，也就是常说的注册中心;
- 常说的服务提供者和消费者都是 eureka 的 eureka client。

## eureka 调用流程

![eureka](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2020/20201214113403.png)



## Eureka-Server 启动原理

### 1. 引入 EurekaServerAutoConfiguration 类

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-eureka-server</artifactId>
</dependency>
```

在**spring-cloud-netflix-eureka-server-2.2.2.RELEASE.jar**的**spring.factories**中

> ```properties
> # 在 SpringBoot 启动时，会自动加载该文件中的 bean
> org.springframework.boot.autoconfigure.EnableAutoConfiguration=\
> org.springframework.cloud.netflix.eureka.server.EurekaServerAutoConfiguration
> ```
>
> > ```java
> > // 根据当前容器中是否包含 Marker 类，来决定自动配置是否生效
> > @ConditionalOnBean(EurekaServerMarkerConfiguration.Marker.class)
> > public class EurekaServerAutoConfiguration implements WebMvcConfigurer {
> > ```

### 2. 使用 `@EnableEurekaServer` 注解向容器中注入 Marker 对象

> ```java
> @Import(EurekaServerMarkerConfiguration.class)
> public @interface EnableEurekaServer {
> ```
>
> > ```java
> > public class EurekaServerMarkerConfiguration {
> >     // 向容器中注入 Marker 对象，使得 EurekaServerAutoConfiguration 自动配置类生效
> >     @Bean
> >     public Marker eurekaServerMarkerBean() {
> >         return new Marker();
> >     }
> >     class Marker {
> >     }
> > }
> > ```

## eureka-server 集群配置

三个以上集群配置

```yaml
eureka:
  client:
    # 是否向服务注册还总新注册自己，默认为 true，因为当前就是注册中心，所以需要禁用其向注册中心注册
    register-with-eureka: false
    # 是否需要去探索寻找服务，因为是注册中心，它的任务是维护服务实例，所以不需要去寻找服务
    fetch-registry: false
    service-url:
      defaultZone: http://eureka-7900:7900/eureka/,http://eureka-7901:7901/eureka/,http://eureka-7902:7902/eureka/
---
spring:
  profiles: 7900
server:
  port: 7900
eureka:
  instance:
    hostname: eureka-7900
---
spring:
  profiles: 7901
server:
  port: 7901
eureka:
  instance:
    hostname: eureka-7901
---
spring:
  profiles: 7902
server:
  port: 7902
eureka:
  instance:
    hostname: eureka-7902
```

## eureka 的 CAP 原则

**Consistency（一致性）**：在分布式系统中的所有数据备份，在同一时刻是否是同样的值。（等同于所有节点访问同一份最新的数据副本）

**Availability（可用性）**：在集群中一部分节点故障后，集群整体是否还能响应客户端的读写请求。（对数据更新具有高可用性）

**Partition Tolerance（分区容错性）**：以实际效果而言，分区相当于对通信的时限要求。系统如果不能在时限内达成数据一致性，就意味着发生了分区的情况，必须就当前操作在 C 和 A 之间作出选择。

### CAP 理论

在一个分布式系统中，Consistency（一致性），Availability（可用性），Partition Tolerance（分区容错性），这三个要素最多只能同时实现两点，不可能三者兼顾。由于 P 是分布式系统中比需要保证的，所以我们只能在 C 和 A 之间进行权衡。Zookeeper 保证的是 CP，而 Eureka 保证的是 AP。

## eureka server 优化（源码）

### 服务剔除（优化点）

eureka-server 定期检查 provider 服务是否存活，对长时间没有心跳的服务，可以进行下线操作等。

`EurekaServerAutoConfiguration`

>  `@Import(EurekaServerInitializerConfiguration.class)`
>
>  > `public void start()`
>  >
>  > > ```java
>  > > eurekaServerBootstrap.contextInitialized(
>  > >     EurekaServerInitializerConfiguration.this.servletContext);
>  > > ```
>  > >
>  > > > `initEurekaServerContext();`
>  > > >
>  > > > > `this.registry.openForTraffic(this.applicationInfoManager, registryCount);`
>  > > > >
>  > > > > > ```java
>  > > > > > super.openForTraffic(applicationInfoManager,
>  > > > > >                      count == 0 ? this.defaultOpenForTrafficCount :count);
>  > > > > > ```
>  > > > > >
>  > > > > > > `super.postInit();`
>  > > > > > >
>  > > > > > > > ```java
>  > > > > > > > protected void postInit() {
>  > > > > > > >        renewsLastMin.start();
>  > > > > > > >        if (evictionTaskRef.get() != null) {
>  > > > > > > >            evictionTaskRef.get().cancel();
>  > > > > > > >        }
>  > > > > > > >        evictionTaskRef.set(new EvictionTask());
>  > > > > > > >        evictionTimer.schedule(evictionTaskRef.get(),
>  > > > > > > >                               // 在 eureka-server 中定期将没有心跳的服务清除
>  > > > > > > >                               serverConfig.getEvictionIntervalTimerInMs(),
>  > > > > > > >                               serverConfig.getEvictionIntervalTimerInMs());
>  > > > > > > > }
>  > > > > > > > ```
>  > > > > > > >
>  > > > > > > > > `EvictionTask.run`
>  > > > > > > > >
>  > > > > > > > > > `evict(compensationTimeMs);`
>  > > > > > > > > >
>  > > > > > > > > > > ```java
>  > > > > > > > > > > public void evict(long additionalLeaseMs) {
>  > > > > > > > > > >        // 没开自我保护，则 isLeaseExpirationEnabled() 为 true，此处取反为 false，即没开自我保护一定执行后面的服务剔除逻辑
>  > > > > > > > > > >        // 开启了自我保护，最后一分钟续约的次数>每分钟续订次数的阈值，isLeaseExpirationEnabled()为 true，此处取反为 false，即最后一分钟续约的次数>每分钟续订次数的阈值进行剔除
>  > > > > > > > > > >        if (!isLeaseExpirationEnabled()) {
>  > > > > > > > > > >            logger.debug("DS: lease expiration is currently disabled.");
>  > > > > > > > > > >            return;
>  > > > > > > > > > >        }
>  > > > > > > > > > >        // We collect first all expired items, to evict them in random order. For large eviction sets,
>  > > > > > > > > > >        // if we do not that, we might wipe out whole apps before self preservation kicks in. By randomizing it,
>  > > > > > > > > > >        // the impact should be evenly distributed across all applications.
>  > > > > > > > > > >        List<Lease<InstanceInfo>> expiredLeases = new ArrayList<>();
>  > > > > > > > > > >        for (Entry<String, Map<String, Lease<InstanceInfo>>> groupEntry : registry.entrySet()) {
>  > > > > > > > > > >            Map<String, Lease<InstanceInfo>> leaseMap = groupEntry.getValue();
>  > > > > > > > > > >            if (leaseMap != null) {
>  > > > > > > > > > >                for (Entry<String, Lease<InstanceInfo>> leaseEntry : leaseMap.entrySet()) {
>  > > > > > > > > > >                    Lease<InstanceInfo> lease = leaseEntry.getValue();
>  > > > > > > > > > >                    if (lease.isExpired(additionalLeaseMs) && lease.getHolder() != null) {
>  > > > > > > > > > >                        expiredLeases.add(lease);
>  > > > > > > > > > >                    }
>  > > > > > > > > > >                }
>  > > > > > > > > > >            }
>  > > > > > > > > > >        }
>  > > > > > > > > > >        // To compensate for GC pauses or drifting local time, we need to use current registry size as a base for
>  > > > > > > > > > >        // triggering self-preservation. Without that we would wipe out full registry.
>  > > > > > > > > > >        int registrySize = (int) getLocalRegistrySize();
>  > > > > > > > > > >        int registrySizeThreshold = (int) (registrySize * serverConfig.getRenewalPercentThreshold());
>  > > > > > > > > > >        int evictionLimit = registrySize - registrySizeThreshold;
>  > > > > > > > > > > 
>  > > > > > > > > > >        int toEvict = Math.min(expiredLeases.size(), evictionLimit);
>  > > > > > > > > > >        if (toEvict > 0) {
>  > > > > > > > > > >            logger.info("Evicting {} items (expired={}, evictionLimit={})", toEvict, expiredLeases.size(), evictionLimit);
>  > > > > > > > > > > 
>  > > > > > > > > > >            Random random = new Random(System.currentTimeMillis());
>  > > > > > > > > > >            for (int i = 0; i < toEvict; i++) {
>  > > > > > > > > > >                // Pick a random item (Knuth shuffle algorithm)
>  > > > > > > > > > >                int next = i + random.nextInt(expiredLeases.size() - i);
>  > > > > > > > > > >                Collections.swap(expiredLeases, i, next);
>  > > > > > > > > > >                Lease<InstanceInfo> lease = expiredLeases.get(i);
>  > > > > > > > > > > 
>  > > > > > > > > > >                String appName = lease.getHolder().getAppName();
>  > > > > > > > > > >                String id = lease.getHolder().getId();
>  > > > > > > > > > >                EXPIRED.increment();
>  > > > > > > > > > >                logger.warn("DS: Registry: expired lease for {}/{}", appName, id);
>  > > > > > > > > > >                // 服务下线，即服务剔除的本质就是服务下线
>  > > > > > > > > > >                internalCancel(appName, id, false);
>  > > > > > > > > > >            }
>  > > > > > > > > > >        }
>  > > > > > > > > > > }
>  > > > > > > > > > > ```
>  > > > > > > > > > >
>  > > > > > > > > > > > `isLeaseExpirationEnabled()`
>  > > > > > > > > > > >
>  > > > > > > > > > > > > ```java
>  > > > > > > > > > > > > public boolean isLeaseExpirationEnabled() {
>  > > > > > > > > > > > >        // 没有开启自我保护直接返回 true
>  > > > > > > > > > > > >        if (!isSelfPreservationModeEnabled()) {
>  > > > > > > > > > > > >            // The self preservation mode is disabled, hence allowing the instances to expire.
>  > > > > > > > > > > > >            return true;
>  > > > > > > > > > > > >        }
>  > > > > > > > > > > > >        // 开启了自我保护
>  > > > > > > > > > > > >        // 最后一分钟续约的次数>每分钟续订次数的阈值，返回 true，否则返回 false
>  > > > > > > > > > > > >        return numberOfRenewsPerMinThreshold > 0 && getNumOfRenewsInLastMin() > numberOfRenewsPerMinThreshold;
>  > > > > > > > > > > > > }
>  > > > > > > > > > > > > ```
>  > > > > > > > > > > >
>  > > > > > > > > > > > `internalCancel(appName, id, false);`
>  > > > > > > > > > > >
>  > > > > > > > > > > > > ```java
>  > > > > > > > > > > > > protected boolean internalCancel(String appName, String id, boolean isReplication) {
>  > > > > > > > > > > > >        try {
>  > > > > > > > > > > > >            read.lock();
>  > > > > > > > > > > > >            CANCEL.increment(isReplication);
>  > > > > > > > > > > > >            // 从 registry 缓存中拿到该实例
>  > > > > > > > > > > > >            Map<String, Lease<InstanceInfo>> gMap = registry.get(appName);
>  > > > > > > > > > > > >            Lease<InstanceInfo> leaseToCancel = null;
>  > > > > > > > > > > > >            if (gMap != null) {
>  > > > > > > > > > > > >                // 从缓存中移除该实例，并用 leaseToCancel 引用它
>  > > > > > > > > > > > >                leaseToCancel = gMap.remove(id);
>  > > > > > > > > > > > >            }
>  > > > > > > > > > > > >            // 添加到下线队列
>  > > > > > > > > > > > >            recentCanceledQueue.add(new Pair<Long, String>(System.currentTimeMillis(), appName + "(" + id + ")"));
>  > > > > > > > > > > > >            InstanceStatus instanceStatus = overriddenInstanceStatusMap.remove(id);
>  > > > > > > > > > > > >            if (instanceStatus != null) {
>  > > > > > > > > > > > >                logger.debug("Removed instance id {} from the overridden map which has value {}", id, instanceStatus.name());
>  > > > > > > > > > > > >            }
>  > > > > > > > > > > > >            if (leaseToCancel == null) {
>  > > > > > > > > > > > >                CANCEL_NOT_FOUND.increment(isReplication);
>  > > > > > > > > > > > >                logger.warn("DS: Registry: cancel failed because Lease is not registered for: {}/{}", appName, id);
>  > > > > > > > > > > > >                return false;
>  > > > > > > > > > > > >            } else {
>  > > > > > > > > > > > >                // 调用下线方法
>  > > > > > > > > > > > >                leaseToCancel.cancel();
>  > > > > > > > > > > > >                InstanceInfo instanceInfo = leaseToCancel.getHolder();
>  > > > > > > > > > > > >                String vip = null;
>  > > > > > > > > > > > >                String svip = null;
>  > > > > > > > > > > > >                if (instanceInfo != null) {
>  > > > > > > > > > > > >                    instanceInfo.setActionType(ActionType.DELETED);
>  > > > > > > > > > > > >                    recentlyChangedQueue.add(new RecentlyChangedItem(leaseToCancel));
>  > > > > > > > > > > > >                    instanceInfo.setLastUpdatedTimestamp();
>  > > > > > > > > > > > >                    vip = instanceInfo.getVIPAddress();
>  > > > > > > > > > > > >                    svip = instanceInfo.getSecureVipAddress();
>  > > > > > > > > > > > >                }
>  > > > > > > > > > > > >                // 从 readWriteCache 中清除该实例
>  > > > > > > > > > > > >                invalidateCache(appName, vip, svip);
>  > > > > > > > > > > > >                logger.info("Cancelled instance {}/{} (replication={})", appName, id, isReplication);
>  > > > > > > > > > > > >            }
>  > > > > > > > > > > > >        } finally {
>  > > > > > > > > > > > >            read.unlock();
>  > > > > > > > > > > > >        }
>  > > > > > > > > > > > > 
>  > > > > > > > > > > > >        synchronized (lock) {
>  > > > > > > > > > > > >            if (this.expectedNumberOfClientsSendingRenews > 0) {
>  > > > > > > > > > > > >                // Since the client wants to cancel it, reduce the number of clients to send renews.
>  > > > > > > > > > > > >                this.expectedNumberOfClientsSendingRenews = this.expectedNumberOfClientsSendingRenews - 1;
>  > > > > > > > > > > > >                updateRenewsPerMinThreshold();
>  > > > > > > > > > > > >            }
>  > > > > > > > > > > > >        }
>  > > > > > > > > > > > > 
>  > > > > > > > > > > > >        return true;
>  > > > > > > > > > > > > }
>  > > > > > > > > > > > > ```

**配置方式**

```yaml
# 在 eureka server 中配置
eureka:
  server:
    # 剔除服务的检测时间间隔，默认 60s
    eviction-interval-timer-in-ms: 60000
```

**面试题**

1. postInit() 方法中使用 evictionTimer（是个 Timer 类的对象）进行定时任务的调用，阿里巴巴 p3c 插件不推荐使用 Timer 进行定时任务调用，因为 Timer 运行多个 TimerTask 时，只要其中之一没有捕获抛出的异常，其他任务便会自动终止运行；建议使用 ScheduledExecutorService。

   ![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2020/20201215164409.png)

### 自我保护（优化点）

eureka server 会定期对 provider 服务进行心跳统计。如果开启自我保护，当最后一分钟有心跳服务个数/总服务数低于阈值（85%），就会触发自我保护，会将有心跳的服务保护起来，如果之后这些被保护的服务中又有服务故障了，eureka server 不会将这些服务进行剔除，此时客户端就可能会调用到这些故障服务。如果关闭自我保护，eureka-server 就总会将故障服务进行剔除，保证客户端不会调用到故障服务。

当服务数量少的时候，请求到故障服务的概率高，服务大概率是真挂掉了，应该把故障服务尽快剔除，所以应该关闭自我保护。

当服务数量多的时候，请求到故障服务的概率低，可能是由于网络原因出现的抖动，所以应该开启自我保护。

`PeerAwareInstanceRegistryImpl`

> ```java
> public void openForTraffic(ApplicationInfoManager applicationInfoManager, int count) {
>      // 自我保护阈值的设置
>      // Renewals happen every 30 seconds and for a minute it should be a factor of 2.
>      this.expectedNumberOfClientsSendingRenews = count;
>      updateRenewsPerMinThreshold();
>      logger.info("Got {} instances from neighboring DS node", count);
>      logger.info("Renew threshold is: {}", numberOfRenewsPerMinThreshold);
>      this.startupTime = System.currentTimeMillis();
>      if (count > 0) {
>            this.peerInstancesTransferEmptyOnStartup = false;
>      }
>      DataCenterInfo.Name selfName = applicationInfoManager.getInfo().getDataCenterInfo().getName();
>      boolean isAws = Name.Amazon == selfName;
>      if (isAws && serverConfig.shouldPrimeAwsReplicaConnections()) {
>            logger.info("Priming AWS connections for all replicas..");
>            primeAwsReplicas(applicationInfoManager);
>      }
>      logger.info("Changing status to UP");
>      applicationInfoManager.setInstanceStatus(InstanceStatus.UP);
>      super.postInit();
> }
> ```
>
> > `updateRenewsPerMinThreshold();`
> >
> > > ```java
> > > protected void updateRenewsPerMinThreshold() {
> > >        this.numberOfRenewsPerMinThreshold = (int) (this.expectedNumberOfClientsSendingRenews
> > >                                                 * (60.0 / serverConfig.getExpectedClientRenewalIntervalSeconds())
> > >                                                 // 对应配置中的 renewal-percent-threshold，设置触发自我保护的阈值
> > >                                                 * serverConfig.getRenewalPercentThreshold());
> > > }
> > > ```

**配置方式**

```yaml
# 在 eureka server 中配置
eureka:
  server:
    # 是否开启自我保护机制，默认是 true
    enable-self-preservation: false
    # 触发自我保护的阈值（有心跳服务/总服务），默认 0.85
    renewal-percent-threshold: 0.85
```

### 三级缓存（优化点）

eureka 使用了三级缓存：registry、readWriteCache、readOnlyCache，因此其没有保证 CAP 中的 C（一致性）。

服务注册/取消注册等写操作，会直接写到 registry 中，并将该服务从 readWriteCache 中移除；当获取该服务时，会将 registry 中的服务与 readWriteCache 进行同步，因此 registry 和 readWriteCache 中同一服务是实时同步的。

获取服务等读操作，先从 readOnlyCache 中读，如果读不到再从 readWriteCache 读，还读不到就从 registry 中读取

#### 写操作（[服务注册](#服务注册)）

#### 读操作（[服务拉取](#服务拉取)）

关闭 ReadOnlyCache 可以减少一次查询，从而提升访问速度，**配置方式**如下

```yaml
# 在 eureka server 中配置
eureka:
  server:
    # 关闭从 readOnlyCache 读注册表，默认 true
    use-read-only-response-cache: false
```

#### readWriteCache 向 readOnlyCache 的同步

`ResponseCacheImpl`

> ```java
> ResponseCacheImpl(EurekaServerConfig serverConfig, ServerCodecs serverCodecs, AbstractInstanceRegistry registry) {
>        // ...
>        // 如果开启 readOnlyCache，会定时将 readWriteCache 向 readOnlyCache 进行同步
>        if (shouldUseReadOnlyResponseCache) {
>            timer.schedule(getCacheUpdateTask(),
>                           new Date(((System.currentTimeMillis() / responseCacheUpdateIntervalMs) * responseCacheUpdateIntervalMs)
>                                 + responseCacheUpdateIntervalMs),
>                        // 通过该属性进行修改同步的时间间隔
>                        responseCacheUpdateIntervalMs);
>     }
>     // ...
> }
> ```

如果开启了 ReadOnlyCache，可以通过如下配置调整同步的时间间隔

```yaml
# 在 eureka server 中配置
eureka:
  server:
    # readWriteCache 向 readOnlyCache 同步注册表的时间间隔，默认 30s
    response-cache-update-interval-ms: 1000
```

### 服务注册

此处启动两个 eureka server 搭建集群，分别标记为 7900 和 7901，然后发送请求让 eureka client 向 7900 进行注册。

**服务注册请求**：

```xml
POST http://localhost:7900/eureka/apps/my-service
Accept: application/json
Content-Type: application/xml

<instance>
    <instanceId>my-instance-id</instanceId>
    <hostName>localhost</hostName>
    <app>my-service</app>
    <ipAddr>127.0.0.1</ipAddr>
    <status>UP</status>
    <overridenstatus>UNKNOWN</overridenstatus>
    <port enabled="true">1900</port>
    <securePort enabled="false">443</securePort>
    <countryId>1</countryId>
    <dataCenterInfo class="com.netflix.appinfo.InstanceInfo$DefaultDataCenterInfo">
        <name>MyOwn</name>
    </dataCenterInfo>
</instance>
```

**debug 源码**：

**先执行 1️⃣，1️⃣执行结束后回过头从 addInstance()方法开始执行 2️⃣**

```java
ApplicationResource.addInstance(InstanceInfo info,
                                @HeaderParam(PeerEurekaNode.HEADER_REPLICATION) String isReplication){
    /*
     * 服务注册分为两种情况
     * 1️⃣. eureka client（包括 provider 和 consumer）向 eureka server 发起的服务注册，此时 isReplication 为 false
     * 2️⃣. eureka server 向 eureka server 的 peer 发起的服务注册请求，是将当前刚注册在 eureka server 上的该 eureka client 复制到 eureka server 的 peer 上，此时 isReplication 为 true
     */
    // 1️⃣eureka client 向 7900 发起服务注册请求，此时 isReplication 为 false，当前服务为 7900
    // 2️⃣7900 向 7901 发起服务注册请求，把刚注册在 7900 上的 eureka client 复制到 7901 上，此时 isReplication 为 true，当前服务已经变为 7901
    registry.register(info, "true".equals(isReplication));
}
```
> ```java
> // PeerAwareInstanceRegistryImpl.java
> public void register(final InstanceInfo info, final boolean isReplication) {
>  int leaseDuration = Lease.DEFAULT_DURATION_IN_SECS;
>  if (info.getLeaseInfo() != null && info.getLeaseInfo().getDurationInSecs() > 0) {
>      leaseDuration = info.getLeaseInfo().getDurationInSecs();
>  }
>  // 1️⃣2️⃣注册到当前 eureka server
>  super.register(info, leaseDuration, isReplication);
>  // 1️⃣向 7900 注册完成后，会将该服务同步注册到 peer(7901)上
>  // 2️⃣7900 向 7901 发起注册请求时，isReplication 为 true
>  replicateToPeers(Action.Register, info.getAppName(), info.getId(), info, null, isReplication);
> }
> ```
> > `super.register(info, leaseDuration, isReplication);`
> >
> > > ```java
> > > AbstractInstanceRegistry.register(InstanceInfo registrant, int leaseDuration, boolean isReplication) {
> > >   try {
> > >         read.lock();
> > >         // ConcurrentHashMap<String, Map<String, Lease<InstanceInfo>>> registry
> > >         // 				 Map<AppName,Map<id, 服务具体信息>>>        
> > >         Map<String, Lease<InstanceInfo>> gMap = registry.get(registrant.getAppName());
> > >         REGISTER.increment(isReplication);
> > >         // 1️⃣2️⃣如果 registry 中不包含该实例，就把它注册进去
> > >         if (gMap == null) {
> > >             final ConcurrentHashMap<String, Lease<InstanceInfo>> gNewMap = new ConcurrentHashMap<String, Lease<InstanceInfo>>();
> > >             // 1️⃣2️⃣向 registry 中添加一个空的 Map，在后面会对其进行填充
> > >             gMap = registry.putIfAbsent(registrant.getAppName(), gNewMap);
> > >             if (gMap == null) {
> > >                 gMap = gNewMap;
> > >             }
> > >         }
> > >         Lease<InstanceInfo> existingLease = gMap.get(registrant.getId());
> > >         // Retain the last dirty timestamp without overwriting it, if there is already a lease
> > >         if (existingLease != null && (existingLease.getHolder() != null)) {
> > >             Long existingLastDirtyTimestamp = existingLease.getHolder().getLastDirtyTimestamp();
> > >             Long registrationLastDirtyTimestamp = registrant.getLastDirtyTimestamp();
> > >             logger.debug("Existing lease found (existing={}, provided={}", existingLastDirtyTimestamp, registrationLastDirtyTimestamp);
> > > 
> > >             // this is a > instead of a >= because if the timestamps are equal, we still take the remote transmitted
> > >             // InstanceInfo instead of the server local copy.
> > >             if (existingLastDirtyTimestamp > registrationLastDirtyTimestamp) {
> > >                 logger.warn("There is an existing lease and the existing lease's dirty timestamp {} is greater" +
> > >                             " than the one that is being registered {}", existingLastDirtyTimestamp, registrationLastDirtyTimestamp);
> > >                 logger.warn("Using the existing instanceInfo instead of the new instanceInfo as the registrant");
> > >                 registrant = existingLease.getHolder();
> > >             }
> > >         } else {
> > >             // The lease does not exist and hence it is a new registration
> > >             synchronized (lock) {
> > >                 if (this.expectedNumberOfClientsSendingRenews > 0) {
> > >                     // Since the client wants to register it, increase the number of clients sending renews
> > >                     this.expectedNumberOfClientsSendingRenews = this.expectedNumberOfClientsSendingRenews + 1;
> > >                     updateRenewsPerMinThreshold();
> > >                 }
> > >             }
> > >             logger.debug("No previous lease information found; it is new registration");
> > >         }
> > >         // 1️⃣2️⃣存放 registrant 信息
> > >         Lease<InstanceInfo> lease = new Lease<InstanceInfo>(registrant, leaseDuration);
> > >         if (existingLease != null) {
> > >             lease.setServiceUpTimestamp(existingLease.getServiceUpTimestamp());
> > >         }
> > >         // 1️⃣2️⃣把 registrant 的信息填充到 gMap 中
> > >         gMap.put(registrant.getId(), lease);
> > >         recentRegisteredQueue.add(new Pair<Long, String>(
> > >             System.currentTimeMillis(),
> > >             registrant.getAppName() + "(" + registrant.getId() + ")"));
> > >         // This is where the initial state transfer of overridden status happens
> > >         if (!InstanceStatus.UNKNOWN.equals(registrant.getOverriddenStatus())) {
> > >             logger.debug("Found overridden status {} for instance {}. Checking to see if needs to be add to the "
> > >                          + "overrides", registrant.getOverriddenStatus(), registrant.getId());
> > >             if (!overriddenInstanceStatusMap.containsKey(registrant.getId())) {
> > >                 logger.info("Not found overridden id {} and hence adding it", registrant.getId());
> > >                 overriddenInstanceStatusMap.put(registrant.getId(), registrant.getOverriddenStatus());
> > >             }
> > >         }
> > >         InstanceStatus overriddenStatusFromMap = overriddenInstanceStatusMap.get(registrant.getId());
> > >         if (overriddenStatusFromMap != null) {
> > >             logger.info("Storing overridden status {} from map", overriddenStatusFromMap);
> > >             registrant.setOverriddenStatus(overriddenStatusFromMap);
> > >         }
> > > 
> > >         // Set the status based on the overridden status rules
> > >         InstanceStatus overriddenInstanceStatus = getOverriddenInstanceStatus(registrant, existingLease, isReplication);
> > >         registrant.setStatusWithoutDirty(overriddenInstanceStatus);
> > > 
> > >         // If the lease is registered with UP status, set lease service up timestamp
> > >         if (InstanceStatus.UP.equals(registrant.getStatus())) {
> > >             lease.serviceUp();
> > >         }
> > >         registrant.setActionType(ActionType.ADDED);
> > >         // 1️⃣2️⃣把新注册的 eureka client 添加到最近改变队列，可用来减少拉取注册表时的数据量
> > >         recentlyChangedQueue.add(new RecentlyChangedItem(lease));
> > >         registrant.setLastUpdatedTimestamp();
> > >         // 1️⃣2️⃣让 readWriteCache 中该 registrant 的注册信息失效
> > >         invalidateCache(registrant.getAppName(), registrant.getVIPAddress(), registrant.getSecureVipAddress());
> > >         logger.info("Registered instance {}/{} with status {} (replication={})",
> > >                     registrant.getAppName(), registrant.getId(), registrant.getStatus(), isReplication);
> > >     } finally {
> > >         read.unlock();
> > >     }
> > > }
> > > ```
> > >
> > > > `invalidateCache(registrant.getAppName(), registrant.getVIPAddress(), registrant.getSecureVipAddress())`
> > > >
> > > > > ```java
> > > > > public void invalidate(Key... keys) {
> > > > >      for (Key key : keys) {
> > > > >            logger.debug("Invalidating the response cache key : {} {} {} {}, {}",
> > > > >                         key.getEntityType(), key.getName(), key.getVersion(), key.getType(), key.getEurekaAccept());
> > > > >           // 1️⃣2️⃣从 readWriteCacheMap 中把该服务删除
> > > > >            readWriteCacheMap.invalidate(key);
> > > > >            Collection<Key> keysWithRegions = regionSpecificKeys.get(key);
> > > > >            if (null != keysWithRegions && !keysWithRegions.isEmpty()) {
> > > > >                for (Key keysWithRegion : keysWithRegions) {
> > > > >                    logger.debug("Invalidating the response cache key : {} {} {} {} {}",
> > > > >                                 key.getEntityType(), key.getName(), key.getVersion(), key.getType(), key.getEurekaAccept());
> > > > >                    readWriteCacheMap.invalidate(keysWithRegion);
> > > > >                }
> > > > >            }
> > > > >      }
> > > > > }
> > > > > ```
> >
> > `replicateToPeers(Action.Register, info.getAppName(), info.getId(), info, null, isReplication);`
> >
> > > ```java
> > > // 1️⃣向 7900 注册完成后，会将该服务复制到 peer(7901)上，注意，此时 isReplication 为 false
> > > // 2️⃣7900 向 7901 发起服务注册请求时, isReplication 为 true
> > > private void replicateToPeers(Action action, String appName, String id,
> > >                               InstanceInfo info /* optional */,
> > >                               InstanceStatus newStatus /* optional */, boolean isReplication) {
> > >     Stopwatch tracer = action.getTimer().start();
> > >     try {
> > >         if (isReplication) {
> > >             numberOfReplicationsLastMin.increment();
> > >         }
> > >         /*
> > >          * 如果 peerEurekaNodes 为 Empty，说明当前是单节点 eureka server，所以不需要进行同步注册，直接 return
> > >          * 如果 isReplicaiton 为 true，说明当前注册请求是 peer 发过来的，不需要再向当前 eureka server 的 peer 进行注册，直接 return.
> > >          * 如果 isReplication 为 false，说明当前请求是 eureka client 发出的服务注册请求，需要将当前服务同步到当前 eureka server 的 peer，所以执行下方服务同步代码。
> > >          */
> > >         // 1️⃣eureke client 向 7900 注册时，isReplicaiton=false，所以执行下方同步代码
> > >         // 2️⃣7900 向 7901 发起服务注册请求时，isReplication=true，不会再向 7901 的 peer 进行同步了，执行结束
> > >         // If it is a replication already, do not replicate again as this will create a poison replication
> > >         if (peerEurekaNodes == Collections.EMPTY_LIST || isReplication) {
> > >             return;
> > >         }
> > >         // 1️⃣eureka server 集群间服务复制代码
> > >         for (final PeerEurekaNode node : peerEurekaNodes.getPeerEurekaNodes()) {
> > >             // If the url represents this host, do not replicate to yourself.
> > >             if (peerEurekaNodes.isThisMyUrl(node.getServiceUrl())) {
> > >                 continue;
> > >             }
> > >             // 1️⃣将当前服务注册到 peer 节点
> > >             replicateInstanceActionsToPeers(action, appName, id, info, newStatus, node);
> > >         }
> > >     } finally {
> > >         tracer.stop();
> > >     }
> > > }
> > > ```
> > >
> > > > `replicateInstanceActionsToPeers(action, appName, id, info, newStatus, node);`
> > > >
> > > > > ```java
> > > > > private void replicateInstanceActionsToPeers(Action action, String appName,
> > > > >                                              String id, InstanceInfo info, InstanceStatus newStatus,
> > > > >                                              PeerEurekaNode node) {
> > > > >     // ...
> > > > >     switch (action) {
> > > > >        	// ...
> > > > >         // 1️⃣eureka client 服务注册走该分支
> > > > >         case Register:
> > > > >             node.register(info);
> > > > >             break;
> > > > > 		// ...
> > > > >     }
> > > > >     // ...
> > > > > }
> > > > > ```
> > > > >
> > > > > > `node.register(info);`
> > > > > >
> > > > > > > ```java
> > > > > > > // 1️⃣此时的服务注册是将已经注册在 7900 上的该服务注册到 peer（7901）上
> > > > > > > public void register(final InstanceInfo info) throws Exception {
> > > > > > >     long expiryTime = System.currentTimeMillis() + getLeaseRenewalOf(info);
> > > > > > >     batchingDispatcher.process(
> > > > > > >         taskId("register", info),
> > > > > > >         // 1️⃣此处 isReplication 写死为 true，标识当前注册请求是复制请求
> > > > > > >         new InstanceReplicationTask(targetHost, Action.Register, info, null, true) {
> > > > > > >             public EurekaHttpResponse<Void> execute() {
> > > > > > >                 // 1️⃣给 peer 发送服务注册请求，此时 isReplicaiton=false，告诉 peer 该注册请求是复制请求，不需要再次向 peer 的 peer 进行注册
> > > > > > >                 return replicationClient.register(info);
> > > > > > >             }
> > > > > > >         },
> > > > > > >         expiryTime
> > > > > > >     );
> > > > > > > }
> > > > > > > ```
> > > > > > >
> > > > > > > > `replicationClient.register(info);`
> > > > > > > >
> > > > > > > > > ```java
> > > > > > > > > public EurekaHttpResponse<Void> register(InstanceInfo info) {
> > > > > > > > >     String urlPath = "apps/" + info.getAppName();
> > > > > > > > >     ClientResponse response = null;
> > > > > > > > >     try {
> > > > > > > > >         Builder resourceBuilder = jerseyClient.resource(serviceUrl).path(urlPath).getRequestBuilder();
> > > > > > > > >         addExtraHeaders(resourceBuilder);
> > > > > > > > >         response = resourceBuilder
> > > > > > > > >             .header("Accept-Encoding", "gzip")
> > > > > > > > >             .type(MediaType.APPLICATION_JSON_TYPE)
> > > > > > > > >             .accept(MediaType.APPLICATION_JSON)
> > > > > > > > >             .post(ClientResponse.class, info);
> > > > > > > > >         // 1️⃣向 peer（7901）发送服务注册请求，此时会调用 7901 服务的 addInstance 方法（从头走 2️⃣）
> > > > > > > > >         return anEurekaHttpResponse(response.getStatus()).headers(headersOf(response)).build();
> > > > > > > > >     } finally {
> > > > > > > > >         if (logger.isDebugEnabled()) {
> > > > > > > > >             logger.debug("Jersey HTTP POST {}/{} with instance {}; statusCode={}", serviceUrl, urlPath, info.getId(),
> > > > > > > > >                          response == null ? "N/A" : response.getStatus());
> > > > > > > > >         }
> > > > > > > > >         if (response != null) {
> > > > > > > > >             response.close();
> > > > > > > > >         }
> > > > > > > > >     }
> > > > > > > > > }
> > > > > > > > > ```

### 服务续约/心跳

**续约请求**：

```xml
PUT http://localhost:7900/eureka/apps/my-service/my-instance-id
Accept: application/json
Content-Type: application/xml

<instance>
	<instanceId>my-instance-id</instanceId>
    <hostName>localhost</hostName>
    <app>my-service</app>
    <ipAddr>127.0.0.1</ipAddr>
    <status>UP</status>
    <overridenstatus>UNKNOWN</overridenstatus>
    <port enabled="true">1900</port>
    <securePort enabled="false">443</securePort>
    <countryId>1</countryId>
    <dataCenterInfo class="com.netflix.appinfo.InstanceInfo$DefaultDataCenterInfo">
    	<name>MyOwn</name>
    </dataCenterInfo>
</instance>
```

**debug 源码**：

```java
// InstanceResource.java
@PUT
public Response renewLease(
    @HeaderParam(PeerEurekaNode.HEADER_REPLICATION) String isReplication,
    @QueryParam("overriddenstatus") String overriddenStatus,
    @QueryParam("status") String status,
    @QueryParam("lastDirtyTimestamp") String lastDirtyTimestamp) {
    // 续约时，isReplication=false，所以也需要向 peer 节点进行复制
    boolean isFromReplicaNode = "true".equals(isReplication);
    // 进行续约
    boolean isSuccess = registry.renew(app.getName(), id, isFromReplicaNode);

    // Not found in the registry, immediately ask for a register
    if (!isSuccess) {
        logger.warn("Not Found (Renew): {} - {}", app.getName(), id);
        return Response.status(Status.NOT_FOUND).build();
    }
    // Check if we need to sync based on dirty time stamp, the client
    // instance might have changed some value
    Response response;
    if (lastDirtyTimestamp != null && serverConfig.shouldSyncWhenTimestampDiffers()) {
        response = this.validateDirtyTimestamp(Long.valueOf(lastDirtyTimestamp), isFromReplicaNode);
        // Store the overridden status since the validation found out the node that replicates wins
        if (response.getStatus() == Response.Status.NOT_FOUND.getStatusCode()
            && (overriddenStatus != null)
            && !(InstanceStatus.UNKNOWN.name().equals(overriddenStatus))
            && isFromReplicaNode) {
            registry.storeOverriddenStatusIfRequired(app.getAppName(), id, InstanceStatus.valueOf(overriddenStatus));
        }
    } else {
        response = Response.ok().build();
    }
    logger.debug("Found (Renew): {} - {}; reply status={}", app.getName(), id, response.getStatus());
    return response;
}
```

> `boolean isSuccess = registry.renew(app.getName(), id, isFromReplicaNode);`
>
> > `super.renew(appName, serverId, isReplication)`
> >
> > > `if(super.renew(appName, id, isReplication))`
> > >
> > > > ```java
> > > > public boolean renew(String appName, String id, boolean isReplication) {
> > > >     RENEW.increment(isReplication);
> > > >     Map<String, Lease<InstanceInfo>> gMap = registry.get(appName);
> > > >     Lease<InstanceInfo> leaseToRenew = null;
> > > >     if (gMap != null) {
> > > >         leaseToRenew = gMap.get(id);
> > > >     }
> > > >     if (leaseToRenew == null) {
> > > >         RENEW_NOT_FOUND.increment(isReplication);
> > > >         logger.warn("DS: Registry: lease doesn't exist, registering resource: {} - {}", appName, id);
> > > >         return false;
> > > >     } else {
> > > >         InstanceInfo instanceInfo = leaseToRenew.getHolder();
> > > >         if (instanceInfo != null) {
> > > >             // touchASGCache(instanceInfo.getASGName());
> > > >             InstanceStatus overriddenInstanceStatus = this.getOverriddenInstanceStatus(
> > > >                 instanceInfo, leaseToRenew, isReplication);
> > > >             if (overriddenInstanceStatus == InstanceStatus.UNKNOWN) {
> > > >                 logger.info("Instance status UNKNOWN possibly due to deleted override for instance {}"
> > > >                             + "; re-register required", instanceInfo.getId());
> > > >                 RENEW_NOT_FOUND.increment(isReplication);
> > > >                 return false;
> > > >             }
> > > >             if (!instanceInfo.getStatus().equals(overriddenInstanceStatus)) {
> > > >                 logger.info(
> > > >                     "The instance status {} is different from overridden instance status {} for instance {}. "
> > > >                     + "Hence setting the status to overridden status", instanceInfo.getStatus().name(),
> > > >                     instanceInfo.getOverriddenStatus().name(),
> > > >                     instanceInfo.getId());
> > > >                 instanceInfo.setStatusWithoutDirty(overriddenInstanceStatus);
> > > > 
> > > >             }
> > > >         }
> > > >         renewsLastMin.increment();
> > > >         // 续约
> > > >         leaseToRenew.renew();
> > > >         return true;
> > > >     }
> > > > }
> > > > ```
> > > >
> > > > > `leaseToRenew.renew();`
> > > > >
> > > > > > ```java
> > > > > > public void renew() {
> > > > > >        // 续约就是只更新 lastUpdateTimestamp 的时间
> > > > > >        lastUpdateTimestamp = System.currentTimeMillis() + duration;
> > > > > > }
> > > > > > ```
> > > >
> > > > `replicateToPeers(Action.Heartbeat, appName, id, null, null, isReplication);`
> > > >
> > > > > ```java
> > > > > // 服务续约/心跳后也需要将其更新后的信息复制到 peer 节点
> > > > > private void replicateToPeers(Action action, String appName, String id,
> > > > >                               InstanceInfo info /* optional */,
> > > > >                               InstanceStatus newStatus /* optional */, boolean isReplication) {
> > > > >     Stopwatch tracer = action.getTimer().start();
> > > > >     try {
> > > > >         if (isReplication) {
> > > > >             numberOfReplicationsLastMin.increment();
> > > > >         }
> > > > >         // 服务续约时，isReplicaiton 为 false
> > > > >         // If it is a replication already, do not replicate again as this will create a poison replication
> > > > >         if (peerEurekaNodes == Collections.EMPTY_LIST || isReplication) {
> > > > >             return;
> > > > >         }
> > > > > 
> > > > >         for (final PeerEurekaNode node : peerEurekaNodes.getPeerEurekaNodes()) {
> > > > >             // If the url represents this host, do not replicate to yourself.
> > > > >             if (peerEurekaNodes.isThisMyUrl(node.getServiceUrl())) {
> > > > >                 continue;
> > > > >             }
> > > > >             // 进行复制
> > > > >             replicateInstanceActionsToPeers(action, appName, id, info, newStatus, node);
> > > > >         }
> > > > >     } finally {
> > > > >         tracer.stop();
> > > > >     }
> > > > > }
> > > > > ```
> > > > >
> > > > > > `replicateInstanceActionsToPeers(action, appName, id, info, newStatus, node);`
> > > > > >
> > > > > > > ```java
> > > > > > > private void replicateInstanceActionsToPeers(Action action, String appName,
> > > > > > >                                                 String id, InstanceInfo info, InstanceStatus newStatus,
> > > > > > >                                                 PeerEurekaNode node) {
> > > > > > >        // ...
> > > > > > >        switch (action) {
> > > > > > >            // ...
> > > > > > >            // 服务续约/心跳走该分支
> > > > > > >            case Heartbeat:
> > > > > > >                InstanceStatus overriddenStatus = overriddenInstanceStatusMap.get(id);
> > > > > > >                infoFromRegistry = getInstanceByAppAndId(appName, id, false);
> > > > > > >                node.heartbeat(appName, id, infoFromRegistry, overriddenStatus, false);
> > > > > > >                break;
> > > > > > >            // ...
> > > > > > >        }
> > > > > > >        // ...
> > > > > > >    }
> > > > > > >    ```
> > > > > > >
> > > > > > >    > `node.heartbeat(appName, id, infoFromRegistry, overriddenStatus, false);`
> > > > > > >    >
> > > > > > >    > > ```java
> > > > > > >    > > public void heartbeat(final String appName, final String id,
> > > > > > >    > >                       final InstanceInfo info, final InstanceStatus overriddenStatus,
> > > > > > >    > >                       boolean primeConnection) throws Throwable {
> > > > > > >    > >     if (primeConnection) {
> > > > > > >    > >         // We do not care about the result for priming request.
> > > > > > >    > >         replicationClient.sendHeartBeat(appName, id, info, overriddenStatus);
> > > > > > >    > >         return;
> > > > > > >    > >     }
> > > > > > >    > >     // 此处指定 isReplication=false，所以会把该续约后的服务复制到所有可达的 peer 上
> > > > > > >    > >     // 此处与服务注册时有明显不同，服务注册时只会复制到相邻的 peer，此处会把该服务复制到所有可达的 peer 上
> > > > > > >    > >     ReplicationTask replicationTask = new InstanceReplicationTask(targetHost, Action.Heartbeat, info, overriddenStatus, false) {
> > > > > > >    > >         @Override
> > > > > > > > >         public EurekaHttpResponse<InstanceInfo> execute() throws Throwable {
> > > > > > > > > 
> > > > > > >> >             return replicationClient.sendHeartBeat(appName, id, info, overriddenStatus);
> > > > > > > > >         }
> > > > > > > > > 
> > > > > > > > >         @Override
> > > > > > > > >         public void handleFailure(int statusCode, Object responseEntity) throws Throwable {
> > > > > > > > >             super.handleFailure(statusCode, responseEntity);
> > > > > > > > >             if (statusCode == 404) {
> > > > > > > > >                 logger.warn("{}: missing entry.", getTaskName());
> > > > > > > > >                 if (info != null) {
> > > > > > > > >                     logger.warn("{}: cannot find instance id {} and hence replicating the instance with status {}",
> > > > > > > > >                                 getTaskName(), info.getId(), info.getStatus());
> > > > > > > > >                     register(info);
> > > > > > > > >                 }
> > > > > > > > >             } else if (config.shouldSyncWhenTimestampDiffers()) {
> > > > > > > > >                 InstanceInfo peerInstanceInfo = (InstanceInfo) responseEntity;
> > > > > > > > >                 if (peerInstanceInfo != null) {
> > > > > > > > >                     syncInstancesIfTimestampDiffers(appName, id, info, peerInstanceInfo);
> > > > > > > > >                 }
> > > > > > > > >             }
> > > > > > > > >         }
> > > > > > > > >     };
> > > > > > > > >     long expiryTime = System.currentTimeMillis() + getLeaseRenewalOf(info);
> > > > > > > > >     batchingDispatcher.process(taskId("heartbeat", info), replicationTask, expiryTime);
> > > > > > > > > }
> > > > > > > > > ```

**配置方式**

```yaml
# 在 provider 服务中配置
eureka:
  instance:
  	# 服务续约时间间隔，默认 30s
    lease-renewal-interval-in-seconds: 30
```

### 服务下线

**下线请求**：

```xml
DELETE http://localhost:7900/eureka/apps/my-service/my-instance-id
        Accept: application/json
        Content-Type: application/xml

<instance>
   <instanceId>my-instance-id</instanceId>
   <hostName>localhost</hostName>
   <app>my-service</app>
   <ipAddr>127.0.0.1</ipAddr>
   <status>UP</status>
   <overridenstatus>UNKNOWN</overridenstatus>
   <port enabled="true">1900</port>
   <securePort enabled="false">443</securePort>
   <countryId>1</countryId>
   <dataCenterInfo class="com.netflix.appinfo.InstanceInfo$DefaultDataCenterInfo">
      <name>MyOwn</name>
   </dataCenterInfo>
</instance>
```

**debug 源码**：

```java
// InstanceResource.java
@DELETE
public Response cancelLease(
    @HeaderParam(PeerEurekaNode.HEADER_REPLICATION) String isReplication) {
    try {
        // 服务下线时, isReplication=false
        boolean isSuccess = registry.cancel(app.getName(), id,
                                            "true".equals(isReplication));

        if (isSuccess) {
            logger.debug("Found (Cancel): {} - {}", app.getName(), id);
            return Response.ok().build();
        } else {
            logger.info("Not Found (Cancel): {} - {}", app.getName(), id);
            return Response.status(Status.NOT_FOUND).build();
        }
    } catch (Throwable e) {
        logger.error("Error (cancel): {} - {}", app.getName(), id, e);
        return Response.serverError().build();
    }

}
```

> `boolean isSuccess = registry.cancel(app.getName(), id, "true".equals(isReplication));`
>
> > `handleCancelation(appName, serverId, isReplication);`
> >
> > > ```java
> > > private void handleCancelation(String appName, String id, boolean isReplication) {
> > >        log("cancel " + appName + ", serverId " + id + ", isReplication "
> > >         + isReplication);
> > >     // 发布下线事件
> > >     publishEvent(new EurekaInstanceCanceledEvent(this, appName, id, isReplication));
> > > }
> > > ```
> >
> > `super.cancel(appName, serverId, isReplication);`
> >
> > > `if (super.cancel(appName, id, isReplication))`
> > >
> > > > `internalCancel(appName, id, isReplication);`
> > > >
> > > > > `super.internalCancel(appName, id, isReplication);`
> > > > >
> > > > > > ```java
> > > > > > protected boolean internalCancel(String appName, String id, boolean isReplication) {
> > > > > >        try {
> > > > > >            read.lock();
> > > > > >            CANCEL.increment(isReplication);
> > > > > >            // 从 registry 缓存中拿到该实例
> > > > > >            Map<String, Lease<InstanceInfo>> gMap = registry.get(appName);
> > > > > >            Lease<InstanceInfo> leaseToCancel = null;
> > > > > >            if (gMap != null) {
> > > > > >                // 从缓存中移除该实例，并用 leaseToCancel 引用它
> > > > > >                leaseToCancel = gMap.remove(id);
> > > > > >            }
> > > > > >            // 添加到下线队列
> > > > > >            recentCanceledQueue.add(new Pair<Long, String>(System.currentTimeMillis(), appName + "(" + id + ")"));
> > > > > >            InstanceStatus instanceStatus = overriddenInstanceStatusMap.remove(id);
> > > > > >            if (instanceStatus != null) {
> > > > > >                logger.debug("Removed instance id {} from the overridden map which has value {}", id, instanceStatus.name());
> > > > > >            }
> > > > > >            if (leaseToCancel == null) {
> > > > > >                CANCEL_NOT_FOUND.increment(isReplication);
> > > > > >                logger.warn("DS: Registry: cancel failed because Lease is not registered for: {}/{}", appName, id);
> > > > > >                return false;
> > > > > >            } else {
> > > > > >                // 调用下线方法
> > > > > >                leaseToCancel.cancel();
> > > > > >                InstanceInfo instanceInfo = leaseToCancel.getHolder();
> > > > > >                String vip = null;
> > > > > >                String svip = null;
> > > > > >                if (instanceInfo != null) {
> > > > > >                    instanceInfo.setActionType(ActionType.DELETED);
> > > > > >                    recentlyChangedQueue.add(new RecentlyChangedItem(leaseToCancel));
> > > > > >                    instanceInfo.setLastUpdatedTimestamp();
> > > > > >                    vip = instanceInfo.getVIPAddress();
> > > > > >                    svip = instanceInfo.getSecureVipAddress();
> > > > > >                }
> > > > > >                // 从 readWriteCache 中清除该实例
> > > > > >                invalidateCache(appName, vip, svip);
> > > > > >                logger.info("Cancelled instance {}/{} (replication={})", appName, id, isReplication);
> > > > > >            }
> > > > > >        } finally {
> > > > > >            read.unlock();
> > > > > >        }
> > > > > > 
> > > > > >        synchronized (lock) {
> > > > > >            if (this.expectedNumberOfClientsSendingRenews > 0) {
> > > > > >                // Since the client wants to cancel it, reduce the number of clients to send renews.
> > > > > >                this.expectedNumberOfClientsSendingRenews = this.expectedNumberOfClientsSendingRenews - 1;
> > > > > >                updateRenewsPerMinThreshold();
> > > > > >            }
> > > > > >        }
> > > > > > 
> > > > > >        return true;
> > > > > > }
> > > > > > ```
> > > > > >
> > > > > > > `leaseToCancel.cancel();`
> > > > > > >
> > > > > > > > ```java
> > > > > > > > public void cancel() {
> > > > > > > >        if (evictionTimestamp <= 0) {
> > > > > > > >            // 将该实例的 evictionTimestamp 时间修改为当前时间
> > > > > > > >            // 服务剔除的本质其实也是服务下线
> > > > > > > >            evictionTimestamp = System.currentTimeMillis();
> > > > > > > >        }
> > > > > > > > }
> > > > > > > > ```
> > >
> > > `replicateToPeers(Action.Cancel, appName, id, null, null, isReplication);`
> > >
> > > > ```java
> > > > // 服务下线后也需要将其复制到 peer 节点
> > > > private void replicateToPeers(Action action, String appName, String id,
> > > >                                  InstanceInfo info /* optional */,
> > > >                                  InstanceStatus newStatus /* optional */, boolean isReplication) {
> > > >        Stopwatch tracer = action.getTimer().start();
> > > >        try {
> > > >            if (isReplication) {
> > > >                numberOfReplicationsLastMin.increment();
> > > >            }
> > > >            // 服务下线时, isReplicaiton 也为 false
> > > >            // If it is a replication already, do not replicate again as this will create a poison replication
> > > >            if (peerEurekaNodes == Collections.EMPTY_LIST || isReplication) {
> > > >                return;
> > > >            }
> > > > 
> > > >            for (final PeerEurekaNode node : peerEurekaNodes.getPeerEurekaNodes()) {
> > > >                // If the url represents this host, do not replicate to yourself.
> > > >                if (peerEurekaNodes.isThisMyUrl(node.getServiceUrl())) {
> > > >                    continue;
> > > >                }
> > > >                // 进行复制
> > > >                replicateInstanceActionsToPeers(action, appName, id, info, newStatus, node);
> > > >            }
> > > >        } finally {
> > > >            tracer.stop();
> > > >        }
> > > > }
> > > > ```
> > > >
> > > > > `replicateInstanceActionsToPeers(action, appName, id, info, newStatus, node);`
> > > > >
> > > > > > ```java
> > > > > > private void replicateInstanceActionsToPeers(Action action, String appName,
> > > > > >                                                 String id, InstanceInfo info, InstanceStatus newStatus,
> > > > > >                                                 PeerEurekaNode node) {
> > > > > >        // ...
> > > > > >        switch (action) {
> > > > > >            // ...
> > > > > >            // 服务下线走该分支
> > > > > >            case Cancel:
> > > > > >                node.cancel(appName, id);
> > > > > >                break;
> > > > > >            // ...
> > > > > >        }
> > > > > >        // ...
> > > > > >    }
> > > > > >    ```
> > > > > >
> > > > > >    > `node.cancel(appName, id);`
> > > > > >    >
> > > > > >    > > ```java
> > > > > >    > > public void cancel(final String appName, final String id) throws Exception {
> > > > > >    > >        long expiryTime = System.currentTimeMillis() + maxProcessingDelayMs;
> > > > > >    > >        batchingDispatcher.process(
> > > > > >    > >            taskId("cancel", appName, id),
> > > > > >    > >            // 服务下线这没有指定 isReplication 的值，默认为 false，所以会将所有可达的 peer 上的该服务全部都下线
> > > > > >    > >            // 此处与服务续约相同，与服务注册不同
> > > > > >    > >            new InstanceReplicationTask(targetHost, Action.Cancel, appName, id) {
> > > > > >    > >                @Override
> > > > > >    > >                public EurekaHttpResponse<Void> execute() {
> > > > > >    > >                    return replicationClient.cancel(appName, id);
> > > > > >    > >                }
> > > > > >    > > 
> > > > > >    > >                @Override
> > > > > >    > >                public void handleFailure(int statusCode, Object responseEntity) throws Throwable {
> > > > > > > >                    super.handleFailure(statusCode, responseEntity);
> > > > > > > >                    if (statusCode == 404) {
> > > > > >> >                        logger.warn("{}: missing entry.", getTaskName());
> > > > > > > >                    }
> > > > > > > >                }
> > > > > > > >            },
> > > > > > > >            expiryTime
> > > > > > > >        );
> > > > > > > > }
> > > > > > > > ```

### 服务拉取

服务拉取分为全量拉取和增量拉取，增量拉取是从

#### 全量拉取

```
GET http://localhost:7900/eureka/apps
```

```java
// ApplicationsResource.java
@GET
public Response getContainers(@PathParam("version") String version,
                              @HeaderParam(HEADER_ACCEPT) String acceptHeader,
                              @HeaderParam(HEADER_ACCEPT_ENCODING) String acceptEncoding,
                              @HeaderParam(EurekaAccept.HTTP_X_EUREKA_ACCEPT) String eurekaAccept,
                              @Context UriInfo uriInfo,
                              @Nullable @QueryParam("regions") String regionsStr) {

    boolean isRemoteRegionRequested = null != regionsStr && !regionsStr.isEmpty();
    String[] regions = null;
    if (!isRemoteRegionRequested) {
        EurekaMonitors.GET_ALL.increment();
    } else {
        regions = regionsStr.toLowerCase().split(",");
        Arrays.sort(regions); // So we don't have different caches for same regions queried in different order.
        EurekaMonitors.GET_ALL_WITH_REMOTE_REGIONS.increment();
    }

    // Check if the server allows the access to the registry. The server can
    // restrict access if it is not
    // ready to serve traffic depending on various reasons.
    if (!registry.shouldAllowAccess(isRemoteRegionRequested)) {
        return Response.status(Status.FORBIDDEN).build();
    }
    CurrentRequestVersion.set(Version.toEnum(version));
    KeyType keyType = Key.KeyType.JSON;
    String returnMediaType = MediaType.APPLICATION_JSON;
    if (acceptHeader == null || !acceptHeader.contains(HEADER_JSON_VALUE)) {
        keyType = Key.KeyType.XML;
        returnMediaType = MediaType.APPLICATION_XML;
    }

    Key cacheKey = new Key(Key.EntityType.Application,
                           ResponseCacheImpl.ALL_APPS,
                           keyType, CurrentRequestVersion.get(), EurekaAccept.fromString(eurekaAccept), regions
                          );

    Response response;
    if (acceptEncoding != null && acceptEncoding.contains(HEADER_GZIP_VALUE)) {
        // 全量拉取的 cacheKey 为 ALL_APPS
        response = Response.ok(responseCache.getGZIP(cacheKey))
            .header(HEADER_CONTENT_ENCODING, HEADER_GZIP_VALUE)
            .header(HEADER_CONTENT_TYPE, returnMediaType)
            .build();
    } else {
        response = Response.ok(responseCache.get(cacheKey))
            .build();
    }
    CurrentRequestVersion.remove();
    return response;
}
```

> `responseCache.getGZIP(cacheKey)`
>
> > ```java
> > public byte[] getGZIP(Key key) {
> >     Value payload = getValue(key, shouldUseReadOnlyResponseCache);
> >     if (payload == null) {
> >         return null;
> >     }
> >     return payload.getGzipped();
> > }
> > ```
> >
> > > `getValue(key, shouldUseReadOnlyResponseCache);`
> > >
> > > > ```java
> > > > Value getValue(final Key key, boolean useReadOnlyCache) {
> > > >     Value payload = null;
> > > >     try {
> > > >         // 判读是否开启了 ReadOnlyCache
> > > >         if (useReadOnlyCache) {
> > > >             // 先从 ReadOnlyCache 中获取
> > > >             final Value currentPayload = readOnlyCacheMap.get(key);
> > > >             if (currentPayload != null) {
> > > >                 payload = currentPayload;
> > > >             } else {
> > > >                 // ReadOnlyCache 中没有就从 ReadWriteCache 中获取
> > > >                 payload = readWriteCacheMap.get(key);
> > > >                 // 并将该值从 ReadWriteCache 中复制到 ReadOnlyCache 中
> > > >                 readOnlyCacheMap.put(key, payload);
> > > >             }
> > > >         } else {
> > > >             // 如果没开启 ReadOnlyCache，直接从 ReadWriteCache 中获取
> > > >             payload = readWriteCacheMap.get(key);
> > > >         }
> > > >     } catch (Throwable t) {
> > > >         logger.error("Cannot get value for key : {}", key, t);
> > > >     }
> > > >     return payload;
> > > > }
> > > > ```
> > > > > `readWriteCacheMap.get(key)`
> > > > > > ```java
> > > > > > // readWriteCacheMap 使用了 LoadingCache，在 ResponseCacheImpl 中对其的 get 进行了设置
> > > > > > ResponseCacheImpl(EurekaServerConfig serverConfig, ServerCodecs serverCodecs, AbstractInstanceRegistry registry) {
> > > > > >     // ...
> > > > > >     this.readWriteCacheMap =
> > > > > >         // 初始化容量，从配置中获取
> > > > > >         CacheBuilder.newBuilder().initialCapacity(serverConfig.getInitialCapacityOfResponseCache())
> > > > > >         // 设置缓存的失效时间，从配置中获取
> > > > > >         .expireAfterWrite(serverConfig.getResponseCacheAutoExpirationInSeconds(), TimeUnit.SECONDS)
> > > > > >         .removalListener(new RemovalListener<Key, Value>() {
> > > > > >             @Override
> > > > > >             public void onRemoval(RemovalNotification<Key, Value> notification) {
> > > > > >                 Key removedKey = notification.getKey();
> > > > > >                 if (removedKey.hasRegions()) {
> > > > > >                     Key cloneWithNoRegions = removedKey.cloneWithoutRegions();
> > > > > >                     regionSpecificKeys.remove(cloneWithNoRegions, removedKey);
> > > > > >                 }
> > > > > >             }
> > > > > >         })
> > > > > >         .build(new CacheLoader<Key, Value>() {
> > > > > >             // 当 readWriteCacheMap 调用 get 方法获取不到值的时候，会调用该方法获取返回值。
> > > > > >             @Override
> > > > > >             public Value load(Key key) throws Exception {
> > > > > >                 if (key.hasRegions()) {
> > > > > >                     Key cloneWithNoRegions = key.cloneWithoutRegions();
> > > > > >                     regionSpecificKeys.put(cloneWithNoRegions, key);
> > > > > >                 }
> > > > > >                 // 该方法是从 registry 中获取值
> > > > > >                 // 所以说 readWriteCache 和 registry 是相同的，因为如果从 readWriteCache 中获取不到值，会直接从 registry 中获取
> > > > > >                 Value value = generatePayload(key);
> > > > > >                 return value;
> > > > > >             }
> > > > > >         });
> > > > > >     // ...
> > > > > > }
> > > > > > ```
> > > > > >
> > > > > > > `Value value = generatePayload(key);`
> > > > > > >
> > > > > > > > ```java
> > > > > > > > private Value generatePayload(Key key) {
> > > > > > > >     Stopwatch tracer = null;
> > > > > > > >     try {
> > > > > > > >         String payload;
> > > > > > > >         switch (key.getEntityType()) {
> > > > > > > >             case Application:
> > > > > > > >                 boolean isRemoteRegionRequested = key.hasRegions();
> > > > > > > > 				// 全量拉取的 key 为 ALL_APPS
> > > > > > > >                 if (ALL_APPS.equals(key.getName())) {
> > > > > > > >                     if (isRemoteRegionRequested) {
> > > > > > > >                         tracer = serializeAllAppsWithRemoteRegionTimer.start();
> > > > > > > >                         payload = getPayLoad(key, registry.getApplicationsFromMultipleRegions(key.getRegions()));
> > > > > > > >                     } else {
> > > > > > > >                         tracer = serializeAllAppsTimer.start();
> > > > > > > >                         // 从 registry 中获取数据并进行包装后返回
> > > > > > > >                         payload = getPayLoad(key, registry.getApplications());
> > > > > > > >                     }
> > > > > > > >                 } else if (ALL_APPS_DELTA.equals(key.getName())) {
> > > > > > > >                     // 增量拉取的 key 为 ALL_APPS_DELTA
> > > > > > > >                     if (isRemoteRegionRequested) {
> > > > > > > >                         tracer = serializeDeltaAppsWithRemoteRegionTimer.start();
> > > > > > > >                         versionDeltaWithRegions.incrementAndGet();
> > > > > > > >                         versionDeltaWithRegionsLegacy.incrementAndGet();
> > > > > > > >                         payload = getPayLoad(key,
> > > > > > > >                                              registry.getApplicationDeltasFromMultipleRegions(key.getRegions()));
> > > > > > > >                     } else {
> > > > > > > >                         tracer = serializeDeltaAppsTimer.start();
> > > > > > > >                         versionDelta.incrementAndGet();
> > > > > > > >                         versionDeltaLegacy.incrementAndGet();
> > > > > > > >                         // 从 registry 的最近更新队列中获取数据并包装后返回
> > > > > > > >                         payload = getPayLoad(key, registry.getApplicationDeltas());
> > > > > > > >                     }
> > > > > > > >                 } else {
> > > > > > > >                     tracer = serializeOneApptimer.start();
> > > > > > > >                     payload = getPayLoad(key, registry.getApplication(key.getName()));
> > > > > > > >                 }
> > > > > > > >                 break;
> > > > > > > >             case VIP:
> > > > > > > >             case SVIP:
> > > > > > > >                 tracer = serializeViptimer.start();
> > > > > > > >                 payload = getPayLoad(key, getApplicationsForVip(key, registry));
> > > > > > > >                 break;
> > > > > > > >             default:
> > > > > > > >                 logger.error("Unidentified entity type: {} found in the cache key.", key.getEntityType());
> > > > > > > >                 payload = "";
> > > > > > > >                 break;
> > > > > > > >         }
> > > > > > > >         return new Value(payload);
> > > > > > > >     } finally {
> > > > > > > >         if (tracer != null) {
> > > > > > > >             tracer.stop();
> > > > > > > >         }
> > > > > > > >     }
> > > > > > > > }
> > > > > > > > ```

#### 增量拉取

增量拉取是从 `recentlyChangedQueue` 中进行拉取，可以减少拉取注册表的数据量

```
GET http://localhost:7900/eureka/apps/delta
```

```java
@Path("delta")
@GET
public Response getContainerDifferential(
    @PathParam("version") String version,
    @HeaderParam(HEADER_ACCEPT) String acceptHeader,
    @HeaderParam(HEADER_ACCEPT_ENCODING) String acceptEncoding,
    @HeaderParam(EurekaAccept.HTTP_X_EUREKA_ACCEPT) String eurekaAccept,
    @Context UriInfo uriInfo, @Nullable @QueryParam("regions") String regionsStr) {

    boolean isRemoteRegionRequested = null != regionsStr && !regionsStr.isEmpty();

    // If the delta flag is disabled in discovery or if the lease expiration
    // has been disabled, redirect clients to get all instances
    if ((serverConfig.shouldDisableDelta()) || (!registry.shouldAllowAccess(isRemoteRegionRequested))) {
        return Response.status(Status.FORBIDDEN).build();
    }

    String[] regions = null;
    if (!isRemoteRegionRequested) {
        EurekaMonitors.GET_ALL_DELTA.increment();
    } else {
        regions = regionsStr.toLowerCase().split(",");
        Arrays.sort(regions); // So we don't have different caches for same regions queried in different order.
        EurekaMonitors.GET_ALL_DELTA_WITH_REMOTE_REGIONS.increment();
    }

    CurrentRequestVersion.set(Version.toEnum(version));
    KeyType keyType = Key.KeyType.JSON;
    String returnMediaType = MediaType.APPLICATION_JSON;
    if (acceptHeader == null || !acceptHeader.contains(HEADER_JSON_VALUE)) {
        keyType = Key.KeyType.XML;
        returnMediaType = MediaType.APPLICATION_XML;
    }

    Key cacheKey = new Key(Key.EntityType.Application,
                           ResponseCacheImpl.ALL_APPS_DELTA,
                           keyType, CurrentRequestVersion.get(), EurekaAccept.fromString(eurekaAccept), regions
                          );

    final Response response;

    if (acceptEncoding != null && acceptEncoding.contains(HEADER_GZIP_VALUE)) {
        // 增量拉取时，cacheKey 为 ALL_APPS_DELTA
        response = Response.ok(responseCache.getGZIP(cacheKey))
            .header(HEADER_CONTENT_ENCODING, HEADER_GZIP_VALUE)
            .header(HEADER_CONTENT_TYPE, returnMediaType)
            .build();
    } else {
        response = Response.ok(responseCache.get(cacheKey)).build();
    }

    CurrentRequestVersion.remove();
    return response;
}
```

> `responseCache.getGZIP(cacheKey)`
>
> > ```java
> > public byte[] getGZIP(Key key) {
> >  Value payload = getValue(key, shouldUseReadOnlyResponseCache);
> >  if (payload == null) {
> >      return null;
> >  }
> >  return payload.getGzipped();
> > }
> > ```
> >
> > > `getValue(key, shouldUseReadOnlyResponseCache);`
> > >
> > > > ```java
> > > > Value getValue(final Key key, boolean useReadOnlyCache) {
> > > >  Value payload = null;
> > > >  try {
> > > >      // 判读是否开启了 ReadOnlyCache
> > > >      if (useReadOnlyCache) {
> > > >          // 先从 ReadOnlyCache 中获取
> > > >          final Value currentPayload = readOnlyCacheMap.get(key);
> > > >          if (currentPayload != null) {
> > > >              payload = currentPayload;
> > > >          } else {
> > > >              // ReadOnlyCache 中没有就从 ReadWriteCache 中获取
> > > >              payload = readWriteCacheMap.get(key);
> > > >              // 并将该值从 ReadWriteCache 中复制到 ReadOnlyCache 中
> > > >              readOnlyCacheMap.put(key, payload);
> > > >          }
> > > >      } else {
> > > >          // 如果没开启 ReadOnlyCache，直接从 ReadWriteCache 中获取
> > > >          // 后续流程可见全量拉取
> > > >          payload = readWriteCacheMap.get(key);
> > > >      }
> > > >  } catch (Throwable t) {
> > > >      logger.error("Cannot get value for key : {}", key, t);
> > > >  }
> > > >  return payload;
> > > > }
> > > > ```

### 集群同步

集群同步的代码主要再 `PeerAwareInstanceRegistryImpl` 类中

1. [eureka server 启动](#eureka server 启动时的集群同步)：如果 registry-sync-retries 大于 0，则会在 eureka server 启动时从 peer 节点拉取注册表信息

2. [服务注册](#服务注册)：eureka client 向某个 eureka server 发起注册，注册成功后，该 eureka server 会将该 eureka client 同步注册到它的相邻 peer 节点

3. [服务续约](#服务续约/心跳)：每个服务续约时都会所有可达的 peer 进行同步

4. [服务下线](#服务下线)：每个服务下线时都会所有可达的 peer 进行同步

5. [服务剔除](#服务剔除（优化点）)：不会同步，因为每个 eureka server 有自己的剔除逻辑

**注意**

服务注册和服务续约/下线在同步时是有区别的，服务注册只会向相邻的 peer 进行复制，服务续约/下线会向所有可达的 peer 都进行复制

#### eureka server 启动时的集群同步

`EurekaServerAutoConfiguration`

> `@Import(EurekaServerInitializerConfiguration.class)`
>
> > `EurekaServerInitializerConfiguration.start()`
> >
> > > `eurekaServerBootstrap.contextInitialized(EurekaServerInitializerConfiguration.this.servletContext);`
> > >
> > > > `initEurekaServerContext();`
> > > >
> > > > > ```java
> > > > > // 在启动的时候从其他 peer 拉取注册表，之后注册到 peer 的服务需要通过后续集群同步服务进行同步，不同 peer 间可能存在不同步的情况，所以此处也没有保证一致性
> > > > > int registryCount = this.registry.syncUp();
> > > > > ```
> > > > >
> > > > > > ```java
> > > > > > public int syncUp() {
> > > > > >     // Copy entire entry from neighboring DS node
> > > > > >     int count = 0;
> > > > > >     // 注册表同步尝试次数，默认值为 0，如果要再 server 启动时就从 peer 进行拉取注册表，需要将其设置为大于 0
> > > > > >     for (int i = 0; ((i < serverConfig.getRegistrySyncRetries()) && (count == 0)); i++) {
> > > > > >         if (i > 0) {
> > > > > >             try {
> > > > > >                 // 拉取注册表服务的等待时间，默认为 0
> > > > > >                 Thread.sleep(serverConfig.getRegistrySyncRetryWaitMs());
> > > > > >             } catch (InterruptedException e) {
> > > > > >                 logger.warn("Interrupted during registry transfer..");
> > > > > >                 break;
> > > > > >             }
> > > > > >         }
> > > > > >         Applications apps = eurekaClient.getApplications();
> > > > > >         for (Application app : apps.getRegisteredApplications()) {
> > > > > >             for (InstanceInfo instance : app.getInstances()) {
> > > > > >                 try {
> > > > > >                     if (isRegisterable(instance)) {
> > > > > >                         // 调用服务注册方法进行注册
> > > > > >                         register(instance, instance.getLeaseInfo().getDurationInSecs(), true);
> > > > > >                         count++;
> > > > > >                     }
> > > > > >                 } catch (Throwable t) {
> > > > > >                     logger.error("During DS init copy", t);
> > > > > >                 }
> > > > > >             }
> > > > > >         }
> > > > > >     }
> > > > > >     return count;
> > > > > > }
> > > > > > ```
> > > > > >
> > > > > > > `register(instance, instance.getLeaseInfo().getDurationInSecs(), true);`
> > > > > > >
> > > > > > > > ```java
> > > > > > > > public void register(InstanceInfo registrant, int leaseDuration, boolean isReplication) {
> > > > > > > >     try {
> > > > > > > >         read.lock();
> > > > > > > >         Map<String, Lease<InstanceInfo>> gMap = registry.get(registrant.getAppName());
> > > > > > > >         REGISTER.increment(isReplication);
> > > > > > > >         if (gMap == null) {
> > > > > > > >             final ConcurrentHashMap<String, Lease<InstanceInfo>> gNewMap = new ConcurrentHashMap<String, Lease<InstanceInfo>>();
> > > > > > > >             gMap = registry.putIfAbsent(registrant.getAppName(), gNewMap);
> > > > > > > >             if (gMap == null) {
> > > > > > > >                 gMap = gNewMap;
> > > > > > > >             }
> > > > > > > >         }
> > > > > > > >         Lease<InstanceInfo> existingLease = gMap.get(registrant.getId());
> > > > > > > >         // Retain the last dirty timestamp without overwriting it, if there is already a lease
> > > > > > > >         if (existingLease != null && (existingLease.getHolder() != null)) {
> > > > > > > >             Long existingLastDirtyTimestamp = existingLease.getHolder().getLastDirtyTimestamp();
> > > > > > > >             Long registrationLastDirtyTimestamp = registrant.getLastDirtyTimestamp();
> > > > > > > >             logger.debug("Existing lease found (existing={}, provided={}", existingLastDirtyTimestamp, registrationLastDirtyTimestamp);
> > > > > > > > 
> > > > > > > >             // this is a > instead of a >= because if the timestamps are equal, we still take the remote transmitted
> > > > > > > >             // InstanceInfo instead of the server local copy.
> > > > > > > >             if (existingLastDirtyTimestamp > registrationLastDirtyTimestamp) {
> > > > > > > >                 logger.warn("There is an existing lease and the existing lease's dirty timestamp {} is greater" +
> > > > > > > >                             " than the one that is being registered {}", existingLastDirtyTimestamp, registrationLastDirtyTimestamp);
> > > > > > > >                 logger.warn("Using the existing instanceInfo instead of the new instanceInfo as the registrant");
> > > > > > > >                 registrant = existingLease.getHolder();
> > > > > > > >             }
> > > > > > > >         } else {
> > > > > > > >             // The lease does not exist and hence it is a new registration
> > > > > > > >             synchronized (lock) {
> > > > > > > >                 if (this.expectedNumberOfClientsSendingRenews > 0) {
> > > > > > > >                     // Since the client wants to register it, increase the number of clients sending renews
> > > > > > > >                     this.expectedNumberOfClientsSendingRenews = this.expectedNumberOfClientsSendingRenews + 1;
> > > > > > > >                     updateRenewsPerMinThreshold();
> > > > > > > >                 }
> > > > > > > >             }
> > > > > > > >             logger.debug("No previous lease information found; it is new registration");
> > > > > > > >         }
> > > > > > > >         Lease<InstanceInfo> lease = new Lease<InstanceInfo>(registrant, leaseDuration);
> > > > > > > >         if (existingLease != null) {
> > > > > > > >             lease.setServiceUpTimestamp(existingLease.getServiceUpTimestamp());
> > > > > > > >         }
> > > > > > > >         gMap.put(registrant.getId(), lease);
> > > > > > > >         recentRegisteredQueue.add(new Pair<Long, String>(
> > > > > > > >             System.currentTimeMillis(),
> > > > > > > >             registrant.getAppName() + "(" + registrant.getId() + ")"));
> > > > > > > >         // This is where the initial state transfer of overridden status happens
> > > > > > > >         if (!InstanceStatus.UNKNOWN.equals(registrant.getOverriddenStatus())) {
> > > > > > > >             logger.debug("Found overridden status {} for instance {}. Checking to see if needs to be add to the "
> > > > > > > >                          + "overrides", registrant.getOverriddenStatus(), registrant.getId());
> > > > > > > >             if (!overriddenInstanceStatusMap.containsKey(registrant.getId())) {
> > > > > > > >                 logger.info("Not found overridden id {} and hence adding it", registrant.getId());
> > > > > > > >                 overriddenInstanceStatusMap.put(registrant.getId(), registrant.getOverriddenStatus());
> > > > > > > >             }
> > > > > > > >         }
> > > > > > > >         InstanceStatus overriddenStatusFromMap = overriddenInstanceStatusMap.get(registrant.getId());
> > > > > > > >         if (overriddenStatusFromMap != null) {
> > > > > > > >             logger.info("Storing overridden status {} from map", overriddenStatusFromMap);
> > > > > > > >             registrant.setOverriddenStatus(overriddenStatusFromMap);
> > > > > > > >         }
> > > > > > > > 
> > > > > > > >         // Set the status based on the overridden status rules
> > > > > > > >         InstanceStatus overriddenInstanceStatus = getOverriddenInstanceStatus(registrant, existingLease, isReplication);
> > > > > > > >         registrant.setStatusWithoutDirty(overriddenInstanceStatus);
> > > > > > > > 
> > > > > > > >         // If the lease is registered with UP status, set lease service up timestamp
> > > > > > > >         if (InstanceStatus.UP.equals(registrant.getStatus())) {
> > > > > > > >             lease.serviceUp();
> > > > > > > >         }
> > > > > > > >         registrant.setActionType(ActionType.ADDED);
> > > > > > > >         recentlyChangedQueue.add(new RecentlyChangedItem(lease));
> > > > > > > >         registrant.setLastUpdatedTimestamp();
> > > > > > > >         invalidateCache(registrant.getAppName(), registrant.getVIPAddress(), registrant.getSecureVipAddress());
> > > > > > > >         logger.info("Registered instance {}/{} with status {} (replication={})",
> > > > > > > >                     registrant.getAppName(), registrant.getId(), registrant.getStatus(), isReplication);
> > > > > > > >     } finally {
> > > > > > > >         read.unlock();
> > > > > > > >     }
> > > > > > > > }
> > > > > > > > ```
> > > > > > > >
> > > > > > > >

```yaml
eureka:
  server:
    # 拉取注册表尝试次数
    registry-sync-retries: 1
    # 拉取注册表的等待时间间隔
    registry-sync-retry-wait-ms: 0
```

### DashBoard

Eureka DashBoard 相关接口都存放再 `EurekaController` 中，就是基于 SpringMVC 的接口。

## eureka server 总结

**eureka server 提供的功能**

1. 接受注册
2. 接受心跳
3. 下线
4. 获取注册列表
5. 集群同步

**优化点**

1. 服务剔除
2. 自我保护
3. 三级缓存

## 其他点

### 服务测算

服务续约的时间间隔默认是 30s，再续约的时候，会向所有 peer 发送服务注册请求。所以单个 eureka server 每 30 秒会接收 2 个请求。

当前工程一共有 18 个服务，假设有 20 个，然后每个服务部署 5 个实例，一共就是 100 个 eureka client;

此时的 eureka server 每 30s 一共会接收 2 * 100=200 个请求，1 分钟就是 400 请求。

模拟服务注册所用时间，大约是每次 100ms，1 分钟单个 eureka server 就可以接收 60 * 1000 / 100 = 600 次请求。

### recentlyChangedQueue

用于保存最近被更改过的注册表信息，可见 [服务注册](#服务注册)，[服务续约/心跳](#服务续约/心跳)，[服务下线](#服务下线)，再进行 [服务拉取](#服务拉取) 时，[增量拉取](#增量拉取) 就是从 recentlyChangedQueue 中进行获取注册表信息，实际使用时，可以选择先进行增量拉取，如果获取不到再进行 [全量拉取](#全量拉取)。

```java
protected AbstractInstanceRegistry(EurekaServerConfig serverConfig, EurekaClientConfig clientConfig, ServerCodecs serverCodecs) {
    // ...
    // 定时触发对 recentlyChangedQueue 中注册信息的失效任务
    this.deltaRetentionTimer.schedule(getDeltaRetentionTask(),
                                      serverConfig.getDeltaRetentionTimerIntervalInMs(),
                                      serverConfig.getDeltaRetentionTimerIntervalInMs());
}
```

> `getDeltaRetentionTask()`
>
> > ```java
> > private TimerTask getDeltaRetentionTask() {
> >     return new TimerTask() {
> >         @Override
> >         public void run() {
> >             Iterator<RecentlyChangedItem> it = recentlyChangedQueue.iterator();
> >             while (it.hasNext()) {
> >                 // 把超过 RetentionTimeInMSInDeltaQueue 时间的注册表失效
> >                 if (it.next().getLastUpdateTime() <
> >                     System.currentTimeMillis() - serverConfig.getRetentionTimeInMSInDeltaQueue()) {
> >                     it.remove();
> >                 } else {
> >                     break;
> >                 }
> >             }
> >         }
> >     };
> > }
> > ```

```yaml
eureka:
  server:
    # recentlyChangedQueue 失效任务的时间间隔，默认 30s
    delta-retention-timer-interval-in-ms: 30000
    # recentlyChangedQueue 中信息的失效时间，默认 3min
    retention-time-in-m-s-in-delta-queue: 180000
```

### unavailable-replicas

在 eureka 的 dashboard 中可能看到 General Info 下 available-replicas 是空的，我们的注册中心地址都在 unavailable-replicas 里，这是不对的，如果是内外网环境，会造成服务调用不通的问题。

`EurekaController`

> ```java
> @RequestMapping(method = RequestMethod.GET)
> public String status(HttpServletRequest request, Map<String, Object> model) {
>     populateBase(request, model);
>     populateApps(model);
>     StatusInfo statusInfo;
>     try {
>         statusInfo = new StatusResource().getStatusInfo();
>     }
>     catch (Exception e) {
>         statusInfo = StatusInfo.Builder.newBuilder().isHealthy(false).build();
>     }
>     model.put("statusInfo", statusInfo);
>     populateInstanceInfo(model, statusInfo);
>     filterReplicas(model, statusInfo);
>     return "eureka/status";
> }
> ```
>
> > `statusInfo = new StatusResource().getStatusInfo();`
> >
> > > `statusUtil.getStatusInfo()`
> > >
> > > > ```java
> > > > public StatusInfo getStatusInfo() {
> > > >     StatusInfo.Builder builder = StatusInfo.Builder.newBuilder();
> > > >     // Add application level status
> > > >     int upReplicasCount = 0;
> > > >     StringBuilder upReplicas = new StringBuilder();
> > > >     StringBuilder downReplicas = new StringBuilder();
> > > > 
> > > >     StringBuilder replicaHostNames = new StringBuilder();
> > > > 	// 获取到当前 EurekaServer 的所有 peer 节点并进行遍历，这里获取到的是配置文件中配置的信息，并且不包含当前服务，要与后续从 registry 中获取到的区分开
> > > >     for (PeerEurekaNode node : peerEurekaNodes.getPeerEurekaNodes()) {
> > > >         if (replicaHostNames.length() > 0) {
> > > >             replicaHostNames.append(", ");
> > > >         }
> > > >         replicaHostNames.append(node.getServiceUrl());
> > > >         // 需要该方法返回 true，才会给 upReplicas 赋值
> > > >         if (isReplicaAvailable(node.getServiceUrl())) {
> > > >             upReplicas.append(node.getServiceUrl()).append(',');
> > > >             upReplicasCount++;
> > > >         } else {
> > > >             downReplicas.append(node.getServiceUrl()).append(',');
> > > >         }
> > > >     }
> > > > 
> > > >     builder.add("registered-replicas", replicaHostNames.toString());
> > > >     // 前端显示的 available-replicas 是 upReplicas 的结果
> > > >     builder.add("available-replicas", upReplicas.toString());
> > > >     builder.add("unavailable-replicas", downReplicas.toString());
> > > > 
> > > >     // Only set the healthy flag if a threshold has been configured.
> > > >     if (peerEurekaNodes.getMinNumberOfAvailablePeers() > -1) {
> > > >         builder.isHealthy(upReplicasCount >= peerEurekaNodes.getMinNumberOfAvailablePeers());
> > > >     }
> > > > 
> > > >     builder.withInstanceInfo(this.instanceInfo);
> > > > 
> > > >     return builder.build();
> > > > }
> > > > ```
> > > >
> > > > > `isReplicaAvailable(node.getServiceUrl()`
> > > > >
> > > > > ```java
> > > > > private boolean isReplicaAvailable(String url) {
> > > > >     try {
> > > > >         // 从 registry 中获取名称为 myAppName 的对象，myAppName 对应 spring.application.name 属性的值
> > > > >         Application app = registry.getApplication(myAppName, false);
> > > > >         // 如果拿不到当前 EurekaServer 对象，直接返回 false
> > > > >         if (app == null) {
> > > > >             return false;
> > > > >         }
> > > > >         // 遍历每个实例信息
> > > > >         for (InstanceInfo info : app.getInstances()) {
> > > > >             // 把从 registry 中获取到的所有实例信息和当前 url 做对比
> > > > >             if (peerEurekaNodes.isInstanceURL(url, info)) {
> > > > >                 return true;
> > > > >             }
> > > > >         }
> > > > >     } catch (Throwable e) {
> > > > >         logger.error("Could not determine if the replica is available ", e);
> > > > >     }
> > > > >     return false;
> > > > > }
> > > > > ```
> > > > >
> > > > > > `peerEurekaNodes.isInstanceURL(url, info)`
> > > > > >
> > > > > > > ```java
> > > > > > > public boolean isInstanceURL(String url, InstanceInfo instance) {
> > > > > > >     // 从 url 中获取到 hostName
> > > > > > >     String hostName = hostFromUrl(url);
> > > > > > >     // 从配置中获取到实例的 hostName，对应的配置为 eureka.instance.hostname
> > > > > > >     String myInfoComparator = instance.getHostName();
> > > > > > >     if (clientConfig.getTransportConfig().applicationsResolverUseIp()) {
> > > > > > >         myInfoComparator = instance.getIPAddr();
> > > > > > >     }
> > > > > > >     return hostName != null && hostName.equals(myInfoComparator);
> > > > > > > }
> > > > > > > ```

**解决方案**：

```yaml
spring:
  application:
    # 相同的服务，myAppName 相同
    name: myAppName
eureka:
   client:
      # 设置为 true，保证将当前 EurekaServer 注册到注册中心
      register-with-eureka: true
      service-url:
         # 此处的 myHostname 需要与 eureka.instance.hostname 一致
         defaultZone: http://myHostname:port/eureka
   instance:
      hostname: myHostname
```
