#!/usr/bin/env bash

# 根据不同的架构平台,安装docker
# https://download.docker.com/linux/centos/9/aarch64/stable/Packages/
# /Users/minxie/docker/centos_arrch64_rpm
cp /home/docker/centos_arrch64_rpm/*.rpm /home/docker/

yum install /home/docker/*.rpm -y

systemctl start docker

systemctl status docker
# 1. 安装docker
# 2. 安装docker-compose
# 3. 安装docker-machine
