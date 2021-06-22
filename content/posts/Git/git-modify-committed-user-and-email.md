---
title: Git修改已经提交的用户名和邮箱
date: '2021-04-05 00:00:00'
tags:
- Git
---
# Git修改已经提交的用户名和邮箱

```bash
git rebase -i HEAD~n
```

把`pick`修改为`e`

```bash
git commit --amend --author="userName <xxx@qq.com>"
```

```bash
git rebase --continue
```

