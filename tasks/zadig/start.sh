#!/usr/bin/env bash
IP=$(ip a | grep -E 'eth0|ens33' | grep '/2\|/8\|/16\|/24' | awk '{print $2}' | awk -F'/' '{print $1}' | tr '' ',' | sed 's/,$//')

export IP=$IP    # 主机 IP，用于访问 Zadig 系统
export PORT=3000 # 随机填写 30000 - 32767 区间的任一端口，如果安装过程中，发现端口占用，换一个端口再尝试
chmod +x /home/zadig/all_in_one_install_quickstart.sh
sh /home/zadig/all_in_one_install_quickstart.sh