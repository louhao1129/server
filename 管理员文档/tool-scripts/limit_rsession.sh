#!/bin/bash

# 计算 512GB 对应的字节数，避免手动算错
MEM_LIMIT=$((512 * 1024 * 1024 * 1024))

while true; do
    for pid in $(pgrep rsession); do
        # 检查是否已经被 cpulimit 限制（以此判断是否为新发现的进程）
        if ! pgrep -f "cpulimit.*-p $pid" > /dev/null; then
            echo "为新进程 $pid 设置 CPU(3200%) 和 内存(512GB) 限制"
            
            # 1. 限制内存 (AS: Address Space/虚拟内存)
            # --as 表示限制虚拟内存上限，超过会导致内存分配失败
            sudo prlimit --pid $pid --as=$MEM_LIMIT
            
            # 2. 限制 CPU
            sudo cpulimit -p $pid -l 3200 -b -z
        fi
    done
    sleep 10
done