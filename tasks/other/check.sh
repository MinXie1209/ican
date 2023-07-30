#!/usr/bin/env bash

# 这里放常量
# 需要检查的端口 以 \| 分隔
needCheckTcpPort="18801\|18802\|18899\|18803\|18804\|18805\|18806\|18807\|18808\|18809\|18810\|18811\|18812\|18813\|18814\|18815\|18851\|18852\|18853\|18854\|28801\|28899\|28802\|28803\|1883\|38000\|28811\|28805\|28806\|28807\|10080\|10043\|58883\|58967\|57999\|58002\|58863\|58003\|1884\|58601\|58602\|58004\|58863\|51111\|51112\|28808\|28809\|38801\|38802\|38803\|38804\|38805\|38806\|38807\|38808\|6520\|3478\|9000\|9001"

# 需要前置的函数

function getOpsy() {
  [ -f /etc/redhat-release ] && awk '{print ($1,$3~/^[0-9]/?$3:$4)}' /etc/redhat-release && return
  [ -f /etc/os-release ] && awk -F'[= "]' '/PRETTY_NAME/{print $3,$4,$5}' /etc/os-release && return
  [ -f /etc/lsb-release ] && awk -F'[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release && return
}

function calcDisk() {
  local totalSize=0
  local array=$@
  for size in ${array[@]}; do
    [ "${size}" == "0" ] && size_t=0 || size_t=$(echo ${size:0:${#size}-1})
    [ "$(echo ${size:(-1)})" == "K" ] && size=0
    [ "$(echo ${size:(-1)})" == "M" ] && size=$(awk 'BEGIN{printf "%.1f", '$size_t' / 1024}')
    [ "$(echo ${size:(-1)})" == "T" ] && size=$(awk 'BEGIN{printf "%.1f", '$size_t' * 1024}')
    [ "$(echo ${size:(-1)})" == "G" ] && size=${size_t}
    totalSize=$(awk 'BEGIN{printf "%.1f", '$totalSize' + '$size'}')
  done
  echo ${totalSize}
}

# 这里放命令

cname=$(awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//')
cores=$(awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo)
freq=$(awk -F: '/cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//')
tram=$(free -m | awk '/Mem/ {print $2}')
uram=$(free -m | awk '/Mem/ {print $3}')
uramAvailable=$(free -m | awk '/Mem/ {print $7}')
swap=$(free -m | awk '/Swap/ {print $2}')
uswap=$(free -m | awk '/Swap/ {print $3}')
uswapAvailable=$(free -m | awk '/Swap/ {print $7}')
up=$(awk '{a=$1/86400;b=($1%86400)/3600;c=($1%3600)/60} {printf("%d days, %d hour %d min",a,b,c)}' /proc/uptime)
load=$(w | head -1 | awk -F'load average:' '{print $2}' | sed 's/^[ \t]*//;s/[ \t]*$//')
opsy=$(getOpsy)
arch=$(uname -m)
lbit=$(getconf LONG_BIT)
kern=$(uname -r)
disk_size1=($(LANG=C df -ahPl | grep -wvE '\-|none|tmpfs|devtmpfs|by-uuid|chroot|Filesystem' | awk '{print $2}'))
disk_size2=($(LANG=C df -ahPl | grep -wvE '\-|none|tmpfs|devtmpfs|by-uuid|chroot|Filesystem' | awk '{print $3}'))
disk_size3=($(LANG=C df -ahPl | grep -wvE '\-|none|tmpfs|devtmpfs|by-uuid|chroot|Filesystem' | awk '{print $4}'))
disk_total_size=$(calcDisk ${disk_size1[@]})
disk_used_size=$(calcDisk ${disk_size2[@]})
disk_unused_size=$(calcDisk ${disk_size3[@]})
HOSTNAME=$(hostname -s)
Physical_CPUs=$(grep "physical id" /proc/cpuinfo | sort | uniq | wc -l)
Virt_CPUs=$(grep "processor" /proc/cpuinfo | wc -l)
TIME=$(date +"%F   %T  %A")
HOST=$(grep -Ev '^#|127.0.0.1|localhost' /etc/hosts)
report_JDK="$(java -version 2>&1 | grep version | awk '{print $1,$3}' | tr '[:lower:]' '[:upper:]' | tr -d '"')"

#这里放函数##############################################################################################################

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

# 判断是否存在wget命令,没有则退出
function judgeWget() {
  if [ ! -e '/usr/bin/wget' ]; then
    echo "Error: wget command not found. You must be install wget command at first."
    #    exit 1
  fi
}

function ioTest() {
  (LANG=C dd if=/dev/zero of=test_$$ bs=64k count=16k conv=fdatasync && rm -f test_$$) 2>&1 | awk -F, '{io=$NF} END { print io}' | sed 's/^[ \t]*//;s/[ \t]*$//'
}

# 空设置默认值
function checkNullToDefault() {
  if [[ -z $1 ]]; then
    echo $2
  else
    echo "$1"
  fi
}

# 输出检查时间
function checkTime() {
  printLine
  echoLnWithGreen "检查时间        : $TIME"
}

# 输出主机信息
function checkHost() {
  echoLnWithGreen "主机信息"
  echoLnWithGreen "主机名          : $HOSTNAME"
  echoLnWithGreen "HOSTS文件"
  echo "$HOST"
}

# 输出语言环境 JDK
function checkJDKStatus() {
  printLine
  echoLnWithBlue "语言环境"
  echoBlankLine
  java -version 2>/dev/null
  if [ $? -eq 0 ]; then
    java -version 2>/dev/null
  fi
  echo "JAVA版本          : $report_JDK"
  echo "JAVA_HOME         : \"$JAVA_HOME\""
}

## 输出磁盘信息
#function checkDisk() {
#  printLine
#  echoLnWithBlue "磁盘信息"
#  diskStatus=$(join /tmp/disk /tmp/inode | awk '{print $1,$2,"|",$3,$4,$5,$6,"|",$8,$9,$10,$11,"|",$12}' | column -t | awk 'NR<=5||NR>=12{print}')
#  echo -e "$diskStatus"
#}

# 输出安全状态
function checkSafe() {
  printLine
  echoLnWithBlue "安全状态"
  fwStatus=$(systemctl status firewalld | grep Active | awk -F '(' '{print $2}' | awk -F ')' '{print $1}' | tr '[:lower:]' '[:upper:]')
  slStatus=$(grep -Ev '^#|SELINUXTYPE|^$' /etc/selinux/config | awk -F '=' '{print $2}' | tr '[:lower:]' '[:upper:]')
  echo "防火墙            :$fwStatus"
  echo "SELINUX           :$slStatus"
}

# 输出定时任务
function checkCron() {
  printLine
  echoLnWithBlue "定时任务"
  crontab=0
  for shell in $(grep -v "/sbin/nologin" /etc/shells); do
    for user in $(grep "$shell" /etc/passwd | awk -F: '{print $1}'); do
      crontab -l -u $user >/dev/null 2>&1
      status=$?
      if [ $status -eq 0 ]; then
        echo "$user"
        echo "--------"
        crontab -l -u $user
        let crontab=crontab+$(crontab -l -u $user | wc -l)
        echoBlankLine
      fi
    done
  done
  #计划任务
  find /etc/cron* -type f | xargs -i ls -l {} | column -t
  let crontab=crontab+$(find /etc/cron* -type f | wc -l)
  #报表信息
  reportCrontab="$crontab"
}

# 输出服务列表
function checkServices() {
  echoLnWithBlue "服务列表"
  running_server=$(systemctl list-units --type=service --state=running --no-pager | grep .service | awk -F'loaded active running' '{print $1,$2}' | nl)
  enabled_server=$(systemctl list-unit-files --type=service --state=enabled --no-pager | awk '{print $1}' | awk 'NR>2{print p}{p=$0}' | nl)
  echoLnWithBlue "正在运行"
  echo "$running_server"
  echoLnWithBlue "开机自启"
  echo "$enabled_server"

}

# 输出用户检查
function checkUserLogin() {
  # 计算一个时间戳离现在有多久了
  datetime="$*"
  [ -z "$datetime" ] && echo $(stat /etc/passwd | awk "NR==6")
  timestamp=$(date +%s -d "$datetime")
  nowTimestamp=$(date +%s)
  diffTimestamp=$(($nowTimestamp - $timestamp))
  days=0
  hours=0
  minutes=0
  sec_in_day=$((60 * 60 * 24))
  sec_in_hour=$((60 * 60))
  sec_in_minute=60
  while (($(($diffTimestamp - $sec_in_day)) > 1)); do
    let diffTimestamp=diffTimestamp-sec_in_day
    let days++
  done
  while (($(($diffTimestamp - $sec_in_hour)) > 1)); do
    let diffTimestamp=diffTimestamp-sec_in_hour
    let hours++
  done
  echo "$days 天 $hours 小时前"
}

function getUserLastLogin() {
  # 获取用户最近一次登录的时间，含年份
  # 很遗憾last命令不支持显示年份，只有"last -t YYYYMMDDHHMMSS"表示某个时间之间的登录，我
  # 们只能用最笨的方法了，对比今天之前和今年元旦之前（或者去年之前和前年之前……）某个用户
  # 登录次数，如果登录统计次数有变化，则说明最近一次登录是今年。
  username=$1
  : ${username:="$(whoami)"}
  thisYear=$(date +%Y)
  oldesYear=$(last | tail -n1 | awk '{print $NF}')
  while (($thisYear >= $oldesYear)); do
    loginBeforeToday=$(last $username | grep $username | wc -l)
    loginBeforeNewYearsDayOfThisYear=$(last $username -t $thisYear"0101000000" | grep $username | wc -l)
    if [ $loginBeforeToday -eq 0 ]; then
      echo "从未登录过"
      break
    elif [ $loginBeforeToday -gt $loginBeforeNewYearsDayOfThisYear ]; then
      lastDateTime=$(last -i $username | head -n1 | awk '{for(i=4;i<(NF-2);i++)printf"%s ",$i}')" $thisYear"
      lastDateTime=$(date "+%Y-%m-%d %H:%M:%S" -d "$lastDateTime")
      echo "$lastDateTime"
      break
    else
      thisYear=$((thisYear - 1))
    fi
  done
}

# 输出用户状态
function checkUserStatus() {
  echoBlankLine
  pwdfile="$(cat /etc/passwd)"
  Modify=$(stat /etc/passwd | grep Modify | tr '.' ' ' | awk '{print $2,$3}')
  echoLnWithBlue "特权用户"
  rootUser=""
  for user in $(echo "$pwdfile" | awk -F: '{print $1}'); do
    if [ $(id -u $user) -eq 0 ]; then
      echo "$user"
      rootUser="$rootUser,$user"
    fi
  done
  echoBlankLine
  echoLnWithBlue "可登录用户"
  userList=0
  echo "$(
    echo "USER UID GID HOME SHELL last_login"
    for shell in $(grep -v "/sbin/nologin" /etc/shells); do
      for username in $(grep "$shell" /etc/passwd | awk -F: '{print $1}'); do
        userLastLogin="$(getUserLastLogin $username)"
        echo "$pwdfile" | grep -w "$username" | grep -w "$shell" | awk -F: -v lastlogin="$(echo "$userLastLogin" | tr ' ' '_')" '{print $1,$3,$4,$6,$7,lastlogin}'
      done
      let userList=userList+$(echo "$pwdfile" | grep "$shell" | wc -l)
    done
  )" | column -t
  echoBlankLine
  echoLnWithBlue "空密码用户"
  echoBlankLine
  userEmptyPassword=""
  for shell in $(grep -v "/sbin/nologin" /etc/shells); do
    for user in $(echo "$pwdfile" | grep "$shell" | cut -d: -f1); do
      r=$(awk -F: '$2=="!!"{print $1}' /etc/shadow | grep -w $user)
      if [ ! -z $r ]; then
        echo $r
        userEmptyPassword="$userEmptyPassword,"$r
      fi
    done
  done
  echoBlankLine
  echoLnWithBlue "相同ID用户"
  echoBlankLine
  userTheSameUID=""
  UIDs=$(cut -d: -f3 /etc/passwd | sort | uniq -c | awk '$1>1{print $2}')
  for uid in $UIDs; do
    echo -n "$uid"
    userTheSameUID="$uid"
    r=$(awk -F: 'ORS="";$3=='"$uid"'{print ":",$1}' /etc/passwd)
    echo "$r"
    echoBlankLine
    userTheSameUID="$userTheSameUID $r,"
  done
  #报表信息
  report_USERs="$USERs"
  report_USEREmptyPassword=$(echo $userEmptyPassword | sed 's/^,//')
  report_USERTheSameUID=$(echo $userTheSameUID | sed 's/,$//')
  report_RootUser=$(echo $RootUser | sed 's/^,//')
}

# 输出密码检查
function checkPasswordStatus {
  printLine
  echoLnWithBlue "密码检查"
  echo "最后一次改密码: $Modify ($(checkUserLogin $Modify))"
  echoBlankLine
  pwdfile="$(cat /etc/passwd)"
  echoLnWithBlue "过期时间"
  result=""
  for shell in $(grep -v "/sbin/nologin" /etc/shells); do
    for user in $(echo "$pwdfile" | grep "$shell" | cut -d: -f1); do
      get_expiry_date=$(/usr/bin/chage -l $user | grep 'Password expires' | cut -d: -f2)
      if [[ $get_expiry_date = ' never' || $get_expiry_date = 'never' ]]; then
        printf "%-15s 永不过期\n" $user
        result="$result,$user:never"
      else
        password_expiry_date=$(date -d "$get_expiry_date" "+%s")
        current_date=$(date "+%s")
        diff=$(($password_expiry_date - $current_date))
        let DAYS=$(($diff / (60 * 60 * 24)))
        printf "%-15s %s天后过期" $user $DAYS
        result="$result,$user:$DAYS days"
      fi
    done
  done
  report_PasswordExpiry=$(echo $result | sed 's/^,//')
  echoBlankLine
  echoLnWithBlue "密码策略"
  echoBlankLine
  grep -v "#" /etc/login.defs | grep -E "PASS_MAX_DAYS|PASS_MIN_DAYS|PASS_MIN_LEN|PASS_WARN_AGE"
}

# 输出软件安装
function checkSoftOfInstalled() {

  printLine
  echoLnWithBlue "软件安装记录"
  soft_number=$(rpm -qa --last | wc -l)
  echoBlankLine
  echoLnWithBlue "最新安装$soft_number 个"
  echoLnWithBlue "最新10条:"
  rpm -qa --last | head -10 | column -t

  printLine
  echoBlankLine
  time_now=$(date +"%F   %T  %A" | column -t)
  echoLnWithBlue "当前时间: $time_now"

  printLine
  echoLnWithBlue "自启动"
  auto_action=$(grep -Ev "^#|^$" /etc/rc.d/rc.local)
  auto_number=$(grep -Ev "^#|^$" /etc/rc.d/rc.local | wc -l)
  echoBlankLine
  echoLnWithBlue "明细$auto_number 个"
  echo "$auto_action"

  printLine
  echoLnWithBlue "进程检查"
  defunct_number=$(ps -ef | grep defunct | grep -v grep | wc -l)
  echoLnWithBlue "僵尸数量 $defunct_number"
  ps -ef | head -n1
  ps -ef | grep defunct | grep -v grep
  echoBlankLine
}

# 输出CPU内存TOP10
function topCpuAndMem() {
  printLine
  CPU_TOP10=$(top b -n1 | head -17 | tail -11 | awk '{print $1, $2,  $9, $12}' | column -t)
  MEM_TOP10=$(ps aux | awk '{print $1, $2, $4, $6, $11}' | sort -k3rn | head -10 | column -t)
  echoLnWithBlue "内存 TOP10"
  echo "USER PID %MEM RSS COMMAND$MEM_TOP10" | column -t
  echoBlankLine

  echoLnWithBlue "CPU TOP10"
  echo "$CPU_TOP10"
  printLine

}

# 输出网络检查
function checkNetwork() {

  echoLnWithBlue "网络信息"
  echoLnWithBlue "地址"
  IP=$(ip a | grep -E 'eth0|ens33' | grep '/2\|/8\|/16\|/24' | awk '{print $2}' | awk -F'/' '{print $1}' | tr '' ',' | sed 's/,$//')
  GATEWAY=$(ip route | grep default | awk '{print $3}')
  MAC=$(ip link | grep -v "LOOPBACK\|loopback" | awk '{print $2}' | sed 'N;s///' | tr '' ',' | sed 's/,$//')
  DNS=$(grep nameserver /etc/resolv.conf | grep -v "#" | awk '{print $2}' | tr '' ',' | sed 's/,$//')
  echoBlankLine
  echo "IP地址               :  $IP "
  echo "MAC地址              ： $MAC"
  echo "DNS地址              ： $DNS"
  echo "网关地址             ： $GATEWAY"
}

# 输出端口检查
function checkPortDetails() {
  echoBlankLine
  echoLnWithBlue "连接"
  netstat -n | grep -v '127.0.0.1' | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'

  echoBlankLine
  echoLnWithBlue "监听"
  netstat -tnpl | awk 'NR>2 {printf "%-20s %-15s ",$4,$7}'
  printLine
  echoLnWithGreen "端口信息"
  echoBlankLine
  echoLnWithGreen "TCP"
  netstat -ntpl
  echoBlankLine
  echoLnWithGreen "UDP"
  netstat -nupl
  echoBlankLine
  printLine
}

# 输出 TCP 端口冲突
function checkTcpConflict() {
  echoLnWithRed "可能冲突的TCP端口"
  netstat -ntpl | grep --color=auto "$needCheckTcpPort"
}

# 输出 UDP 端口冲突
function checkUdpConflict() {
  echoBlankLine
  echoLnWithRed "可能冲突的UDP端口"
  netstat -nupl | grep --color=always "$needCheckTcpPort"
}

# 输出系统信息
function totalDetails() {
  printLine
  echoLnWithBlue "硬件配置"
  echo -e "CPU 型号                     : $cname"
  echo -e "CPU 主频                     : $freq MHz"
  echo -e "CPU 架构                     : $arch ($lbit Bit)"
  echo -e "CPU 物理数                   : $Physical_CPUs"
  echo -e "CPU 逻辑数                   : $Virt_CPUs"
  echo -e "CPU 核心数                   : $cores"
  echoBlankLine
  echo -e "系统空闲时间                 : $up"
  echo -e "系统平均负载                 : $load"
  echo -e "系统版本                     : $opsy"
  echo -e "内核版本                     : $kern"
  echoBlankLine
  echo -e "磁盘空间(总/已用/可用)       : $disk_total_size GB ($(echoLnWithRed "$disk_used_size GB") Used,$(echoLnWithGreen "$disk_unused_size GB") Available)"
  echo -e "物理内存(总/已用/可用)       : $tram MB ($(echoLnWithRed "$uram MB") Used,$(echoLnWithGreen "$uramAvailable MB") Available)"
  echo -e "虚拟内存(总/已用/可用)       : $swap MB ($(echoLnWithRed "$uswap MB") Used,$(echoLnWithGreen "$(checkNullToDefault "$uswapAvailable" 0) MB") Available)"

  printLine
  echoLnWithBlue "IO性能"
  io1=$(ioTest)
  echo "I/O speed(1st run)   : $io1"
  io2=$(ioTest)
  echo "I/O speed(2nd run)   : $io2"
  io3=$(ioTest)
  echo "I/O speed(3rd run)   : $io3"
  ioraw1=$(echo $io1 | awk 'NR==1 {print $1}')
  [ "$(echo $io1 | awk 'NR==1 {print $2}')" == "GB/s" ] && ioraw1=$(awk 'BEGIN{print '$ioraw1' * 1024}')
  ioraw2=$(echo $io2 | awk 'NR==1 {print $1}')
  [ "$(echo $io2 | awk 'NR==1 {print $2}')" == "GB/s" ] && ioraw2=$(awk 'BEGIN{print '$ioraw2' * 1024}')
  ioraw3=$(echo $io3 | awk 'NR==1 {print $1}')
  [ "$(echo $io3 | awk 'NR==1 {print $2}')" == "GB/s" ] && ioraw3=$(awk 'BEGIN{print '$ioraw3' * 1024}')
  ioall=$(awk 'BEGIN{print '$ioraw1' + '$ioraw2' + '$ioraw3'}')
  ioavg=$(awk 'BEGIN{printf "%.1f", '$ioall' / 3}')
  echo "平均I/O性能          : $ioavg MB/s"
  printLine
}

# judge
function judge() {
  if [[ $1 ]]; then
    echo -e "$2"
  else
    echo -e "$3"
  fi
}

# finish
function finish() {
  # 最后需要判断的内容
  # 操作系统是否是Centos7.9的版本
  systemFlag=$(cat /etc/redhat-release | grep -oE '7.9')

  # 磁盘可用空间是否大于等于4T
  diskFreeSpace=$(echo "$disk_unused_size  / 1024" | bc)
  # 内存可用空间是否大于等于32G
  memoryFreeSpace=$(echo "$uramAvailable / 1024" | bc)

  # CPU 核心数是否大于等于16
  cpuCore=$(echo "$Virt_CPUs" | bc)

  # CPU 频率是否大于等于2.3
  cpuFrequency=$(echo "scale=0; $freq / 1.0" | bc)

  checkResult=1
  echoLnWithGreen "检测完成"

  if [[ -n $systemFlag ]]; then
    echo -e "- 操作系统是否满足(Centos7.9) ? $(echoLnWithGreen "✔ ")"
  else
    checkResult=0
    echo -e "- 操作系统是否满足(Centos7.9) ? $(echoLnWithRed "✘")"
  fi

  if ((diskFreeSpace >= 4)); then
    echo -e "- 可用存储空间是否满足(4T) ? $(echoLnWithGreen "✔ ")"
  else
    checkResult=0
    echo -e "- 可用存储空间是否满足(4T) ? $(echoLnWithRed "✘")"
  fi

  if ((memoryFreeSpace >= 32)); then
    echo -e "- 可用内存空间是否满足(32G) ? $(echoLnWithGreen "✔ ")"
  else
    checkResult=0
    echo -e "- 可用内存空间是否满足(32G) ? $(echoLnWithRed "✘")"
  fi

  if ((cpuCore >= 16)); then
    echo -e "- CPU核心数是否满足(16核) ? $(echoLnWithGreen "✔ ")"
  else
    checkResult=0
    echo -e "- CPU核心数是否满足(16核) ? $(echoLnWithRed "✘")"
  fi

  if ((cpuFrequency >= 2300)); then
    echo -e "- CPU频率是否满足(2.3GHz) ? $(echoLnWithGreen "✔ ")"
  else
    checkResult=0
    echo -e "- CPU频率是否满足(2.3GHz) ? $(echoLnWithRed "✘")"
  fi

   # 判断是否存在的命令
  if [[ -z $(command -v netstat) ]]; then
    echoLnWithRed "注意: netstat命令不存在，无法检测端口是否满足，请先安装netstat命令\nyum install net-tools"
  else
    tcp=$(netstat -ntpl | grep --color=auto "$needCheckTcpPort")
    udp=$(netstat -nupl | grep --color=auto "$needCheckTcpPort")
    if [[ -z $tcp && -z $udp ]]; then
      echo -e "- 端口是否满足 ? $(echoLnWithGreen "✔ ")"
    else
      checkResult=0
      echo -e "- 端口是否满足 ? $(echoLnWithRed "✘")"
    fi
  fi

  if [[ $checkResult -eq 0 ]]; then
    echoLnWithRed "检测结果: 环境不满足部署"
  else
    echoLnWithGreen "检测结果: 环境满足部署"
  fi
}


#这里组织逻辑#############################################################################################################

# 入口函数
main() {
  checkTime
  checkHost
  checkJDKStatus
  checkSafe
  checkCron
  checkServices
  checkUserStatus
  checkPasswordStatus
  checkSoftOfInstalled
  topCpuAndMem
  # 判断是否存在的命令
  if [[ -z $(command -v ip) ]]; then
    echoLnWithRed "注意: ip命令不存在，无法检测ip信息，请先安装ip命令:\nyum install -y iproute"
  else
    checkNetwork
  fi
  # 判断是否存在的命令
  if [[ -z $(command -v netstat) ]]; then
    echoLnWithRed "注意: netstat命令不存在，无法检测网络信息，请先安装netstat命令:\nyum install net-tools"
  else
    checkPortDetails
    checkTcpConflict
    checkUdpConflict
  fi

  totalDetails
  finish
  printLine
}

main
