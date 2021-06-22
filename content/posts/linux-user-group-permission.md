---
title: 用户, 组和权限
date: '2020-01-04 22:26:57'
tags:
- Linux
categories:
- Linux
- 阿里云Linux运维学习路线
- 阶段一:Linux入门
---

# 用户, 组和权限

## 本章内容

- 解释Linux的安全模型
- 解释用户帐号和组群帐号的目的
- 用户和组管理命令
- 理解并设置文件权限
- 默认权限
- 特殊权限
- ACL


## 介绍安全3A
- 资源分派:
    - Authentication: 认证
    - Authorization: 授权
    - Accounting|Audition: 审计

## 用户user

- 令牌token, identity
- Linux用户: Username/UID
- 管理员: root, 0
- 普通用户: 1-60000 自动分配
    - 系统用户: 1-499, 1-999(CentOS7)
      
        > 对守护进程获取资源进行权限分配
        
    - 登录用户: 500+, 1000+(CentOS7)
    
        > 交互式登录

## 组group
- Linux组: Groupname/GID
- 管理员组: root, 0
- 普通组: 
    - 系统组: 1-499, 1-999(CentOS7)
    - 普通组: 500+, 1000+(CentOS7)


- **在Linux中用户名和组名可以同名, 用户ID和组ID也可以相同**
- **一个用户可以属于多个组, 一个组也可以包含多个用户**
- **属于多个组的帐号, 获得的权限是多个组权限的累加**


> Windows查看用户组: `net localgroup`  
> Windows查看用户帐号: `net user`  
> 在Windows中用户名和组名不能同名

## 安全上下文

- Linux安全上下文
    - 运行中的程序: 进程(process)
    - 以进程发起者的身份运行:
        - root:/bin/cat
        - mage:/bin/cat
    
    进程所能够访问资源的权限取决于进程的运行者的身份

## 组的类别

- Linux组的类别
    - 用户的主要组(primary group)
        - 用户必须属于一个且只有一个主组
        - 组名同用户名, 且仅包含一个用户, 私有组
    - 用户的附加组(supplementary group)
        - 一个用户可以属于零个或多个辅助组

**当创建新用户时, 会自动创建一个与用户名同名的组, 作为该用户的主要组**

> Windows中创建新用户时, 会默认将用户添加到users组中, 不会创建新组

使用 `id 用户名` 查看该用户的uid, gid, groups

## 用户和组的配置文件

Linux用户和组的配置文件

- **/etc/passwd :** 用户及其属性信息(名称, UID, 主组ID等)
    ```bash
    root:x:0:0:root:/root:/bin/bash
    bin:x:1:1:bin:/bin:/sbin/nologin
    ...
    wang:x:1000:1000::/home/wang:/bin/bash
    
    格式:
    username:password:UID:GID:GECOS:directory:shell
    用户名:密码:用户ID:主组ID:用户描述:家目录:
    
    修改用户描述可以使用`chfn 用户名`, 使用`finger 用户名`查看, 使用`chfn -f '' -o '' -p '' -h '' 用户名`清空用户描述
    
    使用`usermod`可以修改用户的各种属性, 例如家目录等
    
    如果shell为nologin, 说明该用户不能登录, 使用`chsh /sbin/nologin 用户名`修改用户shell为/sbin/nologin
    
    可以使用`getent passwd [用户名1] [用户名2] [用户名...]`来查看所有或指定用户名的信息, 类似于`cat /etc/passwd`
    ```
    可通过修改该文件中的UID来更改用户的权限, **如果没有UID为0的用户, 系统启动时会卡住**, 可通过如下方式解决:
    
    > 在如下页面
    > ![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210607235726.png)</br>
    > 根据提示输入<kbd>e</kbd>, 在linux16的后方添加`init=/bin/bash`
    > ![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210607235727.png)</br>
    > 按<kbd>Ctrl</kbd> + <kbd>x</kbd>启动
    > 此时可以进入命令行模式
    > 使用`mount -o rw.remount /`将根目录重新挂载为可读可写模式
    > 修改/etc/passwd文件, <kbd>Ctrl</kbd>+<kbd>x</kbd>保存, `reboot`重启即可

