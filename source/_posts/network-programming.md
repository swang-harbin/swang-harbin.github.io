---
title: java网络编程
date: '2020-04-04 00:00:00'
updated: '2020-04-04 00:00:00'
tags:
- Java
categories:
- Java
---

# java网络编程

所谓的网络编程指的就是多台主机之间的数据通讯操作.

## 网络编程简介

网络的核心定义在于: 有两台以上的电脑就称为网络. 实际上在世界上产生第一台之后, 就有人开始思考如何将更多的电脑生产出来并将其进行有效的连接.

网络连接的目的不仅仅是为了进行电脑的串联, 更多的情况下是为了彼此之间的数据通讯, 包括现在所谓的网络游戏本质上还是网络通讯的问题. 而在通讯的实现上就产生了一系列的处理协议: IP, TCP, UDP等等, 也就是说所谓的网络编程就是一个数据的通讯操作而已, 只不过这个网络通讯操作需要分为客户端和用户端.

于是针对于网络程序的开发就有了两种模型:

- C/S(Client/Server, 客户端与服务器端): 要开发出两套程序, 一套客户端, 一套用户端, 如果服务器端发生了改变之后客户端也应该进行更新处理; 这种开发可以由开发者自定义传输协议, 并且使用一些比较私密的端口; 安全性比较高, 但是开发与维护成本比较高
- B/S(Browse/Server, 浏览器与服务器端), 只开发一套服务端的程序, 而后利用浏览器作为客户端进行访问, 这种开发与维护的成本较低(只有一套程序), 但是由于其使用的是公共的HTTP协议, 并且使用的是公共的80端口, 所以安全性较差, 现在的开发基本上以"B/S"结构为主.

本次所要讲解的网络编程主要就是C/S程序模型开发: TCP(可靠的数据连接), UDP(不可靠的数据连接);

## TCP程序的基本实现

TCP的程序开发是网络程序的最基本的开发模型, 其核心的特点是使用两个类实现数据的交互处理: ServerSocket(服务器端), Socket(客户端)

**ServerSocket与Socket :**

![](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2020/20201207210342.png)

> 每个服务端服务都需要使用ServerSocket来监听一个端口(门牌号), 客户端使用Socket向该端口发送请求, 被ServerSocket监听到, 进而被服务处理, 处理结束后, 需要给客户端返回消息, 此时服务端需要根据Socket来得知将返回的消息发送给哪个客户端.

ServerSocket的主要目的是设置服务器的监听端口, 而Socket需要指明要连接的服务器地址和端口. 下面实现一个最简单的数据处理操作, 即: Echo程序实现.

**Echo模型 :**

![](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2020/20201207210418.jpg)

- 实现服务器端的定义

  ```java
  import java.io.IOException;
  import java.io.PrintWriter;
  import java.net.ServerSocket;
  import java.net.Socket;
  import java.util.Scanner;
  
  public class EchoServer {
  
      public static void main(String[] args) throws IOException {
          ServerSocket server = new ServerSocket(9999); // 设置服务器端的监听端口
          System.out.println("等待客户端连接...........");
          Socket client = server.accept(); // 有客户端连接
          // 1. 首先需要先接收客户端发送来的信息, 然后才可以将信息处理后发送回客户端
          Scanner scan = new Scanner(client.getInputStream()); // 客户端输入流
          scan.useDelimiter("\n"); // 设置分隔符
          PrintWriter out = new PrintWriter(client.getOutputStream()); //客户端输出流
          boolean flag = true; // 循环标记
          while (flag) {
              if (scan.hasNext()) { // 现在有数据发送过来
                  String val = scan.next();
                  if ("byebye".equalsIgnoreCase(val)) {
                      out.println("byebye....");
                      flag = false;
                  } else {
                      out.println("[echo] " + val);
                  }
                  out.flush(); // 强制刷新缓冲区
              }
          }
          out.close();
          scan.close();
          client.close();
          server.close();
      }
  }
  ```

- 实现客户端的定义

  ```java
  import java.io.BufferedReader;
  import java.io.IOException;
  import java.io.InputStreamReader;
  import java.io.PrintWriter;
  import java.net.Socket;
  import java.util.Scanner;
  
  public class EchoClient {
  
      private static final BufferedReader KEYBOARD_INPUT = new BufferedReader(new InputStreamReader(System.in));
  
      public static void main(String[] args) throws IOException {
          Socket client = new Socket("localhost", 9999); // 定义服务端的连接信息
          // 现在客户端需要有输入与输出的操作支持, 所以依然要准备Scanner与PrintWrite
          Scanner scan = new Scanner(client.getInputStream()); // 接收服务端的输入内容
          scan.useDelimiter("\n");
          PrintWriter out = new PrintWriter(client.getOutputStream()); // 向服务端发送数据
          boolean flag = true;
          while (flag) {
              System.out.println("请输入要发送的内容:");
              String input = KEYBOARD_INPUT.readLine();
              out.println(input);
              out.flush();
              if (scan.hasNext()) {   // 服务器端有回应了
                  String val = scan.next();
                  System.out.println(val);
                  if ("byebye".equalsIgnoreCase(val)) {
                      flag = false;
                  }
              }
          }
          out.close();
          scan.close();
          client.close();
      }
  }
  ```

