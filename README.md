# ICan

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://github.com/MinXie1209/ican/main/LICENSE)
[![Commit activity](https://img.shields.io/github/commit-activity/m/MinXie1209/ican)](https://github.com/MinXie1209/ican/graphs/commit-activity)
[![Average time to resolve an issue](http://isitmaintained.com/badge/resolution/minxie1209/ican.svg)](http://isitmaintained.com/project/MinXie1209/ican "Average time to resolve an issue")
[![Percentage of issues still open](http://isitmaintained.com/badge/open/MinXie1209/ican.svg)](http://isitmaintained.com/project/MinXie1209/ican "Percentage of issues still open")
[![codecov](https://codecov.io/github/minxie1209/ican/branch/main/graph/badge.svg?token=WAIEL0SCX6)](https://app.codecov.io/github/minxie1209/ican)
![Build Status](https://github.com/minxie1209/ican/workflows/Workflow%20for%20Codecov%20ican/badge.svg)


[ican](https://github.com/MinXie1209/ican) 什么都能做。
如果你是个 Java 开发者，你一定会遇到这样的问题：
- 想要部署应用,需要装个虚拟机,装个虚拟机又要下载个linux镜像文件,安装linux需要各种各样的配置
- 想要安装docker,需要下载安装docker,然后还要下载各种镜像,配置各种文件
- 想要搭建harhor,harbor是什么?可能你都不知道是什么,还得去学习
- 想要部署k8s
- 想要安装更多

🔥🔥🔥ICan,为什么叫ICan?因为想要做的就能做,沉淀解决重复的问题,一键完成各种复杂麻烦的安装：

环境要求: 基于M1芯片,基于OrbStack(后面会慢慢适配)

能做什么?
* 创建虚拟机Centos
* 安装ssh
* 安装docker
* 安装harbor
* ...

-----------------

## 快速开始
在命令行中执行
1. 下载资源文件
```shell
sh download.sh
```
2. 启动脚本
```shell
sh main.sh
```

## 项目结构
```text
.
├── task-template : 任务模板
│   ├── download.mx : 这里定义需要下载的文件
│   └──  start.sh : 这里定义任务的启动脚本
├── tasks : 任务列表
│   ├── ansible
│   ├── ansible-semaphore
│   ├── docker
│   │   ├── centos_arrch64_rpm
│   │   └── dockerFile
│   │       └── nginx
│   ├── etcd
│   ├── harbor
│   ├── init
│   ├── other
│   └── zadig
├── common.sh : 公共方法
├── download.sh : 下载资源文件
├── main.sh : 启动脚本
└── README.md : 项目说明


```
