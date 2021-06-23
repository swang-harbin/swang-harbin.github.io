---
title: Linux 基本命令
date: '2020-01-08 22:26:17'
tags:
- Linux
---

# Linux 基本命令

## 简单命令

**关机：** `halt`，`poweroff`

**重启：** `reboot`

- `-f`：强制，不调用`shutdown`
- `-p`：切断电源

**关机或重启：** `shutdown`

```bash
shutdown [OPTION]... [TIME] [MESSAGE]
```
- OPTION：
    - `-r`：reboot
    - `-h`：halt
    - `-c`：cancel
- TIME：无指定，默认相当于 +1（CentOS7）
    - `now`：立刻，相当于 +0
    - `+m`：相对时间表示法，几分钟之后
    - `hh:mm`：绝对时间表示，指明具体时间

**用户登陆信息查看命令**

- `whoami`：显示当前登陆的有效用户
- `who`：系统的那个前所有的登陆会话
- `w`：系统的当前所有的登陆会话及所做的操作

`nano`：文本编辑

## 高级命令

### screen 命令

远程协助字符界面

- 创建新 screen 会话
    ```bash
    screen -S [SESSION]
    ```
- 加入 screen 会话
    ```bash
    screen -x [SESSION]
    ```
- 退出并关闭 screen 会话
    ```bash
    exit
    ```
- 剥离当前 screen 会话
    ```bash
    Ctrl+a，Ctrl+d
    ```
- 显示所有已经打开的 screen 会话
    ```bash
    screen -ls
    ```
- 恢复某 screen 会话
    ```bash
    screen -r [SESSION]
    ```

### echo 命令

