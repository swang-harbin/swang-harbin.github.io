---
title: 用户, 组和权限
date: 2020-01-04 22:26:57
updated: 2020-01-04 22:26:57
tags:
- Linux
categories:
- [Linux, 阿里云Linux运维学习路线, 阶段一:Linux入门]
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
wang用户对aaa文件不能读/写/执行
属于duan组的用户只能对aaa进行写
其他用户可以对该文件进行读写

duan用户属于duan组, 则duan用户只能对aaa进行写操作

wang用户可以使用chmod修改该文件的权限
```

**可以只有写权限, 没有读权限, 通过`echo xxx >> file`向file中追加xxx**

**如果要删除文件, 必须对文件所在目录有写权限**

**root用户没有读写权限也可以读写, root用户没有执行权限也不能执行**

## 默认权限设置

新建文件的最大权限为666, 为了防止新建的文件带有可执行权限, 新建文件夹的最大权限为777

**umask + 默认权限 = 最大权限**

**底层计算方法**
```bash
umask为123, 创建文件, 计算文件的默认权限

文件的最大权限666        : 110110110
umask为321             : 101010001
                        -----------
666-321=234, 真实结果为  : 010100110  -> 246

由上, 默认权限为246

umask为1的位会遮掩原来的值, 变为为0, umask为0的位, 结果不变.
```

- umask值 可以用来保存新建文件或目录时的默认权限
- 新建FILE权限 : 666-umask
  
    > 如果所得结果某位存在执行(奇数)权限, 则将其权限+1
- 新建DIR权限 : 777-umask
- 非特权用户umask默认时002
- root的umask默认时022
- 查看umask : `umask`
- 设置umask : `umask [-p] [-S] [mode]`
    ```bash
    示例 :
    umask 002
    umask u=rw g=r o=
    ```
- 模式方式显示 : `umask -S`
  
    使用字母的方式, 显示新建文件夹的默认权限
- 输出可被调用 : `umask -p`
  
    输出 : umask 0102  
    可将其直接重定向到配置文件中 : `umask -p >> ~/.bashrc`
- 全局配置文件 : /etc/bashrc
    ```bash
    if [ $UID -gt 199 ] && [ "`/usr/bin/id -gn`" = "`/usr/bin/id -un`" ]; then
       umask 002
    else
       umask 022
    fi
    ```
- 用户配置文件 : ~/.bashrc

## 权限相关练习

1. 当用户docker对/testdir目录无执行权限时, 意味着无法做哪些操作
   
    > 无法cd, 如果有读权限可以使用ll查看文件
2. 当用户mongodb对/testdir目录无读取权限时, 意味着无法做哪些操作
   
    > 
3. 当用户redis对/testdir目录无写权限时, 该目录下的只读文件file1是否可以修改和删除
4. 当用户zabbix对/testdir目录有写和执行权限时, 该目录下的只读文件file1是否可修改和删除
5. 复制/etc/fstab文件到/var/tmp下, 设置文件所有者为tomcat读写权限, 所属组为apps组有读写权限, 其他人无权限
6. 无删除了用户git的家目录, 请重新创建并恢复该家目录及相应权限属性

**程序运行说明**

安全上下文

前提 : 进程有属主和属组; 文件有属主和属组
1. 任何一个可执行程序文件能不能启动为进程, 取决于发起者对程序文件是否拥有执行权限
2. 启动为进程后, 其进程的属主为发起者, 进程的属组为发起者所属的组
3. 进程访问文件时的权限, 取决于进程的发起者
    1. 进程的发起者, 同文件的属主: 则应用文件属主权限
    2. 进程的发起者, 属于文件属组: 则应用文件属组权限
    3. 应用文件"其他"权限

## Linux文件系统上的特殊权限

### 三种特殊权限

**1. SUID :** 一个二进制程序包含SUID, 则任何用户执行时都会继承该二进制程序所有者的身份, 获得它的权限
- 作用目标 :
    - 仅二进制程序
- 位置 : user, 占据属主的执行权限位
    - s : 属主拥有x权限
    - S : 属主没有x权限

- 场景: 普通用户无法修改/etc/shadow文件, 却可以使用passwd命令修改自己的密码, 对/etc/shadow文件造成修改.
- 原因 : 因为passwd程序包含SUID权限
    ```bash
    [root@localhost ~]# ll /usr/bin/passwd
    -rwsr-xr-x. 1 root root 27856 Aug  9 09:39 /usr/bin/passwd
    ```
    注意所属用户的执行权限x变为了s, 代表具有SUID权限. 带有SUID权限的程序, 任何用户在执行时, 都会继承该二进制程序所有者的身份, passwd程序的所有者为root, 对/etc/passwd可以读写, 因此其他用户可以使用passwd程序对passwd文件进行修改.
- 添加和删除SUID权限
    ```bash
    添加SUID权限
    chmod u+s /bin/cat
    chmod 4755 /bin/cat # 4代表添加suid权限
    删除SUID权限
    chmod u-s /bin/cat
    chmod 755 /bin/cat
    ```
- 其他说明
    ```bash
    [root@localhost ~]# ll /bin/cat
    -rwxr-xr-x. 1 root root 54080 Aug 20 14:25 /bin/cat
    # 为cat程序添加SUID权限
    [root@localhost ~]# chmod u+s /bin/cat
    [root@localhost ~]# ll /bin/cat
    -rwsr-xr-x. 1 root root 54080 Aug 20 14:25 /bin/cat
    # 删除cat程序的可执行x权限
    [root@localhost ~]# chmod u-x /bin/cat
    # 会发现s变为了S, 此时root用户不具备可执行权限
    [root@localhost ~]# ll /bin/cat
    -rwSr-xr-x. 1 root root 54080 Aug 20 14:25 /bin/cat
    而root用户依旧可以使用cat命令查看/etc/passwd, 是因为root用户在root组中, root组具备cat程序的执行权限
    ```
    **2. SGID :** 
- 位置 : group, 占据属组的执行权限位
    - s : group拥有x权限
    - S : group没有x权限
- 作用目标 :
    - 二进制程序
      
        一个二进制程序包含SGID, 则任何用户执行时都会继承该二进制程序所属组的身份, 获得所属组权限
        
    - 文件夹
      
        默认情况下, 用户创建文件时, 其属组为此用户所属的主组, 一旦某目录设定了SGID权限, 则对此目录有写权限的用户在此目录中创建的文件所属的组为此目录的所属组
        
        - 使用场景 : 通常用于创建一个协作目录
          
            wang用户和duan用户在做同一个项目, 项目文件均放在web目录下, 两用户均需要对web目录下的文件进行修改, 此时可以创建一个web组, 将wang和duan均加入该组, 修改web目录数据web组, 对其设置SGID, 此时, wang和duan创建的文件默认所属组均会变为web, 则两用户均可以通过组权限对对方的文件进行修改.
    
- 添加和删除SUID权限
    ```bash
    添加SGID权限
    chmod g+s /bin/cat
    chmod 2755 /bin/cat # 2代表添加sgid权限
    删除SGID权限
    chmod g-s /bin/cat
    chmod 755 /bin/cat
    ```
    **`chmod 6755 /bin/cat`, 6代表添加SUID和SGID权限.**

**3. Sticky :** 对目录具有写权限的用户, 通常可以删除该目录中的任何文件, 无论该文件的权限或拥有权. 在目录设置Sticky位, 只有文件的所有者或root可以删除该文件. Sticky设置在文件上无意义
- 作用目标 :
    - 仅文件夹
- 位置 : other, 占据other的执行权限位
    - t : other拥有x权限
    - T : other没有x权限
- 示例 :
    ```bash
    [root@localhost data]# ll -d /tmp
    drwxrwxrwt. 8 root root 211 Feb  7 11:16 /tmp
    ```

- 添加和删除Sticky权限
    ```bash
    添加Sticky权限
    chmod o+t ~/data # t代表Sticky权限
    chmod 1777 ~/data # 1代表Sticky权限
    删除Sticky权限
    chmod o-t ~/data
    chmod 777 ~/data
    ```
### 特殊权限数字法

| SUID | SGID | STICKY | 八进制和 |
| ---- | ---- | ------ | -------- |
| 0    | 0    | 0      | 0        |
| 0    | 0    | 1      | 1        |
| 0    | 1    | 0      | 2        |
| 0    | 1    | 1      | 3        |
| 1    | 0    | 0      | 4        |
| 1    | 0    | 1      | 5        |
| 1    | 1    | 0      | 6        |
| 1    | 1    | 1      | 7        |

示例 :
```
chmod 4777 /tmp/a.txt
```

## 设定文件特定属性

该属性属于扩展属性, 存储在元数据中

- `chattr +i filename` : 不能删除, 改名, 更改
- `chattr +a filename` : 只能追加内容
- `lsattr filename` : 显示特定属性
- `chattr -i filename` : 删除i属性
- `chattr -a filename` : 删除a属性

```bash
[root@localhost webdir]# lsattr wang1
----i----------- wang1
```
**该操作对root帐号也会生效**

## 访问控制列表

因为普通的权限设置只能对所属者, 所属组, 其他用户进行权限设置, 无法细粒度的进行权限控制, 例如对tom用户设置特定不同于other用户的权限, 这是做不到的, 所以引入了访问控制列表技术.


- 访问控制列表 : ACL, Access Control List, 实现灵活的权限管理
- 除了文件的所有者, 所属组和其他人, 可以对更多的用户设置权限
- CentOS7默认创建的xfs和ext4文件系统具有ACL功能
    ```bash
    查看文件系统格式
    df -T
    ```
- CentOS7之前版本, 默认手工创建的ext4文件系统无ACL功能, 需手动地添加
    ```bash
    tune2fs -o acl /dev/sdb1
    mount -o acl /dev/sdb1 /mnt/test
    ```
- 查看分区是否支持ACL权限
    ```bash
    tune2fs -l /dev/sda1
    # 只对ext系列生效
    ```
- 查看文件是否包含ACL权限
    ```bash
    [root@localhost data]# ll f1
    -rw-r--r--+ 1 root root 0 Feb  7 22:40 f1
    ```
    **+号代表该文件包含ACL权限**
- ACL相关命令
- 
    - 查看ACL权限信息(get file access control list)
        ```bash
        Usage: getfacl [-aceEsRLPtpndvh] file ...
        -a,  --access           display the file access control list only
        -d, --default           display the default access control list only
        -c, --omit-header       do not display the comment header
        -e, --all-effective     print all effective rights
        -E, --no-effective      print no effective rights
        -s, --skip-base         skip files that only have the base entries
        -R, --recursive         recurse into subdirectories
        -L, --logical           logical walk, follow symbolic links
        -P, --physical          physical walk, do not follow symbolic links
        -t, --tabular           use tabular output format
        -n, --numeric           print numeric user/group identifiers
        -p, --absolute-names    don't strip leading '/' in pathnames
        -v, --version           print version and exit
        -h, --help              this help text
        ```
    
    - 设置ACL权限(set file access control list)
      
        ```bash
        Usage: setfacl [-bkndRLP] { -m|-M|-x|-X ... } file ...
        -m, --modify=acl        modify the current ACL(s) of file(s)
        -M, --modify-file=file  read ACL entries to modify from file
        -x, --remove=acl        remove entries from the ACL(s) of file(s)
        -X, --remove-file=file  read ACL entries to remove from file
        -b, --remove-all        remove all extended ACL entries
        -k, --remove-default    remove the default ACL
          --set=acl           set the ACL of file(s), replacing the current ACL
          --set-file=file     read ACL entries to set from file
          --mask              do recalculate the effective rights mask
        -n, --no-mask           don't recalculate the effective rights mask
        -d, --default           operations apply to the default ACL
        -R, --recursive         recurse into subdirectories
        -L, --logical           logical walk, follow symbolic links
        -P, --physical          physical walk, do not follow symbolic links
          --restore=file      restore ACLs (inverse of `getfacl -R')
          --test              test mode (ACLs are not modified)
        -v, --version           print version and exit
        -h, --help              this help text
        ```
- base ACL 不能删除
- getfacl file1 | setfacl --set-file=- file2 : 赋值file1的ACL权限给file2
- ACL权限显示说明
    ```bash
    [root@localhost data]# getfacl f1 
    # file: f1      文件名
    # owner: root   属主
    # group: root   属组
    user::rw-       属主权限
    user:wang:rwx   wang用户的权限
    group::r--      属组权限
    group:duan:rw-  duan组的权限
    mask::r--       对应ll时, 显示的组权限
    other::r--      其他用户的权限
    ```
- ACL生效顺序 : 所有者, 自定义用户, 自定义组, 其他人
- 当一个用户属于多个自定义组, 会具有多个自定义组的权限
- 为多用户或者组的文件和目录赋予访问权限rwx
    ```bash
    mount -o acl /directory
    # 查看file|directory的ACL权限
    getfacl file|directory
    # 给file|directory添加wang用户的rwx权限
    setfacl -m u:wang:rwx file|directory
    # 给directory递归添加sales组的rwX权限
    setfacl -Rm g:sales:rwX directory
    # 使用file.acl为file|directory赋予批量权限
    setfacl -M file.acl file|directory
    # 给file|directory添加salesgroup组的rw权限
    setfacl -m g:salesgroup:rw file|directory
    # d, default: 设置以后在directory中新建的文件/目录都具有u:wang:rx的acl权限
    setfacl -m d:u:wang:rx directory
    # 删除file|directory对wang用户的ACL权限
    setfacl -x u:wang file|directory
    # 对directory批量删除file.acl文件中记录的ACL权限
    setfacl -X file.acl directory
    ```
- ACL文件上的group权限是mask值(自定义用户, 自定义组, 拥有组的最大权限), 而非传统的组权限
  
    如果使用了ACL权限, 则会将`ll file`显示的传统属组权限修改为ACL权限中的mask值, 此时使用`chmod g=rw file`修改的是ACL权限中的mask值, 也可以通过`setfacl -m mask::rw file`来修改ACL权限中的mask值. 
    
    mask值代表了所有ACL权限的最高权限, 即, 如果mask::r, 那么所有ACL权限都只能读, 不能写和执行, 效果如下方两处`#effective:r--`
    
    ```bash
    [root@localhost data]# setfacl -m mask::r f1
    [root@localhost data]# getfacl f1 
    # file: f1
    # owner: root
    # group: root
    user::rw-
    user:wang:rwx			#effective:r--
    group::rw-			    #effective:r--
    group:duan:rw-			#effective:r--
    mask::r--
    other::r--
    ```
- mask只影响除所有者和other之外的人和组的最大权限, mask需要与用户的权限进行逻辑与运算后, 才能变成有限的权限(Effective Permission)
    用户或组的设置必须存在于mask权限设定范围内才会生效
- `--set`选项会把原有的ACL项都删除, 用新的替代, 需要注意的是一定要包含UGO的设置, 不能像`-m`一样只是添加ACL就可以
  
    ```bash
    示例 :
    setfacl --set u::rw,u:wang:rw,g::r,o::- file1
    ```
- 备份和恢复ACL
  
    主要的文件操作命令cp和mv都支持ACL, 知识cp命令需要加上-p参数. 但是tar等常见的备份工具是不会保留目录和文件的ACL信息.
    
    ```bash
    # 递归/tmp/dir1目录, 将ACL信息保存到acl.txt文件中
    getfacl -R /tmp/dir1 > acl.txt
    # 递归还原/tmp/dir1目录的ACL信息
    setfacl -R -b /tmp/dir1
    # 递归/tmp/dir1目录, 恢复acl.txt中的ACL信息
    setfacl -R --set-file=acl.txt /tmp/dir1
    # 还原acl.txt中记录的ACL信息
    setfacl --restore acl.txt
    # 
    getfacl -R /tmp/dir1
    ```