- **/etc/group :** 组及其属性信息
    ```bash
    root:x:0:
    bin:x:1:
    ...
    wang:x:1000:
    
    格式:
    组名称:组密码:组ID:组成员
    
    
    管理员将指定用户添加到指定组中 `groupmems -a 用户名 -g 组名`
    管理员将指定用户从指定组中删除 `groupmems -d 用户名 -g 组名`
    
    普通用户使用`newgrp 组名`将本用户添加到指定组, 并临时将指定组作为该用户的主组, 此时需要使用到组密码
    
    管理员使用`gpasswd 组名`给指定组添加密码
    
    管理员将某个用户添加到指定组后, 该用户如果正在使用, 则需要重新登录才能显示已在该组中, 因为用户是在登录时获取令牌的.
    
    清空指定组的口令`gpasswd -r 组名`
    ```
- **/etc/shadow :** 用户密码及其相关属性
    ```bash
    root:$6$5bHCOKlltInipu7D$NmY1mZI3MAGIAznrPa6yqmzLVuTWr2od0PSDWCg4zGtdFd4xJEYeypkv2JtLBbnquig1b1RC9Lk5hetNP5N1r/::0:99999:7:::
    
    格式:
    login name:encrypted password:date of last password change:minimum password age:maximum password age:password warning period:password inactivity period:account expiration date:reserved field
    用户名:加密后的密码:最后一次修改密码距离1970/01/01的天数:密码在过几天可以被变更:密码再过几天必须被变更:密码过期前几天系统提醒用户:密码过期几天后帐号被锁定:帐号有效期:预留字段
    
    加密后的密码: $6$5bHCOKlltInipu7D$NmY1mZI3MAGIAznrPa6yqmzLVuTWr2od0PSDWCg4zGtdFd4xJEYeypkv2JtLBbnquig1b1RC9Lk5hetNP5N1r/
    
    其中$6代表使用sha512的加密算法加密, $1代表使用md5加密算法加密
    
    可以使用`grub-md5-crypt`来获取使用md5加密后的字符串
    
    `getent shadow [用户名1] [用户名2] [用户名...]`来查看指定用户的口令信息
    
    Windows使用`net accounts`可以查看密码有效期等信息
    ```
    **使用`chage 用户名`来修改用户口令的信息, 直接编辑文件不安全, 使用`chage -d0 用户名`, 使得该用户下次登录必须立即更改口令**
    
- **/etc/gshadow :** 组密码及其相关属性
    ```bash
    root:::
    bin:::
    ...
    wang:!::
    
    格式:
    组名:加密后的组密码:当前组的管理员:组成员
    ```

使用`pwunconv`可以将口令(密码)放回到/etc/passwd中, `pwconv`将口令还原到/etc/shadow中.

`!`代表禁用/锁定, 相当于没有密码

可以使用`getent`来查看passwd, shadow, group, gshadow中的内容.


## 密码加密

当前使用的加密算法信息保存在**/etc/login.defs**文件中

- **加密机制**
    - 加密: 明文 --> 密文
    - 解密: 密文 --> 明文
- **单向加密 :** 哈希算法, 原文不同, 密文必不同
    - 相同算法定长输出, 获得密文不可逆推出原始数据
    - 雪崩效应: 初始条件的微小改变, 引起结果的巨大改变
        - md5: message digest, 128bit
        - sha1: secure hash algorithm, 160bit
        - sha224: 224bit
        - sha256: 256bit
        - sha384: 384bit
        - sha512: 512bit
- **更改加密算法 :**
    ```bash
    authconfig --passalgo=sha256 --update
    ```
    只会对以后添加的用户生效, 对之前的用户不产生影响.
## 密码的复杂性策略

- 使用数字, 大写字母, 小写字母及特殊字符中至少3种
- 足够长
- 使用随机密码
- 定期更换, 不要使用最近曾经使用过得密码

使用`openssl rand -base64 12`生成随机密码

## 文件操作
使用工具来对用户和组进行修改

- **vipw和vigr**
    - vipw : 相当于 vi /etc/pwsswd
    - vigr : 相当于 vi /etc/group

- **pwck和grpck**
    - pwck : passwd checked 检查/etc/passwd的文件格式是否正确
    - grpck : group checked 检查/etc/group文件格式是否正确

## 用户和组的管理命令

### 用户管理命令

**/ect/login.defs**文件中存储着新建用户的默认配置信息等.

#### useradd

