---
title: Annotation注解
date: '2019-12-23 00:00:00'
updated: '2019-12-23 00:00:00'
tags:
- Annotation
- Java
categories:
- Java
---
# Annotation注解

Annotation是从JDK1.5之后提出的一个新的开发技术结构, 利用Annotation可以有效的减少程序配置的代码, 可以利用Annotation进行一些结构化的定义. Annotation是以一种注解的形式实现的程序开发.

如果要想清楚Annotation的产生意义, 必须了解下程序开发结构的历史, 从历史来讲,

## 程序开发共分为三个过程 :

### 过程一

在程序定义的时候, 将所有可能使用到的资源全部定义在程序代码之中

![img](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2020/20201129023528.png)

此方法如果数据库IP改变后, 需要修改原代码

### 过程二

引入配置文件, 在配置文件中定义全部要使用的服务器资源 

![](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2020/20201129024434.png)

在配置项不多的情况下, 此类配置非常好用, 十分简单. 但是如果所有的项目都使用这种方式开发, 可能出现配置文件暴多

所有的操作都需要通过配置文件完成, 这样对于开发的难度提升了

### 过程三

将配置信息重新写回到程序里, 利用一些特殊的标记与程序代码分离.

如果全部都使用注解开发, 难度太高了, 配置文件也有好处也有缺点, 所以现在使用注解加配置文件的形式开发.

## Java中的内置注解

### 基本注解

#### @Override(覆盖)

检查该方法是否是重写方法. 如果如果发现其父类, 或者是引用的接口中并没有该方法时, 会报编译错误

```java
package java.lang;
/**
 * @since 1.5
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.SOURCE)
public @interface Override {
}
```

在进行覆盖时, 发生如下状况, 在编译时不会产生任何的错误信息

- 虽然明确继承一个父类并进行方法的覆盖, 但是忘记写extends关键字
- 在进行方法覆盖时单词写错了

可通过@Override标记在方法上, 明确表示该方法是覆盖的方法, 可以在编译过程中将bug暴露出来, 保证覆盖的准确性

示例:

```java
class Base {
    void method() {
    }
}

class Sub extends Base {
    @Override
    void method() {
    }
}
```

#### @Deprecated(过期操作)

标记过时方法. 如果使用该注解标记的方法, 会报编译警告

```java
package java.lang;
/**
 * @since 1.5
 */
@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target(value={CONSTRUCTOR, FIELD, LOCAL_VARIABLE, METHOD, PACKAGE, PARAMETER, TYPE})
public @interface Deprecated {
}
```

所谓的过期操作指的是在一些软件项目的迭代过程中, 可能有某个类或方法由于在最初设计时考虑不周, 导致新版本的应用会有不适应的地方(老版本不影响), 这个时候又不能直接删除这些操作, 给一个过渡的时间, 于是可以采用过期的声明, 目的告诉新的用户不要使用这些操作.

例如:

```java
public class Date
    implements java.io.Serializable, Cloneable, Comparable<Date>
{
    @Deprecated
    public Date(int year, int month, int date, int hrs, int min) {
        this(year, month, date, hrs, min, 0);
    }
}
```

#### @SuppressWarnings(压制警告)

指示编译器去忽略该注解中声明的警告

```java
package java.lang;
/**
 * @since 1.5
 */
@Target({TYPE, FIELD, METHOD, PARAMETER, CONSTRUCTOR, LOCAL_VARIABLE, MODULE})
@Retention(RetentionPolicy.SOURCE)
public @interface SuppressWarnings {
    String[] value();
}
```