此时就完成了一个最基础的服务器与客户端之间的通讯

## 多线程与网络编程

现在尽管已经实现了一个标准的网络程序开发, 但是在整个开发过程之中, 本程序存在有严重的性能缺陷, 因为该服务器只能为一个线程提供Echo服务, 如果说现在的服务器需要有多人进行连接访问的时候, 那么其他的使用者将无法连接(等待连接).

所以现在就可以发现单线程的服务器开发就是一种不合理的做法, 那么此时最好的解决方案就是将每一个连接到服务器上的客户端都通过一个线程对象来进行处理, 即: 服务器上启动多个线程, 每一个线程单独为每一个客户端实现echo服务支持.

**Echo多线程模型(BIO)**

![image](https://gitee.com/swang-harbin/pic-bed/raw/master/images/2020/20201207210457.png)

修改服务器端程序

```java
import java.io.IOException;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.Scanner;

public class EchoServer {

    private static class ClientThread implements Runnable {
        private Socket client = null; // 描述每一个不通的客户端
        private Scanner scan = null;
        private PrintWriter out = null;

        public ClientThread(Socket client) throws IOException {
            this.client = client;
            this.scan = new Scanner(client.getInputStream());
            this.scan.useDelimiter("\n");
            this.out = new PrintWriter(client.getOutputStream());
        }

        @Override
        public void run() {
            boolean flag = true; // 循环标记
            while (flag) {
                if (scan.hasNext()) { // 现在有数据发送过来
                    String val = scan.next();
                    if ("byebye".equalsIgnoreCase(val)) {
                        out.println("byebye....");
                        flag = false;
                    } else {
                        out.println("[echo] " + val);
                    }
                    out.flush(); // 强制刷新缓冲区
                }
            }
            try {
                out.close();
                scan.close();
                client.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
    
    public static void main(String[] args) throws IOException {
        ServerSocket server = new ServerSocket(9999); // 设置服务器端的监听端口
        System.out.println("等待客户端连接...........");
        boolean flag = true; // 循环标记
        while (flag) {
            Socket client = server.accept(); // 有客户端连接
            new Thread(new ClientThread(client)).start();
        }
        server.close();
    }
}
```

如果在这类代码里再追加一些集合的数据控制, 实际上就可以实现一个80年代的聊天室了.

## 数据报发送与接收

之前所见到的都属于TCP程序开发范畴, TCP程序最大的特点是可靠的网络连接, 但是在网络程序开发之中还存在一种UDP的程序, 基于数据报的网络编程实现, 如果要想实现UDP程序, 需要两个类DatagramPacket(数据内容), DatagramSocket(网络发送与接收). 数据报就好比发送的短消息一样, 客户端是否接收到与发送者无关.

- 实现一个UDP客户端

  ```java
  import java.io.IOException;
  import java.net.DatagramPacket;
  import java.net.DatagramSocket;
  
  public class UDPClient {
  
      public static void main(String[] args) throws IOException {
          DatagramSocket client = new DatagramSocket(9999); // 连接到9999端口
          byte data[] = new byte[1024]; //接收消息
          DatagramPacket packet = new DatagramPacket(data, data.length);
          System.out.println("客户端等待接收发送的消息.........");
          client.receive(packet); // 接收消息, 所有的消息都在data字节数组中
          System.out.println("接收到的消息内容为: " + new String(data, 0, packet.getLength()));
          client.close();
      }
  }
  ```

- 实现一个UDP服务端

  ```java
  import java.io.IOException;
  import java.net.DatagramPacket;
  import java.net.DatagramSocket;
  import java.net.InetAddress;
  
  public class UDPServer {
  
      public static void main(String[] args) throws IOException {
          DatagramSocket server = new DatagramSocket(9000);
          String str = "www.example.com"; // 要发送的消息的内容
          DatagramPacket packet = new DatagramPacket(str.getBytes(), 0, str.length(), InetAddress.getByName("localhost"), 9999);
          server.send(packet);
          System.out.println("消息发送完毕....");
          server.close();
      }
  }
  ```

UDP发送的数据一定是不可靠的, 但是TCP由于要保证可靠的连接所以所需要的服务器资源就越多
