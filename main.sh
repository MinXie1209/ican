#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
source $DIR/common.sh
source common.sh

usage=$'用法: sh main.sh <系统命名>'

createSystem() {
  result=$(orbctl list |awk '{print$1}' | grep $1 || echo "")
  # 如果result不等于$1,则创建系统
  if [[ "$result" != "$1" ]]; then
    echoLnWithGreen "创建系统$1"
    orb create centos $1
  else
    echoLnWithGreen "系统$1已经存在"
  fi
}

sendFiles() {
  # 传输文件
  scp -Or ./tasks/* root@${1}@orb:/home
}

main() {
  # help
  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo $1
    echo "$usage"
    exit 0
  fi

  systemName=$1
  if [[ -z $1 ]]; then
      read -p "请输入系统名称:" systemName
  fi

  allStep=4
  echoLnWithGreen "[Step 1,TOTAL $allStep] 创建系统开始..."
  createSystem $systemName
  echoLnWithGreen "[Step 1,TOTAL $allStep] 创建系统结束..."
  echoLnWithGreen "[Step 2,TOTAL $allStep] 传输文件开始..."
  sendFiles $systemName
  echoLnWithGreen "[Step 2,TOTAL $allStep] 传输文件结束..."

  # 定义一个任务数组
  tasks=(
    "docker"
    "init"
    "harbor"
  )

  echoLnWithGreen "[Step 3,TOTAL $allStep] 远程执行任务开始..."
  # 远程执行任务
  ssh root@${systemName}@orb "chmod +x /home/run.sh & sh /home/run.sh ${tasks[@]}"
  echoLnWithGreen "[Step 3,TOTAL $allStep] 远程执行任务结束..."

  echoLnWithGreen "[Step 4,TOTAL $allStep] 拉取服务端日志开始..."
  rm -rf remoteLogs/$systemName
  mkdir -p remoteLogs/$systemName
  scp -r root@${systemName}@orb:/home/logs/*.log remoteLogs/$systemName/
  echoLnWithGreen "[Step 4,TOTAL $allStep] 拉取服务端日志结束..."
}

# 将外面的参数传递给main函数
main $@

# 如何直到前面的任务是否完成呢?
# 1.可以通过日志来判断
# 2.可以通过返回值来判断
# 3.可以通过文件来判断