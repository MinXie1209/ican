#!/usr/bin/env bash

PASSWD=$(openssl rand -base64 16)
echo "root:$PASSWD" | chpasswd
yum install net-tools -y
yum install bc -y
yum install openssh-server -y
yum install iproute -y
yum install ncurses -y

systemctl stop sshd
rm -rf /etc/ssh/sshd_config
cp -f /home/init/ssh_conf /etc/ssh/sshd_config
#cat /etc/ssh/sshd_config
systemctl start sshd
systemctl status sshd

IP=$(ip a | grep -E 'eth0|ens33' | grep '/2\|/8\|/16\|/24' | awk '{print $2}' | awk -F'/' '{print $1}' | tr '' ',' | sed 's/,$//')
echo "ip: $IP"
echo "password: $PASSWD"