- 功能：显示字符
- 语法：`echo [-neE] [字符串]`
- 说明：`echo` 会将输入的字符串送往标准输出。输出的字符串间以空白字符隔开，并在最后加上换行号
- 选项：
    - `-E` （默认） 不支持`\`解释功能
    - `-n` 不自动换行
    - `-e` 启用`\`字符的解释功能
- 显示变量
    - `echo "$VAR_NAME"` 变量会替换，弱引用
    - `echo '$VAR_NAME'` 变量不会替换，强引用
- 启用命令选项 `-e`，若字符串中出现以下字符，则特别加以处理，而不会将它当成一般文字输出。
    - `\\a` 发出警告声
    - `\\b` 退格键
    - `\\c` 最后不加上换行符号
    - `\\n` 换行且光标移至行首
    - `\\r` 回车，即光标移至行首，但不换行
    - `\\t` 插入 `tab`
    - `\\` 插入 `\` 字符
    - `\\0nnn` 插入 nnn（八进制）所代表的 ASCII 字符
    - `\\xHH` 插入 HH（十六进制）所代表的 ASCII 数字

''，``，""的区别：

- `''`：原封不动显示

- ``或$()：可以识别命令和变量
- `""` 或 `${}`：可以识别变量，不能识别命令
  
    ```bash
    [root@localhost ~]# echo "echo $PATH"
    echo /usr/share/Modules/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/root/bin
    [root@localhost ~]# echo 'echo $PATH'
    echo $PATH
    [root@localhost ~]# echo `echo $PATH`
    /usr/share/Modules/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/root/bin
    ```

**命令行扩展，被括起来的集合：**

- 命令行扩展：`$()` 或 ``

    把一个命令的输出打印给另一个命令的参数
    
    ```bash
    echo "This system's name is $(hostname)"
    echo "i am `whoami`"
    ```
- 括号扩展：`{}`

    打印重复字符串的简化形式
    ```bash
    echo file{1,3,5}
    rm -rf file{1,3,5}
    echo {1..10}
    echo {a..z}
    echo {000..20..2}
    ```


### history 命令

- `history [-c] [-d offset] [n]`
- `history -anrw [filename]`
- `history -ps arg [arg...]`

    - `-c`：清空命令历史

    - `-d offset`：删除历史中指定的第 offset 个命令

    - `n`：显示最近的 n 条历史

    - `-a`：追加本次会话新执行的命令历史列表至历史文件

    - `-r`：读历史文件附加到历史列表

    - `-w`：保存历史列表到指定的历史文件

    - `-n`：读历史文件中未读过的行到历史列表

    - `-p`：展开历史参数成多行，但不保存到历史列表中

      ```shell
      history -p `hostname` `lscpu`
      ```

      会执行 `hostname` 和 `lscpu`，并将执行结果变成多行，并且不存入到 history 列表

    - `-s`：展开历史参数成一行，附加在历史列表后

      ```shell
      history -s `rm -rf /*`
      ```

      不会执行 `rm -rf /*`，但会将其保存到 history 中

**命令行历史**

- 保存你输入的命令历史。可以用它来重复执行命令

- 登陆 shell 时，会读取命令历史文件中记录下的命令 ~/.bash_history

- 登陆进 shell 后新执行的命令只会记录在缓存中；这些命令会在用户退出时追加到命令历史文件中。

- 重复前一个命令有 4 种方法
    - 使用上方向键，并回车执行
    - 按 `!!` 并回车执行
    - 输入 `!-1` 并回车执行
    - 按 <kbd>Ctrl</kbd><kbd>p</kbd> 并回车执行
    
- `!:0` 执行前一条命令，但会去除参数

- `Ctrl+n` 显示当前记录中的下一条命令，但不执行，相当于下方向键

- `Ctrl+j` 执行当前命令

- `!n` 执行 history 命令输出中，对应序号 n 的命令

- `!-n` 执行 history 历史中倒数第 n 个命令

- `!string` 重复前一个以 string 开头的命令

- `!?string` 重复前一个包含 string 的命令

- `!string:p` 仅打印命令历史，而不执行

- `!$:p` 打印输出 !$（上一条命令的最后一个参数）的内容

- `!*:p` 打印输出 !*（上一条命令的所有参数）的内容

- `^string` 删除上一条命令中的第一个 string

- `^string1^string2` 将上一条命令中的第一个 string1 替换为 stirng2

- `!:gs/string1/string2` 将上一条命令中所有的 string1 都替换为 string2

- 使用 Up（向上）和 Down（向下）键来上下浏览从前输入的命令

- <kbd>Ctrl</kbd>+<kbd>r</kbd> 在命令历史中搜索命令

    ```bash
    (reverse-i-search)`': 
    ```

- <kbd>Ctrl</kbd>+<kbd>g</kbd> 从搜索命令中退出

- 要重新调用前一个命令中最后一个参数
    - `!$`
    - <kbd>esc</kbd><kbd>.</kbd>（点击 esc 后松开，然后点击。键）
    - <kbd>Alt</kbd>+<kbd>.</kbd> （按住 Alt 键的同时点击。键）

**调用历史参数**

- `command !^` 利用上一个命令的第一个参数做 cmd 的参数
- `command !$` 利用上一个命令的最后一个参数做 cmd 的参数
- `command !*` 利用上一个命令的全部参数做 cmd 的参数
- `command !:n` 利用上一个命令的第 n 个参数做 cmd 的参数
- `command !n:^` 调用第 n 条命令的第一个参数
- `command !n:$` 调用第 n 条命令的最后一个参数
- `command !n:m` 调用第 n 条命令的第 m 个参数
- `command !n:*` 调用第 n 条命令的所有参数
- `command !string:^` 从命令历史中搜索以 string 开头的命令，并获取它的第一个参数
- `command !string:$` 从命令历史中搜索以 string 开头的命令，并获取它的最后一个参数
- `command !string:n` 从命令历史中搜索以 stirng 开头的命令，并获取它的第 n 个参数
- `command !string:*` 从命令历史中搜索以 stirng 开头的命令，并获取它的所有参数

**命令历史相关环境变量**
- `HISTSIZE`：内存中命令历史记录的条数
- `HISTFILE`：指定历史文件，默认为 ~/.bash_history
- `HISTFILESIZE`：命令历史文件记录历史的条数
- `HISTTIMEFORMAT="%F %T "` 显示时间
- `HISTIGNORE="str1:str2*:..."` 不将 str1 命令，str2 开头的命令记录到历史列表
- 控制命令历史的记录方式：
    - 环境变量：`HISTCONTROL`
        - `ignoredups` 默认，忽略重复的命令，连续且相同为“重复”
        - `ignorespace` 忽略所有以空白开头的命令
        - `ignoreboth` 相当于 ignoredups 和 ignorespace 组合
        - `erasedups` 删除重复命令
    - `export 变量名="值"`
    - 存放在 /etc/profile 或 ~/.bash_profile


## 字符集和编码

`hexdump -C file` 查看文件的 16 进制

**ASCII 码：** 计算机内部，所有信息最终都是一个二进制值。上世纪 60 年代，美国制定了一套字符编码，对英语字符与二进制位之间的关系，做了统一规定。ASCII 码一共规定了 128 个字符的编码，占用了一个字节的后面 7 位，最前面的一位统一规定为 0。可通过 `man ascii` 查看

**Unicode：** 用于表示世界上所有语言中的所有字符。每一个符号都给予一个独一无二的编码数字，Unicode 是一个很大的集合，现在的规模可以容纳 100 多万个符号。Unicode 仅仅只是一个字符集，规定了每个字符对应的二进制代码，至于这个二进制代码如何存储则没有规定。

**Unicode 编码方案：**
- UTF-8 变长，1 到 4 个字节
- UTF-16 变长，2 或 4 个字节
- UTF-32 固定长度，4 个字节

**UTF-8：** 是目前互联网上使用最广泛的一种 Unicode 编码方式，可变长存储。使用 1-4 个字节表示一个字符，根据字符的不同变换长度。编码规则如下：
- 对于单个字节的字符，第一位设为 0，后面的 7 位对应着个字符的 Unicode 码。因此，对于英文中的 0-127 号字符，与 ASCII 码完全相同。这意味着 ASCII 码的文档可用 UTF-8 编码打开
- 对于需要使用 N 个字节来表示的字符（N>1），第一个字节的前 N 位都设为 1，第 N+1 位设为 0，剩余的 N-1 个字节的前两位都设为 10，剩下的二进制位则使用这个字符的 Unicode 码来填充

**编码查询和转换：**
- https://javawind.net/tools/native2ascii.jsp
- https://tool.oschina.net/encode
- http://www.chi2ko.com/tool/CJK.htm

`iconv` 查看系统支持的所有编码表

`iconv -f gb2312 in.txt -o out.txt` 将 gb2312 格式的 in.txt 转换为 Unicode 文件格式

`localectl list-locales`或`cat /etc/locale.conf` 查看所有支持的语言和编码表

`localectl set-locale LANG=zh_CN.utf8`或`vim /etc/locale.conf` 设置系统使用中文


## tab 键

**命令补全：**

- 内部命令：
- 外部命令：bash 根据 PATH 环境变量定义的路径，自左而右在每个路径搜寻以给定命令名命名的文件，第一次找到的命令即为要执行的命令

    用户给定的字符串只有一条唯一对应的命令，直接补全，否则，再次 Tab 会给出列表

**路径补全：**

把用户给出的字符串当做路径开头，并在其指定上级目录下搜索以指定的字符串开头的文件名
- 如果唯一：直接补全
- 否则：再次 Tab 给出列表

## 获取帮助

**获取帮助的能力决定了技术能力**

**多层次的帮助**
- `whatis`
- `command --help`
- `man` and `info`
- /usr/share/doc/
- Red Hat documentation
- 其他网站和搜索

**whatis**
- 显示命令的简短描述
- 使用了 whatis 的数据库，刚安装后不可立即使用，需要使用 makewhatis 或 mandb 制作数据库
- 使用示例：whatis cal 或 man -f cal

**命令帮助**
- 内部命令：`help COMMAND` 或 `man bash`
- 外部命令：
    - `COMMAND --help` 或 `COMMAND -h`
    - 使用手册（manual）：`man COMMAND`
    - 信息页：`info COMMAND`
    - 程序自身的帮助文档：README、INSTALL、ChangeLog
    - 程序官方文档：官方站点 Documentation
    - 发行版的官方文档
    - Google

**--help 和 -h 选项**

- 显示用法总结和参数列表
- 使用的大多数，但并非所有
- 示例：
    - `date --help`
    ```
    Usage: date [OPTION]... [+FORMAT]
  or:  date [-u|--utc|--universal] [MMDDhhmm[[CC]YY][.ss]]
  
    [] 表示可选项
    CAPS 或<> 表示变化的数据
    ... 表示一个列表
    x|y|z 表示 x 或 y 或 z
    -abc -a -b -c
    {} 表示分组
  ```

**man 命令**

- 可以看外部命令的帮助，配置文件格式语法，游戏说明等，将这些分类放到了不同的章节中
- 手册页存放在 /usr/share/man
- 几乎每个命令都有 man 的“页面”
- man 页面分组为不同的“章节”
- 统称为 Linux 手册
- man 命令的配置文件：/etc/man.config 或 man_db.conf
    - MANPATH /PATH/TO/SOMEWHERE：指明 man 文件搜索位置
- ``man -M /PATH/TO/SOMEWHERE COMMAND`：到指定位置下搜索 COMMAND 命令的手册页并显示
- 中文 man 需要安装包 man-pages-zh-CN

**man 章节**
- 1：用户命令
- 2：系统调用
- 3：C 库调用
- 4：设备文件及特殊文件
- 5：配置文件格式
- 6：游戏
- 7：杂项
- 8：管理类的命令
- 9：Linux 内核 API

**man 帮助段落说明**

- 帮助手册中的段落说明
    - NAME 名称及简要说明
    - SYNOPSIS 用法格式说明
        - [] 可选内容
        - <> 必选内容
        - a|b 二选一
        - {} 分组
        - ... 同一内容可出现多次
    - DESCRIPTION 详细说明
    - OPTIONS 选项说明
    - EXAMPLES 示例
    - FILES 相关文件
    - AUTHOR 作者
    - COPYRIGHT 版本信息
    - REPORTING BUGS bug 信息
    - SEE ALSO 其他帮助参考
    - 
    **man 帮助**
- 查看 man 手册页
    ```
    man [章节] keyword
    ```
- 列出所有帮助
    ```
    man -a keyword
    ```
- 搜索 man 手册
    ```
    man -k keyword 从 whatis 数据库中查询所有包含 keyword 的信息
    ```
- 相当于 whatis
    ```
    man -f keyword
    ```
- 打印 man 帮助文档的路径
    ```
    man -w [章节] keyword
    ```

**man 命令**

- `man` 命令的操作方法：使用 `less` 命令实现
    - <kbd>space</kbd>，<kbd>Ctrl</kbd>+<kbd>v</kbd>，<kbd>Ctrl</kbd>+<kbd>f</kbd>，<kbd>Ctrl</kbd>+<kbd>F</kbd>：下一屏
    - <kbd>b</kbd>，<kbd>Ctrl</kbd>+<kbd>b</kbd>：上一屏
    - <kbd>d</kbd>，<kbd>Ctrl</kbd>+<kbd>d</kbd>：下半屏
    - <kbd>u</kbd>，<kbd>Ctrl</kbd>+<kbd>u</kbd>：上半屏
    - <kbd>Enter</kbd>，<kbd>Ctrl</kbd>+<kbd>N</kbd>，<kbd>e</kbd>，<kbd>Ctrl</kbd>+<kbd>E</kbd>，<kbd>j</kbd>，<kbd>Ctrl</kbd>+<kbd>J</kbd>：下一行
    - <kbd>y</kbd>，<kbd>Ctrl</kbd>+<kbd>Y</kbd>，<kbd>Ctrl</kbd>+<kbd>P</kbd>，<kbd>k</kbd>，<kbd>Ctrl</kbd>+<kbd>K</kbd>：上一行
    - <kbd>q</kbd>：退出
    - <kbd>#</kbd>：跳至第#行
    - <kbd>1</kbd><kbd>G</kbd>：回到文件首部
    - <kbd>G</kbd>：翻至文件尾部

**man 搜索**

- `/KEYWORD`
  
    ```
    以 KEYWORD 指定的字符串为关键字，从当前位置向文件尾部搜索；不区分大小写
    n：下一个
    N：上一个
    ```
- `?KEYWORD`
  
    ```
    以 KEYWORD 指定的字符串为关键字，从当前位置向文件首部搜索；不区分大小写
    n：跟搜索命令同方向，下一个
    N：跟搜索命令反方向，上一个
    ```

**info**

- man 常用于命令参考，GNU 工具 info 适合通用文档参考
- 没有参数，列出所有的页面
- info 页面的结构就像一个网站
- 每一页分为“节点”
- 链接节点之前*
- `info [命令]`

**导航 info 页面**

- 方向键，<kbd>PageUp</kbd>，<kbd>PageDown</kbd> 导航
- <kbd>Tab</kbd> 移动到下一个链接
- <kbd>b</kbd> 显示主题目录
- <kbd>Home</kbd> 显示主题首部
- <kbd>Enter</kbd> 进入选定连接
- <kbd>n</kbd>/<kbd>p</kbd>/<kbd>u</kbd>/<kbd>l</kbd> 进入下/前/上一层/最后一个链接
- <kbd>s</kbd> 文字 文本搜索
- <kbd>q</kbd> 退出 info

**通过本地文档获取帮助**

- System -> help（CentOS6）
- Applications -> documentation -> help（CentOS7）
    - 提供的官方使用指南和发行注记
- /usr/share/doc 目录
    - 多数安装了的软件包的子目录，包括了这些软件的相关原理说明
    - 常见文档：README INSTALL CHANGES
    - 不适合其他地方的文档的位置
        - 配置文件范例
        - HTML/PDF/PS 格式的文档
        - 授权书详情

sosreport
**网站和搜索**
- http://www.tldp.org
- http://www.slideshare.net
- http://www.googe.com
    ```
    Openstack filetype:pdf
    rhca site:redhat.com/docs
    ```

## bash 的快捷键

- <kbd>Ctrl</kbd> + <kbd>l</kbd> 清屏，相当于 clear 命令
- <kbd>Ctrl</kbd> + <kbd>o</kbd> 执行当前命令，并重新显示本命令
- <kbd>Ctrl</kbd> + <kbd>s</kbd> 阻止屏幕输出，锁定
- <kbd>Ctrl</kbd> + <kbd>q</kbd> 允许屏幕输出
- <kbd>Ctrl</kbd> + <kbd>c</kbd> 终止命令
- <kbd>Ctrl</kbd> + <kbd>z</kbd> 挂起命令
- <kbd>Ctrl</kbd> + <kbd>a</kbd> 光标移动命令行首，相当于 Home
- <kbd>Ctrl</kbd> + <kbd>e</kbd> 光标移动到命令行尾，相当于 End
- <kbd>Ctrl</kbd> + <kbd>f</kbd> 光标向右移动一个字符
- <kbd>Ctrl</kbd> + <kbd>b</kbd> 光标向左移动一个字符
- <kbd>Alt</kbd> + <kbd>f</kbd> 光标向右移动一个单词尾
- <kbd>Alt</kbd> + <kbd>b</kbd> 光标向左移动一个单词首
- <kbd>Ctrl</kbd> + <kbd>x</kbd> 光标在命令行首和光标之间移动
- <kbd>Ctrl</kbd> + <kbd>u</kbd> 从光标处删除至命令行首
- <kbd>Ctrl</kbd> + <kbd>k</kbd> 从光标处删除至命令行尾
- <kbd>Alt</kbd> + <kbd>r</kbd> 删除当前整行
- <kbd>Ctrl</kbd> + <kbd>w</kbd> 从光标处向左删除至单词首
- <kbd>Alt</kbd> + <kbd>d</kbd> 从光标处向右删除至单词尾
- <kbd>Ctrl</kbd> + <kbd>d</kbd> 删除光标处的一个字符
- <kbd>Ctrl</kbd> + <kbd>h</kbd> 删除光标前的一个字符
- <kbd>Ctrl</kbd> + <kbd>y</kbd> 将删除的字符粘贴至光标后
- <kbd>Alt</kbd> + <kbd>c</kbd> 从光标处开始向右更改为首字母大写的单词
- <kbd>Alt</kbd> + <kbd>u</kbd> 从光标处开始，将右边一个单词更改为大写
- <kbd>Alt</kbd> + <kbd>l</kbd> 从光标处开始，将右边一个单词更改为大写
- <kbd>Ctrl</kbd> + <kbd>t</kbd> 交换光标处和之前的字符位置
- <kbd>Alt</kbd> + <kbd>t</kbd> 交换光标处和之前的单词位置
- <kbd>Alt</kbd> + <kbd>n</kbd> 提示输入指定字符后，重复显示该字符 N 次
