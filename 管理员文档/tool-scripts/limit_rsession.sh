#!/bin/bash

# 512GB 字节数
MEM_LIMIT=$((512 * 1024 * 1024 * 1024))

while true; do
    for pid in $(pgrep rsession); do
        
        # --- 检查 1: 内存限制 ---
        # 读取该进程的 limits 文件，如果发现 Max address space 还是 unlimited，就限制它
        if grep -q "Max address space.*unlimited" /proc/$pid/limits 2>/dev/null; then
            echo "补打内存限制(512GB) -> 进程 $pid"
            sudo prlimit --pid $pid --as=$MEM_LIMIT
        fi

        # --- 检查 2: CPU 限制 ---
        # 检查是否已运行 cpulimit
        if ! pgrep -f "cpulimit.*-p $pid" > /dev/null; then
            echo "启动 CPU 限制(3200%) -> 进程 $pid"
            sudo cpulimit -p $pid -l 3200 -b -z
        fi
        
    done
    sleep 10
done