---
title: 批量安装 R 包
date: '2020-09-09 00:00:00'
tags:
- R
---
# 批量安装 R 包

```R
words <- c("dplyr","purrr","rlang","readr","mlegp","tibble","magrittr","solartime","bigleaf","Rcpp")
for(var in words){
cat("start install " , var)
install.packages(var)
cat("installed ",var)
}
```
