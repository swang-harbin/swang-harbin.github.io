---
title: Linux设置k380锁定fn按键
date: '2020-01-03 00:00:00'
tags:
- Linux
categories:
- Linux
---
# Linux设置k380锁定fn按键


使用如下github开源项目 : [k380-function-keys-conf](https://github.com/jergusg/k380-function-keys-conf)

## k380-function-keys-conf

Make function keys default on Logitech k380 bluetooth keyboard.
Instructions

First install gcc. On Ubuntu run:

```bash
sudo apt install gcc
```


Download installation files https://github.com/jergusg/k380-function-keys-conf/releases/ (Source code).

Connect your K380 keyboard via bluetooth to your computer.

Run build.sh

```bash
./build.sh
```


To switch keyboard's upper keys to F-keys run:

```bash
sudo ./k380_conf -d /dev/hidrawX -f on
```

Where X is number of your keyboard hidraw interface. Possibly 0, 1, 2, 3.
Switch keys to F-keys automatically

Follow instructions your received when you built k380_conf:

```bash
sudo cp /your-build-path/80-k380.rules /etc/udev/rules.d/ && sudo udevadm control --reload
```

Now, when you reconnect your keyboard it will be automatically switched to F-keys mode.
