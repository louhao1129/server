#!/bin/bash

# ================= 配置中心 =================
# 【只需要修改这里的一个数字即可】
# 设置每个用户的内存总阈值 (单位: GB)
LIMIT_GB=256
# ===========================================

# --- 自动计算区域 (无需修改) ---
# 1. prlimit 使用字节 (Bytes)
SINGLE_PROC_LIMIT=$((LIMIT_GB * 1024 * 1024 * 1024))
# 2. ps 统计使用 KB
USER_MEM_LIMIT_KB=$((LIMIT_GB * 1024 * 1024))
# 3. 目标进程关键词
TARGET_REGEX="rsession|ipykernel|jupyter-lab|jupyter-notebook"

echo "脚本启动: 限制阈值设为 ${LIMIT_GB}GB"

while true; do
    # =======================================================
    # 功能一：单进程限制 (防止单个进程直接撑爆内存)
    # =======================================================
    for pid in $(pgrep -f "$TARGET_REGEX"); do
        # 排除自身
        if [[ "$pid" == "$$" ]] || [[ "$pid" == "$BASHPID" ]]; then continue; fi
        
        # 检查并补充内存限制
        if grep -q "Max address space.*unlimited" /proc/$pid/limits 2>/dev/null; then
            # 这里不打印日志了，避免刷屏，默默执行即可
            sudo prlimit --pid $pid --as=$SINGLE_PROC_LIMIT
        fi

        # 检查并启动 CPU 限制
        if ! pgrep -f "cpulimit.*-p $pid" > /dev/null; then
            echo "发现新进程: $pid -> 启动 CPU限制"
            sudo cpulimit -p $pid -l 2400 -b -z
        fi
    done

    # =======================================================
    # 功能二：计算用户总内存，超标则杀掉最新进程
    # =======================================================
    
    # 找出相关用户
    active_users=$(ps -eo user,cmd | grep -E "$TARGET_REGEX" | grep -v "grep" | awk '{print $1}' | sort | uniq)

    for user in $active_users; do
        # 计算该用户所有相关进程的物理内存 (RSS) 总和 (KB)
        total_mem_kb=$(ps -u "$user" -o rss,cmd | grep -E "$TARGET_REGEX" | grep -v "grep" | awk '{sum+=$1} END {print sum+0}')

        # 判断是否超过 300GB (转换后的KB值)
        if [ "$total_mem_kb" -gt "$USER_MEM_LIMIT_KB" ]; then
            
            # 换算成 GB 用于显示日志
            total_mem_gb=$((total_mem_kb / 1024 / 1024))
            
            echo "警告: 用户 $user 总内存已达 ${total_mem_gb}GB (上限 ${LIMIT_GB}GB)"
            
            # 找出最新启动的一个进程
            newest_pid=$(pgrep -u "$user" -f "$TARGET_REGEX" -n)
            
            if [ -n "$newest_pid" ]; then
                echo "--> 内存超标，终止最新进程: $newest_pid"
                sudo kill -9 "$newest_pid"
                sleep 2
            fi
        fi
    done

    sleep 5
done