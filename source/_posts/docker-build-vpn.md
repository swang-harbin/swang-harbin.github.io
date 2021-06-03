---
title: 使用Docker搭建VPN
date: '2019-12-27 00:00:00'
updated: '2019-12-27 00:00:00'
tags:
- Docker
- VPN
categories:
- Docker
---

http://medium.com/@gurayy/set-up-a-vpn-server-with-docker-in-5-minutes-a66184882c45



git clone https://github.com/kylemanna/docker-openvpn.git

cd docker-openvpn

docker build -t myownupn .

cd ..
mkdir vpn-data

docker run -v $PWD/vpn-data:/etc/openvpn --rm myownvpn ovpn_genconfig -u udp://IP_ADDRESS:3000

docker run -v $PWD/vpn-data:/etc/openvpn --rm -it myownvpn ovpn_initpki

docker run -v $PWD/vpn-data:/etc/openvpn -d -p 3000:1194/udp --cap-add=NET_ADMIN myownvpn

docker run -v $PWD/vpn-data:/etc/openvpn --rm -it myownvpn easyrsa build-client-full user1 nopass

docker run -v $PWD/vpn-data:/etc/openvpn --rm myownvpn ovpn_getclient user1 > user1.ovpn

