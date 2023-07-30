#!/usr/bin/env bash
set -ex
IP=$(ip a | grep -E 'eth0|ens33' | grep '/2\|/8\|/16\|/24' | awk '{print $2}' | awk -F'/' '{print $1}' | tr '' ',' | sed 's/,$//')
# 随机生成8位密码
PASSWD=$(openssl rand -base64 8)
# 解压harbor文件 到 /home/harbor/harbor
tar -zxvf /home/harbor/harbor-offline-installer-v2.8.3.tgz -C /home/harbor
cp /home/harbor/harbor.yml /home/harbor/harbor/harbor.yml
sed -i "s/127.0.0.1/$IP/g" /home/harbor/harbor/harbor.yml
sed -i "s/Harbor12345/$PASSWD/g" /home/harbor/harbor/harbor.yml
cat /home/harbor/harbor/harbor.yml
chmod +x /home/harbor/harbor/*.sh
sh /home/harbor/harbor/install.sh

echo "Harbor安装完成"
echo "Harbor地址：http://$IP"
echo "Harbor账号：admin"
echo "Harbor密码：$PASSWD"

# 配置docker deamon.json
echo '{"insecure-registries":["'$IP'"]}' > /etc/docker/daemon.json
systemctl reload docker

