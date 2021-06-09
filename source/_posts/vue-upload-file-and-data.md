---
title: vue上传文件并携带数据
date: '2020-03-23 00:00:00'
updated: '2020-03-23 00:00:00'
tags:
- VUE
categories:
- VUE
---
# vue上传文件并携带数据

使用ElementsUI的upload组件[官方地址](https://element.eleme.io/#/zh-CN/component/upload)

```vue
<el-upload
           class="upload-demo"
           ref="upload"
           action="https://jsonplaceholder.typicode.com/posts/"  // 后台服务url
           :auto-upload="false"
           :data="otherData" // 添加需要上传的数据
           >
    <el-button slot="trigger" size="small" type="primary">选取文件</el-button>
    <el-button style="margin-left: 10px;" size="small" type="success" @click="submitUpload">上传到服务器</el-button>
    <div slot="tip" class="el-upload__tip">只能上传jpg/png文件，且不超过500kb</div>
</el-upload>
<script>
    export default {
        data() {
            return {
                otherData: {"id": "A01", "name": "zhangsan"}
            };
        },
        methods: {
            submitUpload() {
                this.$refs.upload.submit();
            }
        }
    }
</script>
```

注意, 使用此方法上传文件时, 请求头中```ContenType=multipart/form-data```, 此时使用的是Form Data形式的数据, 后台SpringMVC需使用@RequestParam进行接收, 对上传的文件可以直接使用@RequestParam("file")进行封装, 但是对于otherData, 本人使用String类型数据进行接收, 并使用阿里巴巴的JSON类对其进行转换, 进而得到相应对象.

```java
@RequestMapping(value = "/method")
@ResponseBody
public String method(@RequestParam("otherDataStr") String otherDataStr,
                     @RequestParam(value = "file", required = false) MultipartFile file) {

    OtherDataStr otherData = JSON.parseObject(otherDataStr, OtherDataStr.class);
```
