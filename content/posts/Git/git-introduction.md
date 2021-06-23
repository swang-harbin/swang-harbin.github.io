---
title: Git 入门
date: '2019-07-18 00:00:00'
tags:
- Git
---
# Git 入门

## CentOS 安装 git

```bash
yum install git
```
安装完成后，设置该计算机上 git 仓库的用户名和邮箱
```bash
git config --global user.name "Your Name"
git config --global user.email "email@example.com"
```
- `--global`：表示这台机器上所有 Git 仓库都会使用这个配置

使用 `git init` 把当前目录变成 Git 可以管理的仓库
```bash
git init
```
## 版本控制
使用 `git log` 查看所有提交，或加上 `--pretty=oneline` 查看简略版
```bash
git log
git log --pretty=oneline
```
使用 `git reset` 回退版本，`HEAD^` 代表上一版本，上上版本就是 `HEAD^^`，或者使用 `HEAD~100` 代表往上 100 个版本
```bash
git reset --hard HEAD^
git reset --hard HEAD^^
git reset --hard HEAD~100
```
使用 `git reflog` 查看每一次命令
```bash
git reflog
```
使用 `git reset --hard 版本号` 回退到指定版本
```bash
git reset --hard 3s4d2s
```
使用 `git status` 查看状态
```bash
git status
```
使用 `git add <file> ...` 添加到暂存区
```bash
git add file1.txt
git add file2.txt file3.txt
```
使用 `git commit` 将暂存区的文件全部提交到版本库
```bash
git commit -m "message"
```
使用 `git checkout -- <file> ...` 丢弃工作区的更改
```bash
git checkout -- readme.txt
```
- 自修改后还没有被放到暂存区，撤销修改就回到和版本库一模一样的状态；
- 已经添加到暂存区后，又做了修改，撤销修改就回到添加到暂存区后的状态。

使用 `git reset HEAD <file>` 撤销暂存区的修改，重新放回工作区
```bash
git reset HEAD readme.txt
```
- 之后可以使用 `git checkout -- <file>` 撤销工作区的修改。

- 如果将修改提交到了版本库，使用版本回退即可。
  ```bash
  git reset --hard HEAD^等/版本号
  ```
  使用 `git rm <file> ...` 删除版本库的文件
  
  ```bash
  git rm test.txt
  ```
  
- 删除后可以使用 `commit` 提交一下更改，并使用 `rm` 命令删除本地文件
  ```bash
  git commit -m "remove test.txt"
  rm test.txt
  ```
  如果误删了工作区的文件，可以使用 `git checkout` 从版本库还原

  ```bash
  git checkout -- test.txt
  ```

## 远程版本库(使用 GitHub)
在用户目录下创建 ssh key 秘钥，成功后，会出现一个 .ssh 的文件夹，里面包含私钥 id_rsa 和公钥 id_rsa.pub。
```bash
ssh-keygen -t rsa -C "youremail@example.com"
```
在 GitHub 中添加 SSH Key  
- Account → Settings → SSH and GPG keys → New SSH key，Title 任意，将公钥粘贴到 Key 中。
  在 GitHub 中创建新的仓库

- ＋ → New repository，填写 Repository name，其他可以默认
  根据提示将本地仓库与该 GitHub 远程仓库关联

  ```bash
  git remote add origin git@github.com:swang-harbin/learngit.git
  ```

将本地仓库的文件推到 GitHub 远程仓库
```bash
git push -u origin master
```
- `-u` 代表将本地仓库的 master 分支与 GitHub 远程仓库的 master 分支进行关联，以后推送或拉取可以简化命令。
  只要本地做了提交，就可以把本地 master 分支的最新修改推送至 GitHub 仓库

  ```shell
  git push origin master
  ```

从 GitHub 服务器克隆仓库到本地仓库
```bash
git clone git@github.com:swang-harbin/gitskills.git
```
## 分支管理
创建 dev 分支
```bash
git branch dev
```
切换分支
```bash
git checkout dev
```
创建 dev 分支，并切换到 dev
```bash
git checkout -b dev
```
查看分支
```bash
git branch
```
将 dev 分支合并到 master 分支，merge 是将指定分支合并到当前分支
```bash
git merge dev
```
删除 dev 分支
```bash
git branch -d dev
```
在两个不同分支上都对同一文件进行了修改，会产生冲突。删除文件中的<<<<<<<<<< ========== >>>>>>>>>>，并修改为所需内容，重新 add、commit 即可解决冲突，并将两分支合并到当前分支。可以查看图形化的 log 日志
```bash
git log --graph --pretty=oneline --abbrev-commit
```
合并分支时，Git 默认使用 Fast forward 模式，在这种模式下，删除分支后，会丢掉被合并分支的信息。可以在合并时通过 `--no-ff` 禁用这种模式，合并后的历史有分支，能看出来曾经做过合并。
```bash
git merge --no-ff -m "merge with no-ff" dev
```
Bug 分支，当前正在 dev 分支上工作，但是需要去解决一个 master 分支上的 bug，但是 dev 分支上的代码没有开发完，不能提交，可以先将 dev 分支上当前的状态储藏起来。
```bash
git stash
```
解决完 bug 之后，可以切换到 dev 分支，查看之前储藏的纪录
```bash
git stash list
```
恢复工作现场
```bash
git stash apply
git stash drop
```
或
```bash
git stash pop
```
- 第一种 apply 恢复后，不会删除 stash，需要使用 drop 删除
- 第二种恢复 stash 后会自动将 stash 删除