默认值设定在/etc/default/useradd文件中
```
# useradd defaults file
GROUP=100   # 默认组ID
HOME=/home  # 默认家目录
INACTIVE=-1 # 如果口令过期, 是否锁定帐号
EXPIRE= # 锁定有效期
SHELL=/bin/bash # 默认shell类型
SKEL=/etc/skel  # 用户家目录的模板文件夹
CREATE_MAIL_SPOOL=yes   #
```
- 显示默认设置`useradd -D`
- 修改默认配置
    - `useradd -D -s SHELL`
    - `useradd -D -b BASE_DIR`
    - `useradd -D -g GROUP`

创建新用户`useradd [OPTIONS] 用户名`
- `-u UID` : 指定UID
- `-o` : 配合`-u`选项, 忽略UID唯一性检查, UID相同, 权限相同
- `-d HOME_DIR` : 指定家目录, 会自动创建
- `-r` : 创建系统用户(CentOS7中UID小于1000), 不会创建家目录
- `-s SHELL` : 指定shell类型, 系统用户建议设置为/sbin/nologin
- `-c "COMMENT"` : 添加描述
- `-g GID` : 指定主组, 不创建同名组
- `-G GROUP1[,GROUP2,...]` : 指定附加组
- `-N` : 将users设置为新用户的主组
- `-m` : 创建家目录, 用于系统用户
- `-M` : 不创建家目录, 用于非系统用户


将shell类型设置为`/sbin/nologin`, 该用户不可登录也不能通过`su 用户名`切换, 如果只指定-r选项, 不指定-s为`/sbin/nologin`, 则可以通过`su`命令切换到该用户.

`groups 用户名`查看用户所属的所有组, 第一个为主组

**练习**

1. 创建用户gentoo, 附加组为bin和root, 默认shell为/bin/csh, 注释信息为"Gentoo Distribution"

   ```bash
   useradd -G bin,root -s /bin/csh -c "Gentoo Distribution" gentoo
   ```

2. 创建下面的用户, 组和组成员关系
    - 名字为webs的组
        ```bash
        groupadd webs
        ```
        
    - 用户nginx使用webs作为附属组
        ```bash
        useradd -G webs nginx
        ```
        
    - 用户varnish, 也使用webs作为附属组
        ```bash
        useradd -G webs varnish
        ```
        
    - 用户mysql, 不可交互登录系统, 且不是webs的成员, nginx, varnish, mysql密码都是123456

        ```bash
        useradd -s /sbin/nologin mysql
        echo 123456 | passwd --stdin nginx
        echo 123456 | passwd --stdin varnish
        echo 123456 | passwd --stdin mysql
        ```

**新建用户的相关文件和命令**

