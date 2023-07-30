#!/bin/bash

# 输入两个目录路径
dir1=$1
dir2=$2

# 传入字符串,返回绿色的字符串
function echoLnWithGreen() {
  echo -e "\033[32m$1\033[0m\n"
}

# 传入字符串,返回红色的字符串
function echoLnWithRed() {
  echo -e "\033[31m$1\033[0m\n"
}
checkWithLinux() {
  # 遍历第一个目录中的文件
  find "$dir1" -type f | while read -r file1; do
    # 提取文件名
    filename=${file1#$dir1}
    # 获取第二个目录中对应的文件路径
    file2="${dir2}$filename"
    echo "检查文件 $filename ..."
    # 检查第二个目录中是否存在对应的文件
    if [ -e "$file2" ]; then
      # 获取文件大小
      #    size1=$(stat -f "%z" "$file1")
      #    size2=$(stat -f "%z" "$file2")
      size1=$(stat -c "%s" "$file1")
      size2=$(stat -c "%s" "$file2")
      # 比较文件大小
      if [ "$size1" -ne "$size2" ]; then
        echoLnWithRed "文件 $filename 大小不同"
        echo "目录1: $size1 字节"
        echo "目录2: $size2 字节"
        echo
      else
        # 获取文件的md5值
        md51=$(md5sum "$file1" | awk '{print $1}')
        md52=$(md5sum "$file2" | awk '{print $1}')
        #      md51=$(md5  -q "$file1")
        #      md52=$(md5  -q "$file2")
        # 比较md5值
        if [ "$md51" != "$md52" ]; then
          echoLnWithRed "文件 $filename 内容不同"
          echo "目录1: $md51"
          echo "目录2: $md52"
          echo
        else
          echoLnWithGreen "文件 $filename 一致"
        fi
      fi
    else
      echoLnWithRed "文件 $dir2$filename 不存在"
      echo
    fi
  done
}

checkWithMac() {

  # 遍历第一个目录中的文件
  find "$dir1" -type f | while read -r file1; do
    # 提取文件名
    filename=${file1#$dir1}
    # 获取第二个目录中对应的文件路径
    file2="${dir2}$filename"
    echo "检查文件 $filename ..."
    # 检查第二个目录中是否存在对应的文件
    if [ -e "$file2" ]; then
      # 获取文件大小
      size1=$(stat -f "%z" "$file1")
      size2=$(stat -f "%z" "$file2")
      # 比较文件大小
      if [ "$size1" -ne "$size2" ]; then
        echoLnWithRed "文件 $filename 大小不同"
        echo "目录1: $size1 字节"
        echo "目录2: $size2 字节"
        echo
      else
        # 获取文件的md5值
        md51=$(md5 -q "$file1")
        md52=$(md5 -q "$file2")
        # 比较md5值
        if [ "$md51" != "$md52" ]; then
          echoLnWithRed "文件 $filename 内容不同"
          echo "目录1: $md51"
          echo "目录2: $md52"
          echo
        else
          echoLnWithGreen "文件 $filename 一致"
        fi
      fi
    else
      echoLnWithRed "文件 $dir2$filename 不存在"
      echo
    fi
  done
}

if [[ $1 == "--help" ]]; then
    echoLnWithRed "用法: $0 <目录1> <目录2> <mac|linux>"
    exit 1
fi


if [[ $3 == mac ]]; then
  checkWithMac
else
  checkWithLinux
fi
echoLnWithGreen "结束检查"
