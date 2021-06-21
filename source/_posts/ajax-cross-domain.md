---
title: Ajax跨域问题
date: '2020-02-20 00:00:00'
updated: '2020-02-20 00:00:00'
tags:
- JavaScript
- Ajax
categories:
- JavaScript
---
# Ajax跨域问题

## 跨域的概念
> 下面要介绍一个知识叫做跨域, 这个知识点是源于一个叫同源策略的东西.

**同源策略 :**

> 同源策略是浏览器上为安全性考虑实施的非常重要的安全机制. Ajax默认时能获取到同源的数据, 对于非同源的数据, Ajax默认是获取不到的.

下面举一个例子, 来看看什么叫做同源:

> 比如说有一个页面, 它的地址为http://www.example.com:80/dir/page.html, 在这个网址中要去获取服务器的数据, 获取数据的地址如下所示, 在下面的地址中, 有的是同源, 有的是非同源.

URL | 结果 | 原因
--- | --- | --- 
https://www.example.com/dir/other.html | 不同源 | 协议不同, http与https
http://en.example.com/dir/other.html | 不同源 | 域名不同
http://www.example.com:81/dir/other.html | 不同源 | 端口不同
http://www.example.com/dir/page2.html | 同源 | 协议, 域名, 端口都相同
http://www.example.com/dir2/other.html | 同源 | 协议, 域名, 端口都相同

==**所谓同源就是协议, 域名, 端口三者都完全一样**==

使用ajax来请求非同源路径下的数据, 示例 :
```html
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Title</title>
    </head>
    <body>
        <button onclick="ajaxtest()">测试ajax非同源请求</button>
    </body>
    <script>
        function ajaxtest() {
            var xhr = null;
            if (window.XMLHttpRequest) {
                xhr = new XMLHttpRequest();
            } else {
                xhr = new ActiveXObject("Microsoft.XMLHTTP");
            }
            var param = "w=" + "你好";
            xhr.open("post", "http://baidu.com", true);
            xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
            xhr.send(param);
            xhr.onreadystatechange = function () {
                if (xhr.readyState == 4) {
                    if (xhr.status == 200) {
                        console.log("请求成功...")
                    } else {
                        console.log("请求失败...")
                    }
                } else {
                    console.log("!4, 请求失败");
                }
            }
        }
    </script>
</html>
```

点击按钮, 会报
![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2021/20210609142949.png)

**前端页面访问非同源的服务器这种需求是非常常见的**, 比如在前端页面中获取天气数据, 天气数据肯定是存在于别人的服务器上的, 我们如果不能使用ajax进行访问的话, 该怎么办呢? 这里就需要使用到 **==跨域==** 了.

所以, 不管是ajax还是跨域, 都是为了访问服务器数据. 简单来说, ==**Ajax是为了访问自己服务器的数据, 跨域是为了访问别人服务器的数据.**==

## 跨域的实现

XMLHttpRequest对象默认情况下是无法获取到非同源服务器下的数据的. 那么怎么获取别人服务器的数据呢? 使用XMLHttpRequesst是达不到的, 我们只能另辟蹊径.

我们可以通过script标签, 用script标签的src属性引入一个外部文件, 这个外部文件是不涉及到同源策略的影响的.

例如 :
```html
<script type="text/javascript" src="http://www.baidu.com/xxx.js"></script>
```

==**跨域的本质其实就是服务器返回一个方法调用, 这个方法是我们事先定义好的, 而方法中的参数就是我们想要的数据.**==

**示例**

- weather.html

  ```html
  <!DOCTYPE html>
  <html lang="en">
      <head>
          <meta charset="UTF-8">
          <title>Title</title>
          <script type="text/javascript">
              window.onload = function () {
                  var btn = document.querySelector("#btn");
                  btn.onclick = function () {
                      var cityName = document.querySelector("#city").value;
  
                      // 动态创建script标签, 动态指定src属性的值
                      var script = document.createElement("script");
                      // 引入外部js/php文件, 动态添加相关参数并指定方法名
                      script.src = "http://www.lisi.com/data.php?city=" + cityName + "&callback=foo";
                      // 将function移动到业务逻辑中
                      window["foo"] = fucntion(data)
                      {
                          console.log(data);
                      }
                      ;
                      var head = document.querySelector("head");
                      head.appendChild(script);
                  }
              }
          </script>
      </head>
      <body>
          <h1>天气查询</h1>
          <input type="text" id="city" placeholder="请输入城市名称">
          <input type="button" id="btn" value="查询">
      </body>
  </html>
  ```

- http://www.lisi.com/data.php

  ```php
  <?php
      
      $cbName = $_GET["callback"];
      $city = $_GET["city"];
      if($city == "beijing"){
          echo $cbName."('北京的天气晴')"
      }else{
          echo $cbName."('没有查询到天气信息')"
      }
  ?>
  ```
淘宝提示词案例接口 :
属性 | 说明
--- | ---
地址 | https://suggest.taobao.com/sug
作用描述 | 获取淘宝提示词接口
请求类型 | GET
参数 | q: 关键字, callback: 回调方法名
返回数据格式 | Jsonp格式

## JQuery获取跨域数据

只需要将dataType指定为"jsonp"即可
```html
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Title</title>
        <script src="https://apps.bdimg.com/libs/jquery/2.1.4/jquery.min.js"></script>
        <script type="text/javascript">
            function btnClick() {
                // 使用JQuery来获取跨域数据
                // dataType: "jsonp"
                // key默认就是callback
                // value的值是以JQuery开头的字符串, 这个字符串就是函数调用的名称
                $.ajax({
                    url: "http://suggest.taobao.com/sug",
                    data: {
                        q: "j"
                    },
                    success: function (data) {
                        console.log(data);
                    },
                    dataType: "jsonp",
                    // 修改回调方法的key值
                    jsonp : "callback",
                    // 修改回调函数名
                    jsonpCallback : "haha"
                });
            }
        </script>
    </head>
    <body>
        <input type="button" id="btn" value="测试JQuery跨域请求" onclick="btnClick()">
    </body>
</html>
```
jsonp : json with padding, 是JSON的一种"使用模式"，可用于解决主流浏览器的跨域数据访问的问题。用 JSONP 抓到的资料并不是 JSON，而是任意的JavaScript，用 JavaScript 直译器执行而不是用 JSON 解析器解析。
