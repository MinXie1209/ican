#!/usr/bin/env bash


# 打印分隔符
function printLine() {
  echo ""
  printf "%-70s" "-" | sed 's/\s/-/g'
  echo ""
}

# 保留颜色显示
function echoLnWithColor() {
  echo -e "\033[0;31m$(cat)\033[0m\n"
}

# 传入字符串,返回绿色的字符串
function echoLnWithGreen() {
  echo -e "\033[32m$1\033[0m\n"
}

# 传入字符串,返回红色的字符串
function echoLnWithRed() {
  echo -e "\033[31m$1\033[0m\n"
}

# 传入字符串,返回黄色的字符串
function echoLnWithYellow() {
  echo -e "\033[33m$1\033[0m\n"
}

# 传入字符串,返回蓝色的字符串
function echoLnWithBlue() {
  echo -e "\033[36m$1\033[0m\n"
}

# 空行
function echoBlankLine() {
  echo ""
}