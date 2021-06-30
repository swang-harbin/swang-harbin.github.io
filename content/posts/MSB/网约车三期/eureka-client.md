---
title: Eureka-Client
date: '2021-02-23 20:54:00'
tags:
- MSB
- Project
- 网约车三期
- Eureka
- Java
---
# Eureka-Client

## Eureka-Client 启动原理

### 引入 EurekaClientAutoConfiguration 自动配置类即可

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
</dependency>
```

在**spring-cloud-netflix-eureka-client-2.2.2.RELEASE.jar**的**spring.factories**中

```properties
# 在 SpringBoot 启动时，会自动将一下的类自动注入到容器中
org.springframework.boot.autoconfigure.EnableAutoConfiguration=\
org.springframework.cloud.netflix.eureka.config.EurekaClientConfigServerAutoConfiguration,\
org.springframework.cloud.netflix.eureka.config.EurekaDiscoveryClientConfigServiceAutoConfiguration,\
org.springframework.cloud.netflix.eureka.EurekaClientAutoConfiguration,\
org.springframework.cloud.netflix.ribbon.eureka.RibbonEurekaAutoConfiguration,\
org.springframework.cloud.netflix.eureka.EurekaDiscoveryClientConfiguration,\
org.springframework.cloud.netflix.eureka.reactive.EurekaReactiveDiscoveryClientConfiguration,\
org.springframework.cloud.netflix.eureka.loadbalancer.LoadBalancerEurekaAutoConfiguration

