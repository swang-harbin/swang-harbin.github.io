---
title: 修改R语言包下载镜像源
date: '2020-09-09 00:00:00'
updated: '2020-09-09 00:00:00'
tags:
- R
categories:
- R
---
# 修改R语言包下载镜像源

- 全局配置文件: /etc/R/Rprofile.site
- 用户配置文件: ~/.Rprofile

如果`~`目录下没有, 将全局配置文件复制到`~`目录, 并重命名为`.Rprofile`即可


修改`~/.Rprofile`文件中镜像地址为国内源即可

```bash
local({
    r <- getOption("repos")
    r["CRAN"] <- "http://mirrors.tuna.tsinghua.edu.cn/CRAN/"
    options(repos = r)
})
```

