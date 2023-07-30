#!/usr/bin/env bash
set -ex
mkdir -p /home/logs
# 接收一个数组参数
arr=("$@")
echo "数组元素个数为: ${#arr[@]}"
for i in "${arr[@]}"; do
  echo "执行任务开始--$i"
  chmod +x /home/$i/start.sh
  sh /home/$i/start.sh >/home/logs/$i.log
  echo "执行任务结束--$i"
done