| 可取值                   | 说明                                                         |
| ------------------------ | ------------------------------------------------------------ |
| all                      | to suppress all warnings（抑制所有警告）                     |
| boxing                   | to suppress warnings relative to boxing/unboxing operations（要抑制与箱/非装箱操作相关的警告） |
| cast                     | to suppress warnings relative to cast operations（为了抑制与强制转换操作相关的警告） |
| dep-ann                  | to suppress warnings relative to deprecated annotation（要抑制相对于弃用注释的警告） |
| deprecation              | to suppress warnings relative to deprecation（要抑制相对于弃用的警告） |
| fallthrough              | to suppress warnings relative to missing breaks in switch statements（在switch语句中，抑制与缺失中断相关的警告） |
| finally                  | to suppress warnings relative to finally block that don’t return（为了抑制警告，相对于最终阻止不返回的警告） |
| hiding                   | to suppress warnings relative to locals that hide variable（为了抑制本地隐藏变量的警告） |
| incomplete-switch        | to suppress warnings relative to missing entries in a switch statement (enum case)（为了在switch语句（enum案例）中抑制相对于缺失条目的警告） |
| nls                      | to suppress warnings relative to non-nls string literals（要抑制相对于非nls字符串字面量的警告） |
| null                     | to suppress warnings relative to null analysis（为了抑制与null分析相关的警告） |
| rawtypes                 | to suppress warnings relative to un-specific types when using generics on class params（在类params上使用泛型时，要抑制相对于非特异性类型的警告） |
| restriction              | to suppress warnings relative to usage of discouraged or forbidden references（禁止使用警告或禁止引用的警告） |
| serial                   | to suppress warnings relative to missing serialVersionUID field for a serializable class（为了一个可串行化的类，为了抑制相对于缺失的serialVersionUID字段的警告） |
| static-access            | o suppress warnings relative to incorrect static access（o抑制与不正确的静态访问相关的警告） |
| synthetic-access         | to suppress warnings relative to unoptimized access from inner classes（相对于内部类的未优化访问，来抑制警告） |
| unchecked                | to suppress warnings relative to unchecked operations（相对于不受约束的操作，抑制警告） |
| unqualified-field-access | to suppress warnings relative to field access unqualified（为了抑制与现场访问相关的警告） |
| unused                   | to suppress warnings relative to unused code（抑制没有使用过代码的警告） |

例如:

```java
class Base {
    @SuppressWarnings({"unused"})
    void method() {
    }
}
```

### 元注解

注解在其他注解类上的注解, 称为元注解

#### @Retention

指明标识了该注解的注解的生命周期. 默认值为`RetentionPolicy.CLASS`.

```java
package java.lang.annotation;

/**
 * @since 1.5
 */
@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.ANNOTATION_TYPE)
public @interface Retention {
    RetentionPolicy value();
}
```

| 可取值                  | 说明                                                         |
| ----------------------- | ------------------------------------------------------------ |
| RetentionPolicy.SOURCE  | 标识了该注解的注解仅存在于编译器处理期间, 编译结束后的.class文件中是没有该注解信息的 |
| RetentionPolicy.CLASS   | 标识了该注解的注解会被记录在编译生成的.class文件中, 但在虚拟机运行时失效 |
| RetentionPolicy.RUNTIME | 标识了该注解的注解会被记录在编译生成的.class文件中, 在虚拟机运行时依旧存在, 所以可以通过反射来进行读取 |

**RetentionPolicy :**

```java
package java.lang.annotation;

/**
 * @since 1.5
 */
public enum RetentionPolicy {
    SOURCE,
    CLASS,
    RUNTIME
}
```

#### @Documented

指明标注了该注解的注解能够包含到Javadoc中去

```java
package java.lang.annotation;
/**
 * @since 1.5
 */
@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.ANNOTATION_TYPE)
public @interface Documented {
}
```

#### @Target

指明标注了该注解的注解可以标注在那些地方, 例如类, 属性, 方法等.

```java
package java.lang.annotation;
/**
 * @since 1.5
 */
@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.ANNOTATION_TYPE)
public @interface Target {
    ElementType[] value();
}
```

