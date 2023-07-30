#!/usr/bin/env bash
jarName="demo.jar"

# 先kill掉之前的进程
runPid=$(ps aux | grep $jarName | awk '{print $2}' | sed -n "1p")
echo "kill pid: $runPid"
kill "$runPid"
# 循环等待，直到进程结束
while true ; do
    res=$(netstat -anp | grep "$runPid/java")
    if [[ -n $res ]]; then
      echo "休息1s"
        sleep 1s
    else
        echo "旧进程已结束"
        break
    fi
done

cat /tmp/app.log > /tmp/app.log.back
echo "" > /tmp/app.log
# 启动新的进程 内存限制为1G
java -jar /tmp/$jarName -Xms1G -Xmx1G > /tmp/app.log &
echo "新进程启动成功"
