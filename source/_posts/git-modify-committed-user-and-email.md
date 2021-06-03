---
title: Git修改已经提交的用户名和邮箱
date: '2021-04-05 00:00:00'
updated: '2021-04-05 00:00:00'
tags:
- Git
categories:
- Git
---
# Git修改已经提交的用户名和邮箱

```shell
git rebase -i HEAD~n
```

把`pick`修改为`e`

```shell
git commit --amend --author="userName <xxx@qq.com>"
```

```shell
git rebase --continue
```

