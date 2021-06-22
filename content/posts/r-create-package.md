---
title: 新建R包
date: '2020-09-09 00:00:00'
updated: '2020-09-09 00:00:00'
tags:
- R
categories:
- R
---
# 新建R包


## 创建R包

首先必须安装RStudio.

然后点击File -> New Project，然后选择New Directory，接着选择R Package，最后给你R包取个名字即可，如下图所示：

![img](http://www.bioinfo-scrounger.com/data/photo/rpackage_creat.png)rpackage_creat

RStudio会在当前目录（默认是个人目录下）创建一个R包文件夹，主要文件（夹）包括：`man`，`R`，`DESCRIPTION`，`NAMESPACE`以及`xx.Rproj`

如果你R包使用的比较多的话，一般就能看明白man文件夹主要放的是一些.Rd文件，R文件夹则是这个R包的R code，DESCRIPTION文件写了这个R的描述信息，NAMESPACE则是命名空间（比较重要，但不是必须的）

先对DESCRIPTION文件进行修改（在RStudio右边Files里打开），这个文件主要为了告诉别人（或者自己）这个R包的一些重要的元数据（官方说法），我将模板修改为如下所示

![img](http://www.bioinfo-scrounger.com/data/photo/rpackage_description.png)rpackage_description

这里主要有几个点，Package包名，Author作者，Description描述信息，Imports依赖包等；Suggests是指那些不是必须的包，License则是协议，最后保存下

接着需要准备好一个写好的R自定义函数，比如我先在R文件夹创建一个uniprot.R文件，然后将函数写入该文件；其实R包粗略的理解就是多个函数的集合，我们使用R包就是将输入参数导入函数中，然后函数给我们一个结果。比如我的函数如下：

```
idmapping <- function(query, inputid, outputid, fmt){
  query <- paste(query, collapse = ",")
  r <- httr::POST('http://www.uniprot.org/uploadlists/', body = list(from= inputid, to = outputid, format = fmt, query = query), encode = "form")
  cont <- httr::content(r, type = "text")
  result <- readr::read_tsv(cont)
}
```

我们需要给上述`idmapping`函数写个文档，告诉使用者这个函数是做什么用的（也可以方便自己记忆）；其实我们再使用R包的时候，为了查看一个函数的使用，都会`?函数名`来阅读使用说明，其实这个使用说明就是接下来要说的对象文档

1. 首先给函数加上注释信息，这里的注释信息不是我们常见的代码注释，而是对函数整体的roxygen注释，主要为了方便后续文档的生成（前人已经帮我们简化了最繁琐的步骤！！！），我比较喜欢用RStudio的快捷键来实现：`Ctrl+Shift+Alt+R`（光标放在函数名上, Code->Insert Roxygen Skeleton），然后其会生成一个最基础的模板，我们按照自己的函数的具体情况做些修改，如下：

   ![img](http://www.bioinfo-scrounger.com/data/photo/rpackage_wendang.png)rpackage_wendang

2. 接着输入`devtools::document()`，自动会在man文件夹下生成该函数的Rd文档

3. 如果修改函数注释后，再重新执行第二步即可

最后安装下自己的这个R包，这里还是用RStudio的功能：点击Build -> Build & Reload，其会重新编译这个R包，更新文档等操作，并重新加载R包；我用`?idmapping`看下自己写的文档（我写的有点粗糙了。。。）

![img](http://www.bioinfo-scrounger.com/data/photo/rpackage_help.png)rpackage_help

最后我们需要考虑的是将这个R包放在哪，传CRAN就暂时别想了，身为野包就要有野包的觉悟，当然也不能放在自己电脑里（不方便别人安装使用），那么Github则是最佳的选择的了，比如我存放的路径是：https://github.com/kaigu1990/rpackage，那么安装方式如下：

```
devtools::install_github("kaigu1990/rpackage")
library(rmytools)
```

这样我随时随地都可以安装并使用自己的R包咯，也方便别人使用


## 参考文档

https://www.bioinfo-scrounger.com/archives/546/