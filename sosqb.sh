#!/bin/bash

# 目标IP和端口
HOST="127.0.0.1"
PORT="18230"

# 超时时间（秒）
TIMEOUT=86400

# 定义计数器文件路径
COUNT_FILE="/tmp/connection_fail_count.txt"

# 如果计数器文件不存在，则创建并初始化为0
if [ ! -f "$COUNT_FILE" ]; then
    echo 0 > "$COUNT_FILE"
fi

# 读取当前的失败计数
fail_count=$(cat "$COUNT_FILE")

# 使用telnet尝试连接，并设置超时时间
if timeout $TIMEOUT telnet $HOST $PORT 2>&1 | grep -q "Connected to $HOST"; then
    echo "连接成功，无需重启服务。"
    # 重置失败计数为0
    echo 0 > "$COUNT_FILE"
else
    echo "连接失败。"
    # 增加失败计数
    fail_count=$((fail_count + 1))
    echo "$fail_count" > "$COUNT_FILE"

    # 如果连续2次失败，重启服务
    if [ "$fail_count" -ge 5 ]; then
        echo "连续5次连接失败，重启qbittorrent-nox服务..."
        sudo systemctl restart qbittorrent-nox@felens
        # 重置失败计数为0
        echo 0 > "$COUNT_FILE"
    fi
fi
