#!/usr/bin/env bash

# 创建一个下载目录
mkdir -p ~/Downloads/soft/tmp

# max环境下安装 brew、jdk、idea等

# 安装brew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# 安装jdk
brew tap caskroom/versions && brew cask install java8

# 安装idea
brew cask install intellij-idea

# 安装maven
brew install maven

# 安装git
brew install git

# 安装微信
brew cask install wechat

# 安装企微