- /etc/default/useradd
- /etc/skel/*
- /etc/login.defs
- `newusers` 与`passwd`格式相同的文件 : 批量创建用户
- `chpasswd` : 批量修改用户口令

```bash
# chpasswd
user1:password1
user2:password2

或

# echo user1:password1 | chpasswd

或

在文本文件(例如 : file)中存储如下格式的内容
user1:password1
user2:password2

# cat file | chpasswd
```

#### usermod

修改用户属性`usermod [OPTION]` 用户名
- `-u UID` : 新UID
- `-g GID` : 新GID
- `-G GROUP1[,GROUP2,...]` : 新附加组, 原来的附加组将会被覆盖; 若保留原有, 则需要同时使用`-a`选项
- `-s SHELL` : 新的默认SHELL
- `-c "COMMENT"` : 新的注释信息
- `-d HOME` : 新家目录不会自动创建; 若要创建新家目录并移动原家数据, 同时使用-m选项
- `-l login_name` : 修改用户登录名
- `-L` : 锁定指定用户, 在/etc/shadow密码栏增加!
- `-U` : 解锁指定用户, 将/etc/shadow密码栏的!拿掉
- `-e YYYY-MM-DD` : 指明用户帐号过期日期
- `-f INACTIVE` : 设定非活动期限

清空附加组
```bash
usermod -G "" 用户名
或
usermod -G 用户主组 用户名
```

密码处的`!!`代表锁定, redhat5版本之前可以使用`usermod -U`将用户密码解锁, 如果用户密码为空, 则不使用密码即可登录系统.

#### userdel

删除用户`userdel [OPTION]...` 用户名
- `-r` : 删除用户相关文件
  
    ```bash
    例如 :
    家目录 : /home/用户名
    邮箱目录: /var/spool/mail/用户名
    ```

### 组帐号维护命令

#### groupadd

创建组 : `groupadd [OPTION]... group_name`
- `-g GID` :指明GID号; [GID_MIN,GID_MAX]
- `-r` : 创建系统组
  
    > CentOS6 : GID<500  
    > CentOS7 : GID<1000

#### groupmod

组属性修改: `groupmod [OPTION]... group`
- `-n group_name` : 新名字
- `-g GID` : 新的GID

#### groupdel

删除组 : `groupdel GROUP`

**主组不能被删除**

## 查看用户相关的ID信息

`id [OPTION]... [USER]`
- `-u` : 显示UID
- `-g` : 显示GID
- `-G` : 显示用户所属的组的ID
- `-n` : 显示名称, 需配合ugG使用

## 切换用户或以其他用户身份执行命令

`su` : switch user

- 命令: 
    ```bash
    su [OPTIONS...] [-] [user [agrs...]]
    ```
- 切换用户的方式
    - `su UserName` : 非登录式切换, 即不会读取目标用户的配置文件, 不改变当前工作目录
    - `su - UserName` : 登录式切换, 会读取目标用户的配置文件, 切换至家目录, 完全切换
- root `su`至其他用户无须密码; 非root用户切换时需要密码
- 换个身份执行命令
    ```bash
    su [-] UserName -c 'COMMAND'
    ```
- 选项 : `-l --login`
    ```    bash
    su -l UserName 相当于 su - UserName
    ```
## 设置密码

修改指定用户的密码 : `passwd [OPTION] UserName`
- `-d` : 删除指定用户密码
- `-l` : 锁定指定用户
- `-u` : 解锁指定用户
- `-e` : 强制用户下次登录修改密码
- `-f` : 强制操作
- `-n mindays` : 指定最短使用期限
- `-x maxdays` : 指定最大使用期限
- `-w warndays` : 提前多少天开始警告
- `-i inactivedays` : 非活动期限
- `--stdin` : 从标准输入接收用户密码
    ```bash
    echo "PASSWORD" | passwd --stdin USERNAME
    ```
## 修改用户密码策略
命令 : `chage [OPTION]... 用户名`
- `-d LAST_DAY`
- `-E --expiredate EXPIRE_DATE`
- `-I --inactive INACTIVE`
- `-m --mindays MIN_DAYS`
- `-M --maxdays MAX_DAYS`
- `-W --warndays WARN_DAYS`
- `-l` 显示密码策略

示例 :
```bash
chage -d 0 tom 下次登录强制重设密码
chage -m 0 -M 42 -W 14 -l 7 tom
chage -E 2016-09-10 tom
```

## 用户相关的其他命令
- `chfn`指定个人信息
- `chsh`指定shell
- `finger`查看个人信息

## 更改组密码

组密码 : `gpasswd [OPTION] GROUP`
- `-a user` : 将user添加到指定组中
- `-d user` : 从指定组中移除用户user
- `-A user1,user2,...` 设置有管理权限的用户列表

临时切换主组 : `newgrp 组名`
> 如果用户本不属于此组, 则需要组密码

## 更改和查看组成员

`groupmems [OPTIONS] [ACIONS]`

- OPTIONS :
    - `-g`, `--group` `groupname` : 更改为指定组(只有root)
- ACTIONS :
    - `-a`, `--add` `username` : 指定用户加入组
    - `-d`, `--delete` `username` : 从组中删除用户
    - `-p`, `--purge` : 从组中清除所有成员
    - `-l`, `--list` : 显示组成员列表

显示用户所属组列表 : `groups [OPTION]... [USERNAME]...`

## 文件属性

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210607235728.png)

### 文件属性操作

**设置文件的所有者 :**
- 格式 :
    ```bash
    chown [OPTION]... [OWNER][:[GROUP]] FILE...
    chown [OPTION]... --reference=RFILE FILE...
    ```
- 选项 : 
    - `-R` : 递归
- 示例 :
    ```bash
    chown wang xxx.txt 将xxx.txt的所有者设置为wang用户
    chown wang:root xxx.txt 将xxx.txt的所有者设置为王用户, 所属组设置为root
    chown --reference=/etc/passwd xxx.txt 将xxx.txt的所有者和所属组修改为与/etc/passwd一样
    ```

**设置文件的所属组信息 :**
- 格式 :
    ```bash
    chgrp [OPTION]... GROUP FILE...
    chgrp [OPTION]... --reference=RFILE FILE...
    ```
- 选项 : 
    - `-R` : 递归
- 示例 :
    ```bash
    chgrp wang xxx.txt 将xxx.txt的所属组设置为wang
    chgrp --reference=/etc/passwd xxx.txt 将xxx.txt的所属组修改为与/etc/passwd一样
    ```

## 文件权限

### 文件权限

#### 文件的权限主要针对三类对象进行定义
- owner : 所有者, u
- group : 所属组, g
- other : 其他, o

#### 每个文件针对每类访问者都定义了三种权限
- r : Readable, 可读
- w : Writable, 可写
- x : eXcutable, 可执行

#### 文件的权限
- r : read, 读, 可使用文件查看类工具获取其内容
- w : write, 写, 可修改其内容
- x : excute, 可执行, 可以把此文件提请内核启动为一个进程

#### 目录的权限
- r : read, 读, 可是使用ls查看此目录中文件列表
- w : write, 写, 可以对目录下的文件进行增删(必须同时有x权限)
- x : excute, 可执行, 可以使用ls -l查看此目录中文件元数据(须配合r), 可以cd进入此目录
- X : 只给目录x权限, 不给文件x权限


## 八进制数字

| 字母表示 | 二进制数字 | 八进制数字 |
| -------- | ---------- | ---------- |
| ---      | 000        | 0          |
| --x      | 001        | 1          |
| -w-      | 010        | 2          |
| -wx      | 011        | 3          |
| r--      | 100        | 4          |
| r-x      | 101        | 5          |
| rw-      | 110        | 6          |
| rwx      | 111        | 7          |

**示例 :**
```bash
640 : rw-r-----
755 : rwxr-xr-x
777 : rwxrwxrwx
```

## 修改文件权限

**文件权限(rwx|X)**

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210607235729.png)

此处的X表示, 只对目录和包含执行权限的文件赋予可执行(x)权限
```bash
[root@localhost ~]# ll data
total 0
-rw-r--r--. 1 root root 0 Feb  6 22:04 aaa
-rwxr--r--. 1 root root 0 Feb  6 22:04 bbb
drwxr-xr-x. 2 root root 6 Feb  6 22:04 ccc
drw-r--r--. 2 root root 6 Feb  6 22:04 ddd
[root@localhost ~]# chmod -R a=rwX data
[root@localhost ~]# ll data
total 0
-rw-rw-rw-. 1 root root 0 Feb  6 22:04 aaa
-rwxrwxrwx. 1 root root 0 Feb  6 22:04 bbb
drwxrwxrwx. 2 root root 6 Feb  6 22:04 ccc
drwxrwxrwx. 2 root root 6 Feb  6 22:04 ddd

aaa文件不包含x权限, 所以执行命令后依旧没有x权限
bbb文件在包含可执行权限, 所以执行命令后包含可执行权限
ccc和ddd是目录, 所以执行命令后, 均包含可执行权限
```

**命令格式 :**
- `chmod [OPTION]... MODE[,MODE]... FILE...`
  
    - OPTION : 
        - `-R` : 递归修改权限
    - MODE :
        - 修改一类用户的所有权限
            ```bash
            u= : 所有者
            g= : 所属组用户
            o= : 其他用户
            a= : 所有用户
            ug= : 所有者和所属组
            ```
        - 修改一类用户某位或某些位权限
            ```bash
            u+ u- : 为所有者增加或删除某个或某些权限
            g+ g- : 为所属组用户增加或删除某个或某些权限
            o+ o- : 为其他用户增加或删除某个或某些权限
            a+ a- : 为所有用户增加或删除某个或某些权限
            + - : 为所有用户增加或删除某个或某些权限
            ```
- `chmod [OPTION]... OCTAL-MODE FILE...`
  
    > 使用数字的方式修改文件的权限
    
- `chmod [OPTION]... --reference=RFILE FILE...`
  
    > 参考RFILE文件的权限, 将FILE的权限修改为同RFILE一样


**对文件进行读/写/执行操作时, 权限的匹配顺序是 所有者权限 -> 所属组权限 -> 其他用户权限, 一旦匹配成功, 则不像下一级进行匹配**
```bash
-----w-rw-. 1 wang duan 0 Feb  6 22:04 aaa