恢复到指定 stash，例如 stash@{0}
```bash
git stash apply stash@{0}
```
强制删除一个没有被合并的分支
```bash
git branch -D feature-vulcan
```
## 多人协作
查看远程库信息
```bash
git remote -v
```
- `-v` 代表显示详细信息，可以不添加

推送分支，把该分支上的本地提交推送到远程库，推送时需要指定本地分支，例如 master
```bash
git push origin master
```
抓取分支，新用户从远程库克隆后，默认只能看到本地的 master 分支，如需抓取远程其他分支，例如 dev
```bash
git checkout -b dev origin/dev
```
## 通常，多人协作的工作模式
首先，可以试图推送自己的修改
```bash
git push origin <branch-name>
```
如果推送失败，则因为远程分支比你的本地更新，需要先用 `git pull` 试图合并；
```bash
git pull
```
如果合并有冲突，则解决冲突，并在本地提交；

没有冲突或者解决掉冲突后，再推送就能成功！
```bash
git push origin <branch-name>
```
如果 `git pull` 提示 no tracking information，则说明本地分支和远程分支的链接关系没有创建，用命令
```bash
git branch --set-upstream-to=origin/<branch-name> <branch-name>
```
## 变基操作
```bash
git rebase
```
## 标签管理
首先，切换到需要打标签的分支上
```bash
git checkout master
```
然后，使用 `git tag <name>` 默认在最新提交的 commit 上打标签
```bash
git tag v1.0
```
使用 `git tag` 查看所有标签
```bash
git tag
```
在历史提交上打标签 `git tag <tagName> <commitId>`
```bash
git tag v0.9 fd32da
```
创建带说明的标签 `git tag -a <tagName> -m <message> <commitId>`
```bash
git tag -a v0.1 -m "version 0.1 released" 1094adb
```
删除标签 `git tag -d <tagName>`
```bash
git tag -d v0.1
```
推送某个标签到远程 `git push origin <tagName>`
```bash
git push origin v1.0
```
推送全部未推送的本地标签
```bash
git push origin --tags
```
删除远程标签
- 先删除本地标签

  ```bash
  git tag -d v0.9
  ```

- 再删除远程标签 `git push origon :refs/tags/<tagName>`

  ```bash
  git push origon :refs/tags/v0.9
  ```

## 关联多个远程库
解除与某一远程库的关联 `git remote rm <repositoryName>`
```bash
git remote rm origin
```
关联 GitHub
```bash
git remote add github git@github.com:swang-harbin/learngit.git
```
关联码云
```bash
git remote add gitee fit@gitee.com:swang-harbin/learngit.git
```
## 自定义 Git
让 Git 显示颜色
```bash
git config --global color.ui true
```
## 忽略特殊文件 
GitHub 提供的忽略文件模板：[链接](https://github.com/github/gitignore/)

**忽略文件的原则**

1. 忽略操作系统自动生成的文件，比如缩略图等
2. 忽略变异生成的中间文件、可执行文件等，也就是如果一个文件是通过另一个文件自动生成的，那自动生成的文件就没必要放进版本库，比如 Java 编译产生的.class 文件
3. 忽略你自己的带有敏感信息的配置文件，比如存放口令的配置文件

强制添加被 `.gitignore` 忽略的文件
```bash
git add -f <file>
```
检查 `.gitignore`
```bash
git check-ignore -v <file>
```
## 配置别名
```bash
git config --global alias.st status
```
`--global` 只针对当前用户起作用，如果不加只针对当前仓库起作用。仓库的配置文件在 `.git/config` 中，用户的在用户主目录下的 `.gitconfig` 文件中。

## 搭建 Git 服务器
1. 安装 Git：

   ```bash
   sudo yum install git
   ```

2. 创建一个 git 用户，用来运行 git 服务：

   ```bash
   sudo adduser git
   ```

3. 创建证书登录：

   收集所有需要登录的用户的公钥，就是他们自己的 id_rsa.pub 文件，把所有公钥导入到 /home/git/.ssh/authorized_keys 文件里，一行一个。

4. 初始化 Git 仓库：先选定一个目录作为 Git 仓库，假定是 /srv/sample.git，在 /srv 目录下输入命令：

   ```bash
   sudo git init --bare sample.git
   ```

   Git 就会创建一个裸仓库，裸仓库没有工作区，因为服务器上的 Git 仓库纯粹是为了共享，所以不让用户直接登录到服务器上去改工作区，并且服务器上的 Git 仓库通常都以 .git 结尾。然后，把 owner 改为 git：

   ```bash
   sudo chown -R git:git sample.git
   ```

5. 禁用 shell 登录
   出于安全考虑，第二步创建的 git 用户不允许登录 shell，这可以通过编辑 /etc/passwd 文件完成。找到类似下面的一行：

   ```bash
   git:x:1001:1001:,,,:/home/git:/bin/bash
   ```

   改为：

   ```bash
   git:x:1001:1001:,,,:/home/git:/usr/bin/git-shell
   ```

   这样，git 用户可以正常通过 ssh 使用 git，但无法登录 shell，因为我们为 git 用户指定的 git-shell 每次一登录就自动退出。

6. 克隆远程仓库：

   ```bash
   git clone git@server:/srv/sample.git
   ```

方便管理公钥：用[Gitosis](https://github.com/sitaramc/gitolite)
控制权限：用[Gitolite](https://github.com/sitaramc/gitolite)