org.springframework.cloud.bootstrap.BootstrapConfiguration=\
org.springframework.cloud.netflix.eureka.config.EurekaDiscoveryClientConfigServiceBootstrapConfiguration
```

> ```java
> // EurekaClientConfig 对应 eureka.client 配置，用于保存客户端与服务端交互的一些配置
> @ConditionalOnClass(EurekaClientConfig.class)
> // 默认是 true
> @ConditionalOnProperty(value = "eureka.client.enabled", matchIfMissing = true)
> // 在加载完以下类之后，再加载该类
> @AutoConfigureAfter(name = {
>     "org.springframework.cloud.autoconfigure.RefreshAutoConfiguration",
>     /* 关键点 2 */
>     "org.springframework.cloud.netflix.eureka.EurekaDiscoveryClientConfiguration",
>     "org.springframework.cloud.client.serviceregistry.AutoServiceRegistrationAutoConfiguration" })
> public class EurekaClientAutoConfiguration {
> 
>     // 静态内部类，在类加载的时候就执行了
>     @Configuration(proxyBeanMethods = false)
>     @ConditionalOnMissingRefreshScope
>     protected static class EurekaClientConfiguration {
> 
>         // 关键点 1：向容器中注入了 EurekaClient
>         @Bean(destroyMethod = "shutdown")
>         @ConditionalOnMissingBean(value = EurekaClient.class,
>                                   search = SearchStrategy.CURRENT)
>         public EurekaClient eurekaClient(ApplicationInfoManager manager,
>                                          EurekaClientConfig config) {
>             return new CloudEurekaClient(manager, config, this.optionalArgs,
>                                          this.context);
>         }
> ```
>
> > ```java
> > // 关键点 1：CloudEurekaClient 继承自 com.netflix.discovery.DiscoveryClient, DiscoveryClient 是 Eureka Client 的入口
> > public class CloudEurekaClient extends DiscoveryClient {
> > ```
> >
> > > ```java
> > > package com.netflix.discovery;
> > > @Singleton
> > > public class DiscoveryClient implements EurekaClient {
> > >     // 重点：该构造方法作为程序启动的入口，包含了 eureka client 启动时的初始化逻辑
> > >     @Inject
> > >     DiscoveryClient(ApplicationInfoManager applicationInfoManager, EurekaClientConfig config, AbstractDiscoveryClientOptionalArgs args,
> > >                     Provider<BackupRegistry> backupRegistryProvider, EndpointRandomizer endpointRandomizer) {
> > > ```
> >
> > ```java
> > // 关键点 2：对 Eureka 提供的 DiscoveryClient 进行包装，作为 Spring 提供的 DiscoveryClient
> > public class EurekaDiscoveryClientConfiguration {
> > 
> >     // 重点：向容器中注入包装后的 EurekaDiscoveryClient 对象
> >     @Bean
> >     @ConditionalOnMissingBean
> >     public EurekaDiscoveryClient discoveryClient(EurekaClient client,
> >                                                  EurekaClientConfig clientConfig) {
> >         return new EurekaDiscoveryClient(client, clientConfig);
> >     }
> > }
> > ```
> >
> > > ```java
> > > // 此处实现的是 org.springframework.cloud.client.discovery.DiscoveryClient，是 Spring 提供的一套标准
> > > public class EurekaDiscoveryClient implements DiscoveryClient {
> > > 
> > >     private final EurekaClient eurekaClient;
> > > 
> > >     private final EurekaClientConfig clientConfig;
> > > 
> > >     public EurekaDiscoveryClient(EurekaClient eurekaClient,
> > >                                  EurekaClientConfig clientConfig) {
> > >         this.clientConfig = clientConfig;
> > >         this.eurekaClient = eurekaClient;
> > >     }
> > > ```

```yaml
eureka:
  client:
    # 通过设置该属性为 false，可以让 Eureka Client 不需要与 Eureka Server 交互，常在本地调试时使用
    enabled: false
```

## Eureka Client 源码

Eureka Client 启动的时候，主要做了服务注册，注册表拉取，以及定时刷新注册表，定时心跳/续约，自动更新实例信息 3 个定时任务

```java
public class EurekaClientAutoConfiguration {

    // 静态内部类，在类加载的时候就执行了
    @Configuration(proxyBeanMethods = false)
    @ConditionalOnMissingRefreshScope
    protected static class EurekaClientConfiguration {

        // 向容器中注入了 EurekaClient，在其销毁的时候，会执行 shutdown 方法
        @Bean(destroyMethod = "shutdown")
        @ConditionalOnMissingBean(value = EurekaClient.class,
                                  search = SearchStrategy.CURRENT)
        public EurekaClient eurekaClient(ApplicationInfoManager manager,
                                         EurekaClientConfig config) {
            return new CloudEurekaClient(manager, config, this.optionalArgs,
                                         this.context);
        }
```
> ```java
> // Eureka Client 初始化
> /**
> * ApplicaitonInfoManager 中包含 EurekaInstanceConfig，其对应 eureka.instance 的配置信息，用于保存当前实例的信息
> * EurekaClientConfig 对应 eureka.client 的配置信息，其保存的是 eureka client 与 eureka server 交互的配置信息
> */
> @Inject
> DiscoveryClient(ApplicationInfoManager applicationInfoManager, EurekaClientConfig config, AbstractDiscoveryClientOptionalArgs args,
>                 Provider<BackupRegistry> backupRegistryProvider, EndpointRandomizer endpointRandomizer) {
>     // ...
>     // 取出 InstanceInfo
>     InstanceInfo myInfo = applicationInfoManager.getInfo();
>     // 赋值给全局属性
>     clientConfig = config;
>     staticClientConfig = clientConfig;
>     transportConfig = config.getTransportConfig();
>     instanceInfo = myInfo;
>     // ...
>     // 是否需要从 eureka server 拉取注册表，eureka.client.fetch-registry，默认为 true
>     if (config.shouldFetchRegistry()) {
>         this.registryStalenessMonitor = new ThresholdLevelsMetric(this, METRIC_REGISTRY_PREFIX + "lastUpdateSec_", new long[]{15L, 30L, 60L, 120L, 240L, 480L});
>     } else {
>         this.registryStalenessMonitor = ThresholdLevelsMetric.NO_OP_METRIC;
>     }
>     // 是否将自己注册到 eureka server，eureka.client.register-with-eureka，默认为 true
>     if (config.shouldRegisterWithEureka()) {
>         this.heartbeatStalenessMonitor = new ThresholdLevelsMetric(this, METRIC_REGISTRATION_PREFIX + "lastHeartbeatSec_", new long[]{15L, 30L, 60L, 120L, 240L, 480L});
>     } else {
>         this.heartbeatStalenessMonitor = ThresholdLevelsMetric.NO_OP_METRIC;
>     }
> 
>     // 如果即不需要向 eureka server 注册自己，也不需要从 eureka server 拉取注册表，那就不需要设置下面的心跳，拉取注册表等定时任务了
>     if (!config.shouldRegisterWithEureka() && !config.shouldFetchRegistry()) {
>         logger.info("Client configured to neither register nor query for data.");
>         scheduler = null;
>         heartbeatExecutor = null;
>         cacheRefreshExecutor = null;
>         eurekaTransport = null;
>         instanceRegionChecker = new InstanceRegionChecker(new PropertyBasedAzToRegionMapper(config), clientConfig.getRegion());
> 
>         // This is a bit of hack to allow for existing code using DiscoveryManager.getInstance()
>         // to work with DI'd DiscoveryClient
>         DiscoveryManager.getInstance().setDiscoveryClient(this);
>         DiscoveryManager.getInstance().setEurekaClientConfig(config);
> 
>         initTimestampMs = System.currentTimeMillis();
>         logger.info("Discovery Client initialized at timestamp {} with initial instances count: {}",
>                     initTimestampMs, this.getApplications().size());
> 
>         // 不需要设置与 Eureka erver 相关的任务直接返回
>         return;  // no need to setup up an network tasks and we are done
>     }
>     // 如果需要与 Eureka erver 进行交互
>     try {
>         // default size of 2 - 1 each for heartbeat and cacheRefresh
>         scheduler = Executors.newScheduledThreadPool(2,
>                                                      new ThreadFactoryBuilder()
>                                                      .setNameFormat("DiscoveryClient-%d")
>                                                      .setDaemon(true)
>                                                      .build());
>         // 定时给 eureka server 发送心跳的线程池
>         heartbeatExecutor = new ThreadPoolExecutor(
>             // eureka.client.heartbeat-executor-thread-pool-size，默认为 2
>             1, clientConfig.getHeartbeatExecutorThreadPoolSize(), 0, TimeUnit.SECONDS,
>             new SynchronousQueue<Runnable>(),
>             new ThreadFactoryBuilder()
>             .setNameFormat("DiscoveryClient-HeartbeatExecutor-%d")
>             .setDaemon(true)
>             .build()
>         );  // use direct handoff
>         // 定时从 eureka server 拉取注册表的线程池
>         cacheRefreshExecutor = new ThreadPoolExecutor(
>             // eureka.client.cache-refresh-executor-thread-pool-size，默认为 2
>             1, clientConfig.getCacheRefreshExecutorThreadPoolSize(), 0, TimeUnit.SECONDS,
>             new SynchronousQueue<Runnable>(),
>             new ThreadFactoryBuilder()
>             .setNameFormat("DiscoveryClient-CacheRefreshExecutor-%d")
>             .setDaemon(true)
>             .build()
>         );  // use direct handoff
>         // 用来和 eureka server 交互的对象
>         eurekaTransport = new EurekaTransport();
>         scheduleServerEndpointTask(eurekaTransport, args);
>         // ...
>     } catch (Throwable e) {
>         throw new RuntimeException("Failed to initialize DiscoveryClient!", e);
>     }
>     // 如果需要从 eureka server 拉取注册表，执行 fetchRegistry
>     if (clientConfig.shouldFetchRegistry() && !fetchRegistry(false)) {
>         fetchRegistryFromBackup();
>     }
> 
>     // call and execute the pre registration handler before all background tasks (inc registration) is started
>     if (this.preRegistrationHandler != null) {
>         this.preRegistrationHandler.beforeRegistration();
>     }
>     // shouldEnforceRegistrationAtInit 设置初始化的时候是否强制注册，默认是 false, 此时不注册，在后面定时任务进行心跳的时候会自动注册
>     if (clientConfig.shouldRegisterWithEureka() && clientConfig.shouldEnforceRegistrationAtInit()) {
>         try {
>             if (!register() ) {
>                 throw new IllegalStateException("Registration error at startup. Invalid server response.");
>             }
>         } catch (Throwable th) {
>             logger.error("Registration error at startup: {}", th.getMessage());
>             throw new IllegalStateException(th);
>         }
>     }
> 
>     // finally, init the schedule tasks (e.g. cluster resolvers, heartbeat, instanceInfo replicator, fetch
>     // 初始化定时任务
>     initScheduledTasks();
>     // ...
>     // This is a bit of hack to allow for existing code using DiscoveryManager.getInstance()
>     // to work with DI'd DiscoveryClient
>     DiscoveryManager.getInstance().setDiscoveryClient(this);
>     DiscoveryManager.getInstance().setEurekaClientConfig(config);
> 
>     initTimestampMs = System.currentTimeMillis();
>     logger.info("Discovery Client initialized at timestamp {} with initial instances count: {}",
>                 initTimestampMs, this.getApplications().size());
> }
> ```
>
> > `if (clientConfig.shouldFetchRegistry() && !fetchRegistry(false)) {`
> >
> > > ```java
> > > // 拉取注册表
> > > private boolean fetchRegistry(boolean forceFullRegistryFetch) {
> > >  Stopwatch tracer = FETCH_REGISTRY_TIMER.start();
> > > 
> > >  try {
> > >      // If the delta is disabled or if it is the first time, get all
> > >      // applications
> > >      Applications applications = getApplications();
> > > 
> > >      if (clientConfig.shouldDisableDelta()
> > >          || (!Strings.isNullOrEmpty(clientConfig.getRegistryRefreshSingleVipAddress()))
> > >          || forceFullRegistryFetch
> > >          || (applications == null)
> > >          || (applications.getRegisteredApplications().size() == 0)
> > >          || (applications.getVersion() == -1)) //Client application does not have latest library supporting delta
> > >      {
> > >          logger.info("Disable delta property : {}", clientConfig.shouldDisableDelta());
> > >          logger.info("Single vip registry refresh property : {}", clientConfig.getRegistryRefreshSingleVipAddress());
> > >          logger.info("Force full registry fetch : {}", forceFullRegistryFetch);
> > >          logger.info("Application is null : {}", (applications == null));
> > >          logger.info("Registered Applications size is zero : {}",
> > >                      (applications.getRegisteredApplications().size() == 0));
> > >          logger.info("Application version is -1: {}", (applications.getVersion() == -1));
> > >          // 全量拉取
> > >          getAndStoreFullRegistry();
> > >      } else {
> > >          // 增量拉取
> > >          getAndUpdateDelta(applications);
> > >      }
> > >      applications.setAppsHashCode(applications.getReconcileHashCode());
> > >      logTotalInstances();
> > >  } catch (Throwable e) {
> > >      logger.error(PREFIX + "{} - was unable to refresh its cache! status = {}", appPathIdentifier, e.getMessage(), e);
> > >      return false;
> > >  } finally {
> > >      if (tracer != null) {
> > >          tracer.stop();
> > >      }
> > >  }
> > > 
> > >  // Notify about cache refresh before updating the instance remote status
> > >  onCacheRefreshed();
> > > 
> > >  // Update remote status based on refreshed data held in the cache
> > >  updateInstanceRemoteStatus();
> > > 
> > >  // registry was fetched successfully, so return true
> > >  return true;
> > > }
> > > ```
> > >
> > > > `getAndStoreFullRegistry();`
> > > >
> > > > > ```java
> > > > > // 全量拉取
> > > > > private void getAndStoreFullRegistry() throws Throwable {
> > > > >        long currentUpdateGeneration = fetchRegistryGeneration.get();
> > > > >     logger.info("Getting all instance registry info from the eureka server");
> > > > >        Applications apps = null;
> > > > >     EurekaHttpResponse<Applications> httpResponse = clientConfig.getRegistryRefreshSingleVipAddress() == null
> > > > >            // 全量拉取注册表
> > > > >            ? eurekaTransport.queryClient.getApplications(remoteRegionsRef.get())
> > > > >            : eurekaTransport.queryClient.getVip(clientConfig.getRegistryRefreshSingleVipAddress(), remoteRegionsRef.get());
> > > > >        // ...
> > > > >    }
> > > > >    ```
> > > > >    
> > > > >    > ```java
> > > > >    > public EurekaHttpResponse<Applications> getApplications(final String... regions) {
> > > > > >        return execute(new RequestExecutor<Applications>() {
> > > > >    >            @Override
> > > > >    >            public EurekaHttpResponse<Applications> execute(EurekaHttpClient delegate) {
> > > > >    >                // 全量拉取注册表
> > > > >    >                return delegate.getApplications(regions);
> > > > >    >            }
> > > > >    >        });
> > > > >    > }
> > > > >    > ```
> > > > > >
> > > > > > > ```java
> > > > >> > public EurekaHttpResponse<Applications> getApplications(String... regions) {
> > > > > > >        // 向 eureka server 发送 apps 请求
> > > > > > >        return getApplicationsInternal("apps/", regions);
> > > > > > > }
> > > > > > > ```
> > > >
> > > > `getAndUpdateDelta(applications);`
> > > >
> > > > > ```java
> > > > > // 增量拉取
> > > > > private void getAndUpdateDelta(Applications applications) throws Throwable {
> > > > >     long currentUpdateGeneration = fetchRegistryGeneration.get();
> > > > > 
> > > > >     Applications delta = null;
> > > > >     EurekaHttpResponse<Applications> httpResponse = 
> > > > >         // 增量拉取注册表
> > > > >         eurekaTransport.queryClient.getDelta(remoteRegionsRef.get());
> > > > >     if (httpResponse.getStatusCode() == Status.OK.getStatusCode()) {
> > > > >         delta = httpResponse.getEntity();
> > > > >     }
> > > > > 
> > > > >     if (delta == null) {
> > > > >         logger.warn("The server does not allow the delta revision to be applied because it is not safe. "
> > > > >                     + "Hence got the full registry.");
> > > > >         // 如果增量拉取失败，会再次进行全量拉取
> > > > >         getAndStoreFullRegistry();
> > > > >     } else if (fetchRegistryGeneration.compareAndSet(currentUpdateGeneration, currentUpdateGeneration + 1)) {
> > > > >         logger.debug("Got delta update with apps hashcode {}", delta.getAppsHashCode());
> > > > >         String reconcileHashCode = "";
> > > > >         if (fetchRegistryUpdateLock.tryLock()) {
> > > > >             try {
> > > > >                 updateDelta(delta);
> > > > >                 reconcileHashCode = getReconcileHashCode(applications);
> > > > >             } finally {
> > > > >                 fetchRegistryUpdateLock.unlock();
> > > > >             }
> > > > >         } else {
> > > > >             logger.warn("Cannot acquire update lock, aborting getAndUpdateDelta");
> > > > >         }
> > > > >         // There is a diff in number of instances for some reason
> > > > >         if (!reconcileHashCode.equals(delta.getAppsHashCode()) || clientConfig.shouldLogDeltaDiff()) {
> > > > >             reconcileAndLogDifference(delta, reconcileHashCode);  // this makes a remoteCall
> > > > >         }
> > > > >     } else {
> > > > >         logger.warn("Not updating application delta as another thread is updating it already");
> > > > >         logger.debug("Ignoring delta update with apps hashcode {}, as another thread is updating it already", delta.getAppsHashCode());
> > > > >     }
> > > > > }
> > > > > ```
> > > > >
> > > > > > ```java
> > > > > > @Override
> > > > > > public EurekaHttpResponse<Applications> getDelta(final String... regions) {
> > > > > >     return execute(new RequestExecutor<Applications>() {
> > > > > >         @Override
> > > > > >         public EurekaHttpResponse<Applications> execute(EurekaHttpClient delegate) {
> > > > > >             // 增量拉取注册表，是从 recentlyChangedQueue 中获取
> > > > > >             return delegate.getDelta(regions);
> > > > > >         }
> > > > > >     });
> > > > > > }
> > > > > > ```
> > > > > >
> > > > > > > ```java
> > > > > > > @Override
> > > > > > > public EurekaHttpResponse<Applications> getDelta(String... regions) {
> > > > > > >     // 向 eureka server 发送 apps/delta 请求
> > > > > > >     return getApplicationsInternal("apps/delta", regions);
> > > > > > > }
> > > > > > > ```
> > >
> > > `initScheduledTasks();`
> > >
> > > > ```java
> > > > // 初始化定时任务
> > > > private void initScheduledTasks() {
> > > >  if (clientConfig.shouldFetchRegistry()) {
> > > >      // registry cache refresh timer
> > > >      // 拉取注册表的时间间隔，eureka.client.registry-fetch-interval-seconds，默认是 30
> > > >      int registryFetchIntervalSeconds = clientConfig.getRegistryFetchIntervalSeconds();
> > > >      int expBackOffBound = clientConfig.getCacheRefreshExecutorExponentialBackOffBound();
> > > >      // 定时拉取注册表
> > > >      cacheRefreshTask = new TimedSupervisorTask(
> > > >          "cacheRefresh",
> > > >          scheduler,
> > > >          cacheRefreshExecutor,
> > > >          registryFetchIntervalSeconds,
> > > >          TimeUnit.SECONDS,
> > > >          expBackOffBound,
> > > >          new CacheRefreshThread()
> > > >      );
> > > >      scheduler.schedule(
> > > >          cacheRefreshTask,
> > > >          registryFetchIntervalSeconds, TimeUnit.SECONDS);
> > > >  }
> > > > 
> > > >  if (clientConfig.shouldRegisterWithEureka()) {
> > > >      // 心跳/续约时间间隔，eureka.instance.lease-renewal-interval-in-seconds，默认 30 秒
> > > >      int renewalIntervalInSecs = instanceInfo.getLeaseInfo().getRenewalIntervalInSecs();
> > > >      int expBackOffBound = clientConfig.getHeartbeatExecutorExponentialBackOffBound();
> > > >      logger.info("Starting heartbeat executor: " + "renew interval is: {}", renewalIntervalInSecs);
> > > > 
> > > >      // Heartbeat timer
> > > >      // 定时心跳
> > > >      heartbeatTask = new TimedSupervisorTask(
> > > >          "heartbeat",
> > > >          scheduler,
> > > >          heartbeatExecutor,
> > > >          renewalIntervalInSecs,
> > > >          TimeUnit.SECONDS,
> > > >          expBackOffBound,
> > > >          new HeartbeatThread()
> > > >      );
> > > >      scheduler.schedule(
> > > >          heartbeatTask,
> > > >          renewalIntervalInSecs, TimeUnit.SECONDS);
> > > > 
> > > >      // InstanceInfo replicator
> > > >      // 实例信息复制器
> > > >      instanceInfoReplicator = new InstanceInfoReplicator(
> > > >          this,
> > > >          instanceInfo,
> > > >          clientConfig.getInstanceInfoReplicationIntervalSeconds(),
> > > >          2); // burstSize
> > > >      // 实例状态改变的监听器，Eureka Client 支持动态刷新，该监听器可以在 Client 已经启动的情况下自动更新 Client 的信息
> > > >      // 与 EurekaClient#registerHealthCheck, EurekaClient#registerEventListener 有关
> > > >      statusChangeListener = new ApplicationInfoManager.StatusChangeListener() {
> > > >          @Override
> > > >          public String getId() {
> > > >              return "statusChangeListener";
> > > >          }
> > > > 
> > > >          @Override
> > > >          public void notify(StatusChangeEvent statusChangeEvent) {
> > > >              if (InstanceStatus.DOWN == statusChangeEvent.getStatus() ||
> > > >                  InstanceStatus.DOWN == statusChangeEvent.getPreviousStatus()) {
> > > >                  // log at warn level if DOWN was involved
> > > >                  logger.warn("Saw local status change event {}", statusChangeEvent);
> > > >              } else {
> > > >                  logger.info("Saw local status change event {}", statusChangeEvent);
> > > >              }
> > > >              instanceInfoReplicator.onDemandUpdate();
> > > >          }
> > > >      };
> > > > 
> > > >      if (clientConfig.shouldOnDemandUpdateStatusChange()) {
> > > >          applicationInfoManager.registerStatusChangeListener(statusChangeListener);
> > > >      }
> > > >      // 启动线程处理 Eureka Client 的自动更新
> > > >      instanceInfoReplicator.start(clientConfig.getInitialInstanceInfoReplicationIntervalSeconds());
> > > >  } else {
> > > >      logger.info("Not registering with Eureka server per configuration");
> > > >  }
> > > > }
> > > > ```
> > > >
> > > > > `new CacheRefreshThread()`
> > > > >
> > > > > > ```java
> > > > > > // 定时拉取注册表的逻辑
> > > > > > @VisibleForTesting
> > > > > > void refreshRegistry() {
> > > > > >  try {
> > > > > >      boolean isFetchingRemoteRegionRegistries = isFetchingRemoteRegionRegistries();
> > > > > > 
> > > > > >      boolean remoteRegionsModified = false;
> > > > > >      // This makes sure that a dynamic change to remote regions to fetch is honored.
> > > > > >      String latestRemoteRegions = clientConfig.fetchRegistryForRemoteRegions();
> > > > > >      if (null != latestRemoteRegions) {
> > > > > >          String currentRemoteRegions = remoteRegionsToFetch.get();
> > > > > >          if (!latestRemoteRegions.equals(currentRemoteRegions)) {
> > > > > >              // Both remoteRegionsToFetch and AzToRegionMapper.regionsToFetch need to be in sync
> > > > > >              synchronized (instanceRegionChecker.getAzToRegionMapper()) {
> > > > > >                  if (remoteRegionsToFetch.compareAndSet(currentRemoteRegions, latestRemoteRegions)) {
> > > > > >                      String[] remoteRegions = latestRemoteRegions.split(",");
> > > > > >                      remoteRegionsRef.set(remoteRegions);
> > > > > >                      instanceRegionChecker.getAzToRegionMapper().setRegionsToFetch(remoteRegions);
> > > > > >                      remoteRegionsModified = true;
> > > > > >                  } else {
> > > > > >                      logger.info("Remote regions to fetch modified concurrently," +
> > > > > >                                  " ignoring change from {} to {}", currentRemoteRegions, latestRemoteRegions);
> > > > > >                  }
> > > > > >              }
> > > > > >          } else {
> > > > > >              // Just refresh mapping to reflect any DNS/Property change
> > > > > >              instanceRegionChecker.getAzToRegionMapper().refreshMapping();
> > > > > >          }
> > > > > >      }
> > > > > > 		// 拉取注册表
> > > > > >      boolean success = fetchRegistry(remoteRegionsModified);
> > > > > >      if (success) {
> > > > > >          registrySize = localRegionApps.get().size();
> > > > > >          lastSuccessfulRegistryFetchTimestamp = System.currentTimeMillis();
> > > > > >      }
> > > > > > 
> > > > > >      if (logger.isDebugEnabled()) {
> > > > > >          StringBuilder allAppsHashCodes = new StringBuilder();
> > > > > >          allAppsHashCodes.append("Local region apps hashcode: ");
> > > > > >          allAppsHashCodes.append(localRegionApps.get().getAppsHashCode());
> > > > > >          allAppsHashCodes.append(", is fetching remote regions? ");
> > > > > >          allAppsHashCodes.append(isFetchingRemoteRegionRegistries);
> > > > > >          for (Map.Entry<String, Applications> entry : remoteRegionVsApps.entrySet()) {
> > > > > >              allAppsHashCodes.append(", Remote region: ");
> > > > > >              allAppsHashCodes.append(entry.getKey());
> > > > > >              allAppsHashCodes.append(" , apps hashcode: ");
> > > > > >              allAppsHashCodes.append(entry.getValue().getAppsHashCode());
> > > > > >          }
> > > > > >          logger.debug("Completed cache refresh task for discovery. All Apps hash code is {} ",
> > > > > >                       allAppsHashCodes);
> > > > > >      }
> > > > > >  } catch (Throwable e) {
> > > > > >      logger.error("Cannot fetch registry from server", e);
> > > > > >  }
> > > > > > }
> > > > > > ```
> > > > >
> > > > > ` new HeartbeatThread()`
> > > > >
> > > > > > ```java
> > > > > > // 定时心跳/续约的逻辑
> > > > > > boolean renew() {
> > > > > >  EurekaHttpResponse<InstanceInfo> httpResponse;
> > > > > >  try {
> > > > > >      // 发送心跳
> > > > > >      httpResponse = eurekaTransport.registrationClient.sendHeartBeat(instanceInfo.getAppName(), instanceInfo.getId(), instanceInfo, null);
> > > > > >      logger.debug(PREFIX + "{} - Heartbeat status: {}", appPathIdentifier, httpResponse.getStatusCode());
> > > > > >      if (httpResponse.getStatusCode() == Status.NOT_FOUND.getStatusCode()) {
> > > > > >          REREGISTER_COUNTER.increment();
> > > > > >          logger.info(PREFIX + "{} - Re-registering apps/{}", appPathIdentifier, instanceInfo.getAppName());
> > > > > >          long timestamp = instanceInfo.setIsDirtyWithTime();
> > > > > >          boolean success = register();
> > > > > >          if (success) {
> > > > > >              instanceInfo.unsetIsDirty(timestamp);
> > > > > >          }
> > > > > >          return success;
> > > > > >      }
> > > > > >      return httpResponse.getStatusCode() == Status.OK.getStatusCode();
> > > > > >  } catch (Throwable e) {
> > > > > >      logger.error(PREFIX + "{} - was unable to send heartbeat!", appPathIdentifier, e);
> > > > > >      return false;
> > > > > >  }
> > > > > > }
> > > > > > ```
> > > > >
> > > > > `instanceInfoReplicator.start(clientConfig.getInitialInstanceInfoReplicationIntervalSeconds());`
> > > > >
> > > > > > ```java
> > > > > > // 自动更新 Eureka Client 信息的逻辑
> > > > > > // InstanceInfoReplicator 实现了 Runnable 接口
> > > > > > class InstanceInfoReplicator implements Runnable {
> > > > > > // eureka.client.initial-instance-info-replication-interval-seconds 默认是 40
> > > > > > public void start(int initialDelayMs) {
> > > > > >   if (started.compareAndSet(false, true)) {
> > > > > >       // 类似于 linux 上脏页的概念，当实例的某些信息被修改了，还没同步到 eureka server，此时就标记其是’脏‘的，等待同步后，会将其设置为’非脏‘的
> > > > > >       instanceInfo.setIsDirty();  // for initial register
> > > > > >       // 执行完该方法后，每 40 秒执行一次下方的 run 方法
> > > > > >       Future next = scheduler.schedule(this, initialDelayMs, TimeUnit.SECONDS);
> > > > > >       scheduledPeriodicRef.set(next);
> > > > > >   }
> > > > > > }
> > > > > > 
> > > > > > public void run() {
> > > > > >   try {
> > > > > >       // 动态更新 Client 的信息
> > > > > >       discoveryClient.refreshInstanceInfo();
> > > > > > 			// 如果是’脏‘的返回时间戳，否则返回 null
> > > > > >       Long dirtyTimestamp = instanceInfo.isDirtyWithTime();
> > > > > >       // 如果实例是’脏‘的
> > > > > >       if (dirtyTimestamp != null) {
> > > > > >           // 向注册中心注册本地已经更新的实例
> > > > > >           discoveryClient.register();
> > > > > >           // 更新之后把实例信息标记为’非脏‘的
> > > > > >           instanceInfo.unsetIsDirty(dirtyTimestamp);
> > > > > >       }
> > > > > >   } catch (Throwable t) {
> > > > > >       logger.warn("There was a problem with the instance info replicator", t);
> > > > > >   } finally {
> > > > > >       Future next = scheduler.schedule(this, replicationIntervalSeconds, TimeUnit.SECONDS);
> > > > > >       scheduledPeriodicRef.set(next);
> > > > > >   }
> > > > > > }
> > > > > > }
> > > > > > ```
> > > > > >
> > > > > > > `discoveryClient.refreshInstanceInfo();`
> > > > > > >
> > > > > > > > ```java
> > > > > > > > /**
> > > > > > > >  * 刷新当前本地的实例信息。
> > > > > > > >  * Refresh the current local instanceInfo. Note that after a valid refresh where changes are observed, the
> > > > > > > >  * isDirty flag on the instanceInfo is set to true
> > > > > > > >  */
> > > > > > > > void refreshInstanceInfo() {
> > > > > > > >     // 刷新数据中心信息，主要是地址和 IP 信息
> > > > > > > >     applicationInfoManager.refreshDataCenterInfoIfRequired();
> > > > > > > >     // 刷新租约信息
> > > > > > > >     applicationInfoManager.refreshLeaseInfoIfRequired();
> > > > > > > > 
> > > > > > > >     InstanceStatus status;
> > > > > > > >     try {
> > > > > > > >         status = getHealthCheckHandler().getStatus(instanceInfo.getStatus());
> > > > > > > >     } catch (Exception e) {
> > > > > > > >         logger.warn("Exception from healthcheckHandler.getStatus, setting status to DOWN", e);
> > > > > > > >         status = InstanceStatus.DOWN;
> > > > > > > >     }
> > > > > > > > 
> > > > > > > >     if (null != status) {
> > > > > > > >         applicationInfoManager.setInstanceStatus(status);
> > > > > > > >     }
> > > > > > > > }
> > > > > > > > ```
> > > > > > > >
> > > > > > > > `applicationInfoManager.refreshDataCenterInfoIfRequired();`
> > > > > > > >
> > > > > > > > > ```java
> > > > > > > > > public void refreshDataCenterInfoIfRequired() {
> > > > > > > > >     String existingAddress = instanceInfo.getHostName();
> > > > > > > > > 
> > > > > > > > >     String existingSpotInstanceAction = null;
> > > > > > > > >     if (instanceInfo.getDataCenterInfo() instanceof AmazonInfo) {
> > > > > > > > >         existingSpotInstanceAction = ((AmazonInfo) instanceInfo.getDataCenterInfo()).get(AmazonInfo.MetaDataKey.spotInstanceAction);
> > > > > > > > >     }
> > > > > > > > > 	// 获取新的地址信息
> > > > > > > > >     String newAddress;
> > > > > > > > >     if (config instanceof RefreshableInstanceConfig) {
> > > > > > > > >         // Refresh data center info, and return up to date address
> > > > > > > > >         newAddress = ((RefreshableInstanceConfig) config).resolveDefaultAddress(true);
> > > > > > > > >     } else {
> > > > > > > > >         newAddress = config.getHostName(true);
> > > > > > > > >     }
> > > > > > > > >     // 获取新的 IP 地址
> > > > > > > > >     String newIp = config.getIpAddress();
> > > > > > > > > 
> > > > > > > > >     if (newAddress != null && !newAddress.equals(existingAddress)) {
> > > > > > > > >         logger.warn("The address changed from : {} => {}", existingAddress, newAddress);
> > > > > > > > >         // 更新实例的信息，并把实例设置为’脏‘
> > > > > > > > >         updateInstanceInfo(newAddress, newIp);
> > > > > > > > >     }
> > > > > > > > > 
> > > > > > > > >     if (config.getDataCenterInfo() instanceof AmazonInfo) {
> > > > > > > > >         String newSpotInstanceAction = ((AmazonInfo) config.getDataCenterInfo()).get(AmazonInfo.MetaDataKey.spotInstanceAction);
> > > > > > > > >         if (newSpotInstanceAction != null && !newSpotInstanceAction.equals(existingSpotInstanceAction)) {
> > > > > > > > >             logger.info(String.format("The spot instance termination action changed from: %s => %s",
> > > > > > > > >                                       existingSpotInstanceAction,
> > > > > > > > >                                       newSpotInstanceAction));
> > > > > > > > >             updateInstanceInfo(null , null );
> > > > > > > > >         }
> > > > > > > > >     }        
> > > > > > > > > }
> > > > > > > > > ```
> > > > > > > > >
> > > > > > > > > > `updateInstanceInfo(newAddress, newIp);`
> > > > > > > > > >
> > > > > > > > > > > ```java
> > > > > > > > > > > private void updateInstanceInfo(String newAddress, String newIp) {
> > > > > > > > > > >     // :( in the legacy code here the builder is acting as a mutator.
> > > > > > > > > > >     // This is hard to fix as this same instanceInfo instance is referenced elsewhere.
> > > > > > > > > > >     // We will most likely re-write the client at sometime so not fixing for now.
> > > > > > > > > > >     InstanceInfo.Builder builder = new InstanceInfo.Builder(instanceInfo);
> > > > > > > > > > >     // 更新新的地址和 IP 信息
> > > > > > > > > > >     if (newAddress != null) {
> > > > > > > > > > >         builder.setHostName(newAddress);
> > > > > > > > > > >     }
> > > > > > > > > > >     if (newIp != null) {
> > > > > > > > > > >         builder.setIPAddr(newIp);
> > > > > > > > > > >     }
> > > > > > > > > > >     builder.setDataCenterInfo(config.getDataCenterInfo());
> > > > > > > > > > >     // 设置’脏‘状态
> > > > > > > > > > >     instanceInfo.setIsDirty();
> > > > > > > > > > > }
> > > > > > > > > > > ```
> > > > > > > >
> > > > > > > > `applicationInfoManager.refreshLeaseInfoIfRequired();`
> > > > > > > >
> > > > > > > > > ```java
> > > > > > > > > public void refreshLeaseInfoIfRequired() {
> > > > > > > > >     LeaseInfo leaseInfo = instanceInfo.getLeaseInfo();
> > > > > > > > >     if (leaseInfo == null) {
> > > > > > > > >         return;
> > > > > > > > >     }
> > > > > > > > >     int currentLeaseDuration = config.getLeaseExpirationDurationInSeconds();
> > > > > > > > >     int currentLeaseRenewal = config.getLeaseRenewalIntervalInSeconds();
> > > > > > > > >     if (leaseInfo.getDurationInSecs() != currentLeaseDuration || leaseInfo.getRenewalIntervalInSecs() != currentLeaseRenewal) {
> > > > > > > > >         // 设置续约相关的信息
> > > > > > > > >         LeaseInfo newLeaseInfo = LeaseInfo.Builder.newBuilder()
> > > > > > > > >             .setRenewalIntervalInSecs(currentLeaseRenewal)
> > > > > > > > >             .setDurationInSecs(currentLeaseDuration)
> > > > > > > > >             .build();
> > > > > > > > >         instanceInfo.setLeaseInfo(newLeaseInfo);
> > > > > > > > >         // 设置’脏‘状态
> > > > > > > > >         instanceInfo.setIsDirty();
> > > > > > > > >     }
> > > > > > > > > }
> > > > > > > > > ```
> > > > > > >
> > > > > > > `discoveryClient.register();`
> > > > > > >
> > > > > > > > ```java
> > > > > > > > boolean register() throws Throwable {
> > > > > > > >  logger.info(PREFIX + "{}: registering service...", appPathIdentifier);
> > > > > > > >  EurekaHttpResponse<Void> httpResponse;
> > > > > > > >  try {
> > > > > > > >      // 发送注册请求
> > > > > > > >      httpResponse = eurekaTransport.registrationClient.register(instanceInfo);
> > > > > > > >  } catch (Exception e) {
> > > > > > > >      logger.warn(PREFIX + "{} - registration failed {}", appPathIdentifier, e.getMessage(), e);
> > > > > > > >      throw e;
> > > > > > > >  }
> > > > > > > >  if (logger.isInfoEnabled()) {
> > > > > > > >      logger.info(PREFIX + "{} - registration status: {}", appPathIdentifier, httpResponse.getStatusCode());
> > > > > > > >  }
> > > > > > > >  return httpResponse.getStatusCode() == Status.NO_CONTENT.getStatusCode();
> > > > > > > > }
> > > > > > > > ```
>
> ```java
> // Eureka Client 销毁
> // 注意，在生产环境中，要先对 Eureka Client 进行停服，在对其进行下线，防止先下线后，Client 的心跳服务重新将其注册到 Server 上
> // DiscoveryClient.java
> // 在销毁之前下线
> @PreDestroy
> @Override
> public synchronized void shutdown() {
>     if (isShutdown.compareAndSet(false, true)) {
>         logger.info("Shutting down DiscoveryClient ...");
> 
>         if (statusChangeListener != null && applicationInfoManager != null) {
>             applicationInfoManager.unregisterStatusChangeListener(statusChangeListener.getId());
>         }
> 		// 关闭定时任务
>         cancelScheduledTasks();
> 
>         // If APPINFO was registered
>         if (applicationInfoManager != null
>             && clientConfig.shouldRegisterWithEureka()
>             && clientConfig.shouldUnregisterOnShutdown()) {
>             applicationInfoManager.setInstanceStatus(InstanceStatus.DOWN);
>             // 取消在注册中心的注册信息
>             unregister();
>         }
> 
>         if (eurekaTransport != null) {
>             eurekaTransport.shutdown();
>         }
> 
>         heartbeatStalenessMonitor.shutdown();
>         registryStalenessMonitor.shutdown();
> 
>         Monitors.unregisterObject(this);
> 
>         logger.info("Completed shut down of DiscoveryClient");
>     }
> }
> ```

## Eureka 配置优化总结

1. 加快服务发现速度

   > 三级缓存，关闭 ReadOnlyCache
   >
   > 降低服务拉取和心跳的时间间隔

2. 加快服务过期剔除速度

   > 降低服务过期剔除的时间间隔

3. 自我保护

   > 根据业务情况进行修改

4. 避免无效集群

   > eureka server 集群最多配 3 个，超过 3 个就没有用了

5. server 之间分担压力

   > eureka server 的 url 要乱序配置，防止第一个 server 压力过大

### Eureka-Server 配置优化

```yaml
eureka:
  server:
    # 自我保护根据服务数量和网络情况选择性是否开启
    enable-self-preservation: false
    # 自我保护阈值
    renewal-percent-threshold: 0.85
    # 剔除服务时间间隔
    eviction-interval-timer-in-ms: 1000
    # 关闭 ReadOnlyCache
    use-read-only-response-cache: false
    # ReadOnlyCache 和 ReadWriteCache 同步时间间隔
    response-cache-update-interval-ms: 1000
# 生产中的问题：
1. 优化目的：减少服务上下线的延时
2. 自我保护的选择：根据服务数量和网络情况
3. 服务更新：先停止服务，再发送下线请求
```

### Eureka-Client 配置优化

```yaml
client:
  # 拉取注册表的时间间隔，默认 30 秒
  registry-fetch-interval-seconds: 30
  service-url:
    # 多个 server 的时候，要打乱顺序，防止都注册到第一个注册中心，或者都从第一个注册中心进行注册表的拉取
    # 此处如果配置多个，eureka 会按顺序进行注册，只要注册成功后，就不会向后面的进行注册了，而且最多配置三个即可，因为 RetryableEurekaHttpClient 中设置了只会重复注册 3 次 DEFAULT_NUMBER_OF_RETRIES = 3;
      # 如果配置多个，eureka 拉取注册表的时候会按顺序进行拉取，只要拉取成功，就不会从后面的进行拉取了，而且最多配置三个即可
      # 所以微服务进行配置的时候，要把这里的顺序进行打乱，防止 client 都从同一个 server 注册和拉取
    defaultZone: http://eureka-7900:7900/eureka/
instance:
  # 心跳/续约时间间隔，默认 30 秒
  lease-renewal-interval-in-seconds: 30
ribbon:
  # 启动饥饿加载
  eager-load:
    enabled: true
    clients: demo
```

## 其他点

### 区域配置

对服务进行分区，不同区域的客户端请求优先被在相同区域的服务端进行处理，可以减少网络延迟。当所在区服务故障的时候，可以自动切换到其他可用区来处理请求。

#### 1. EurekaServer 配置

```yaml
spring:
  application:
    # 相同的服务，服务名相同
    name: cloud-eureka
eureka:
  client:
    # 向注册中心注册自己
    register-with-eureka: true
    # 拉取注册表信息
    fetch-registry: false
    # 地区设置
    region: bj
    # 配置每个 zone 的注册中心地址
    service-url:
      # 设置 z1 区中的两个 Eureka Server
      z1: http://cloud-eureka-bjz11:7911/eureka/,http://cloud-eureka-bjz12:7912/eureka/
      # 设置 z2 区中的两个 Eureka Server
      z2: http://cloud-eureka-bjz21:7921/eureka/,http://cloud-eureka-bjz22:7922/eureka/
---
spring:
  profiles: 7911
server:
  port: 7911
eureka:
  client:
    availability-zones:
      # 设置 region 内的可用 zone，此处注意“,”号后面不能有空格，源码按“,”进行切割后并没有去空格
      # 此处设置后，z1 和 z2 中的 4 个 Eureka Server 都是互为 peer 的
      bj: z1,z2
  instance:
    hostname: cloud-eureka-bjz11
---
spring:
  profiles: 7912
server:
  port: 7912
eureka:
  client:
    availability-zones:
      # 设置 region 内的可用 zone，此处注意“,”号后面不能有空格，源码按“,”进行切割后并没有去空格
      # 此处设置后，z1 和 z2 中的 4 个 Eureka Server 都是互为 peer 的
      bj: z1,z2
  instance:
    hostname: cloud-eureka-bjz12
---
spring:
  profiles: 7921
server:
  port: 7921
eureka:
  client:
    availability-zones:
      # 设置 region 内的可用 zone，此处注意“,”号后面不能有空格，源码按“,”进行切割后并没有去空格
      # 此处设置后，z1 和 z2 中的 4 个 Eureka Server 都是互为 peer 的
      bj: z2,z1
  instance:
    hostname: cloud-eureka-bjz21
---
spring:
  profiles: 7922
server:
  port: 7922
eureka:
  client:
    availability-zones:
      # 设置 region 内的可用 zone，此处注意“,”号后面不能有空格，源码按“,”进行切割后并没有去空格
      # 此处设置后，z1 和 z2 中的 4 个 Eureka Server 都是互为 peer 的
      bj: z2,z1
  instance:
    hostname: cloud-eureka-bjz22
```

#### 2. Eureka Client 服务提供者配置

```yaml
spring:
  application:
    name: api-provider
eureka:
  client:
    register-with-eureka: true
    fetch-registry: true
    # 设置地区
    region: bj
    service-url:
      # eureka server 的 url
      z1: http://cloud-eureka-bjz11:7911/eureka/,http://cloud-eureka-bjz12:7912/eureka/
      z2: http://cloud-eureka-bjz21:7921/eureka/,http://cloud-eureka-bjz22:7922/eureka/
    # 设置优先使用相同区域的服务
    prefer-same-zone-eureka: true
---
spring:
  profiles: 9091
eureka:
  client: 
    availability-zones:
      # 设置可用区，z1 在前，优先将该服务向 z1 的注册中心注册，向 z1 注册失败才会向 z2 注册
      bj: z1,z2
  instance:
  metadata-map:
  # 标记当前服务的区域是 z1，调用方可以获取到该信息
  zone: z1
  hostname: localhost
zone:
  name: bjz1
---
spring:
  profiles: 9092
eureka:
  client: 
    availability-zones:
      # 设置可用区，z2 在前，优先将该服务向 z2 的注册中心注册，向 z2 注册失败才会向 z1 注册
      bj: z2,z1
  instance:
  metadata-map:
  # 标记当前服务的区域是 z1，调用方可以获取到该信息
  zone: z2
  hostname: localhost
zone:
  name: bjz2
```

测试代码

```java
@RestController
public class ProviderController {

    @Value("${zone.name}")
    private String zoneName;

    @GetMapping("zoneName")
    public String getZoneName() {
        return zoneName;
    }
}
```

#### 3. Eureka Client 服务消费者配置

```yaml
spring:
  application:
    name: api-consumer
server:
  port: 8081
eureka:
  client:
    register-with-eureka: true
    fetch-registry: true
    region: bj
    availability-zones:
      # 拉取注册表时，也是先从 z1 拉取，z1 拉取失败才从 z2 拉取
      bj: z1,z2
    service-url:
      z1: http://cloud-eureka-bjz11:7911/eureka/, http://cloud-eureka-bjz12:7912/eureka/
      z2: http://cloud-eureka-bjz21:7921/eureka/, http://cloud-eureka-bjz22:7922/eureka/
    # 设置优先使用相同区域的服务
    prefer-same-zone-eureka: true
  instance:
    hostname: localhost
```

测试代码

```java
@Configuration
@RestController
public class ConsumerController {

    @Bean
    @LoadBalanced
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }

    @Autowired
    private RestTemplate restTemplate;

    @GetMapping("test")
    public String test() {
        return restTemplate.getForObject("http://api-provider/zoneName", String.class);
    }
}
```

#### 4. DashBoard 效果

![image-20201229223616805](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2020/20201229223619.png)
