---
title: Typora 修改字体
date: '2021-06-23 00:00:00'
tags:
- Typora
---

# Typora 修改字体

1. File → Preferences...

![image-20210623151844146](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210623151939.png)

2. Appearance → Open Theme Folder

![image-20210623152057314](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210623152057.png)

3. 新建一个 base.user.css

![image-20210623152135297](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210623152135.png)

4. 在 base.user.css 中添加

   ```css
   body {
       font-family: "JetBrains Mono", "Ubuntu Mono", "DejaVu Sans Mono", "Open Sans","Clear Sans", "Helvetica Neue", Helvetica, Arial, sans-serif;
   }
   ```

   设置目标字体

5. 重启 Typora