| 可选值                      | 说明                                                         |
| --------------------------- | ------------------------------------------------------------ |
| ElementType.TYPE            | 可标注在类, 接口(包含注解类), 枚举                           |
| ElementType.FIELD           | 可标注在字段上(包含枚举常量)                                 |
| ElementType.METHOD          | 可标注在方法上                                               |
| ElementType.PARAMETER       | 可标注在形式参数上                                           |
| ElementType.CONSTRUCTOR     | 可标注在构造方法上                                           |
| ElementType.LOCAL_VARIABLE  | 可标注在局部变量上                                           |
| ElementType.ANNOTATION_TYPE | 可标注在注解类上                                             |
| ElementType.PACKAGE         | 可标注在包上                                                 |
| ElementType.TYPE_PARAMETER  | since1.8, 可标注在任意声明类型的地方. // TODO 不懂           |
| ElementType.TYPE_USE        | since 1.8, 可标注在任何使用类型的地方. 例如new, 强制类型转换, implements子句和throws子句. |
| ElementType.MODULE          | since9, 声明模块. // TODO不了解                              |

**ElementType :**

```java
package java.lang.annotation;
/**
 * @since 1.5
 */
public enum ElementType {

    TYPE,

    FIELD,

    METHOD,
    
    PARAMETER,

    CONSTRUCTOR,

    LOCAL_VARIABLE,

    ANNOTATION_TYPE,

    PACKAGE,

    TYPE_PARAMETER,

    TYPE_USE,

    MODULE
}
```

#### @Inherited

指明标注了该注解的注解具有继承性. 例如MyAnnotation被标注了@Inherited, 现在一个类Base使用了MyAnnotation, 则它的子类Sub也具有MyAnnotation注解.

```java
package java.lang.annotation;

/**
* @since 1.5
*/
@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.ANNOTATION_TYPE)
public @interface Inherited {
}
```

#### @Repeatable

指明标注了该注解的注解, 可以在其可标注的地方标注多次.

```java
package java.lang.annotation;
/**
 * @since 1.8
 */
@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.ANNOTATION_TYPE)
public @interface Repeatable {
    Class<? extends Annotation> value();
}
```

例如 :

```java
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.TYPE)
@Documented
@Repeatable(MyAnnos.class)
public @interface MyAnno {
    String[] value() default {};
}

@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.TYPE)
@Documented
public @interface MyAnnos {
    
    MyAnno[] value();
    
}
```

### JDK1.7后新增非元注解

#### @SafeVarargs

忽略任何使用参数为泛型变量的方法或构造函数调用产生的警告

```java
package java.lang;
/**
 * @since 1.7
 */
@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.CONSTRUCTOR, ElementType.METHOD})
public @interface SafeVarargs {}
```

#### @FunctionalInterface

标识一个匿名函数或函数式接口

```java
package java.lang;

import java.lang.annotation.*;

/**
 * @since 1.8
 */
@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.TYPE)
public @interface FunctionalInterface {}
```

## 自定义注解

Java中使用`@interface`声明一个类为注解

```java
public @interface MyAnno {
}
```

可在其类上方标注之前介绍的元注解

```java
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.TYPE)
@Documented
public @interface MyAnno {

}
```

可在其内部指定方法

```java
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.TYPE)
@Documented
public @interface MyAnno {
    // 指定注解中有一个属性name, 没有默认值, 所以在使用该注解的时候, 必须给出值
    String name();

    // 指定注解中有一个属性value, 默认值为false, 在使用该注解时如果不指定, 则使用默认值
    boolean value() default false;
}
```

使用示例

```java
@MyAnno(name = "base")
public class Base{
    
}
```

使用Annotation之后最大特点是可以结合反射, 通过反射获取注解中的值

```java
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.TYPE)
@Documented
public @interface MyAnno {
    String name();

    boolean value() default false;
}

@MyAnno(name = "base")
public class Base {
    public static void main(String[] args) {
        Class<Base> clazz = Base.class;
        MyAnno anno = clazz.getAnnotation(MyAnno.class);
        System.out.println(anno.name() + " " + anno.value());
    }
}
```

输出结果

```
base false
```

