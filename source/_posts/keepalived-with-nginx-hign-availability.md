---
title: Keepalived+Nginx高可用
date: '2019-12-19 00:00:00'
updated: '2019-12-19 00:00:00'
tags:
- Keepalived
- Nginx
categories:
- Keepalived
---
# Keepalived+Nginx高可用

## 简介

### keepalived介绍

[官方说明](https://www.keepalived.org/)

Keepalived是C语言编写的路由软件. 该项目的主要目标是为Linux系统(和基于Linux的基础结构的系统)的负载均衡和高可用提供简单和健壮的设施. 负载均衡框架依赖知名并被广泛应用的[Linux Virtual Server(IPVS)](http://www.linux-vs.org/)核心模块, 提供第4层的负载均衡. Keepalived实现了一组检查器, 根据服务器的健康状态, 自适应维护和管理负载均衡服务池. 另一方面, 通过[VRRP](https://datatracker.ietf.org/wg/vrrp/documents/)协议实现高可用. VRRP是路由故障转移的根本. 另外, Keepalived实现了一组搭载了VRRP的有限状态机, 提供低级别和高速的协议交互. 为了提供快速的网络故障发现能力, Keepalived实现了[BFD](datatracker.ietf.org/wg/bfd/)协议. VRRP状态转换可以根据BFD的提示加快状态转换. Keepalived框架可以独立使用也可以多个一起使用, 以提供弹性基础架构.

### 双机高可用的两种方法

- **Nginx+keepalived 双机 主从 模式**：即前端使用两台服务器，一台主服务器和一台热备服务器，正常情况下，主服务器绑定一个公网虚拟IP，提供负载均衡服务，热备服务器处于空闲状态；当主服务器发生故障时，热备服务器接管主服务器的公网虚拟IP，提供负载均衡服务；但是热备服务器在主机器不出现故障的时候，永远处于浪费状态，对于服务器不多的网站，该方案不经济实惠。

- **Nginx+keepalived 双机 主主 模式：** 即前端使用两台负载均衡服务器，互为主备，且都处于活动状态，同时各自绑定一个公网虚拟IP，提供负载均衡服务；当其中一台发生故障时，另一台接管发生故障服务器的公网虚拟IP（这时由非故障机器一台负担所有的请求）。这种方案，经济实惠，非常适合于当前架构环境。

## 架构及说明

### Nginx+Keepalived 双机 主从模式

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142951.png)

设备 | IP | 说明
--- | --- | --- 
master主机 | 192.168.64.129 | master机器, CentOS7.6_X64
backup主机 | 192.168.64.130 | backup机器, CentOS7.6_X64
VIP | 192.168.64.128 | 虚拟IP(飘移IP)

VIP是一个对外提供访问的虚拟IP, 可自定义, 不需要提供真实机器

## Keepalived及Nginx安装

### 安装依赖

此处防止出错, 将官方展示的依赖包全部安装

```bash
yum install -y make autoconf automake openssl-devel libnl3-devel ipset-devel iptables-devel file-devel net-snmp-devel glib2-devel json-c-devel pcre2-devel libnftnl-devel libmnl-devel python-sphinx epel-release python-sphinx_rtd_theme latexmk texlive texlive-titlesec texlive-framed texlive-threeparttable texlive-wrapfig texlive-multirow
```

### 下载源码压缩包

```bash
wget https://www.keepalived.org/software/keepalived-2.0.19.tar.gz
wget https://nginx.org/download/nginx-1.9.9.tar.gz
```

### 安装Keepalived

[Keepalived官方安装说明](https://github.com/acassen/keepalived/blob/master/INSTALL)

keepalived默认安装位置/usr/local/keepalived

```bash
$ tar -zxvf keepalived-2.0.19.tar.gz
$ cd keepalived-2.0.19
$ ./configure
$ make
$ make install
```

### 安装nginx

[Nginx官方安装说明](http://nginx.org/en/docs/configure.html)

nginx默认安装位置/usr/local/nginx

```bash
$ tar -zxvf nginx-1.9.9.tar.gz
$ cd nginx-1.9.9
$ ./configure
$ make
$ make install
```

### 配置Nginx

Nginx默认配置文件位置: /usr/local/nginx/conf/nginx.conf

以下仅提供最基本的测试配置

```nginx
# 需指定运行nginx的用户, 默认是nobody
user root;

# 指定工作进程的数量
worker_processes  1;

events {
    worker_connections  1024;
}

http {
    # 定义upstream实现负载均衡, 可省略
    #upstream upstream-name {
        #server xx.xx.xx.xx:8000;
        #server xx.xx.xx.xx:port;
    #}
    server {
        # 指定nginx监听主机的80端口
        listen 80;
    
        # 拦截/test开头的请求, eg. http://localhost:80/test/test.json
        location /test {
          # 示例请求会返回主机的/root/test目录查找test.json文件
          root /root;
        }
    
        # 拦截所有请求, 将请求路由到upstream中定义的服务器上
        #location / {
          #proxy_pass http://upstream-name;
          # 反向代理不改变请求头的信息
          #proxy_set_header Host $http_host;
        #}
    }
}
```
在/root目录下创建/test/test.json文件, 内容可以为各自主机的地址, 用于测试主机keepalived关闭后, VIP是否会飘移到备用主机.

```json
129机器的test.json
{
    "message" : "This Is Master-129"
}

130备用机器的test.json
{
    "message" : "This Is Backup-130"
}
```
nginx启动命令默认在如下位置， 启动nginx
```bash
/usr/local/nginx/sbin/nginx
```

此时访问http://192.168.64.129:80/test/test.json会返回```{"message" : "This Is Master-129}"```, 访问http://192.168.64.130:80/test/test.json会返回```{"message" : "This Is Backup-130"}```

### 配置Keepalived

keepalived默认的配置文件放在/usr/local/etc/keepalived/keepalived.conf, 需要将配置文件放在/etc/keepalived/keepalived.conf才可以成功启动/关闭keepalived服务, 可将如下的配置文件直接放在/etc/keepalived目录下

#### master-129主机的配置

由于未部署sendmail, 已将相关配置注释, 如需部署可参考[linux下sendmail邮件系统安装操作记录](https://www.cnblogs.com/kevingrace/p/6143977.html)

```keepalived
! Configuration File for keepalived          #全局定义

global_defs {
   #notification_email {   #指定keepalived在发生事件时(比如切换)发送通知邮件的邮箱
   #  xiaochong@then.com   #设置报警邮件地址，可以设置多个，每行一个。 需开启本机的sendmail服务
   #}
   #notification_email_from xiaochong@then.com  #keepalived在发生诸如切换操作时需要发送email通知地址
   #smtp_server 127.0.0.1                        #指定发送email的smtp服务器
   #smtp_connect_timeout 30                      #设置连接smtp server的超时时间
   router_id HAmaster-129   #运行keepalived的机器的一个标识，通常可设为hostname。故障发生时，发邮件时显示在邮件主题中的信息。
}

vrrp_script chk_http_port {      #检测nginx服务是否在运行。有很多方式，比如进程，用脚本检测等等
    script "/root/software/chk_nginx.sh"   #这里通过脚本监测
    interval 2                   #脚本执行间隔，每2s检测一次
    weight -5                    #脚本结果导致的优先级变更，检测失败（脚本返回非0）则优先级 -5
    fall 2                    #检测连续2次失败才算确定是真失败。会用weight减少优先级（1-255之间）
    rise 1                    #检测1次成功就算成功。但不修改优先级
}

vrrp_instance VI_1 {    #keepalived在同一virtual_router_id中priority（0-255）最大的会成为master，也就是接管VIP，当priority最大的主机发生故障后次priority将会接管
    state MASTER    #指定keepalived的角色，MASTER表示此主机是主服务器，BACKUP表示此主机是备用服务器。注意这里的state指定instance(Initial)的初始状态，就是说在配置好后，这台服务器的初始状态就是这里指定的，但这里指定的不算，还是得要通过竞选通过优先级来确定。如果这里设置为MASTER，但如若他的优先级不及另外一台，那么这台在发送通告时，会发送自己的优先级，另外一台发现优先级不如自己的高，那么他会就回抢占为MASTER
    interface ens33          #指定HA监测网络的接口。实例绑定的网卡，因为在配置虚拟IP的时候必须是在已有的网卡上添加的
    mcast_src_ip 192.168.64.129  # 发送多播数据包时的源IP地址，这里注意了，这里实际上就是在哪个地址上发送VRRP通告，这个非常重要，一定要选择稳定的网卡端口来发送，这里相当于heartbeat的心跳端口，如果没有设置那么就用默认的绑定的网卡的IP，也就是interface指定的IP地址
    virtual_router_id 51         #虚拟路由标识，这个标识是一个数字，同一个vrrp实例使用唯一的标识。即同一vrrp_instance下，MASTER和BACKUP必须是一致的
    priority 101                 #定义优先级，数字越大，优先级越高，在同一个vrrp_instance下，MASTER的优先级必须大于BACKUP的优先级
    advert_int 1                 #设定MASTER与BACKUP负载均衡器之间同步检查的时间间隔，单位是秒
    authentication {             #设置验证类型和密码。主从必须一样
        auth_type PASS           #设置vrrp验证类型，主要有PASS和AH两种
        auth_pass 1111           #设置vrrp验证密码，在同一个vrrp_instance下，MASTER与BACKUP必须使用相同的密码才能正常通信
    }
    virtual_ipaddress {          #VRRP HA 虚拟地址 如果有多个VIP，继续换行填写
        192.168.64.128
    }

	track_script {                      #执行监控的服务。注意这个设置不能紧挨着写在vrrp_script配置块的后面（实验中碰过的坑），否则nginx监控失效!!
    chk_http_port                    #引用VRRP脚本，即在 vrrp_script 部分指定的名字。定期运行它们来改变优先级，并最终引发主备切换。
	}
}

```

#### backup-130备用主机的配置

```keepalived
! Configuration File for keepalived    

global_defs {
	#notification_email {                
	#	xiaochong@then.com                     
	#	10997173638883@qq.com
	#}

	#notification_email_from xiaochong@then.com  
	#smtp_server 127.0.0.1                    
	#smtp_connect_timeout 30                 
	router_id HAbackup-130                    
}

vrrp_script chk_http_port {         
    script "/root/software/chk_nginx.sh"
    interval 2
    weight -5
    fall 2                   
    rise 1                  
}

vrrp_instance VI_1 {            
    state BACKUP           
    interface ens33            
    mcast_src_ip 192.168.64.130  
    virtual_router_id 51        
    priority 99               
    advert_int 1               
    authentication {            
        auth_type PASS         
        auth_pass 1111          
    }
    virtual_ipaddress {        
        192.168.64.128
    }

    track_script {                     
        chk_http_port                 
    }

}
```

### 测试

经过前面的配置, 如果master主服务器的keepalived停止服务, backup备用服务器会自动接管VIP对外服务; 一旦master主服务器的keepalived恢复, 会重新接管VIP.

**1. 分别启动主备服务器上的keepalived和nginx**

```bash
systemctl start keepalived
/nginx/path/sbin/nginx -c /nginx/path/conf/nginx.conf
```


**2. 使用```ip addr```命令, 查看master主服务器的网卡信息, 发现ens33中包含VIP的信息**

```bash
[root@localhost keepalived]# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 00:0c:29:0d:99:c1 brd ff:ff:ff:ff:ff:ff
    inet 192.168.64.129/24 brd 192.168.64.255 scope global noprefixroute dynamic ens33
       valid_lft 1738sec preferred_lft 1738sec
    inet 192.168.64.128/32 scope global ens33
       valid_lft forever preferred_lft forever
    inet6 fe80::ec49:90d1:6713:bc21/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
```

**3. 使用```ip addr```命令, 查看backup备用服务器的网卡信息, ens33网卡中不包含VIP的信息**
```bash
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 00:0c:29:e2:e8:ec brd ff:ff:ff:ff:ff:ff
    inet 192.168.64.130/24 brd 192.168.64.255 scope global noprefixroute dynamic ens33
       valid_lft 1654sec preferred_lft 1654sec
    inet6 fe80::a458:734d:1f98:9472/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
```

**4. 测试访问http://192.168.64.128:80/test/test.json, 返回**

```json
{
    "message" : "This Is Master-129."
}
```

请求被主服务器master处理

**5. 关闭master主服务器的keepalived服务, 使用```ip addr```再次查看, 已不存在VIP**

```bash
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 00:0c:29:0d:99:c1 brd ff:ff:ff:ff:ff:ff
    inet 192.168.64.129/24 brd 192.168.64.255 scope global noprefixroute dynamic ens33
       valid_lft 1521sec preferred_lft 1521sec
    inet6 fe80::ec49:90d1:6713:bc21/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
```

**6. 使用```ip addr```查看backup备用服务器, VIP已经飘移到该服务器**

```bash
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 00:0c:29:e2:e8:ec brd ff:ff:ff:ff:ff:ff
    inet 192.168.64.130/24 brd 192.168.64.255 scope global noprefixroute dynamic ens33
       valid_lft 1463sec preferred_lft 1463sec
    inet 192.168.64.128/32 scope global ens33
       valid_lft forever preferred_lft forever
    inet6 fe80::a458:734d:1f98:9472/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
```

**7. 测试访问http://192.168.64.128:80/test/test.json, 返回**

```json
{
    "message" : "This Is Backup-130."
}
```

请求已被备用服务器backup接管

## 使用keepalived监控nginx状态

以上已完成基本的keepalived+nginx的配置和测试, 为保证系统稳定性, 我们需要**当Nginx服务停止后, Keepalived可以自动启动Nginx服务, 如果启动失败, 则将keepalived也停止, 将请求交由其他备用服务器处理.**

**keepalived支持配置监控脚本, 可以通过脚本监控Nginx服务的状态.**

**监控Nginx状态的三种方式 :**
- 最简单的做法是**监控Nginx进程**
- 更靠谱的做法是**检查Nginx端口**
- 最靠谱的做方法是**检查多个url能否获取到页面**


keepalived配置文件的vrrp_script chk_http_port中的script一般有两种写法, 分别对应监控进程和监控端口, 当前使用的配置方式是监控端口的方式, 可以直接查看监控端口的方式

## 监控进程的方式

keepalived通过脚本执行的返回结果, 改变vrrp_instance的优先级(priority), 然后继续发送通告消息, backup比较优先级再决定是否抢占IP.

```bash
需要安装psmisc软件包, 并将配置文件中的
script "/root/software/chk_nginx.sh"
修改为
script "killall -0 nginx"
如果nginx进程存在返回0, 否则返回1
```

优先级的改变策略
```
如果脚本执行结果为0，并且weight配置的值大于0，则优先级相应的增加
如果脚本执行结果非0，并且weight配置的值小于0，则优先级相应的减少
其他情况，原本配置的优先级不变，即配置文件中priority对应的值。
```

优先级的范围在[1,254], 不会一直升高或减小, 可以编写多个检测脚本并为每个检测脚本设置不同的weight(在配置中列出就行) 


在MASTER节点的 vrrp_instance 中 配置 nopreempt, 当它异常恢复后, 即使它 priority更高也不会抢占，这样可以避免正常情况下做无谓的切换.


## 监控端口的方式

手动在脚本里面检测是否有异常情况, 如果有直接关闭keepalived进程, backup机器接收不到advertisement则会抢占IP.

脚本文件chk_nginx.sh如下, 需要修改启动nginx和停止keepalived的代码 :
```bash
counter=$(ps -C nginx --no-heading|wc -l)
echo "current nginx : $counter"
if [ "${counter}" = "0" ]; then
    /nginx/path/sbin/nginx -c /nginx/path/conf/nginx.conf
    sleep 2
    counter=$(ps -C nginx --no-heading|wc -l)
    echo "after start nginx : $counter"
    if [ "${counter}" = "0" ]; then
        systemctl stop keepalived
    fi
fi
```

修改脚本文件权限
```shell
$ chmod 755 chk_nginx.sh
```

该脚本检查nginx服务是否存在(counter>0), 如果不存在(counter=0)启动之, 并在2秒后重新检查, 如果启动失败, 则停止keepalived服务, 此时备用服务器将抢占VIP.


## 检测keepalived是否会启动nginx

关闭nginx, 会发现最多2s后, nginx就会重新启动

## 双机 双主模式

只需修改配置文件即可, 增加新的VIP:192.168.64.127, 192.168.64.128是129机器上朱虚拟VIP, 192.168.64.127是130机器上主虚拟VIP

129的keepalived配置文件, 在最后一行添加
```keepalived
vrrp_instance VI_2 {
    state BACKUP
    interface ens33
    virtual_router_id 52
    priority 90
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        192.168.139.127
    }
}
```

130的keepalived配置文件, 在最后一行添加
```keepalived
vrrp_instance VI_2 {
    state MASTER
    interface ens33
    virtual_router_id 52
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        192.168.139.127
    }
}
```

## 参考文档
[Nginx+keepalived 高可用双机热备(主从模式/双主模式)](https://blog.csdn.net/u012599988/article/details/82152224)
