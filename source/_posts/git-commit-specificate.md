---
title: Git提交规范
date: '2020-04-15 00:00:00'
updated: '2020-04-15 00:00:00'
tags:
- Git
categories:
- Git
---
# Git提交规范

现在市面上比较流行的git的commit message方案时`约定式提交规范(ConventionalCommits)`, 其受到`Angular提交准则`的启发, 并很大程度上以其为依据. 

**标准格式如下 :**

```
<type>([scope]): <subject>
<BLANK LINE>
[body]
<BLANK LINE>
[footer]
```

**格式说明 :**

- `<type>([scope]): <subject>`称为页眉(head), `[body]`称为正文, `[footer]`称为页脚.
- 页眉与正文, 正文与页脚之间必须包含1个空行(`<BLANK LINE>`)
- 其中`type`, `subject`, `BLANK LINE`是必填信息, 其他信息可选填
- 每次提交的信息不超过`100`个字符
- `type:`和`subject`之间包含1个空格


## 属性及其可选值说明

### type(提交类型)

==必填项==, 用来说明此次提交的类型

提交类型可指定为下面其中的一个:

**主要type**

1. `feat`：增加新的特征
2. `fix`：修复bug

**Angular提交准则中其他推荐type**

1. `build`：对构建系统或者外部依赖项进行了修改
2. `ci`：对CI配置文件或脚本进行了修改
3. `docs`：对文档进行了修改
4. `pref`：提高性能的代码更改
5. `refactor`：既不是修复bug也不是添加特征的代码重构
6. `style`：不影响代码含义的修改，比如空格、格式化、缺失的分号等
7. `test`：增加确实的测试或者矫正已存在的测试

**其他推荐type**

1. `improvement`: 在不添加新功能或修复bug的情况下改进当前的实现

### scope(作用域)

可填项, 取值范围可以是任何指定提交更改位置的内容

### subject(主题)

==必填项==, 包括对本次修改的简洁描述

**填写准则 :**

1. 使用命令式, 现在时态: "改变"不是"已改变"也不是"改变了"
2. 不要大写首字母
3. 不要在末尾填写句号

### body(正文)

可填项, 包括**修改的动机**以及**和之前行为的对比**

**填写准则 :**

1. 使用命令式, 现在时态
2. 对小的修改不做要求, 但重大需求, 更新等必须添加body来说明
3. 多个改动可以换行说明, 但是如果改动过多, 建议分解为多个commit进行提交

### footer(页尾)

可填项, 主要包括对**不兼容修改的说明**以及**引用提交的问题**

#### 对不兼容修改的说明

不兼容修改指的是本次提交修改了不兼容之前版本的API或者环境变量, 例如版本升级, 接口参数减少, 接口删除, 迁移等.

所有不兼容修改都必须在页尾中作为中断更改块提到, 以`BREAKING CHANGES:`开头, 后面跟1个空格, 其余的信息就是对此次修改的描述, 修改理由和修改注释.

示例:
```
BREAKING CHANGE: isolate scope bindings definition has changed and
    the inject option for the directive controller injection was removed.
    
    To migrate the code follow the example below:
    
    Before:
    
    。。。
    。。。
    
    After:
    
    。。。
    。。。
    
    The removed `inject` wasn't generaly useful for directives so there should be no code using it.
```

#### 引用提交的问题(affect issue)

如果本次提交目的是修改`issue`的话, 需要在页脚引用该`issue`

例如关闭`issue`
```
Closes #234
```

如果修改了多个bug，以逗号隔开
```
Closes #123, #245, #992
```

### 回滚设置

当此次提交包含回滚(revert)操作，那么页眉以`revert:`开头，同时在正文中添加`This reverts commit hash`，其中`hash`值表示被回滚前的提交

```
revert:<type>(<scope>): <subject>
<BLANK LINE>
This reverts commit hash
<other-body>
<BLANK LINE>
<footer>
```

## 实现示例

只有页眉和页尾
```
feat: allow provided config object to extend other configs

BREAKING CHANGE: `extends` key in config file is now used for extending other config files
```

只有页眉
```
docs: correct spelling of CHANGELOG
```

使用了作用域
```
feat(lang): added polish language
```

修复了bug
```
fix: minor typos in code

see the issue for details on the typos fixed

fixes issue #12
```

## 参考文档

[git-guide](https://zj-git-guide.readthedocs.io/zh_CN/stable/message-guideline.html)

