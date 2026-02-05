#!/bin/bash

# 512GB 字节数
MEM_LIMIT=$((512 * 1024 * 1024 * 1024))

# 定义要监控的关键词（使用竖线 | 分隔）
# rsession: RStudio
# ipykernel: Jupyter 的 Python 计算内核（最耗资源的）
# jupyter-lab / jupyter-notebook: Jupyter 的服务进程
TARGET_REGEX="rsession|ipykernel|jupyter-lab|jupyter-notebook"

while true; do
    # 使用 -f 参数匹配完整命令行，支持正则
    for pid in $(pgrep -f "$TARGET_REGEX"); do
        
        # 排除脚本自身和 cpulimit 进程，防止误伤
        if [[ "$pid" == "$$" ]] || [[ "$pid" == "$BASHPID" ]]; then continue; fi
        
        # --- 检查 1: 内存限制 ---
        # 检查 limits 文件，如果发现 Max address space 是 unlimited，则限制它
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
    sleep 5
done