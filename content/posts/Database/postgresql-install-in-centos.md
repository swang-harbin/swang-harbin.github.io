---
title: CentOS7 安装 PostgreSQL12.2
date: '2019-12-04 00:00:00'
tags:
- PostgreSQL
- CentOS
---

# CentOS7 安装 PostgreSQL12.2

## yum 命令方式

参考 [官方文档](https://www.postgresql.org/download/linux/redhat/)

安装成功后，使用 `createdb mydb`，测试创建一个数据库 mydb，可能会有以下提示

```
createdb: could not connect to database template1: FATAL:  role "root" does not exist
```

因为创建数据库必须登入数据库才行，数据库中并没有 root 这个角色，因为安装好 PostgreSQL 后，PostgreSQL 会自动创建一个 Linux 用户和一个对应的数据库角色，均叫 postgres，它是一个具备数据库超级管理员权限的角色，所以可以使用 postgres 角色去创建其他数据库角色。此处可以不创建该 root 角色，可以直接通过 postgres 角色去访问数据库.

```bash
# 切换到系统的 postgres 用户
su - postgres
# 登录到主数据库
psql postgres
# 设置 postgres 角色的密码
\password postgres
# 创建一个数据库角色 root，并赋予超级管理员权限
create user root superuser;
```

最后一个命令创建了一个 root 角色，并给他 superuser 的权限.

使用 `\q`，`exit` 依次退出主数据库和 postgres 角色，使用 root 角色登录到主数据库

```bash
# 退出主数据库
\q
# 退出 postgres 角色
exit
# 使用 root 角色登录主数据库
psql postgres
# 修改 root 角色密码
\password root
```

登录到数据库

```bash
psql -U root -d mydb -h 127.0.0.1 -p 5432
```

**参数说明**

- `-U`：数据库用户名
- 数据库名称
- 数据库服务器 IP
- 数据库服务器端口号

## 源文件方式

**CentOS7 需要提前安装的软件包**

```bash
yum install -y gcc-c++ make readline-devel zlib-devel docbook-dtds docbook-style-xsl fop libxslt
```

[官方文件仓库](https://www.postgresql.org/ftp/source/)

[官方文档](https://www.postgresql.org/docs/)

[官方安装文档](https://www.postgresql.org/docs/12/installation.html)

### 配置

第一步是在源目录修改 PostgreSQL 的配置文件。使用默认配置只需要执行

```bash
./configure
```

该脚本会查找并检查 PostgreSQL 所需的系统变量等信息，并将编译结果保存到编译目录下。默认配置会编译服务端和它的应用程序，以及所有的客户端和它的界面。所有的文件都会被安装到 /usr/local/pgsql 目录下.

如果想自己指定编译目录，可以在源目录的外部运行 `configure`，这个过程也叫做 VPATH 编译.

```bash
# 创建存放编译结果的目录
mkdir build_dir
# 移动到该目录下
cd build_dir
# 运行 configure 进行编译
# 此处如果报关于 readline/zlib 的错误，需要使用 yum 安装 readline/zlib 和 readline-devel/zlib-devel 包
# 如果卡在 checking for DocBook XML，需要 yum install docbook-dtds docbook-style-xsl fop libxslt -y
/path/to/source/tree/configure [option go here]
```

**可以选用以下的命令，来自定义编译和安装：**

- `--prefix=PREFIX`：

  将所有的文件安装到 `PREFIX` 目录下，而不是默认的 `/usr/local/pgsql` 目录。实际文件会安装到相应的子目录，没有一个文件是直接安装到 `PREFIX` 目录下的

- `--exec-prefix=EXE-PREFIX`：

  将与 PostgreSQL 体系结构相关的文件安装到指定的 `EXE-PREFIX` 目录下，而不是 `PREFIX`，这利对于在主机间共享与 PostgreSQL 体系结构无关的文件。如忽略此设置，则 `EXEC-PREFIX` 默认与 `PREFIX` 相同，此时这些文件都会被安装到同一目录树下

- `--bindir=DIRECTORY`：

  指定可执行程序的目录。默认在 `EXEC-PREFIX/bin` 目录，默认是 `/usr/local/pgsql/bin` 目录

- `--sysconfdir=DIRECTORY`：

  设置各个配置文件的目录，默认是 `PREFIX/etc`

- `--libdir=DIRECTORY`：

  设置库文件和动态加载模块。默认是 `EXEC-PREFIX/lib`.

[更多参数详见官方说明](https://www.postgresql.org/docs/12/install-procedure.html)

### 编译

- 下列命令二选一，开始编译：

  ```bash
  make
  make all
  ```

  编译成功后会显示

  > All of PostgreSQL successfully made. Ready to install.

- 如果想要编译所有的可以编译的，包括文档（HTML 和手册），以及附加模块（contrib），请使用：

  ```bash
  make world
  ```

  编译成功后会显示

  > PostgreSQL, contrib, and documentation successfully made. Ready to install.

### 回归测试

如果你想在安装之前对编译进行测试，可以在这里进行回归测试。该回归测试是用来测试 PostgreSQL 能否像开发人员预想的一样，在当前机器运行。

```bash
make check
```

### 安装

输入安装命令

```bash
make install
```

此时会将文件安装到第一步指定的目录下。此时请确保有足够的权限可以进入指定的目录。通常这一步需要具备 root 权限。或者指定目录是由当前用户创建的。

如需安装文档（HTML 和手册页）

```bash
make install-docs
```

如需全部安装（包含 HTML 和手册页和附加模块）

```bash
make install-world
```

**卸载**：使用 `mark uninstall` 去卸载安装。然后，这不会把创建的目录全清理掉。

**清理**：在安装之后，可以使用 `make clean` 将编译文件清除。这会保留由 `configure` 程序创建的文件，所以，如果你需要在以后重新编译，可以直接使用 `mark` 系列命令。如果需要重新指定安装目录，使用 `make distclean`。如果要在同一个源码目录下编译多个平台并要重新配置每个平台，那么必须执行该命令。（当然，可以使用不同的编译目录，使得源代码目录的结构保持不变）

如果在编译时，发现 `configure` 操作失败了，或者需要对 configure 进行修改（例如系统更新），那么在重新配置和重新编译之前执行 `make distclean` 是很好的。否则，你对配置的改变可能不会应用到所有的地方。

### 安装后的设置

#### 设置分享库（shared libraries）

在某些系统上使用共享库，你需要告诉系统怎么找到新安装的共享库。一些不需要告诉的系统有：FreeBSD、HP-UX、Linux、NetBSD、OpenBSD 和 Solaris。

各个系统设置共享库的搜索路径是不同的，但是最广泛地方式是设置环境变量。

- 使用 Bourne shells（sh、ksh、base、zsh）

  ```bash
  LD_LIBRARY_PATH=/usr/local/pgsql/lib
  export LD_LIBRARY_PATH
  ```

- 使用 csh 或 tcsh

  ```bash
  setenv LD_LIBRARY_PATH /usr/local/pgsql/lib
  ```

需要将 `/usr/local/pgsql/lib` 替换成第一步中 `--libdir` 指定的位置，并将上面的命令放在 `/etc/profile` 或 `~/.bash_profile` 中。

#### 环境变量

将 `/usr/local/pgsql` 或者第一步设置的 `--bindir` 目录添加到系统的 `PATH`。严格的说，这是不必要的，但是会让使用 PostgreSQL 更简便。

将下面代码添加到 shell 的启动文件，例如 `~/.bash_profile`（如果想对所有用户生效，放在 `/etc/profile` 下）

```bash
PATH=/usr/local/pgsql/bin:$PATH
export PATH
```

### 初始化

在做任何事情之前，需要初始化数据库的存储区域，称之为 *database cluster*（数据库群，SQL 标准术语叫 *catalog cluster*）。一个数据库群是由数据库服务器的单个实例管理的数据库集合。在初始化后，会创建一个叫 `postgres` 的数据库作为默认数据库。数据库服务本身不需要该数据库一定存在，但是许多第三方的程序假定它存在。使用如下命令初始化数据库群的目录，`/usr/local/pgsql/data` 可自定义。

```bash
initdb -D /usr/local/pgsql/data
或
pg_ctl -D /usr/local/pgsql/data initdb
```

如果提示 `bash: initdb: command not found...`，可通过指定 initdb 的绝对路径方式执行

```bash
例如：
/usr/local/pgsql/bin/initdb -D /usr/local/pgsql/data
```

### 启动服务

数据库服务的名称叫 `postgres`，`postgres` 程序必须知道在哪里可以找到它要使用的数据。通过 `-D` 选项来指定 data 目录的位置。如果不使用 `-D`，服务将会去环境变量中查找 `PGDATA`，如果没有这个变量，会启动失败。

```bash
postgres -D /usr/local/pgsql/data
# 如果提示 command not found，使用
/usr/local/pgsql/bin/postgres -D /usr/local/pgsql/data
```

服务默认在前台运行，并且必须保持这样才能使用 PostgreSQL 账号登录。

**使用以下命令让服务在后台运行**

```bash
# 普通的 Unix shell 命令，指定了将服务的标准输出和标准错误输出保存在 logfile 中
postgres -D /usr/local/pgsql/data >logfile 2>&1 &

# 使用 pgSql 提供的简单命令，-l 后指定 log 文件的位置
pg_ctl start -D /usr/local/pgsql/data -l logfile
```

### 连接

安装完成后会自动创建一个与当前 Linux 系统用户名相同的数据库角色，并具有数据库的 superuser 权限。并会创建一个默认的数据库叫 postgres，属于该角色

#### 连接到一个数据库

```bash
psql dbname
# 例如，连接到默认数据库
psql postgres
```

#### 设置用户密码

登录到一个数据库后，输入

```bash
\password
```

#### 远程连接

例如使用 Navicat 连接

修改 pg_hba.conf 和 postgresql.conf 文件

> **pg_hba.conf** 文件在默认在 `/var/lib/pgsql/12/data/pg_hba.conf`
>
> **postgresql.conf** 文件默认在 `/var/lib/pgsql/12/data/postgresql.conf`
>
> 可以通过 `find / -name filename` 从 `/` 目录查找 filename 文件。

**pg_hba.conf**

```bash
# 在 ipv4 下添加
host all all 0.0.0.0/0 trust
```

**postgresql.conf**

```bash
listen_addresses='*'
```

**关闭 PostgreSQL 服务**

```bash
/path/for/postgresql/bin/pg_ctl -D /path/for/postgresql/data stop
```

**启动 PostgreSQL 服务**

```bash
/path/for/postgresql/bin/pg_ctl -D /path/for/postgresql/data -l /path/for/postgresql/logs/logfile start
```