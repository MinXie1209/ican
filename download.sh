#!/usr/bin/env bash
set -ex

# 函数：下载文件
download_file() {
  local url="$1"
  local path="$2"
  if command -v curl >/dev/null; then
    curl -o "$path" -X GET "$url" -L
  elif command -v wget >/dev/null; then
    wget -O "$path" "$url"
  else
    echo "无法找到可用的下载工具（curl 或 wget）。请安装其中一个工具后重试。"
    exit 1
  fi
}

download() {

  # 定义多个下载链接和路径的文本文件
  input_file="./tasks/$1/download.mx"

  # 检查输入文件是否存在
  if [ ! -f "$input_file" ]; then
    echo "输入文件 $input_file 不存在。请确保文件存在并包含有效的下载链接和路径。"
    exit 1
  fi

  # 逐行读取输入文件并执行下载
  while IFS= read -r line || [ -n "$line" ]; do
    # 忽略以 "#" 开头的注释行
    if [[ "$line" =~ ^#.* ]]; then
      continue
    fi

    # 解析每一行的路径和 URL
    path=$(echo "$line" | awk -F ' ' '{print $1}' | xargs)
    url=$(echo "$line" | awk -F ' ' '{print $2}' | xargs)

    # 下载文件
    download_file "$url" "$path"
  done <"$input_file"

}

# 下载大文件
module=$@
if [[ -z $@ ]]; then
  read -p $'请选择需要下载的模块名(多选 docker,harbor)' module
  # 转为数组
  module=(${module//,/ })
  echo ${module[@]}
fi

#遍历模块
for i in ${module[@]}; do
  echo "开始下载$i"
  # 下载
  download $i
  echo "下载${i}完成"
done
