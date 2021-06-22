---
title: PathUtil
date: '2020-01-09 00:00:00'
tags:
- Java
categories:
- Java
---

# PathUtils

```java
import java.io.File;

public class PathUtils {

    private static final String FILE_SEPARATOR = File.separator;

    private PathUtils() {
    }


    /**
     * 文件路径中的分隔副全部转换为Unix风格：/
     * <p>
     * 例如：C:\\temp\ -> C://temp/
     *
     * @param path
     * @return
     */
    public static String toUnixSeparator(String path) {
        return path.replace("\\", "/");
    }

    /**
     * 文件路径中的分隔符全部转换为Windows风格：\
     * <p>
     * 例如： C://temp/ -> C:\\temp\
     *
     * @param path
     * @return
     */
    public static String toWindowsSeparator(String path) {
        return path.replace("/", "\\");
    }

    /**
     * 将文件路径中的分隔符转换为当前系统的分隔符
     * 例如：Windows : C://temp// -> C:\\temp\\
     * Unix : C:\\temp\\ -> C://temp//
     *
     * @param path
     * @return
     */
    public static String toSystemSeparator(String path) {
        return isUnix()
            ? toUnixSeparator(path)
            : toWindowsSeparator(path);
    }

    /**
     * 将文件路径中的分隔符转换为Unix风格并以一个/结尾
     * <p>
     * 例如：C:\\temp\\ -> C://temp/
     * C:\\temp -> C://temp/
     *
     * @param path
     * @return
     */
    public static String endWithSingleUnixSeparator(String path) {
        return endWithoutUnixSeparator(path) + "/";
    }

    /**
     * 将文件路径中的分隔符转换为Windows风格并以一个\结尾
     * <p>
     * 例如：C:/temp -> C:\temp\
     * C://temp// -> C:\\temp\
     *
     * @param path
     * @return
     */
    public static String endWithSingleWindowsSeparator(String path) {
        return endWithoutWindowsSeparator(path) + "\\";
    }

    /**
     * 将文件路径中的分隔符转换为当前系统的分隔符， 并且结尾包含一个分隔符
     * 例如： Windows ：
     * C://temp -> C:\\temp\
     * C://temp/ -> C:\\temp\
     * C：//temp// -> C:\\temp\
     * Unix :
     * C:\\temp -> C://temp/
     * C:\\temp\ -> C://temp/
     * C：\\temp\\ -> C://temp/
     *
     * @param path
     * @return
     */
    public static String endWithSingleSystemSeparator(String path) {
        return isUnix()
            ? endWithSingleUnixSeparator(p-ath)
            : endWithoutWindowsSeparator(path);
    }

    /**
     * 将文件路径中的分隔符转换为Unix风格, 并且结尾没有/
     * 例如： C:\\temp\ -> C://temp
     * C:\\temp\\ -> C://temp
     *
     * @param path
     * @return
     */
    public static String endWithoutUnixSeparator(String path) {
        return toUnixSeparator(path).replaceAll("^(.*?)/+$", "$1");
    }

    /**
     * 将文件路径中的分隔符转换为Windows风格, 并且结尾没有\
     * 例如： C://temp/ -> C:\\temp
     * C://temp// -> C:\\temp
     *
     * @param path
     * @return
     */
    public static String endWithoutWindowsSeparator(String path) {
        return toWindowsSeparator(path).replaceAll("^(.*?)\\\\+$", "$1");
    }


    /**
     * 将文件路径中的分隔符转换为当前系统的分隔符， 并且结尾没有分隔符
     * 例如： Windows ：
     * C://temp -> C:\\temp
     * C://temp/ -> C:\\temp
     * C：//temp// -> C:\\temp
     * Unix :
     * C:\\temp -> C://temp
     * C:\\temp\ -> C://temp
     * C：\\temp\\ -> C://temp
     *
     * @param path
     * @return
     */
    public static String endWithoutSystemSeparator(String path) {
        return isUnix()
            ? endWithoutUnixSeparator(path)
            : endWithoutWindowsSeparator(path);
    }


    /**
     * 将文件路径中的分隔符转换为Unix的分隔符， 相邻的多个分隔符只保留一个, 并且结尾包含一个分隔符
     * <p>
     * 例如:C:\\temp -> C:/temp/
     * C:\\temp\ -> C:/temp/
     * C:\\temp\\ -> C:/temp/
     * C:\/\temp\/\ -> C:/temp/
     *
     * @param path
     * @return
     */
    public static String removeDuplicateEndWithUnixSeparator(String path) {
        return endWithSingleUnixSeparator(path)
            .replaceAll("[/\\\\]+[/\\\\]+", "/");
    }

    /**
     * 将文件路径中的分隔符转换为Windows的分隔符， 相邻的多个分隔符只保留一个, 并且结尾包含一个分隔符
     * <p>
     * 例如:C://temp -> C:\temp\
     * C://temp/ -> C:\temp\
     * C://temp// -> C:\temp\
     * C:/\/temp/\/ -> C:\temp\
     *
     * @param path
     * @return
     */
    public static String removeDuplicateEndWithWindowsSeparator(String path) {
        return endWithSingleWindowsSeparator(path)
            .replaceAll("[/\\\\]+[/\\\\]+", "\\\\");
    }

    /**
     * 将文件路径中的分隔符转换为系统分隔符， 相邻的多个分隔符只保留一个, 并且结尾包含一个分隔符
     * <p>
     * 例如:
     * <p>
     * Unix：
     * C:\\temp -> C:/temp/
     * * C:\\temp\ -> C:/temp/
     * * C:\\temp\\ -> C:/temp/
     * * C:\/\temp\/\ -> C:/temp/
     * Windows：
     * C://temp -> C:\temp\
     * C://temp/ -> C:\temp\
     * C://temp// -> C:\temp\
     * C:/\/temp/\/ -> C:\temp\
     *
     * @param path
     * @return
     */
    public static String removeDuplicateEndWithSystemSeparator(String path) {
        return isUnix()
            ? removeDuplicateEndWithUnixSeparator(path)
            : removeDuplicateEndWithWindowsSeparator(path);
    }

    /**
     * 将文件路径中的分隔符转换为Unix的分隔符， 相邻的多个分隔符只保留一个, 并且结尾没有分隔符
     * <p>
     * 例如:C:\\temp -> C:/temp
     * C:\\temp\ -> C:/temp
     * C:\\temp\\ -> C:/temp
     * C:\/\temp\/\ -> C:/temp
     *
     * @param path
     * @return
     */
    public static String removeDuplicateEndWithoutUnixSeparator(String path) {
        return endWithoutUnixSeparator(path)
            .replaceAll("[/\\\\]+[/\\\\]+", "/");
    }

    /**
     * 将文件路径中的分隔符转换为Windows的分隔符， 相邻的多个分隔符只保留一个, 并且结尾没有分隔符
     * <p>
     * 例如:C://temp -> C:\temp
     * C://temp/-> C:\temp
     * C://temp// -> C:\temp
     * C:/\/temp/\/ -> C:\temp
     *
     * @param path
     * @return
     */
    public static String removeDuplicateEndWithoutWindowsSeparator(String path) {
        return endWithoutWindowsSeparator(path)
            .replaceAll("[/\\\\]+[/\\\\]+", "\\\\");
    }

    /**
     * 将文件路径中的分隔符转换为系统分隔符， 相邻的多个分隔符只保留一个, 并且结尾没有分隔符
     * <p>
     * 例如:
     * <p>
     * Unix:
     * C:\\temp -> C:/temp
     * C:\\temp\ -> C:/temp
     * C:\\temp\\ -> C:/temp
     * C:\/\temp\/\ -> C:/temp
     * Windows:
     * C://temp -> C:\temp
     * C://temp/-> C:\temp
     * C://temp// -> C:\temp
     * C:/\/temp/\/ -> C:\temp
     *
     * @param path
     * @return
     */
    public static String removeDuplicateEndWithoutSystemSeparator(String path) {
        return isUnix()
            ? removeDuplicateEndWithoutUnixSeparator(path)
            : removeDuplicateEndWithoutWindowsSeparator(path);
    }

    /**
     * 清除路径中的盘符
     * <p>
     * 例如：
     * Z:/temp/file -> /temp/file
     *
     * @param path
     * @return
     */
    public static String removeDiskChar(String path) {
        return path.substring(path.indexOf(":") + 1);
    }

    /**
     * 清除路径中指定前缀
     * <p>
     * 例如：
     * path = Z:/temp/file
     * prePath = Z:/temp
     * return /file
     *
     * @param path
     * @param prePath
     * @return
     */
    public static String removePrePath(String path, String prePath) {
        return path.substring(path.indexOf(prePath) + 1);
    }


    /**
     * 系统分隔符号为/返回true
     *
     * @return
     */
    private static boolean isUnix() {
        return FILE_SEPARATOR.equals("/");
    }

    /**
     * 分隔符号为\返回true
     *
     * @return
     */
    private static boolean isWindows() {
        return FILE_SEPARATOR.equals("\\");
    }
}
```
